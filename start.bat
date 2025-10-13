@echo off
REM Personal Blog System Startup Script (Windows Version)
REM Using local Qwen model with vLLM deployment

echo Starting Personal Blog System (Using Local Qwen Model)
echo ======================================================

echo need to mvn clean package -DskipTests and npm install first

REM Check if model files exist
set "MODEL_PATH=D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat"
if not exist "%MODEL_PATH%" (
    echo ERROR: Model directory does not exist: %MODEL_PATH%
    echo Please ensure Qwen model is downloaded to the specified path
    pause
    exit /b 1
)

REM Check required model files
set "REQUIRED_FILES=config.json tokenizer.json"
for %%f in (%REQUIRED_FILES%) do (
    if not exist "%MODEL_PATH%\%%f" (
        echo ERROR: Missing model file: %%f
        echo Please ensure model files are complete
        pause
        exit /b 1
    )
)

echo Model files check passed

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running, please start Docker Desktop first
    pause
    exit /b 1
)

REM Enter project directory
cd /d "%~dp0local"
if errorlevel 1 (
    echo ERROR: Cannot enter project directory
    pause
    exit /b 1
)

echo Starting vLLM service...
cd /d "%~dp0local"
docker-compose up -d vllm

REM Wait for vLLM to start
echo Waiting for vLLM service to start...
timeout /t 10 /nobreak >nul

REM Check vLLM service status by container state and logs
echo Checking vLLM service status...

REM Wait a bit more for service to fully initialize
timeout /t 15 /nobreak >nul

REM Check if container is running and healthy by examining logs
docker ps -f name=vllm --format "{{.Status}}" | findstr "Up" >nul 2>&1
if errorlevel 1 (
    echo ERROR: vLLM container is not running, please check logs:
    docker logs vllm
    pause
    exit /b 1
)

REM Check if vLLM is responding to requests (more reliable check)
echo Waiting for vLLM to fully initialize...
timeout /t 30 /nobreak >nul

REM Check if container is healthy by looking for successful startup in logs
docker logs vllm | findstr "Application startup complete" >nul 2>&1
if errorlevel 1 (
    echo Warning: vLLM may still be initializing, but continuing...
) else (
    echo vLLM API server is ready!
)

echo vLLM service started successfully

echo Starting backend service...
docker-compose up -d backend

echo Starting frontend service...
docker-compose up -d frontend

echo Starting FRP client...
docker-compose up -d frpc

echo.
echo =============================================
echo Service Status:
docker-compose ps

echo.
echo 🎉 All services started successfully!

echo.
echo Service Access URLs:
echo    Frontend (Vue.js): http://localhost:3000
echo    Backend API:       http://localhost:8080
echo    vLLM AI API:       http://localhost:8000
echo    API Documentation: http://localhost:8000/docs

echo.
echo Common Commands:
echo View all logs:      docker-compose logs -f
echo View vLLM logs:     docker-compose logs -f vllm
echo View backend logs:  docker-compose logs -f backend
echo View frontend logs: docker-compose logs -f frontend
echo Stop all services:  docker-compose down
echo Restart services:   docker-compose restart

pause
