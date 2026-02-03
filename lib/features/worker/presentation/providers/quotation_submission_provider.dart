import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotationSubmissionState {
  final bool isLoading;
  final String? error;
  
  // Job Context
  final String? jobId;
  final bool isJobOpen;
  
  // Step 6: Quotation Data
  final double? laborCost;
  final double? materialCost;
  final int? timelineDays;
  final File? videoPitch; // Optional 30-sec video
  
  final bool isDuplicate; // Prevent duplicate quotes
  final bool isWindowOpen; // Validate time window

  const QuotationSubmissionState({
    this.isLoading = false,
    this.error,
    this.jobId,
    this.isJobOpen = true,
    this.laborCost,
    this.materialCost,
    this.timelineDays,
    this.videoPitch,
    this.isDuplicate = false,
    this.isWindowOpen = true,
  });

  QuotationSubmissionState copyWith({
    bool? isLoading,
    String? error,
    String? jobId,
    bool? isJobOpen,
    double? laborCost,
    double? materialCost,
    int? timelineDays,
    File? videoPitch,
    bool? isDuplicate,
    bool? isWindowOpen,
  }) {
    return QuotationSubmissionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      jobId: jobId ?? this.jobId,
      isJobOpen: isJobOpen ?? this.isJobOpen,
      laborCost: laborCost ?? this.laborCost,
      materialCost: materialCost ?? this.materialCost,
      timelineDays: timelineDays ?? this.timelineDays,
      videoPitch: videoPitch ?? this.videoPitch,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      isWindowOpen: isWindowOpen ?? this.isWindowOpen,
    );
  }
  
  double get totalEstimate => (laborCost ?? 0) + (materialCost ?? 0);
}

class QuotationSubmissionNotifier extends Notifier<QuotationSubmissionState> {
  @override
  QuotationSubmissionState build() {
    return const QuotationSubmissionState();
  }

  void initJob(String jobId) {
    // In real app: Fetch job status to ensure it's open and window is valid
    state = state.copyWith(jobId: jobId, isJobOpen: true, isWindowOpen: true);
  }

  void updateCosts({double? labor, double? material, int? days}) {
    state = state.copyWith(
      laborCost: labor ?? state.laborCost,
      materialCost: material ?? state.materialCost,
      timelineDays: days ?? state.timelineDays,
    );
  }

  void setVideoPitch(File video) {
    state = state.copyWith(videoPitch: video);
  }

  // Step 6: Validate and Submit
  Future<bool> submitQuotation() async {
    state = state.copyWith(isLoading: true, error: null);

    // 1. Validation Logic
    if (!state.isJobOpen || !state.isWindowOpen) {
      state = state.copyWith(isLoading: false, error: "Quotation window is closed.");
      return false;
    }
    if (state.laborCost == null || state.laborCost! <= 0) {
      state = state.copyWith(isLoading: false, error: "Labor cost must be valid.");
      return false;
    }
    if (state.timelineDays == null || state.timelineDays! <= 0) {
      state = state.copyWith(isLoading: false, error: "Timeline is required.");
      return false;
    }
    
    // Anti-underpricing warning logic (Extra Feature)
    if (state.totalEstimate < 100) { 
       // In real flow, toggle a warning before blocking
       // but for now we just proceed
    }

    try {
      // Simulate API Submission
      await Future.delayed(const Duration(seconds: 1));
      
      // On Success
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final quotationSubmissionProvider = NotifierProvider<QuotationSubmissionNotifier, QuotationSubmissionState>(() {
  return QuotationSubmissionNotifier();
});
