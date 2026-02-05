import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';

class WorkerProfileScreen extends StatelessWidget {
  static const String routeName = '/worker-profile';
  final Map<String, dynamic> worker;

  const WorkerProfileScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final String name = worker['name'] ?? 'Unknown Pro';
    final String image = worker['profileImage'] ?? '';
    final List<dynamic> skills = worker['skills'] ?? [];
    final double rating = (worker['rating'] ?? 0.0).toDouble();
    final int hourlyRate = (worker['hourlyRate'] ?? 0).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Premium Sliver App Bar with Hero Image
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.colors.primary,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                       if (image.isNotEmpty)
                        Image.network(image, fit: BoxFit.cover)
                       else
                        Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 80, color: Colors.grey)),
                       
                       // Gradient Overlay for text readability
                       Container(
                         decoration: BoxDecoration(
                           gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [
                               Colors.transparent,
                               appThemePrimaryColor.withValues(alpha: 0.2), // Subtle tint
                               Colors.black.withValues(alpha: 0.9),
                             ],
                             stops: const [0.4, 0.7, 1.0],
                           ),
                         ),
                       ),
                       
                       // Info Overlay
                       Positioned(
                         bottom: 30,
                         left: 20,
                         right: 20,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             // Verified Badge
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: AppTheme.colors.secondary,
                                 borderRadius: BorderRadius.circular(20),
                                 boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                               ),
                               child: const Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(Icons.verified, color: Colors.white, size: 14),
                                   SizedBox(width: 6),
                                   Text(
                                     'VERIFIED PRO', 
                                     style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(height: 12),
                             Text(
                               name,
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 32,
                                 fontWeight: FontWeight.w800,
                                 shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                                 height: 1.1,
                                 letterSpacing: -0.5,
                               ),
                             ),
                             const SizedBox(height: 8),
                             Row(
                               children: [
                                 Text(
                                   (skills.isNotEmpty) ? skills.first.toString() : 'Service Provider',
                                   style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, fontWeight: FontWeight.w500),
                                 ),
                                 const SizedBox(width: 8),
                                 Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
                                 const SizedBox(width: 8),
                                 const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                 const SizedBox(width: 2),
                                 const Text(
                                   "3.2 km away",
                                   style: TextStyle(color: Colors.white70, fontSize: 14),
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                    ],
                  ),
                ),
              ),

              // 2. Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Stats Row
                      Transform.translate(
                        offset: const Offset(0, -0), // Optional overlap effect
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Rating', rating > 0 ? rating.toString() : 'New', Icons.star_rounded, Colors.amber),
                              _buildDivider(),
                              _buildStatItem('Rate', hourlyRate > 0 ? '₹$hourlyRate/hr' : 'Ask', Icons.monetization_on_outlined, Colors.green),
                              _buildDivider(),
                              _buildStatItem('Jobs', '12+', Icons.work_outline, AppTheme.colors.primary), // Improve with real data later
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // About / Bio
                      _buildSectionHeader('About Professional'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              "I am a dedicated ${skills.isNotEmpty ? skills.first : 'professional'} with years of experience in delivering high-quality services. Committed to customer satisfaction and timely completion of tasks.",
                              style: TextStyle(color: Colors.blueGrey[700], height: 1.6, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 28),

                      // Skills Chips
                      _buildSectionHeader('Specializations'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 4),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: skills.map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_outlined, size: 16, color: AppTheme.colors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  s.toString(),
                                  style: TextStyle(
                                    color: AppTheme.colors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Reviews Teaser
                      _buildSectionHeader('Reviews'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            const Text(
                              "No reviews yet",
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),

                      const SizedBox(height: 120), // Spacing for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                   BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                       height: 56,
                       width: 56,
                       decoration: BoxDecoration(
                         color: AppTheme.colors.secondary.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: IconButton(
                         onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat feature coming soon')));
                         },
                         icon: Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.colors.secondary),
                       ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking feature coming soon')));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.colors.primary,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Book Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
  
  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey[100]);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.colors.secondary, borderRadius: BorderRadius.circular(4)), margin: const EdgeInsets.only(right: 10)),
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF2D3748), letterSpacing: -0.5)),
        ],
      ),
    );
  }
}

// Temporary Helper for direct color usage if needed, though AppTheme is preferred
const Color appThemePrimaryColor = Color(0xFF008080);
