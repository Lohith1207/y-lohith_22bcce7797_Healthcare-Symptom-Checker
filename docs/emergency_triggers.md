# Emergency Trigger Detection

This document lists all emergency trigger phrases used by the Healthcare Symptom Checker for immediate safety detection.

## Trigger Detection Strategy

The system performs case-insensitive matching using both:
1. **Whole phrase matching**: Exact phrase detection
2. **Individual word matching**: For compound terms, all words must be present

## Emergency Trigger Phrases

### Cardiac/Chest Emergencies
- `chest pain`
- `heart attack`
- `myocardial infarction`
- `cardiac arrest`
- `severe chest pain`
- `crushing chest pain`
- `chest tightness`
- `chest pressure`

### Respiratory Emergencies
- `severe shortness of breath`
- `cannot breathe`
- `struggling to breathe`
- `severe breathing difficulty`
- `acute respiratory distress`
- `choking`
- `severe asthma attack`

### Neurological Emergencies
- `sudden weakness`
- `sudden numbness`
- `stroke`
- `cerebrovascular accident`
- `paralysis`
- `loss of consciousness`
- `unconscious`
- `severe headache`
- `worst headache of my life`
- `thunderclap headache`

### Bleeding Emergencies
- `uncontrolled bleeding`
- `severe bleeding`
- `hemorrhage`
- `bleeding heavily`
- `cannot stop bleeding`

### Allergic Reactions
- `severe allergic reaction`
- `anaphylaxis`
- `anaphylactic shock`
- `severe swelling`
- `throat swelling`
- `difficulty swallowing`

### Trauma Emergencies
- `severe trauma`
- `major accident`
- `head injury with loss of consciousness`
- `severe burns`

### Mental Health Emergencies
- `suicidal thoughts`
- `want to hurt myself`
- `want to die`
- `suicide attempt`

### Other Medical Emergencies
- `severe abdominal pain`
- `acute abdomen`
- `severe dehydration`
- `severe fever with confusion`
- `seizure lasting more than 5 minutes`
- `status epilepticus`

## Implementation Details

### Matching Algorithm
```dart
static bool isEmergency(String symptoms) {
  final normalizedSymptoms = symptoms.toLowerCase();
  
  for (final trigger in _emergencyTriggers) {
    final normalizedTrigger = trigger.toLowerCase();
    
    // Check for whole phrase match
    if (normalizedSymptoms.contains(normalizedTrigger)) {
      return true;
    }
    
    // Check for individual word matches (for compound terms)
    final triggerWords = normalizedTrigger.split(' ');
    if (triggerWords.length > 1) {
      bool allWordsPresent = triggerWords.every((word) => 
        normalizedSymptoms.contains(word));
      if (allWordsPresent) {
        return true;
      }
    }
  }
  
  return false;
}
```

### Emergency Response
When emergency triggers are detected, the system immediately returns:
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

## Safety Considerations

1. **False Positives**: The system is designed to err on the side of caution
2. **Regular Updates**: Trigger lists should be reviewed and updated regularly
3. **Medical Review**: All triggers should be validated by medical professionals
4. **User Education**: Clear messaging about emergency detection capabilities
5. **Fallback**: Always provide emergency contact information

## Testing Emergency Detection

```bash
# Test emergency detection
curl -X POST http://localhost:8080/api/symptom-check \
  -H "Content-Type: application/json" \
  -d '{"symptoms": "severe chest pain and cannot breathe"}'

# Expected: Immediate emergency response without LLM call
```

## Maintenance

- Review trigger phrases quarterly
- Add new emergency conditions as needed
- Monitor false positive/negative rates
- Update based on medical literature and guidelines
- Document all changes with rationale
