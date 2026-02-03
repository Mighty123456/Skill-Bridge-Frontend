import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import '../../data/worker_identity_service.dart';
import '../../../auth/data/auth_service.dart';

import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class WorkerPassportScreen extends StatefulWidget {
  final String? userId; // Optional: View other worker's passport
  const WorkerPassportScreen({super.key, this.userId});

  @override
  State<WorkerPassportScreen> createState() => _WorkerPassportScreenState();
}

class _WorkerPassportScreenState extends State<WorkerPassportScreen> {
  Future<Map<String, dynamic>>? _passportFuture;
  String? _currentUserId;
  bool _initializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _loadPassport();
  }

  Future<void> _loadPassport() async {
    setState(() {
       _initializing = true;
       _initError = null;
    });

    try {
        if (widget.userId != null) {
          _currentUserId = widget.userId;
        } else {
          final user = await AuthService().getMe();
          if (user['success'] && user['data'] != null) {
            _currentUserId = user['data']['user']?['_id'] ?? user['data']['_id']; 
          }
        }
    
        if (_currentUserId != null) {
          setState(() {
            _passportFuture = WorkerIdentityService.getSkillPassport(_currentUserId!).then((result) {
               // If API returns failure, return a clean empty passport structure instead of erroring
               if (!result['success']) {
                  return {
                    'success': true,
                    'data': <String, dynamic>{
                       'name': 'Worker', 
                       'verified': false,
                       'rating': 0.0,
                       'skills': [],
                       'badges': [],
                       'warrantyRecalls': 0,
                       'experienceYears': 0
                    }
                  };
               }
               return result;
            });
          });
        } else {
            // No user ID found (not logged in?), use empty fallback
            setState(() {
              _passportFuture = Future.value({
                  'success': true,
                  'data': <String, dynamic>{
                      'name': 'Worker', 
                      'verified': false,
                      'rating': 0.0,
                      'skills': [],
                      'badges': [],
                      'warrantyRecalls': 0,
                      'experienceYears': 0
                  }
              });
            });
        }
    } catch (e) {
        // On exception, also use empty fallback for UI robustness
        setState(() {
           _passportFuture = Future.value({
              'success': true,
              'data': <String, dynamic>{
                  'name': 'Worker', 
                  'verified': false,
                  'rating': 0.0,
                  'skills': [],
                  'badges': [],
                   'warrantyRecalls': 0,
                   'experienceYears': 0
              }
           });
        });
    } finally {
        if (mounted) {
            setState(() {
                _initializing = false;
            });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we somehow still have an init error (should be rare now), show fallback
    if (_initError != null) {
         return Scaffold(
            appBar: const PremiumAppBar(title: 'Skill Passport'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.person_off_outlined, size: 60, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text(_initError ?? 'Could not load passport information', textAlign: TextAlign.center),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: _loadPassport,
                     child: const Text('Retry'),
                   )
                ],
              ),
            ),
         );
    }

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: const PremiumAppBar(
        title: 'Skill Passport',
        showBackButton: true,
      ),
      body: _passportFuture == null && _initializing
          ? const Center(child: PremiumLoader())
          : FutureBuilder<Map<String, dynamic>>(
              future: _passportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: PremiumLoader());
                }
                
                // If data is present (even if it's the fallback empty data), show it
                if (snapshot.hasData && snapshot.data!['success'] == true) {
                     final passport = snapshot.data!['data'];
                     return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                            _buildProfileHeader(passport),
                            const SizedBox(height: 24),
                            _buildSummaryCards(passport),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Active Skill Identity', Icons.psychology),
                            const SizedBox(height: 12),
                            _buildSkillList(passport),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Professional Badges', Icons.verified),
                            const SizedBox(height: 12),
                            _buildBadgesGrid(passport),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Warranty & reliability', Icons.shield),
                            const SizedBox(height: 12),
                            _buildWarrantySection(passport),
                            const SizedBox(height: 40),
                        ],
                      ),
                    );
                }

                // Generic error fallback for unforeseen cases
                   return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Unable to connect to service'),
                         TextButton(
                          onPressed: _loadPassport,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
              },
            ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> passport) {
    return Column(
      children: [
         CircleAvatar(
            radius: 45,
            backgroundImage: passport['profileImage'] != null
                ? NetworkImage(passport['profileImage'])
                : null,
            backgroundColor: AppTheme.colors.primaryLight,
            child: passport['profileImage'] == null
                ? const Icon(Icons.person, size: 45, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            passport['name'] ?? 'Worker',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (passport['verified'] == true) ...[
                const Icon(Icons.verified, color: Colors.lightBlueAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Verified Professional',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ] else
                Text(
                  'Unverified Account',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.colors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> passport) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard('Rating', '${passport['rating']?.toStringAsFixed(1) ?? "0.0"}', Icons.star, Colors.amber)),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoCard('Warranty Recalls', '${passport['warrantyRecalls'] ?? 0}', Icons.history, 
            (passport['warrantyRecalls'] ?? 0) > 0 ? Colors.red : Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoCard('Experience', '${passport['experienceYears'] ?? 0} Yrs', Icons.work, Colors.blue)),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSkillList(Map<String, dynamic> passport) {
    List stats = passport['skillStats'] ?? [];
    List skills = passport['skills'] ?? [];

    // Merge basic skills if not incomplete stats
    if (stats.isEmpty && skills.isNotEmpty) {
        stats = skills.map((s) => {'skill': s, 'confidence': 50, 'last_used': null}).toList();
    }

    if (stats.isEmpty) {
        return _buildEmptyState('No skills verified yet.');
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stat = stats[index];
        final confidence = stat['confidence'] ?? 50;
        final skillName = stat['skill'] ?? 'Unknown Skill';
        final lastUsed = stat['last_used'];
        String lastUsedText = lastUsed != null 
            ? 'Last used: ${DateFormat.yMMMd().format(DateTime.parse(lastUsed))}'
            : 'New Skill';

        Color barColor = Colors.green;
        if (confidence < 80) barColor = Colors.orange;
        if (confidence < 60) barColor = Colors.grey;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(skillName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(confidence == 100 ? 'Verified' : 'Self-declared', 
                      style: TextStyle(color: barColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lastUsedText,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgesGrid(Map<String, dynamic> passport) {
    List badges = passport['badges'] ?? [];
    if (badges.isEmpty) return _buildEmptyState('No badges earned yet.');

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: badges.map((badge) {
        // Handle badge object or string id
        String name = badge['name'] ?? 'Badge';
        String colorHex = badge['color'] ?? '#3B82F6';
        Color color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));

        return Chip(
          avatar: const Icon(Icons.star, size: 16, color: Colors.white),
          label: Text(name),
          backgroundColor: color,
          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }).toList(),
    );
  }

  Widget _buildWarrantySection(Map<String, dynamic> passport) {
     int recalls = passport['warrantyRecalls'] ?? 0;
     List history = passport['recallHistory'] ?? [];

     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: recalls == 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2), // Green tint / Red tint
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: recalls == 0 ? Colors.green.shade200 : Colors.red.shade200),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               Icon(recalls == 0 ? Icons.check_circle : Icons.warning, 
                    color: recalls == 0 ? Colors.green : Colors.red),
               const SizedBox(width: 12),
               Expanded(
                 child: Text(
                   recalls == 0 
                     ? 'No warranty recalls recorded.'
                     : '$recalls Warranty Recall(s) recorded.',
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                 ),
               ),
             ],
           ),
           if (recalls > 0 && history.isNotEmpty) ...[
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 8.0),
               child: Divider(),
             ),
             ...history.map((h) => Padding(
               padding: const EdgeInsets.symmetric(vertical: 4.0),
               child: Text('• ${h['reason'] ?? 'Issue reported'}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
             )),
           ]
         ],
       ),
     );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(text, style: TextStyle(color: Colors.grey[500]))),
    );
  }
}
