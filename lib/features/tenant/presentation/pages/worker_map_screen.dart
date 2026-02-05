import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import '../providers/worker_discovery_provider.dart';
import 'dart:math' as math;
import 'worker_profile_screen.dart';

class WorkerMapScreen extends ConsumerStatefulWidget {
  static const String routeName = '/worker-map';
  const WorkerMapScreen({super.key});

  @override
  ConsumerState<WorkerMapScreen> createState() => _WorkerMapScreenState();
}

class _WorkerMapScreenState extends ConsumerState<WorkerMapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _myLocation;
  late final AnimationController _pulseController;
  
  // Filters
  final List<String> _skills = [
    'Plumber', 'Electrician', 'Carpenter', 'Painter', 'Cleaner', 'Gardener'
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initializeLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the 
        // App to enable the location services.
        debugPrint('Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied, we cannot request permissions.');
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      
      if (mounted) {
        setState(() {
          _myLocation = LatLng(position.latitude, position.longitude);
        });

        // Center map on user initially
        _mapController.move(_myLocation!, 15.0);
        
        // Update Provider
        ref.read(workerDiscoveryProvider.notifier).setLocation(position.latitude, position.longitude);
        ref.read(workerDiscoveryProvider.notifier).searchWorkers();
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(workerDiscoveryProvider);
    final isLoading = discoveryState.isLoading;

    // Auto-Zoom Listener
    ref.listen(workerDiscoveryProvider, (previous, next) {
      if (next.isLoading == false && next.workers.isNotEmpty) {
         // Fix: Ensure we trigger zoom only when content changes effectively
         // or if it was loading before.
         if (previous?.isLoading == true || previous?.workers.length != next.workers.length) {
            // Include a small delay to allow map to render frame
            Future.delayed(const Duration(milliseconds: 500), () {
               if (mounted) _fitCameraBounds(next.workers);
            });
         }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. MAP DISCOVERY LAYER
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _myLocation ?? const LatLng(19.0760, 72.8777), // Default Mumbai
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                 flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.skillbridge_mobile',
              ),
              // Search Radius Circle
              if (_myLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _myLocation!,
                      radius: discoveryState.searchRadius * 1000, 
                      useRadiusInMeter: true,
                      color: AppTheme.colors.primary.withValues(alpha: 0.05),
                      borderColor: AppTheme.colors.primary.withValues(alpha: 0.3),
                      borderStrokeWidth: 1.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // My Location (Scanner or Pulse)
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 200, // Large area for radar
                      height: 200,
                      child: isLoading 
                          ? const RadarScanWidget()
                          : _buildUserPulse(),
                    ),
                  
                  // Worker Pins
                  if (!isLoading)
                    ...discoveryState.workers.map((worker) {
                       final loc = worker['location'];
                       if (loc == null || loc['coordinates'] == null) return null;
                       final lng = loc['coordinates'][0];
                       final lat = loc['coordinates'][1];

                       return Marker(
                         point: LatLng(lat, lng),
                         width: 60,
                         height: 70, // Taller for pin shape
                         child: GestureDetector(
                           onTap: () => _showWorkerDetails(worker),
                           child: _buildCustomPin(worker),
                         ),
                       );
                    }).whereType<Marker>(),
                ],
              ),
            ],
          ),

          // 2. TOP GLASS HEADER (Back + Title)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 40, bottom: 10, left: 16, right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                   CircleAvatar(
                     backgroundColor: Colors.white,
                     radius: 20,
                     child: IconButton(
                       icon: const Icon(Icons.arrow_back, color: Colors.black),
                       onPressed: () => Navigator.pop(context),
                     ),
                   ),
                   const SizedBox(width: 16),
                   const Text(
                     "Nearby Pros",
                     style: TextStyle(
                       color: Colors.white, 
                       fontSize: 20, 
                       fontWeight: FontWeight.bold,
                       shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 2))]
                     ),
                   ),
                ],
              ),
            ),
          ),

          // 3. FLOATING FILTER CHIPS
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All', null, discoveryState.skillFilter),
                  ..._skills.map((s) => _buildFilterChip(s, s, discoveryState.skillFilter)),
                ],
              ),
            ),
          ),
          
          // Note: Removed the old "Scanning area..." top loader as functionality is moved to map marker.

           // Error Toast
          if (discoveryState.error != null)
             Positioned(
               bottom: 100, 
               left: 20, 
               right: 20, 
               child: Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.redAccent,
                   borderRadius: BorderRadius.circular(12),
                   boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.error_outline, color: Colors.white),
                     const SizedBox(width: 12),
                     Expanded(child: Text(discoveryState.error!, style: const TextStyle(color: Colors.white))),
                   ],
                 ),
               )
             ),

           // Recenter Button
           Positioned(
             right: 20,
             bottom: 40,
             child: FloatingActionButton(
               backgroundColor: Colors.white,
               foregroundColor: AppTheme.colors.primary,
               onPressed: () {
                 // Re-check location and permission logic if needed
                 _initializeLocation();
               },
               child: const Icon(Icons.my_location),
             ),
           ),
        ],
      ),
    );
  }

  // --- COMPONENT BUILDERS ---

  Widget _buildUserPulse() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Double Ripple Logic
        final val1 = _pulseController.value;
        final val2 = (val1 + 0.5) % 1.0; // Second wave offset
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ripple 1
            Opacity(
              opacity: (1.0 - val1).clamp(0.0, 1.0),
              child: Container(
                width: 60 + (val1 * 100),
                height: 60 + (val1 * 100),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Ripple 2 (Staggered)
            Opacity(
              opacity: (1.0 - val2).clamp(0.0, 1.0),
              child: Container(
                width: 60 + (val2 * 100),
                height: 60 + (val2 * 100),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Core Glow
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              ),
            ),
            // Inner Location Dot
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black38)],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? value, String? currentValue) {
    final isSelected = value == currentValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: isSelected ? AppTheme.colors.primary : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        onPressed: () {
          ref.read(workerDiscoveryProvider.notifier).setFilters(skill: value);
        },
      ),
    );
  }

  Widget _buildCustomPin(Map<String, dynamic> worker) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.colors.primary, width: 2),
            boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black38, offset: Offset(0, 3))],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: worker['profileImage'] != null 
                ? NetworkImage(worker['profileImage']) 
                : null,
            child: worker['profileImage'] == null 
                ? Text(worker['name'][0], style: const TextStyle(fontWeight: FontWeight.bold))
                : null,
          ),
        ),
        // Pin Triangle Pointer
        ClipPath(
          clipper: TriangleClipper(),
          child: Container(
            width: 14,
            height: 10,
            color: AppTheme.colors.primary,
          ),
        ),
      ],
    );
  }

  void _showWorkerDetails(Map<String, dynamic> worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Hero(
                  tag: 'worker_${worker['id']}',
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: worker['profileImage'] != null 
                        ? Image.network(worker['profileImage'], width: 70, height: 70, fit: BoxFit.cover)
                        : Container(
                            width: 70, height: 70, color: Colors.grey[100], 
                            child: Center(child: Text(worker['name'][0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker['name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        worker['skills']?.join(' • ') ?? 'General Worker',
                        style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber[700], size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${worker['rating'] ?? 'New'}", 
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.monetization_on_outlined, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "₹${worker['hourlyRate'] ?? 0}/hr", 
                            style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToWorkerProfile(worker);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
                    ),
                    child: const Text("View Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _navigateToWorkerProfile(Map<String, dynamic> worker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkerProfileScreen(worker: worker),
      ),
    );
  }

  void _fitCameraBounds(List<dynamic> workers) {
    if (_myLocation == null) return;
    
    // Collect all points
    List<LatLng> points = [_myLocation!];
    for (var w in workers) {
      if (w['location'] != null && w['location']['coordinates'] != null) {
        // Ensure coordinates are valid numbers
        final lng = w['location']['coordinates'][0];
        final lat = w['location']['coordinates'][1];
        if (lng != null && lat != null) {
          points.add(LatLng(lat.toDouble(), lng.toDouble()));
        }
      }
    }

    // Need at least 2 points to make bounds meaningful, or just use user location
    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);
    
    // Safer zooming with maxZoom cap
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60), // Increased padding
        maxZoom: 16.0, // Don't zoom in super close if only 1-2 points are near
        forceIntegerZoomLevel: false,
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// A professional radar scanning animation widget
class RadarScanWidget extends StatefulWidget {
  const RadarScanWidget({super.key});

  @override
  State<RadarScanWidget> createState() => _RadarScanWidgetState();
}

class _RadarScanWidgetState extends State<RadarScanWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Expanding Circles (Sonar effect)
        _buildExpandingCircle(0),
        _buildExpandingCircle(0.33),
        _buildExpandingCircle(0.66),

        // Rotating Radar Sweep
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    center: Alignment.center,
                    startAngle: 0.0,
                    endAngle: 1.0, // approx 60 degrees
                    colors: [
                      Colors.transparent,
                      AppTheme.colors.primary.withValues(alpha: 0.1),
                      AppTheme.colors.primary.withValues(alpha: 0.5),
                    ],
                    stops: const [0.5, 0.8, 1.0],
                  ),
                ),
              ),
            );
          },
        ),

        // Center User Dot
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.colors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colors.primary.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandingCircle(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = (_controller.value + delay) % 1.0;
        return Opacity(
          opacity: (1.0 - val).clamp(0.0, 1.0),
          child: Container(
            width: 40 + (val * 160), // Expand from 40 to 200
            height: 40 + (val * 160),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.colors.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
