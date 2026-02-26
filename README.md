# Air Quality Prediction System

A complete full-stack application for real-time air quality monitoring and ML-powered predictions.

## 🏗️ Architecture

This project consists of **4 Docker containers**:

1. **PostgreSQL Database** - Stores air quality measurements and predictions
2. **Python/Flask ML Backend** - REST API with machine learning models
3. **React Frontend** - Modern, responsive UI with real-time data visualization
4. **Nginx Reverse Proxy** - Routes traffic and serves as API gateway

## 🚀 Features

- **Real-time Air Quality Monitoring** - Track PM2.5, PM10, NO2, SO2, CO, O3 levels
- **ML-Powered Predictions** - 24-hour air quality forecasts using Random Forest and Gradient Boosting
- **Multi-Location Support** - Monitor multiple cities simultaneously
- **Interactive Dashboard** - Beautiful charts and visualizations
- **AQI Calculations** - Automatic Air Quality Index computation
- **Historical Data Analysis** - View trends and statistics
- **RESTful API** - Full CRUD operations with comprehensive endpoints

## 📋 Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)
- 4GB RAM minimum
- 10GB free disk space

## 🛠️ Installation & Setup

### 1. Clone or Download the Project

```bash
cd air-quality-system
```

### 2. Start All Services

```bash
docker-compose up --build
```

This will:
- Build all 4 containers
- Initialize the PostgreSQL database with sample data
- Train the ML model on startup
- Start the backend API server
- Build and serve the React frontend
- Configure Nginx reverse proxy

### 3. Access the Application

- **Frontend UI**: http://localhost (port 80)
- **Backend API**: http://localhost/api
- **Direct Backend**: http://localhost:5000
- **Direct Frontend**: http://localhost:3000
- **Database**: localhost:5432

## 📊 API Endpoints

### Data Retrieval
- `GET /api/health` - Health check
- `GET /api/locations` - Get available locations
- `GET /api/data?location={city}&limit={n}` - Get historical data
- `GET /api/current/{location}` - Get current air quality
- `GET /api/stats/{location}` - Get statistics

### Predictions
- `POST /api/predict` - Generate ML prediction
  ```json
  {
    "location": "Delhi",
    "hours_ahead": 24
  }
  ```

### Data Management
- `POST /api/add-data` - Add new measurement
  ```json
  {
    "location": "Delhi",
    "pm25": 156.3,
    "pm10": 210.5,
    "no2": 45.2,
    "so2": 12.3,
    "co": 1.2,
    "o3": 65.4,
    "temperature": 28.5,
    "humidity": 62.0,
    "wind_speed": 3.2
  }
  ```

- `POST /api/train` - Manually trigger model training

## 🧪 Testing the System

### 1. Check Backend Health
```bash
curl http://localhost/api/health
```

### 2. Get Available Locations
```bash
curl http://localhost/api/locations
```

### 3. Get Current Data
```bash
curl http://localhost/api/current/Delhi
```

### 4. Generate Prediction
```bash
curl -X POST http://localhost/api/predict \
  -H "Content-Type: application/json" \
  -d '{"location": "Delhi", "hours_ahead": 24}'
```

## 🔧 Development

### Backend Development

```bash
cd backend
pip install -r requirements.txt
python app.py
```

### Frontend Development

```bash
cd frontend
npm install
npm start
```

### Database Access

```bash
docker exec -it airquality_db psql -U admin -d airquality
```

Useful SQL queries:
```sql
-- View all data
SELECT * FROM air_quality_data ORDER BY timestamp DESC LIMIT 10;

-- View predictions
SELECT * FROM predictions ORDER BY timestamp DESC LIMIT 10;

-- Check data count
SELECT location, COUNT(*) FROM air_quality_data GROUP BY location;
```

## 📦 Container Details

### Database Container (PostgreSQL)
- **Image**: postgres:15-alpine
- **Port**: 5432
- **Database**: airquality
- **User**: admin
- **Password**: admin123

