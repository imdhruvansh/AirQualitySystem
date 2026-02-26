from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler
import joblib
from datetime import datetime, timedelta
import traceback

app = Flask(__name__)
CORS(app)

# Database configuration
DB_CONFIG = {
    'host': 'db',
    'database': 'airquality',
    'user': 'admin',
    'password': 'admin123'
}

# Model storage
MODEL_PATH = '/app/models/aqi_model.pkl'
SCALER_PATH = '/app/models/scaler.pkl'

def get_db_connection():
    """Create database connection"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

def calculate_aqi(pm25, pm10, no2, so2, co, o3):
    """Calculate AQI from pollutant concentrations"""
    # Simplified AQI calculation based on PM2.5 (primary pollutant in most cases)
    if pm25 <= 12.0:
        aqi = (50 / 12.0) * pm25
        category = 'Good'
    elif pm25 <= 35.4:
        aqi = ((100 - 51) / (35.4 - 12.1)) * (pm25 - 12.1) + 51
        category = 'Moderate'
    elif pm25 <= 55.4:
        aqi = ((150 - 101) / (55.4 - 35.5)) * (pm25 - 35.5) + 101
        category = 'Unhealthy for Sensitive Groups'
    elif pm25 <= 150.4:
        aqi = ((200 - 151) / (150.4 - 55.5)) * (pm25 - 55.5) + 151
        category = 'Unhealthy'
    elif pm25 <= 250.4:
        aqi = ((300 - 201) / (250.4 - 150.5)) * (pm25 - 150.5) + 201
        category = 'Very Unhealthy'
    else:
        aqi = ((500 - 301) / (500.4 - 250.5)) * (pm25 - 250.5) + 301
        category = 'Hazardous'
    
    return int(aqi), category

def train_model():
    """Train ML model using historical data"""
    try:
        conn = get_db_connection()
        if not conn:
            return False
        
        # Fetch training data
        query = """
            SELECT pm25, pm10, no2, so2, co, o3, temperature, humidity, wind_speed, aqi
            FROM air_quality_data
            ORDER BY timestamp
        """
        df = pd.read_sql(query, conn)
        conn.close()
        
        if len(df) < 5:
            print("Not enough data to train model")
            return False
        
        # Prepare features and target
        features = ['pm10', 'no2', 'so2', 'co', 'o3', 'temperature', 'humidity', 'wind_speed']
        X = df[features].values
        y_pm25 = df['pm25'].values
        y_aqi = df['aqi'].values
        
        # Scale features
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        # Train models
        pm25_model = GradientBoostingRegressor(n_estimators=100, random_state=42)
        pm25_model.fit(X_scaled, y_pm25)
        
        aqi_model = RandomForestRegressor(n_estimators=100, random_state=42)
        aqi_model.fit(X_scaled, y_aqi)
        
        # Save models
        os.makedirs('/app/models', exist_ok=True)
        joblib.dump({'pm25': pm25_model, 'aqi': aqi_model}, MODEL_PATH)
        joblib.dump(scaler, SCALER_PATH)
        
        print("Model trained and saved successfully!")
        return True
    except Exception as e:
        print(f"Error training model: {e}")
        traceback.print_exc()
        return False

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

@app.route('/api/data', methods=['GET'])
def get_air_quality_data():
    """Get historical air quality data"""
    try:
        location = request.args.get('location', None)
        limit = request.args.get('limit', 50, type=int)
        
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        if location:
            query = """
                SELECT * FROM air_quality_data 
                WHERE location = %s 
                ORDER BY timestamp DESC 
                LIMIT %s
            """
            cursor.execute(query, (location, limit))
        else:
            query = """
                SELECT * FROM air_quality_data 
                ORDER BY timestamp DESC 
                LIMIT %s
            """
            cursor.execute(query, (limit,))
        
        data = cursor.fetchall()
        cursor.close()
        conn.close()
        
        # Convert datetime objects to strings
        for row in data:
            if 'timestamp' in row and row['timestamp']:
                row['timestamp'] = row['timestamp'].isoformat()
        
        return jsonify({'data': data, 'count': len(data)})
    except Exception as e:
        print(f"Error fetching data: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/locations', methods=['GET'])
def get_locations():
    """Get list of available locations"""
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT DISTINCT location FROM air_quality_data ORDER BY location")
        locations = [row['location'] for row in cursor.fetchall()]
        
        cursor.close()
        conn.close()
        
        return jsonify({'locations': locations})
    except Exception as e:
        print(f"Error fetching locations: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/current/<location>', methods=['GET'])
def get_current_data(location):
    """Get current air quality for a location"""
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        query = """
            SELECT * FROM air_quality_data 
            WHERE location = %s 
            ORDER BY timestamp DESC 
            LIMIT 1
        """
        cursor.execute(query, (location,))
        data = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        if data:
            if 'timestamp' in data and data['timestamp']:
                data['timestamp'] = data['timestamp'].isoformat()
            return jsonify(data)
        else:
            return jsonify({'error': 'Location not found'}), 404
    except Exception as e:
        print(f"Error fetching current data: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/predict', methods=['POST'])
def predict():
    """Predict future air quality"""
    try:
        data = request.json
        location = data.get('location', 'Delhi')
        hours_ahead = data.get('hours_ahead', 24)
        
        # Check if model exists, if not train it
        if not os.path.exists(MODEL_PATH):
            print("Model not found. Training new model...")
            if not train_model():
                return jsonify({'error': 'Failed to train model'}), 500
        
        # Load model and scaler
        models = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        
        # Get latest data for the location
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        query = """
            SELECT pm10, no2, so2, co, o3, temperature, humidity, wind_speed
            FROM air_quality_data 
            WHERE location = %s 
            ORDER BY timestamp DESC 
            LIMIT 1
        """
        cursor.execute(query, (location,))
        current_data = cursor.fetchone()
        
        if not current_data:
            cursor.close()
            conn.close()
            return jsonify({'error': 'No data available for this location'}), 404
        
        # Prepare features for prediction
        features = np.array([[
            current_data['pm10'],
            current_data['no2'],
            current_data['so2'],
            current_data['co'],
            current_data['o3'],
            current_data['temperature'] or 25.0,
            current_data['humidity'] or 60.0,
            current_data['wind_speed'] or 5.0
        ]])
        
        # Scale features
        features_scaled = scaler.transform(features)
        
        # Make prediction
        predicted_pm25 = models['pm25'].predict(features_scaled)[0]
        predicted_aqi = models['aqi'].predict(features_scaled)[0]
        
        # Add some variation for future hours (simple simulation)
        variation = np.random.normal(1.0, 0.1)
        predicted_pm25 *= variation
        predicted_aqi = int(predicted_aqi * variation)
        
        # Calculate category
        _, category = calculate_aqi(predicted_pm25, current_data['pm10'], 
                                    current_data['no2'], current_data['so2'],
                                    current_data['co'], current_data['o3'])
        
        prediction_time = datetime.now() + timedelta(hours=hours_ahead)
        
        # Save prediction to database
        insert_query = """
            INSERT INTO predictions 
            (location, prediction_date, predicted_aqi, predicted_pm25, confidence_score, model_version)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        cursor.execute(insert_query, (
            location,
            prediction_time,
            predicted_aqi,
            float(predicted_pm25),
            0.85,
            'v1.0'
        ))
        conn.commit()
        
        cursor.close()
        conn.close()
        
        result = {
            'location': location,
            'prediction_time': prediction_time.isoformat(),
            'hours_ahead': hours_ahead,
            'predicted_pm25': round(float(predicted_pm25), 2),
            'predicted_aqi': int(predicted_aqi),
            'category': category,
            'confidence': 0.85
        }
        
        return jsonify(result)
    except Exception as e:
        print(f"Error making prediction: {e}")
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

