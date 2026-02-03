import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🎯 STATE: Tracks the live status of the job execution
class JobExecutionState {
  final bool isLoading;
  final String? error;
  
  // Job Context
  final String? jobId;
  final String status; // 'assigned', 'in_progress', 'paused', 'completed'
  
  // Step 9: Secure Start
  final bool isJobStarted; 
  final DateTime? startTime;
  
  // Step 10: Execution & Timer
  final Duration elapsedDuration;
  final bool isPaused;
  final List<String> activityLog;    // Immutable logs
  final List<String> materialsAdded; // Placeholder for Phase 8

  // Step 11: Completion
  final File? completionProof;
  final bool isDisputeOpen;

  const JobExecutionState({
    this.isLoading = false,
    this.error,
    this.jobId,
    this.status = 'assigned',
    this.isJobStarted = false,
    this.startTime,
    this.elapsedDuration = Duration.zero,
    this.isPaused = false,
    this.activityLog = const [],
    this.materialsAdded = const [],
    this.completionProof,
    this.isDisputeOpen = false,
  });

  JobExecutionState copyWith({
    bool? isLoading,
    String? error,
    String? jobId,
    String? status,
    bool? isJobStarted,
    DateTime? startTime,
    Duration? elapsedDuration,
    bool? isPaused,
    List<String>? activityLog,
    List<String>? materialsAdded,
    File? completionProof,
    bool? isDisputeOpen,
  }) {
    return JobExecutionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      isJobStarted: isJobStarted ?? this.isJobStarted,
      startTime: startTime ?? this.startTime,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      isPaused: isPaused ?? this.isPaused,
      activityLog: activityLog ?? this.activityLog,
      materialsAdded: materialsAdded ?? this.materialsAdded,
      completionProof: completionProof ?? this.completionProof,
      isDisputeOpen: isDisputeOpen ?? this.isDisputeOpen,
    );
  }
}

// 🎮 NOTIFIER: Logic for Job Execution (Timer, OTP, Logs)
class JobExecutionNotifier extends Notifier<JobExecutionState> {
  Timer? _timer;

  @override
  JobExecutionState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const JobExecutionState();
  }

  // Step 9: Secure Start with OTP
  Future<bool> startJobWithOTP(String inputOtp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // API Verification with OTP
      await Future.delayed(const Duration(seconds: 1)); // Mock
      
      if (inputOtp == "123456") { // Mock check
        _startTimer();
        state = state.copyWith(
          isLoading: false,
          status: 'in_progress',
          isJobStarted: true,
          startTime: DateTime.now(),
          activityLog: [...state.activityLog, "Job Started at ${DateTime.now()}"],
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: "Invalid OTP");
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Step 10: Timer Logic
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused) {
        state = state.copyWith(
          elapsedDuration: state.elapsedDuration + const Duration(seconds: 1),
        );
      }
    });
  }

  void pauseJob() {
    if (state.status != 'in_progress') return;
    
    _timer?.cancel();
    state = state.copyWith(
      isPaused: true,
      status: 'paused',
      activityLog: [...state.activityLog, "Job Paused at ${DateTime.now()}"],
    );
  }

  void resumeJob() {
    if (state.status != 'paused') return;
    
    _startTimer();
    state = state.copyWith(
      isPaused: false,
      status: 'in_progress',
      activityLog: [...state.activityLog, "Job Resumed at ${DateTime.now()}"],
    );
  }

  // Step 11: Completion
  Future<bool> completeJob(File proof) async {
    _timer?.cancel();
    state = state.copyWith(isLoading: true);
    
    try {
      // API Upload Proof
      await Future.delayed(const Duration(seconds: 1)); 

      state = state.copyWith(
        isLoading: false,
        status: 'completed',
        completionProof: proof,
        activityLog: [...state.activityLog, "Job Completed at ${DateTime.now()}"],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Manual cleanup hook provided by Notifier mainly for keepAlive but we can rely on GC or ref.onDispose
  // For timers, it's best to use ref.onDispose
}

// 🔌 PROVIDER (Shared for both Worker and Tenant View)
final jobExecutionProvider = NotifierProvider<JobExecutionNotifier, JobExecutionState>(() {
  return JobExecutionNotifier();
});
