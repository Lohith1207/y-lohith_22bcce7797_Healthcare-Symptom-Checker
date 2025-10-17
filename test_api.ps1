# Test script for Healthcare Symptom Checker API

Write-Host "Testing Healthcare Symptom Checker API..." -ForegroundColor Green

# Test 1: Health Check
Write-Host "`n1. Testing Health Check..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method GET
    Write-Host "✓ Health Check: $($healthResponse.status)" -ForegroundColor Green
} catch {
    Write-Host "✗ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Normal Symptoms
Write-Host "`n2. Testing Normal Symptoms..." -ForegroundColor Yellow
try {
    $normalResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/symptom-check" -Method POST -ContentType "application/json" -Body '{"symptoms": "mild headache and fatigue"}'
    Write-Host "✓ Normal Symptoms: Triage Level = $($normalResponse.triage.level)" -ForegroundColor Green
} catch {
    Write-Host "✗ Normal Symptoms Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Emergency Symptoms
Write-Host "`n3. Testing Emergency Symptoms..." -ForegroundColor Yellow
try {
    $emergencyResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/symptom-check" -Method POST -ContentType "application/json" -Body '{"symptoms": "severe chest pain"}'
    Write-Host "✓ Emergency Symptoms: Triage Level = $($emergencyResponse.triage.level)" -ForegroundColor Green
} catch {
    Write-Host "✗ Emergency Symptoms Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAPI Testing Complete!" -ForegroundColor Green
