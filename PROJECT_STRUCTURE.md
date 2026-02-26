# Project Structure

```
air-quality-system/
├── backend/                      # Python ML Backend (Container 2)
│   ├── Dockerfile               # Backend container configuration
│   ├── requirements.txt         # Python dependencies
│   ├── app.py                   # Main Flask application
│   └── models/                  # ML models (generated at runtime)
│       ├── aqi_model.pkl       # Trained ML models
│       └── scaler.pkl          # Feature scaler
│
├── database/                     # Database Initialization (Container 1)
│   └── init.sql                 # Database schema and seed data
│
├── frontend/                     # React Frontend (Container 3)
│   ├── Dockerfile               # Multi-stage build (Node + Nginx)
│   ├── nginx.conf               # Frontend-specific Nginx config
│   ├── package.json             # Node dependencies
│   ├── public/
│   │   └── index.html          # HTML template
│   └── src/
│       ├── index.js            # React entry point
│       ├── index.css           # Global styles
│       ├── App.js              # Main React component
│       └── App.css             # Component styles
│
├── nginx/                        # Reverse Proxy (Container 4)
│   └── nginx.conf               # Main Nginx configuration
│
├── docker-compose.yml           # Main orchestration file
├── docker-compose.dev.yml       # Development overrides
├── start.sh                     # Quick start script
├── README.md                    # Main documentation
├── API_TESTING.md              # API testing guide
└── .gitignore                  # Git ignore rules
```

## Container Details

### Container 1: PostgreSQL Database
- **Image**: postgres:15-alpine
- **Port**: 5432
- **Purpose**: Stores air quality measurements and predictions
- **Tables**:
  - `air_quality_data` - Historical measurements
  - `predictions` - ML predictions
- **Initialization**: Runs `database/init.sql` on first start

### Container 2: Python ML Backend
- **Base Image**: python:3.11-slim
- **Port**: 5000
- **Purpose**: REST API and ML inference
- **Key Files**:
  - `app.py` - Flask application with 10+ endpoints
  - `requirements.txt` - Dependencies (Flask, scikit-learn, pandas, etc.)
- **ML Models**: Random Forest & Gradient Boosting
- **Auto-trains**: Model trains automatically on startup

### Container 3: React Frontend
- **Build Stage**: node:18-alpine
- **Runtime Stage**: nginx:alpine
- **Port**: 3000 (dev), 80 (prod)
- **Purpose**: Interactive web dashboard
- **Key Features**:
  - Real-time data visualization
  - Interactive charts (Recharts)
  - Responsive design
  - Cosmic theme with custom animations

### Container 4: Nginx Reverse Proxy
- **Image**: nginx:alpine
- **Port**: 80
- **Purpose**: API gateway and static file server
- **Routes**:
  - `/` → Frontend (Container 3)
  - `/api/*` → Backend (Container 2)
- **Features**: Compression, buffering, load balancing

## Data Flow

```
User Browser
    ↓
Nginx (Container 4) :80
    ↓
    ├── / → Frontend (Container 3) :80
    │         ↓
    │    Static React App
    │
    └── /api/* → Backend (Container 2) :5000
                    ↓
              Flask API + ML Models
                    ↓
              Database (Container 1) :5432
                    ↓
              PostgreSQL
```

## Network Architecture

All containers are connected via a Docker bridge network:
- Network name: `airquality_network`
- Internal DNS: Containers can reach each other by service name
  - `db` → PostgreSQL
  - `backend` → Flask API
  - `frontend` → React/Nginx
  - `nginx` → Reverse Proxy

## Volume Mounts

### Persistent Volumes
- `postgres_data` → Database persistence
- `model_data` → ML model persistence

### Development Mounts (docker-compose.dev.yml)
- `./backend:/app` → Hot reload for Python
- `./frontend/src:/app/src` → Hot reload for React

## Technology Stack

### Backend
- **Language**: Python 3.11
- **Framework**: Flask 3.0.0
- **Database**: PostgreSQL 15
- **ML Libraries**:
  - scikit-learn 1.3.2
  - pandas 2.1.4
  - numpy 1.26.2
- **API**: RESTful with CORS support

### Frontend
- **Framework**: React 18.2.0
- **Bundler**: Create React App
- **Charts**: Recharts 2.10.3
- **Icons**: Lucide React 0.263.1
- **HTTP**: Axios 1.6.2
- **Styling**: Custom CSS with CSS Variables

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Reverse Proxy**: Nginx
- **Database**: PostgreSQL 15

## Environment Variables

### Database (Container 1)
```
POSTGRES_DB=airquality
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
```

### Backend (Container 2)
```
DATABASE_URL=postgresql://admin:admin123@db:5432/airquality
FLASK_ENV=production
```

## Build Process

### Production Build
```bash
docker-compose up --build
```

1. Database container starts
2. Runs init.sql to create schema
3. Backend container builds
4. Installs Python dependencies
5. Waits for database health check
6. Trains initial ML model
7. Frontend container builds
8. Runs npm build
9. Copies build to Nginx
10. Nginx container starts
11. Configures routes

### Development Build
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

Enables:
- Hot reload for backend
- Hot reload for frontend
- Debug mode
- Volume mounts for live editing

## Port Mapping

| Service | Internal | External | Purpose |
|---------|----------|----------|---------|
| Nginx | 80 | 80 | Main entry point |
| Frontend | 80 | 3000 | React dev server |
| Backend | 5000 | 5000 | API (also via Nginx) |
| Database | 5432 | 5432 | PostgreSQL |

## Security Notes

⚠️ **Development Configuration** - Not production-ready!

**Current Setup**:
- Default credentials in code
- No authentication/authorization
- CORS enabled for all origins
- No rate limiting
- No HTTPS/SSL
- Database exposed on host

**For Production**:
- Use environment variables for secrets
- Implement JWT authentication
- Configure CORS properly
- Add rate limiting
- Enable HTTPS with SSL certificates
- Use database connection pooling
- Don't expose database port
- Add input validation
- Implement logging and monitoring

## Scaling Considerations

To scale this application:

1. **Horizontal Scaling**:
   - Add more backend containers
   - Use Nginx load balancing
   - Separate read/write database replicas

2. **Caching**:
   - Add Redis for API responses
   - Cache predictions
   - Cache static data

3. **Message Queue**:
   - Add RabbitMQ/Celery for async tasks
   - Background model training
   - Scheduled predictions

4. **Monitoring**:
   - Add Prometheus for metrics
   - Add Grafana for dashboards
   - Implement health checks

## File Sizes (Approximate)

- Backend image: ~800MB
- Frontend image: ~50MB (production)
- Database image: ~250MB
- Nginx image: ~25MB
- Total: ~1.1GB

## Startup Time

- Cold start: ~45 seconds
- Warm start: ~15 seconds
- ML model training: ~5-10 seconds

## Dependencies Count

- Backend: 9 Python packages
- Frontend: 5 npm packages (+ dependencies)
- Total npm modules: ~2000+
