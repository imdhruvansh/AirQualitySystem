-- Air Quality Database Schema

-- Create air quality measurements table
CREATE TABLE IF NOT EXISTS air_quality_data (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(100) NOT NULL,
    pm25 FLOAT NOT NULL,
    pm10 FLOAT NOT NULL,
    no2 FLOAT NOT NULL,
    so2 FLOAT NOT NULL,
    co FLOAT NOT NULL,
    o3 FLOAT NOT NULL,
    temperature FLOAT,
    humidity FLOAT,
    wind_speed FLOAT,
    aqi INTEGER,
    category VARCHAR(50)
);

-- Create predictions table
CREATE TABLE IF NOT EXISTS predictions (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(100) NOT NULL,
    prediction_date TIMESTAMP NOT NULL,
    predicted_aqi INTEGER NOT NULL,
    predicted_pm25 FLOAT NOT NULL,
    confidence_score FLOAT,
    model_version VARCHAR(50)
);

-- Create indexes for better query performance
CREATE INDEX idx_timestamp ON air_quality_data(timestamp);
CREATE INDEX idx_location ON air_quality_data(location);
CREATE INDEX idx_prediction_date ON predictions(prediction_date);

-- Insert sample historical data
INSERT INTO air_quality_data (location, pm25, pm10, no2, so2, co, o3, temperature, humidity, wind_speed, aqi, category, timestamp) VALUES
('Delhi', 156.3, 210.5, 45.2, 12.3, 1.2, 65.4, 28.5, 62.0, 3.2, 201, 'Very Unhealthy', CURRENT_TIMESTAMP - INTERVAL '10 days'),
('Delhi', 142.1, 195.3, 42.1, 11.5, 1.1, 62.3, 29.1, 58.0, 3.5, 192, 'Unhealthy', CURRENT_TIMESTAMP - INTERVAL '9 days'),
('Delhi', 128.5, 178.2, 38.9, 10.2, 1.0, 58.7, 30.2, 55.0, 4.1, 178, 'Unhealthy', CURRENT_TIMESTAMP - INTERVAL '8 days'),
('Mumbai', 85.2, 112.3, 28.5, 8.1, 0.8, 45.2, 32.1, 75.0, 5.2, 165, 'Unhealthy', CURRENT_TIMESTAMP - INTERVAL '7 days'),
('Mumbai', 72.3, 98.5, 25.3, 7.2, 0.7, 42.1, 31.8, 76.0, 5.5, 152, 'Unhealthy', CURRENT_TIMESTAMP - INTERVAL '6 days'),
('Bangalore', 45.2, 68.3, 18.2, 5.1, 0.5, 35.2, 25.5, 65.0, 4.8, 98, 'Moderate', CURRENT_TIMESTAMP - INTERVAL '5 days'),
('Bangalore', 38.5, 58.2, 15.8, 4.5, 0.4, 32.1, 26.2, 63.0, 5.1, 85, 'Moderate', CURRENT_TIMESTAMP - INTERVAL '4 days'),
('Chennai', 52.3, 75.2, 20.5, 6.2, 0.6, 38.5, 33.5, 80.0, 6.2, 115, 'Unhealthy for Sensitive Groups', CURRENT_TIMESTAMP - INTERVAL '3 days'),
('Kolkata', 98.5, 135.2, 35.2, 9.5, 0.9, 52.3, 30.5, 70.0, 4.5, 172, 'Unhealthy', CURRENT_TIMESTAMP - INTERVAL '2 days'),
('Hyderabad', 62.3, 88.5, 22.8, 6.8, 0.7, 40.2, 28.8, 58.0, 5.8, 128, 'Unhealthy for Sensitive Groups', CURRENT_TIMESTAMP - INTERVAL '1 day');

-- Insert more recent data for better predictions
INSERT INTO air_quality_data (location, pm25, pm10, no2, so2, co, o3, temperature, humidity, wind_speed, aqi, category, timestamp) VALUES
('Delhi', 165.2, 220.3, 48.5, 13.2, 1.3, 68.2, 27.8, 64.0, 3.0, 212, 'Very Unhealthy', CURRENT_TIMESTAMP - INTERVAL '12 hours'),
('Mumbai', 78.5, 105.2, 26.8, 7.5, 0.75, 43.5, 32.5, 74.0, 5.3, 158, 'Unhealthy', CURRENT_TIMESTAMP - INTERVAL '6 hours'),
('Bangalore', 42.1, 62.5, 16.5, 4.8, 0.45, 33.5, 25.8, 64.0, 5.0, 92, 'Moderate', CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('Chennai', 55.8, 78.5, 21.2, 6.5, 0.65, 39.2, 33.8, 79.0, 6.0, 120, 'Unhealthy for Sensitive Groups', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
('Kolkata', 102.3, 142.5, 36.8, 10.2, 0.95, 54.2, 30.2, 71.0, 4.3, 178, 'Unhealthy', CURRENT_TIMESTAMP - INTERVAL '1 hour');

COMMIT;
