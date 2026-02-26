import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend
} from 'recharts';
import { Wind, Droplets, Thermometer, Activity, TrendingUp, MapPin } from 'lucide-react';
import './App.css';

const API_URL = '/api';

function App() {
  const [locations, setLocations] = useState([]);
  const [selectedLocation, setSelectedLocation] = useState('Delhi');
  const [currentData, setCurrentData] = useState(null);
  const [historicalData, setHistoricalData] = useState([]);
  const [prediction, setPrediction] = useState(null);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchLocations();
  }, []);

  useEffect(() => {
    if (selectedLocation) {
      fetchCurrentData();
      fetchHistoricalData();
      fetchStats();
    }
  }, [selectedLocation]);

  const fetchLocations = async () => {
    try {
      const response = await axios.get(`${API_URL}/locations`);
      setLocations(response.data.locations);
      if (response.data.locations.length > 0) {
        setSelectedLocation(response.data.locations[0]);
      }
    } catch (error) {
      console.error('Error fetching locations:', error);
    }
  };

  const fetchCurrentData = async () => {
    try {
      const response = await axios.get(`${API_URL}/current/${selectedLocation}`);
      setCurrentData(response.data);
    } catch (error) {
      console.error('Error fetching current data:', error);
    }
  };

  const fetchHistoricalData = async () => {
    try {
      const response = await axios.get(`${API_URL}/data?location=${selectedLocation}&limit=20`);
      const formatted = response.data.data.map(item => ({
        time: new Date(item.timestamp).toLocaleTimeString(),
        aqi: item.aqi,
        pm25: item.pm25,
        pm10: item.pm10,
        temp: item.temperature
      })).reverse();
      setHistoricalData(formatted);
    } catch (error) {
      console.error('Error fetching historical data:', error);
    }
  };

  const fetchStats = async () => {
    try {
      const response = await axios.get(`${API_URL}/stats/${selectedLocation}`);
      setStats(response.data);
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  };

  const handlePredict = async () => {
    setLoading(true);
    try {
      const response = await axios.post(`${API_URL}/predict`, {
        location: selectedLocation,
        hours_ahead: 24
      });
      setPrediction(response.data);
    } catch (error) {
      console.error('Error making prediction:', error);
    } finally {
      setLoading(false);
    }
  };

  const getAQIColor = (aqi) => {
    if (aqi <= 50) return '#10b981';
    if (aqi <= 100) return '#f59e0b';
    if (aqi <= 150) return '#ef4444';
    if (aqi <= 200) return '#dc2626';
    if (aqi <= 300) return '#991b1b';
    return '#7f1d1d';
  };

  const getAQIGradient = (aqi) => {
    const color = getAQIColor(aqi);
    return `linear-gradient(135deg, ${color}22 0%, ${color}44 100%)`;
  };

  return (
    <div className="app">
      <div className="cosmic-bg"></div>
      
      <header className="header">
        <div className="header-content">
          <div className="logo-section">
            <Activity className="logo-icon" size={40} strokeWidth={2.5} />
            <div>
              <h1 className="title">AirSense</h1>
              <p className="subtitle">Real-time Air Quality Intelligence</p>
            </div>
          </div>
          
          <div className="location-selector">
            <MapPin size={20} className="location-icon" />
            <select 
              value={selectedLocation} 
              onChange={(e) => setSelectedLocation(e.target.value)}
              className="location-select"
            >
              {locations.map(loc => (
                <option key={loc} value={loc}>{loc}</option>
              ))}
            </select>
          </div>
        </div>
      </header>

      <main className="main-content">
        {currentData && (
          <div className="grid">
            {/* Main AQI Display */}
            <div className="card hero-card" style={{ background: getAQIGradient(currentData.aqi) }}>
              <div className="card-header">
                <h2>Current Air Quality Index</h2>
                <div className="badge">{currentData.category}</div>
              </div>
              <div className="aqi-display">
                <div className="aqi-number" style={{ color: getAQIColor(currentData.aqi) }}>
                  {currentData.aqi}
                </div>
                <div className="aqi-label">AQI</div>
              </div>
              <div className="metrics-grid">
                <div className="metric">
                  <span className="metric-label">PM2.5</span>
                  <span className="metric-value">{currentData.pm25.toFixed(1)} µg/m³</span>
                </div>
                <div className="metric">
                  <span className="metric-label">PM10</span>
                  <span className="metric-value">{currentData.pm10.toFixed(1)} µg/m³</span>
                </div>
              </div>
            </div>

            {/* Environmental Conditions */}
            <div className="card">
              <h2 className="card-title">Environmental Conditions</h2>
              <div className="conditions-grid">
                <div className="condition-item">
                  <div className="condition-icon temp">
                    <Thermometer size={24} />
                  </div>
                  <div className="condition-info">
                    <div className="condition-label">Temperature</div>
                    <div className="condition-value">{currentData.temperature}°C</div>
                  </div>
                </div>
                <div className="condition-item">
                  <div className="condition-icon humidity">
                    <Droplets size={24} />
                  </div>
                  <div className="condition-info">
                    <div className="condition-label">Humidity</div>
                    <div className="condition-value">{currentData.humidity}%</div>
                  </div>
                </div>
                <div className="condition-item">
                  <div className="condition-icon wind">
                    <Wind size={24} />
                  </div>
                  <div className="condition-info">
                    <div className="condition-label">Wind Speed</div>
                    <div className="condition-value">{currentData.wind_speed} m/s</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Pollutants Breakdown */}
            <div className="card">
              <h2 className="card-title">Pollutants Breakdown</h2>
              <div className="pollutants">
                <div className="pollutant-bar">
                  <div className="pollutant-header">
                    <span>NO₂</span>
                    <span>{currentData.no2.toFixed(1)} µg/m³</span>
                  </div>
                  <div className="progress-bar">
                    <div className="progress-fill" style={{ width: `${Math.min(currentData.no2 / 100 * 100, 100)}%`, background: '#3b82f6' }}></div>
                  </div>
                </div>
                <div className="pollutant-bar">
                  <div className="pollutant-header">
                    <span>SO₂</span>
                    <span>{currentData.so2.toFixed(1)} µg/m³</span>
                  </div>
                  <div className="progress-bar">
                    <div className="progress-fill" style={{ width: `${Math.min(currentData.so2 / 50 * 100, 100)}%`, background: '#8b5cf6' }}></div>
                  </div>
                </div>
                <div className="pollutant-bar">
                  <div className="pollutant-header">
                    <span>CO</span>
                    <span>{currentData.co.toFixed(1)} mg/m³</span>
                  </div>
                  <div className="progress-bar">
                    <div className="progress-fill" style={{ width: `${Math.min(currentData.co / 5 * 100, 100)}%`, background: '#ec4899' }}></div>
                  </div>
                </div>
                <div className="pollutant-bar">
                  <div className="pollutant-header">
                    <span>O₃</span>
                    <span>{currentData.o3.toFixed(1)} µg/m³</span>
                  </div>
                  <div className="progress-bar">
                    <div className="progress-fill" style={{ width: `${Math.min(currentData.o3 / 100 * 100, 100)}%`, background: '#10b981' }}></div>
                  </div>
                </div>
              </div>
            </div>

            {/* ML Prediction */}
            <div className="card prediction-card">
              <div className="card-header">
                <h2 className="card-title">
                  <TrendingUp size={24} />
                  24-Hour Prediction
                </h2>
              </div>
              
              {prediction ? (
                <div className="prediction-result">
                  <div className="prediction-aqi">
                    <div className="prediction-number" style={{ color: getAQIColor(prediction.predicted_aqi) }}>
                      {prediction.predicted_aqi}
                    </div>
                    <div className="prediction-label">Predicted AQI</div>
                  </div>
                  <div className="prediction-details">
                    <div className="prediction-item">
                      <span className="prediction-key">PM2.5</span>
                      <span className="prediction-val">{prediction.predicted_pm25} µg/m³</span>
                    </div>
                    <div className="prediction-item">
                      <span className="prediction-key">Category</span>
                      <span className="prediction-val">{prediction.category}</span>
                    </div>
                    <div className="prediction-item">
                      <span className="prediction-key">Confidence</span>
                      <span className="prediction-val">{(prediction.confidence * 100).toFixed(0)}%</span>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="prediction-empty">
                  <p>Get AI-powered predictions for the next 24 hours</p>
                </div>
              )}
              
              <button 
                onClick={handlePredict} 
                disabled={loading}
                className="predict-button"
              >
                {loading ? 'Analyzing...' : 'Generate Prediction'}
              </button>
            </div>

            {/* Historical Chart */}
            <div className="card chart-card">
              <h2 className="card-title">AQI Trends</h2>
              <div className="chart-container">
                <ResponsiveContainer width="100%" height={300}>
                  <AreaChart data={historicalData}>
                    <defs>
                      <linearGradient id="aqiGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#6366f1" stopOpacity={0.8}/>
                        <stop offset="95%" stopColor="#6366f1" stopOpacity={0.1}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#333" opacity={0.3} />
                    <XAxis dataKey="time" stroke="#888" fontSize={12} />
                    <YAxis stroke="#888" fontSize={12} />
                    <Tooltip 
                      contentStyle={{ background: '#1a1a1a', border: '1px solid #333', borderRadius: '8px' }}
                      labelStyle={{ color: '#fff' }}
                    />
                    <Area type="monotone" dataKey="aqi" stroke="#6366f1" strokeWidth={2} fill="url(#aqiGradient)" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Stats Card */}
            {stats && (
              <div className="card stats-card">
                <h2 className="card-title">Statistics</h2>
                <div className="stats-grid">
                  <div className="stat-item">
                    <div className="stat-value">{stats.avg_aqi ? Math.round(stats.avg_aqi) : 'N/A'}</div>
                    <div className="stat-label">Average AQI</div>
                  </div>
                  <div className="stat-item">
                    <div className="stat-value">{stats.max_aqi || 'N/A'}</div>
                    <div className="stat-label">Peak AQI</div>
                  </div>
                  <div className="stat-item">
                    <div className="stat-value">{stats.min_aqi || 'N/A'}</div>
                    <div className="stat-label">Lowest AQI</div>
                  </div>
                  <div className="stat-item">
                    <div className="stat-value">{stats.total_readings || 'N/A'}</div>
                    <div className="stat-label">Total Readings</div>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
      </main>

      <footer className="footer">
        <p>Powered by Machine Learning & Real-time Analytics</p>
      </footer>
    </div>
  );
}

export default App;
