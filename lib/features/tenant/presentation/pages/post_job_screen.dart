import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import '../../data/job_service.dart';
import '../../../../widgets/custom_feedback_popup.dart';

class PostJobScreen extends StatefulWidget {
  static const String routeName = '/post-job';
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  String? _selectedSkill;
  String _urgency = 'Normal';
  bool _materialRequired = false;
  bool _isLoading = false;
  int _quotationWindowDays = 1;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customSkillController = TextEditingController();

  final List<Map<String, dynamic>> _skills = [
    {'name': 'Plumber', 'icon': Icons.plumbing_rounded},
    {'name': 'Electrician', 'icon': Icons.electric_bolt_rounded},
    {'name': 'Cleaner', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Painter', 'icon': Icons.format_paint_rounded},
    {'name': 'Carpenter', 'icon': Icons.carpenter_rounded},
    {'name': 'Gardener', 'icon': Icons.yard_rounded},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (_selectedSkill == null) {
      CustomFeedbackPopup.show(context, title: 'Missing Info', message: 'Please select a service type', type: FeedbackType.error);
      return;
    }

    String finalSkill = _selectedSkill!;
    if (_selectedSkill == 'Other') {
      if (_customSkillController.text.trim().isEmpty) {
         CustomFeedbackPopup.show(context, title: 'Missing Info', message: 'Please specify the service needed', type: FeedbackType.error);
         return;
      }
      finalSkill = _customSkillController.text.trim();
    }

    if (_descriptionController.text.trim().isEmpty) {
      CustomFeedbackPopup.show(context, title: 'Missing Info', message: 'Please describe your problem', type: FeedbackType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // In a real app, we would get proper Title from user or generate it better
      final String jobTitle = '${_urgency == 'Emergency' ? 'URGENT: ' : ''}Need $finalSkill Help';

      final result = await JobService.createJob(
        title: jobTitle,
        description: _descriptionController.text.trim(),
        skill: finalSkill, 
        urgency: _urgency,
        quotationWindowDays: _quotationWindowDays,
        location: {
          'coordinates': [72.8777, 19.0760], // Hardcoded Mumbai for DEMO as requested "Start simple"
          'address': 'Demo Location (Mumbai)'
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
         CustomFeedbackPopup.show(
           context, 
           title: 'Job Posted!', 
           message: 'Workers nearby have been notified.', 
           type: FeedbackType.success,
           onConfirm: () {
             // Clear form
             setState(() {
               _descriptionController.clear();
               _customSkillController.clear();
               _selectedSkill = null;
               _urgency = 'Normal';
             });
           }
         );
      } else {
        CustomFeedbackPopup.show(context, title: 'Error', message: result['message'] ?? 'Failed', type: FeedbackType.error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomFeedbackPopup.show(context, title: 'Error', message: e.toString(), type: FeedbackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: const PremiumAppBar(title: 'Post a Job'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Service Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('SELECT SERVICE'),
                  const SizedBox(height: 12),
                  _buildServiceGrid(),
                  if (_selectedSkill == 'Other') ...[
                     const SizedBox(height: 16),
                     _buildCustomSkillField(),
                  ],
                  
                  const SizedBox(height: 28),
                  
                  // Job Description
                  _buildSectionLabel('DESCRIBE YOUR PROBLEM'),
                  const SizedBox(height: 12),
                  _buildDescriptionField(),
                  
                  const SizedBox(height: 28),
                  
                  // Urgency Level
                  _buildSectionLabel('URGENCY LEVEL'),
                  const SizedBox(height: 12),
                  _buildUrgencySelector(),
                  
                  const SizedBox(height: 28),
                  
                  // Quotation Window
                  _buildSectionLabel('QUOTATION WINDOW'),
                  const SizedBox(height: 8),
                  Text('How long do you want to receive quotes?', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 12),
                  _buildQuotationWindowSelector(),

                  const SizedBox(height: 28),
                  
                  // Location
                  _buildSectionLabel('SERVICE LOCATION'),
                  const SizedBox(height: 12),
                  _buildLocationCard(),
                  
                  const SizedBox(height: 28),
                  
                  // Additional Options
                  _buildMaterialToggle(),
                  
                  const SizedBox(height: 32),
                  
                  // AI Suggestions Card
                  _buildSuggestionsCard(),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  _buildSubmitButton(context),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSkillField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: _customSkillController,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: 'Enter Service Name (e.g. Welder)',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.edit, color: AppTheme.colors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }


  Widget _buildQuotationWindowSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [1, 2, 3, 5, 7].map((days) {
          final isSelected = _quotationWindowDays == days;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _quotationWindowDays = days),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.colors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.colors.primary : Colors.grey[300]!,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                  ] : null,
                ),
                child: Text(
                  '$days Day${days > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _skills.length,
      itemBuilder: (context, index) {
        final skill = _skills[index];
        final isSelected = _selectedSkill == skill['name'];
        
        return GestureDetector(
          onTap: () => setState(() => _selectedSkill = skill['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.colors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.colors.primary 
                    : Colors.grey.withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppTheme.colors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  skill['icon'],
                  color: isSelected ? Colors.white : AppTheme.colors.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  skill['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'e.g., Kitchen sink is leaking from the pipe connection...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildUrgencySelector() {
    return Row(
      children: [
        Expanded(
          child: _buildUrgencyOption(
            label: 'Normal',
            subtitle: 'Within 24 hours',
            icon: Icons.schedule_rounded,
            isSelected: _urgency == 'Normal',
            onTap: () => setState(() => _urgency = 'Normal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildUrgencyOption(
            label: 'Emergency',
            subtitle: 'ASAP',
            icon: Icons.bolt_rounded,
            isSelected: _urgency == 'Emergency',
            onTap: () => setState(() => _urgency = 'Emergency'),
            isEmergency: true,
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencyOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    final color = isEmergency ? Colors.red : AppTheme.colors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Map Preview
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.grey[100],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://static-maps.yandex.ru/1.x/?ll=72.8777,19.0760&z=14&l=map&size=500,140',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Address Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Using Demo Location',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Mumbai, India (Test Mode)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                // TextButton(
                //   onPressed: () {},
                //   child: const Text(
                //     'Change',
                //     style: TextStyle(
                //       fontSize: 13,
                //       fontWeight: FontWeight.w800,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialToggle() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.colors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppTheme.colors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materials Required',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Worker should bring parts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _materialRequired,
            onChanged: (val) => setState(() => _materialRequired = val),
            activeTrackColor: AppTheme.colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.colors.primary.withValues(alpha: 0.05),
            AppTheme.colors.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.colors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.colors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Suggestions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSuggestionRow(
            icon: Icons.payments_outlined,
            label: 'Estimated Cost',
            value: '₹400 - ₹650',
          ),
          const SizedBox(height: 12),
          _buildSuggestionRow(
            icon: Icons.timer_outlined,
            label: 'Expected Response',
            value: 'Within 15 mins',
          ),
          const SizedBox(height: 12),
          _buildSuggestionRow(
            icon: Icons.people_outline_rounded,
            label: 'Available Workers',
            value: 'Searching...',
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitJob,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
          shadowColor: AppTheme.colors.primary.withValues(alpha: 0.3),
        ),
        child: _isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Post Job Request',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
