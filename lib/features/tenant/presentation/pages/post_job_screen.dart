import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import '../../data/job_service.dart';
import '../../../../widgets/custom_feedback_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

class PostJobScreen extends StatefulWidget {
  static const String routeName = '/post-job';
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  String? _selectedSkill;
  String _urgency = 'medium'; // Changed default to lowercase per backend enum

  bool _isLoading = false;
  int _quotationWindowDays = 1;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customSkillController = TextEditingController();
  final MapController _mapController = MapController();

  // Image State
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  // Location State
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocationLoading = true;

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
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            // Construct a decent address string
            _currentAddress = [
                place.subLocality, 
                place.locality, 
                place.administrativeArea, 
                place.country
              ].where((element) => element != null && element.isNotEmpty).join(', ');
          } else {
            _currentAddress = 'Unknown Location';
          }
          _isLocationLoading = false;
        });
        
        // Move map to new location safely
        if (_currentPosition != null) {
          try {
            _mapController.move(
              lat_lng.LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 
              15.0
            );
          } catch (e) {
            // Map might not be ready yet, which is fine as initialCenter will handle it
            debugPrint('Map move skipped: $e');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Location not available';
          _isLocationLoading = false;
        });
      }
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
         CustomFeedbackPopup.show(context, title: 'Error', message: 'Could not pick images', type: FeedbackType.error);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _customSkillController.dispose();
    _mapController.dispose();
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
    
    // Ensure we have location
    if (_currentPosition == null) {
       // Try fetching again or warn
       await _getCurrentLocation();
       if (_currentPosition == null) {
          if (!mounted) return;
           CustomFeedbackPopup.show(context, title: 'Location Error', message: 'We need your location to find valid workers nearby.', type: FeedbackType.error);
           return;
       }
    }

    setState(() => _isLoading = true);

    try {
      final String jobTitle = '${_urgency == 'emergency' ? 'URGENT: ' : ''}Need $finalSkill Help';

      final result = await JobService.createJob(
        title: jobTitle,
        description: _descriptionController.text.trim(),
        skill: finalSkill, 
        urgency: _urgency,
        quotationWindowDays: _quotationWindowDays,

        location: {
          'coordinates': [_currentPosition!.longitude, _currentPosition!.latitude],
          'address': _currentAddress ?? 'Unknown Location'
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
               _urgency = 'medium';
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
                   // Address / Location Status Header (Optional visual feedback)
                   if (_isLocationLoading)
                     Padding(
                       padding: const EdgeInsets.only(bottom: 20),
                       child: LinearProgressIndicator(
                         backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                         valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                         borderRadius: BorderRadius.circular(2),
                       ),
                     ),

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

                  // Photos of the Issue
                  _buildSectionLabel('PHOTOS OF THE ISSUE'),
                  const SizedBox(height: 12),
                  _buildImageUploadSection(),

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
            isSelected: _urgency == 'medium',
            onTap: () => setState(() => _urgency = 'medium'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildUrgencyOption(
            label: 'Emergency',
            subtitle: 'ASAP',
            icon: Icons.bolt_rounded,
            isSelected: _urgency == 'emergency',
            onTap: () => setState(() => _urgency = 'emergency'),
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
    return GestureDetector(
      onTap: _getCurrentLocation, // Tap to refresh
      child: Container(
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
            // Map Preview with FlutterMap
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: _isLocationLoading && _currentPosition == null
                    ? Center(child: CircularProgressIndicator(color: AppTheme.colors.primary))
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentPosition != null
                              ? lat_lng.LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                              : const lat_lng.LatLng(19.0760, 72.8777), // Default to Mumbai
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.skillbridge_mobile',
                          ),
                          if (_currentPosition != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: lat_lng.LatLng(
                                    _currentPosition!.latitude, 
                                    _currentPosition!.longitude
                                  ),
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppTheme.colors.primary,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
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
                      color: AppTheme.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.my_location_rounded, color: AppTheme.colors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Location',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _currentAddress ?? 'Detecting...',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImages.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.colors.primary,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.add_a_photo_rounded, color: AppTheme.colors.primary, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