### Backend Container (Python/Flask)
- **Base**: python:3.11-slim
- **Port**: 5000
- **ML Libraries**: scikit-learn, pandas, numpy
- **Framework**: Flask with CORS support

### Frontend Container (React)
- **Build**: Node 18 Alpine
- **Runtime**: Nginx Alpine
- **Port**: 3000 (dev), 80 (prod)
- **Libraries**: React, Recharts, Axios, Lucide React

### Nginx Container
- **Image**: nginx:alpine
- **Port**: 80
- **Purpose**: Reverse proxy and load balancer

## 🎨 Frontend Features

- **Cosmic Design Theme** - Unique visual identity with custom fonts and gradients
- **Responsive Layout** - Works on desktop, tablet, and mobile
- **Real-time Charts** - Interactive data visualizations with Recharts
- **AQI Color Coding** - Visual indicators based on air quality levels
- **Smooth Animations** - Polished user experience with CSS animations
- **Dark Theme** - Eye-friendly interface for extended use

## 🤖 Machine Learning

### Models Used
1. **Gradient Boosting Regressor** - PM2.5 prediction
2. **Random Forest Regressor** - AQI prediction

### Features
- PM10, NO2, SO2, CO, O3 concentrations
- Temperature, Humidity, Wind Speed

### Training
- Automatic training on startup with historical data
- Manual retraining via API endpoint
- Model persistence using joblib

### Prediction Process
1. Fetch latest measurements for location
2. Scale features using StandardScaler
3. Generate predictions using trained models
4. Calculate AQI and category
5. Store predictions in database

## 📈 Sample Data

The system comes pre-loaded with historical data for:
- Delhi
- Mumbai
- Bangalore
- Chennai
- Kolkata
- Hyderabad

## 🔐 Security Notes

⚠️ **Important**: This is a development setup. For production:
- Change default database credentials
- Add environment variables for secrets
- Enable HTTPS/SSL
- Implement authentication
- Add rate limiting
- Configure CORS properly
- Use production-grade database settings

## 🛑 Stopping the System

```bash
# Stop all containers
docker-compose down

# Stop and remove volumes (deletes all data)
docker-compose down -v
```

## 🔄 Updating

```bash
# Rebuild specific service
docker-compose up --build backend

# Rebuild all services
docker-compose up --build
```

## 🐛 Troubleshooting

### Backend won't start
- Check if port 5000 is already in use
- Verify database connection: `docker logs airquality_backend`
- Ensure database is healthy: `docker ps`

### Frontend shows blank page
- Check browser console for errors
- Verify backend is accessible: `curl http://localhost:5000/api/health`
- Check Nginx logs: `docker logs airquality_nginx`

### Database connection issues
- Wait 30 seconds after startup for DB initialization
- Check database logs: `docker logs airquality_db`
- Verify network: `docker network inspect air-quality-system_airquality_network`

### Model not training
- Check if enough data exists (minimum 5 records)
- View backend logs: `docker logs airquality_backend`
- Manually trigger training: `curl -X POST http://localhost/api/train`

## 📝 Environment Variables

Create `.env` file to customize:

```env
# Database
POSTGRES_DB=airquality
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123

# Backend
FLASK_ENV=production
DATABASE_URL=postgresql://admin:admin123@db:5432/airquality
```

## 🎯 Next Steps

Potential enhancements:
- [ ] Add user authentication
- [ ] Implement WebSocket for real-time updates
- [ ] Add more ML models (LSTM, Prophet)
- [ ] Create mobile app
- [ ] Add email/SMS alerts
- [ ] Integrate external API data sources
- [ ] Add data export functionality
- [ ] Implement caching (Redis)
- [ ] Add Grafana dashboards
- [ ] Create admin panel

## 📄 License

MIT License - feel free to use for learning and development

## 🤝 Contributing

This is a demonstration project. Feel free to fork and customize!

## 📧 Support

For issues or questions, please check the troubleshooting section or review container logs.

---

**Built with** ❤️ **using Docker, Python, React, and PostgreSQL**