@app.route('/api/train', methods=['POST'])
def train():
    """Manually trigger model training"""
    try:
        success = train_model()
        if success:
            return jsonify({'message': 'Model trained successfully', 'status': 'success'})
        else:
            return jsonify({'message': 'Model training failed', 'status': 'failed'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/add-data', methods=['POST'])
def add_data():
    """Add new air quality measurement"""
    try:
        data = request.json
        
        # Calculate AQI
        aqi, category = calculate_aqi(
            data['pm25'], data['pm10'], data['no2'],
            data['so2'], data['co'], data['o3']
        )
        
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = conn.cursor()
        query = """
            INSERT INTO air_quality_data 
            (location, pm25, pm10, no2, so2, co, o3, temperature, humidity, wind_speed, aqi, category)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (
            data['location'],
            data['pm25'],
            data['pm10'],
            data['no2'],
            data['so2'],
            data['co'],
            data['o3'],
            data.get('temperature'),
            data.get('humidity'),
            data.get('wind_speed'),
            aqi,
            category
        ))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'message': 'Data added successfully', 'aqi': aqi, 'category': category})
    except Exception as e:
        print(f"Error adding data: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stats/<location>', methods=['GET'])
def get_stats(location):
    """Get statistics for a location"""
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        query = """
            SELECT 
                AVG(aqi) as avg_aqi,
                MAX(aqi) as max_aqi,
                MIN(aqi) as min_aqi,
                AVG(pm25) as avg_pm25,
                COUNT(*) as total_readings
            FROM air_quality_data
            WHERE location = %s
        """
        cursor.execute(query, (location,))
        stats = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        return jsonify(stats)
    except Exception as e:
        print(f"Error fetching stats: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("Starting Air Quality Prediction API...")
    print("Waiting for database connection...")
    
    # Wait for database to be ready
    import time
    max_retries = 30
    for i in range(max_retries):
        conn = get_db_connection()
        if conn:
            conn.close()
            print("Database connected successfully!")
            break
        print(f"Waiting for database... ({i+1}/{max_retries})")
        time.sleep(2)
    
    # Train initial model
    print("Training initial model...")
    train_model()
    
    app.run(host='0.0.0.0', port=5000, debug=True)
