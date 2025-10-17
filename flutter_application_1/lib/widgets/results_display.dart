import 'package:flutter/material.dart';
import '../models/symptom_models.dart';

class ResultsDisplay extends StatelessWidget {
  final SymptomResponse response;

  const ResultsDisplay({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTriageSection(context),
            const SizedBox(height: 24),
            _buildConditionsSection(context),
            const SizedBox(height: 24),
            _buildRecommendedStepsSection(context),
            const SizedBox(height: 24),
            _buildDisclaimerSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTriageSection(BuildContext context) {
    Color triageColor;
    IconData triageIcon;

    switch (response.triage.level) {
      case 'emergency':
        triageColor = Colors.red;
        triageIcon = Icons.warning;
        break;
      case 'urgent':
        triageColor = Colors.orange;
        triageIcon = Icons.priority_high;
        break;
      case 'non-urgent':
        triageColor = Colors.blue;
        triageIcon = Icons.info;
        break;
      case 'self-care':
        triageColor = Colors.green;
        triageIcon = Icons.self_improvement;
        break;
      default:
        triageColor = Colors.grey;
        triageIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: triageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: triageColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(triageIcon, color: triageColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Triage Level: ${response.triage.level.toUpperCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: triageColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(response.triage.message, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildConditionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Possible Conditions',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...response.conditions
            .take(3)
            .map((condition) => _buildConditionCard(context, condition)),
      ],
    );
  }

  Widget _buildConditionCard(BuildContext context, Condition condition) {
    Color confidenceColor;
    switch (condition.confidence) {
      case 'high':
        confidenceColor = Colors.green;
        break;
      case 'medium':
        confidenceColor = Colors.orange;
        break;
      case 'low':
        confidenceColor = Colors.red;
        break;
      default:
        confidenceColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    condition.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: confidenceColor),
                  ),
                  child: Text(
                    '${condition.confidence.toUpperCase()} CONFIDENCE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(condition.rationale, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedStepsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Next Steps',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...response.recommendedNextSteps.map(
          (action) => _buildActionCard(context, action),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, RecommendedAction action) {
    Color urgencyColor;
    IconData urgencyIcon;

    switch (action.urgency) {
      case 'emergency':
        urgencyColor = Colors.red;
        urgencyIcon = Icons.warning;
        break;
      case 'soon':
        urgencyColor = Colors.orange;
        urgencyIcon = Icons.schedule;
        break;
      case 'routine':
        urgencyColor = Colors.blue;
        urgencyIcon = Icons.calendar_today;
        break;
      case 'self-care':
        urgencyColor = Colors.green;
        urgencyIcon = Icons.self_improvement;
        break;
      default:
        urgencyColor = Colors.grey;
        urgencyIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(urgencyIcon, color: urgencyColor),
        title: Text(action.action, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          'Priority: ${action.urgency.toUpperCase()}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: urgencyColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              response.disclaimer,
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
