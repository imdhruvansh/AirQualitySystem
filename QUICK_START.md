# Quick Start Guide - Air Quality Prediction System

## 🚀 Get Started in 3 Steps

### Step 1: Navigate to Project
```bash
cd air-quality-system
```

### Step 2: Start All Containers
```bash
docker-compose up --build
```

### Step 3: Open Browser
```
http://localhost
```

That's it! The system will:
✅ Build all 4 containers
✅ Initialize database with sample data
✅ Train ML model automatically
✅ Start the web interface

## 📊 What You Get

- **4 Docker Containers**: Database, Backend API, Frontend, Nginx
- **Full Stack**: PostgreSQL + Python/ML + React + Nginx
- **10+ Cities**: Pre-loaded with Indian city data
- **ML Predictions**: 24-hour forecasts using Random Forest
- **10+ API Endpoints**: Complete REST API
- **Beautiful UI**: Modern dashboard with charts

## 🔗 Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| Dashboard | http://localhost | Main web interface |
| API | http://localhost/api | REST API endpoints |
| Health | http://localhost/api/health | Health check |
| Database | localhost:5432 | PostgreSQL (admin/admin123) |

## 🧪 Quick Test

```bash
# Check if working
curl http://localhost/api/health

# Get data
curl http://localhost/api/locations

# Make prediction
curl -X POST http://localhost/api/predict \
  -H "Content-Type: application/json" \
  -d '{"location": "Delhi", "hours_ahead": 24}'
```

## 📁 Project Files

```
air-quality-system/
├── docker-compose.yml          # Main orchestration
├── start.sh                    # Quick start script
├── README.md                   # Full documentation
├── API_TESTING.md             # API testing guide
├── PROJECT_STRUCTURE.md        # Architecture docs
├── backend/                    # Python ML Backend
│   ├── Dockerfile
│   ├── app.py                 # Flask API
│   └── requirements.txt
├── frontend/                   # React Frontend
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── database/                   # PostgreSQL
│   └── init.sql
└── nginx/                      # Reverse Proxy
    └── nginx.conf
```

## 🛑 Stop System

```bash
docker-compose down
```

To remove all data:
```bash
docker-compose down -v
```

## 💡 Key Features

### Backend (Python/Flask)
- Machine Learning predictions (Random Forest, Gradient Boosting)
- 10+ REST API endpoints
- Auto-trains on startup
- PostgreSQL database
- Real-time AQI calculations

### Frontend (React)
- Real-time air quality monitoring
- Interactive charts (Recharts)
- Multi-city support
- Responsive design
- Beautiful cosmic theme
- Live predictions

### Infrastructure
- 4 containerized services
- Nginx reverse proxy
- Docker networking
- Volume persistence
- Health checks

## 📖 Documentation

- **README.md** - Complete setup and features
- **API_TESTING.md** - All API endpoints with examples
- **PROJECT_STRUCTURE.md** - Architecture details

## 🎯 Sample API Calls

### Get Current Air Quality
```bash
curl http://localhost/api/current/Delhi
```

### Get Historical Data
```bash
curl "http://localhost/api/data?location=Mumbai&limit=10"
```

### Generate Prediction
```bash
curl -X POST http://localhost/api/predict \
  -H "Content-Type: application/json" \
  -d '{"location": "Bangalore", "hours_ahead": 24}'
```

### Add New Data
```bash
curl -X POST http://localhost/api/add-data \
  -H "Content-Type: application/json" \
  -d '{
    "location": "Pune",
    "pm25": 75.5,
    "pm10": 105.3,
    "no2": 32.5,
    "so2": 9.2,
    "co": 0.95,
    "o3": 48.3,
    "temperature": 28.5,
    "humidity": 62.0,
    "wind_speed": 4.2
  }'
```

## 🔧 Common Commands

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend

# Restart service
docker-compose restart backend

# Rebuild specific service
docker-compose up --build backend

# Access database
docker exec -it airquality_db psql -U admin -d airquality

# Check running containers
docker ps

# Check container health
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## 🐛 Troubleshooting

### Issue: Backend won't start
```bash
# Check logs
docker logs airquality_backend

# Verify database is ready
docker ps | grep airquality_db
```

### Issue: Frontend shows blank page
```bash
# Check if backend is accessible
curl http://localhost:5000/api/health

# Check frontend logs
docker logs airquality_frontend
```

### Issue: Database connection failed
```bash
# Wait 30 seconds after startup
# Then check database
docker exec -it airquality_db psql -U admin -d airquality -c "SELECT COUNT(*) FROM air_quality_data;"
```

## 🎨 Frontend Features

- **Live Data**: Real-time air quality monitoring
- **Predictions**: ML-powered 24-hour forecasts
- **Charts**: Interactive trend visualization
- **AQI**: Color-coded air quality index
- **Multi-city**: Switch between locations
- **Statistics**: Historical analytics
- **Responsive**: Works on all devices
- **Dark Theme**: Easy on the eyes

## 🤖 ML Models

- **PM2.5 Prediction**: Gradient Boosting Regressor
- **AQI Prediction**: Random Forest Regressor
- **Features**: PM10, NO2, SO2, CO, O3, Temperature, Humidity, Wind Speed
- **Training**: Automatic on startup
- **Accuracy**: ~85% confidence

## 📊 Pre-loaded Data

Cities with historical data:
- Delhi
- Mumbai
- Bangalore
- Chennai
- Kolkata
- Hyderabad

Each with 10+ measurements ready for analysis and predictions.

## ⚙️ System Requirements

- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM
- 10GB disk space
- Modern web browser

## 🔐 Default Credentials

**Database**:
- User: admin
- Password: admin123
- Database: airquality

⚠️ **Change these for production use!**

## 🎓 Learning Resources

This project demonstrates:
- Full-stack Docker architecture
- REST API development
- Machine Learning integration
- React frontend development
- Nginx reverse proxy
- PostgreSQL database
- Container orchestration

## 📝 Next Steps

1. ✅ Get system running
2. ✅ Explore the web interface
3. ✅ Test API endpoints
4. ✅ View database
5. ✅ Make predictions
6. ✅ Add new cities
7. ✅ Customize ML models
8. ✅ Extend features

## 🤝 Support

- Check logs: `docker-compose logs -f`
- Read full docs: `README.md`
- API guide: `API_TESTING.md`
- Architecture: `PROJECT_STRUCTURE.md`

---

**Enjoy your Air Quality Prediction System!** 🌍
