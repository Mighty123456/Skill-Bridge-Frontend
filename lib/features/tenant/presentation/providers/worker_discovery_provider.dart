import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/tenant_worker_service.dart';

// 🎯 STATE: Holds discovery data (Workers nearby)
class WorkerDiscoveryState {
  final bool isLoading;
  final String? error;
  
  // Step 5: Filtered Results
  final List<dynamic> workers; // List of worker objects
  final double searchRadius; // in km
  final String? skillFilter;
  final bool verifiedOnly;
  
  // Location
  final double? latitude;
  final double? longitude;

  const WorkerDiscoveryState({
    this.isLoading = false,
    this.error,
    this.workers = const [],
    this.searchRadius = 8.0,
    this.skillFilter,
    this.verifiedOnly = true,
    this.latitude,
    this.longitude,
  });

  WorkerDiscoveryState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? workers,
    double? searchRadius,
    String? skillFilter,
    bool? verifiedOnly,
    double? latitude,
    double? longitude,
  }) {
    return WorkerDiscoveryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      workers: workers ?? this.workers,
      searchRadius: searchRadius ?? this.searchRadius,
      skillFilter: skillFilter ?? this.skillFilter,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

// 🎮 NOTIFIER: Logic for finding workers
class WorkerDiscoveryNotifier extends Notifier<WorkerDiscoveryState> {
  @override
  WorkerDiscoveryState build() {
    return const WorkerDiscoveryState();
  }

  // Set location
  void setLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng);
  }

  // Set filters
  void setFilters({double? radius, String? skill, bool? verified}) {
    state = state.copyWith(
      searchRadius: radius ?? state.searchRadius,
      skillFilter: skill ?? state.skillFilter,
      verifiedOnly: verified ?? state.verifiedOnly,
    );
    // Automatically refresh search when filters change
    searchWorkers(); 
  }

  // Step 5: Geo-query workers
  Future<void> searchWorkers() async {
    if (state.latitude == null || state.longitude == null) {
      // Try to get current location if not set?
       // For now, assume location is set by the UI before calling search
       return; 
    }
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await TenantWorkerService.getNearbyWorkers(
        lat: state.latitude!, 
        lng: state.longitude!,
        radius: state.searchRadius,
        skill: state.skillFilter
      );

      if (result['success']) {
        state = state.copyWith(
          isLoading: false,
          workers: result['data'],
        );
      } else {
         state = state.copyWith(isLoading: false, error: result['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 🔌 PROVIDER
final workerDiscoveryProvider = NotifierProvider<WorkerDiscoveryNotifier, WorkerDiscoveryState>(() {
  return WorkerDiscoveryNotifier();
});

