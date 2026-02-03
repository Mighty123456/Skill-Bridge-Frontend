import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🎯 STATE: Holds data for the Job Posting Flow (User Side)
class JobPostingState {
  final bool isLoading;
  final String? error;
  
  // Step 4: Job Details
  final String? selectedSkill;
  final String description;
  final bool isEmergency;
  final DateTime? quotationStartTime;
  final DateTime? quotationEndTime;
  final String status; // 'open', 'draft'

  const JobPostingState({
    this.isLoading = false,
    this.error,
    this.selectedSkill,
    this.description = '',
    this.isEmergency = false,
    this.quotationStartTime,
    this.quotationEndTime,
    this.status = 'draft',
  });

  JobPostingState copyWith({
    bool? isLoading,
    String? error,
    String? selectedSkill,
    String? description,
    bool? isEmergency,
    DateTime? quotationStartTime,
    DateTime? quotationEndTime,
    String? status,
  }) {
    return JobPostingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedSkill: selectedSkill ?? this.selectedSkill,
      description: description ?? this.description,
      isEmergency: isEmergency ?? this.isEmergency,
      quotationStartTime: quotationStartTime ?? this.quotationStartTime,
      quotationEndTime: quotationEndTime ?? this.quotationEndTime,
      status: status ?? this.status,
    );
  }
}

// 🎮 NOTIFIER: Logic for Creating a Job
class JobPostingNotifier extends Notifier<JobPostingState> {
  @override
  JobPostingState build() {
    return const JobPostingState();
  }

  void setSkill(String skill) {
    state = state.copyWith(selectedSkill: skill);
  }

  void setDescription(String desc) {
    state = state.copyWith(description: desc);
  }

  void setUrgency(bool isEmergency) {
    state = state.copyWith(isEmergency: isEmergency);
  }

  void setQuotationWindow(DateTime start, DateTime end) {
    state = state.copyWith(
      quotationStartTime: start,
      quotationEndTime: end,
    );
  }

  // Validate and Submit Job (Step 4)
  Future<bool> postJob() async {
    state = state.copyWith(isLoading: true, error: null);

    // Validation
    if (state.selectedSkill == null) {
      state = state.copyWith(isLoading: false, error: "Please select a skill.");
      return false;
    }
    if (state.description.isEmpty) {
      state = state.copyWith(isLoading: false, error: "Description is required.");
      return false;
    }

    try {
      // Simulate API Call to create job
      await Future.delayed(const Duration(seconds: 1)); // Replace with actual API

      // On Success
      state = state.copyWith(
        isLoading: false,
        status: 'open',
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const JobPostingState();
  }
}

// 🔌 PROVIDER
final jobPostingProvider = NotifierProvider<JobPostingNotifier, JobPostingState>(() {
  return JobPostingNotifier();
});
