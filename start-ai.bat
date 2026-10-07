@echo off
cd /d "C:\Users\Udaypratap Singh\StudioProjects\Aasha-Final\ai-service"
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
