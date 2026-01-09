import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

class QuotationSubmissionScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const QuotationSubmissionScreen({super.key, required this.jobData});

  @override
  State<QuotationSubmissionScreen> createState() => _QuotationSubmissionScreenState();
}

class _QuotationSubmissionScreenState extends State<QuotationSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _laborCostController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _timelineController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Submit Quotation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJobBrief(),
              const SizedBox(height: 24),
              Text('Your Quotation', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Labor Cost (₹)',
                controller: _laborCostController,
                keyboardType: TextInputType.number,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Estimated Material Cost (₹)',
                controller: _materialCostController,
                keyboardType: TextInputType.number,
                icon: Icons.build_outlined,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Estimated Timeline (e.g. 2 days)',
                controller: _timelineController,
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Additional Notes / Process',
                controller: _descriptionController,
                maxLines: 4,
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitQuotation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('SUBMIT QUOTATION', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Remaining time to bid: 2h 45m',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobBrief() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_rounded, color: AppTheme.colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.jobData['title'] ?? 'Job Title',
                style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.jobData['description'] ?? 'Need a professional to fix the kitchen sink leakage and check other pipes.',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppTheme.colors.primary) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary),
            ),
          ),
        ),
      ],
    );
  }

  void _submitQuotation() {
    if (_formKey.currentState!.validate()) {
      // Handle submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quotation submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }
}
