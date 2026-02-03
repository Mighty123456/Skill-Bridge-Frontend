import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🎯 STATE: Holds discovery data (Workers nearby)
class WorkerDiscoveryState {
  final bool isLoading;
  final String? error;
  
  // Step 5: Filtered Results
  final List<Map<String, dynamic>> workers; // List of worker objects
  final double searchRadius; // in km
  final String? skillFilter;
  final bool verifiedOnly;

  const WorkerDiscoveryState({
    this.isLoading = false,
    this.error,
    this.workers = const [],
    this.searchRadius = 5.0,
    this.skillFilter,
    this.verifiedOnly = true,
  });

  WorkerDiscoveryState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? workers,
    double? searchRadius,
    String? skillFilter,
    bool? verifiedOnly,
  }) {
    return WorkerDiscoveryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      workers: workers ?? this.workers,
      searchRadius: searchRadius ?? this.searchRadius,
      skillFilter: skillFilter ?? this.skillFilter,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }
}

// 🎮 NOTIFIER: Logic for finding workers
class WorkerDiscoveryNotifier extends Notifier<WorkerDiscoveryState> {
  @override
  WorkerDiscoveryState build() {
    return const WorkerDiscoveryState();
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API Call (Geo-query)
      // fetchWorkers(lat, lng, radius, skill, verifiedOnly)
      await Future.delayed(const Duration(milliseconds: 800)); 

      // Mock Data
      final mockWorkers = [
        {
          'id': 'w1',
          'name': 'Rajesh Kumar',
          'skill': 'Plumber',
          'isVerified': true,
          'rating': 4.8,
          'distance': 1.2, // km
          'availability': 'green', // Prediction feature
        },
        {
          'id': 'w2',
          'name': 'Anil Singh',
          'skill': 'Plumber',
          'isVerified': true,
          'rating': 4.5,
          'distance': 3.5,
          'availability': 'yellow',
        },
      ];

      // Local Filter Logic (if not handled by backend completely)
      final filtered = mockWorkers.where((w) {
        if (state.skillFilter != null && w['skill'] != state.skillFilter) return false;
        if (state.verifiedOnly && w['isVerified'] != true) return false;
        return true;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        workers: filtered,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 🔌 PROVIDER
final workerDiscoveryProvider = NotifierProvider<WorkerDiscoveryNotifier, WorkerDiscoveryState>(() {
  return WorkerDiscoveryNotifier();
});
