import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

class JobBidScreen extends StatefulWidget {
  static const String routeName = '/job-bid';
  const JobBidScreen({super.key});

  @override
  State<JobBidScreen> createState() => _JobBidScreenState();
}

class _JobBidScreenState extends State<JobBidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _laborCostController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _timelineController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Submit Quotation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work_rounded, color: AppTheme.colors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text('Kitchen Sink Leakage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Urgency: Emergency • Sector 15 • 2.5 km away', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const Divider(height: 24),
                    const Text(
                      'Budget Range: ₹400 - ₹600',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text('YOUR QUOTATION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2, color: Colors.grey)),
              const SizedBox(height: 16),

              _buildField(
                label: 'Labor Cost (₹)',
                controller: _laborCostController,
                hint: 'e.g. 500',
                icon: Icons.person_outline,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildField(
                label: 'Estimated Material Cost (₹)',
                controller: _materialCostController,
                hint: 'e.g. 200 (if any)',
                icon: Icons.build_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildField(
                label: 'Estimated Timeline',
                controller: _timelineController,
                hint: 'e.g. 2 hours',
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 20),

              _buildField(
                label: 'Notes / Way of Work',
                controller: _noteController,
                hint: 'Briefly explain how you will fix this...',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor: AppTheme.colors.primary.withValues(alpha: 0.3),
                  ),
                  child: const Text('SUBMIT QUOTATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Quotation can be updated within 30 mins', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppTheme.colors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.colors.primary)),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quotation submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}

