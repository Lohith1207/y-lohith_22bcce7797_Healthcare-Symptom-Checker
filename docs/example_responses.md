# Example API Responses

This document provides example input/output pairs for the Healthcare Symptom Checker API.

## Example 1: Emergency Case

### Input
```json
{
  "symptoms": "I have severe chest pain and cannot breathe",
  "age": 45,
  "sex": "Male"
}
```

### Output
```json
{
  "triage": {
    "level": "emergency",
    "message": "This appears to be a medical emergency. Please call emergency services (911) immediately or go to the nearest emergency room."
  },
  "conditions": [
    {
      "name": "Potential Medical Emergency",
      "confidence": "high",
      "rationale": "Symptoms suggest a medical emergency requiring immediate attention.",
      "typical_symptoms": ["Emergency symptoms detected"]
    }
  ],
  "recommended_next_steps": [
    {
      "urgency": "emergency",
      "action": "Call emergency services (911) immediately or go to the nearest emergency room"
    }
  ],
  "disclaimer": "For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.",
  "asked_clarifying_questions": []
}
```

## Example 2: Non-Urgent Case

### Input
```json
{
  "symptoms": "I have a mild headache and feel tired",
  "age": 30,
  "sex": "Female",
  "other_info": "Started yesterday morning"
}
```

### Output
```json
{
  "triage": {
    "level": "non-urgent",
    "message": "Symptoms suggest mild, non-urgent conditions that may benefit from rest and observation."
  },
  "conditions": [
    {
      "name": "Tension Headache",
      "confidence": "medium",
      "rationale": "Headache with fatigue are common symptoms of tension headache, especially if stress-related.",
      "typical_symptoms": ["headache", "fatigue", "muscle tension"]
    },
    {
      "name": "Viral Illness",
      "confidence": "low",
      "rationale": "Headache and fatigue could also indicate the early stages of a viral illness.",
      "typical_symptoms": ["headache", "fatigue", "general malaise"]
    }
  ],
  "recommended_next_steps": [
    {
      "urgency": "self-care",
      "action": "Rest, stay hydrated, and consider over-the-counter pain relief if appropriate"
    },
    {
      "urgency": "routine",
      "action": "If symptoms persist or worsen, consult a healthcare provider"
    }
  ],
  "disclaimer": "For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.",
  "asked_clarifying_questions": [
    "How long have you had these symptoms?",
    "Have you had similar symptoms before?",
    "Are you experiencing any other symptoms?"
  ]
}
```

## Example 3: Urgent Case

### Input
```json
{
  "symptoms": "I have severe abdominal pain that started suddenly and is getting worse",
  "age": 35,
  "sex": "Male"
}
```

### Output
```json
{
  "triage": {
    "level": "urgent",
    "message": "These symptoms require prompt medical evaluation. Consider seeking urgent care or emergency services."
  },
  "conditions": [
    {
      "name": "Acute Appendicitis",
      "confidence": "medium",
      "rationale": "Sudden onset of severe abdominal pain that worsens is a classic presentation of appendicitis.",
      "typical_symptoms": ["severe abdominal pain", "pain worsening", "nausea", "fever"]
    },
    {
      "name": "Kidney Stone",
      "confidence": "medium",
      "rationale": "Sudden severe abdominal pain can also indicate kidney stones or other urinary tract issues.",
      "typical_symptoms": ["severe abdominal pain", "sudden onset", "flank pain"]
    }
  ],
  "recommended_next_steps": [
    {
      "urgency": "soon",
      "action": "Seek urgent medical care within the next few hours"
    },
    {
      "urgency": "emergency",
      "action": "If pain becomes unbearable or you develop fever, go to the emergency room immediately"
    }
  ],
  "disclaimer": "For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.",
  "asked_clarifying_questions": [
    "Where exactly is the pain located?",
    "Have you experienced nausea or vomiting?",
    "Do you have a fever?",
    "Have you had similar pain before?"
  ]
}
```

## Example 4: Self-Care Case

### Input
```json
{
  "symptoms": "I have a stuffy nose and mild cough",
  "age": 25,
  "sex": "Female"
}
```

### Output
```json
{
  "triage": {
    "level": "self-care",
    "message": "These symptoms suggest a mild upper respiratory infection that can typically be managed with self-care measures."
  },
  "conditions": [
    {
      "name": "Common Cold",
      "confidence": "high",
      "rationale": "Stuffy nose and mild cough are typical symptoms of a viral upper respiratory infection.",
      "typical_symptoms": ["nasal congestion", "cough", "sore throat", "mild fatigue"]
    }
  ],
  "recommended_next_steps": [
    {
      "urgency": "self-care",
      "action": "Rest, stay hydrated, use saline nasal spray, and consider over-the-counter cold medications"
    },
    {
      "urgency": "routine",
      "action": "If symptoms worsen or persist for more than 10 days, consult a healthcare provider"
    }
  ],
  "disclaimer": "For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.",
  "asked_clarifying_questions": [
    "How long have you had these symptoms?",
    "Do you have a fever?",
    "Are you experiencing any difficulty breathing?"
  ]
}
```

## Example 5: Error Case

### Input
```json
{
  "age": 30
}
```

### Output (Error Response)
```json
{
  "error": "Symptoms field is required"
}
```

## cURL Examples

### Emergency Case
```bash
curl -X POST http://localhost:8080/api/symptom-check \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": "severe chest pain and cannot breathe",
    "age": 45,
    "sex": "Male"
  }'
```

### Non-Emergency Case
```bash
curl -X POST http://localhost:8080/api/symptom-check \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": "mild headache and fatigue",
    "age": 30,
    "sex": "Female",
    "other_info": "Started yesterday"
  }'
```

### Health Check
```bash
curl -X GET http://localhost:8080/api/health
```

## Response Time Expectations

- **Emergency cases**: < 100ms (rule-based detection)
- **Non-emergency cases**: 2-5 seconds (LLM processing)
- **Health check**: < 50ms

## Error Handling

The API returns appropriate HTTP status codes:
- `200`: Successful analysis
- `400`: Bad request (missing required fields)
- `500`: Internal server error (LLM API issues, etc.)

All error responses include a descriptive error message in JSON format.
