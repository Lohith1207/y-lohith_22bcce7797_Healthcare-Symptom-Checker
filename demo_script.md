# Healthcare Symptom Checker - Demo Script

**Duration**: 60-90 seconds  
**Target**: Technical audience, potential users, stakeholders

## Script Outline

### Introduction (10 seconds)
"Today I'm demonstrating a Healthcare Symptom Checker built entirely in Dart - both backend and frontend. This is an educational tool that provides symptom analysis with proper safety disclaimers and emergency triage."

### Emergency Detection Demo (20 seconds)
**Show**: Enter emergency symptoms
- **Say**: "First, let me show the emergency detection system"
- **Do**: Type "I have severe chest pain and cannot breathe"
- **Say**: "Notice how it immediately detects this as an emergency without calling external services, returning an emergency triage response instructing the user to call 911"

### Normal Symptom Analysis (25 seconds)
**Show**: Enter non-emergency symptoms
- **Say**: "Now let's try a non-emergency case"
- **Do**: Type "I have a mild headache and feel tired, age 30, female"
- **Say**: "This goes through the full LLM analysis pipeline, returning probable conditions with confidence levels, recommended next steps, and clarifying questions"

### Technical Highlights (15 seconds)
**Show**: Code or architecture
- **Say**: "The system is built with Dart Shelf for the backend API, Flutter for the web frontend, includes comprehensive safety checks, and stores anonymized data in PostgreSQL"
- **Show**: Safety disclaimers prominently displayed

### Conclusion (10 seconds)
**Say**: "This demonstrates a complete, production-ready healthcare symptom checker with proper safety measures, emergency detection, and educational focus. All code is available on GitHub with full documentation."

## Demo Commands

### Start the System
```bash
# Terminal 1: Start database and backend
docker-compose up -d postgres backend

# Terminal 2: Start frontend (if not using Docker)
cd frontend
flutter run -d web-server --web-port 3000
```

### Test Emergency Detection
```bash
curl -X POST http://localhost:8080/api/symptom-check \
  -H "Content-Type: application/json" \
  -d '{"symptoms": "severe chest pain and cannot breathe"}'
```

### Test Normal Analysis
```bash
curl -X POST http://localhost:8080/api/symptom-check \
  -H "Content-Type: application/json" \
  -d '{"symptoms": "mild headache and fatigue", "age": 30, "sex": "Female"}'
```

## Key Points to Emphasize

1. **Safety First**: Emergency detection happens before LLM calls
2. **Educational Purpose**: Clear disclaimers throughout
3. **Complete Dart Stack**: Backend + Frontend in one language
4. **Production Ready**: Docker, tests, documentation
5. **Privacy Focused**: Anonymized data storage
6. **Open Source**: Full code available

## Troubleshooting

- If backend fails: Check LLM_API_KEY in .env file
- If frontend can't connect: Verify backend is running on port 8080
- If database issues: Ensure PostgreSQL is running via docker-compose

## Demo Environment Setup

```bash
# Clone and setup
git clone <repository-url>
cd healthcare-symptom-checker
cp env.example .env
# Edit .env with your API keys

# Start services
docker-compose up -d

# Run tests
cd backend && dart test

# Start development
cd backend && dart run bin/server.dart
cd frontend && flutter run -d web-server --web-port 3000
```

## Visual Cues for Demo

1. **Red warning banner** - Point out safety disclaimers
2. **Emergency response** - Highlight immediate 911 instruction
3. **Confidence levels** - Show high/medium/low indicators
4. **Triage levels** - Demonstrate emergency/urgent/non-urgent/self-care
5. **Professional UI** - Clean, medical-grade interface design
