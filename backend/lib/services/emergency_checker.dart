class EmergencyChecker {
  // Emergency trigger phrases - case insensitive, whole word and phrase matching
  static const List<String> _emergencyTriggers = [
    // Chest pain and heart-related
    'chest pain',
    'heart attack',
    'myocardial infarction',
    'cardiac arrest',
    'severe chest pain',
    'crushing chest pain',
    'chest tightness',
    'chest pressure',

    // Breathing difficulties
    'severe shortness of breath',
    'cannot breathe',
    'struggling to breathe',
    'severe breathing difficulty',
    'acute respiratory distress',
    'choking',
    'severe asthma attack',

    // Neurological emergencies
    'sudden weakness',
    'sudden numbness',
    'stroke',
    'cerebrovascular accident',
    'paralysis',
    'loss of consciousness',
    'unconscious',
    'severe headache',
    'worst headache of my life',
    'thunderclap headache',

    // Bleeding emergencies
    'uncontrolled bleeding',
    'severe bleeding',
    'hemorrhage',
    'bleeding heavily',
    'cannot stop bleeding',

    // Allergic reactions
    'severe allergic reaction',
    'anaphylaxis',
    'anaphylactic shock',
    'severe swelling',
    'throat swelling',
    'difficulty swallowing',

    // Trauma
    'severe trauma',
    'major accident',
    'head injury with loss of consciousness',
    'severe burns',

    // Mental health emergencies
    'suicidal thoughts',
    'want to hurt myself',
    'want to die',
    'suicide attempt',

    // Other emergencies
    'severe abdominal pain',
    'acute abdomen',
    'severe dehydration',
    'severe fever with confusion',
    'seizure lasting more than 5 minutes',
    'status epilepticus',
  ];

  /// Checks if the symptom text contains emergency triggers
  /// Returns true if emergency conditions are detected
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
        bool allWordsPresent =
            triggerWords.every((word) => normalizedSymptoms.contains(word));
        if (allWordsPresent) {
          return true;
        }
      }
    }

    return false;
  }

  /// Returns emergency response when emergency conditions are detected
  static Map<String, dynamic> getEmergencyResponse() {
    return {
      'triage': {
        'level': 'emergency',
        'message':
            'This appears to be a medical emergency. Please call emergency services (911) immediately or go to the nearest emergency room.'
      },
      'conditions': [
        {
          'name': 'Potential Medical Emergency',
          'confidence': 'high',
          'rationale':
              'Symptoms suggest a medical emergency requiring immediate attention.',
          'typical_symptoms': ['Emergency symptoms detected']
        }
      ],
      'recommended_next_steps': [
        {
          'urgency': 'emergency',
          'action':
              'Call emergency services (911) immediately or go to the nearest emergency room'
        }
      ],
      'disclaimer':
          'For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.',
      'asked_clarifying_questions': []
    };
  }

  /// Returns list of emergency trigger phrases for documentation
  static List<String> getEmergencyTriggers() {
    return List.unmodifiable(_emergencyTriggers);
  }
}
