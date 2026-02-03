import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_service.dart';
import 'auth_provider.dart';

// 🎯 STATE: Holds all the data for Phase 1 (Worker Identity)
class WorkerRegistrationState {
  final bool isLoading;
  final String? error;
  final int currentStep; // 0: Basic Info, 1: Documents & Skills, 2: Submission

  // Step 1: Basic Info & Geolocation
  final String name;
  final String email;
  final String phone;
  final double? latitude;
  final double? longitude;

  // Step 2: Documents & Skills
  final File? idProof;       // For Cloudinary upload
  final File? selfie;        // Live selfie
  final List<String> selectedSkills;
  final List<File> workHistory; // Photos/Videos

  // Identity Status (The core of Phase 1)
  final String status; // 'incomplete', 'pending', 'verified', 'rejected'

  const WorkerRegistrationState({
    this.isLoading = false,
    this.error,
    this.currentStep = 0,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.latitude,
    this.longitude,
    this.idProof,
    this.selfie,
    this.selectedSkills = const [],
    this.workHistory = const [],
    this.status = 'incomplete',
  });

  WorkerRegistrationState copyWith({
    bool? isLoading,
    String? error,
    int? currentStep,
    String? name,
    String? email,
    String? phone,
    double? latitude,
    double? longitude,
    File? idProof,
    File? selfie,
    List<String>? selectedSkills,
    List<File>? workHistory,
    String? status,
  }) {
    return WorkerRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Clear error on new state change unless explicitly set
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      idProof: idProof ?? this.idProof,
      selfie: selfie ?? this.selfie,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      workHistory: workHistory ?? this.workHistory,
      status: status ?? this.status,
    );
  }
}

// 🎮 NOTIFIER: Logic for Phase 1 Flow
class WorkerRegistrationNotifier extends Notifier<WorkerRegistrationState> {
  late final AuthService _authService;

  @override
  WorkerRegistrationState build() {
    _authService = ref.read(authServiceProvider);
    return const WorkerRegistrationState();
  }

  // ——— STEP 1: Basic Info ———
  void updateBasicInfo({String? name, String? email, String? phone}) {
    state = state.copyWith(
      name: name ?? state.name,
      email: email ?? state.email,
      phone: phone ?? state.phone,
    );
  }

  void setLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng);
  }

  // ——— STEP 2: Documents & Skills ———
  void setFiles({File? idProof, File? selfie}) {
    state = state.copyWith(
      idProof: idProof ?? state.idProof,
      selfie: selfie ?? state.selfie,
    );
  }

  void toggleSkill(String skill) {
    final currentSkills = List<String>.from(state.selectedSkills);
    if (currentSkills.contains(skill)) {
      currentSkills.remove(skill);
    } else {
      currentSkills.add(skill);
    }
    state = state.copyWith(selectedSkills: currentSkills);
  }

  void addWorkHistoryFile(File file) {
    state = state.copyWith(workHistory: [...state.workHistory, file]);
  }

  // ——— NAVIGATION & SUBMISSION ———
  
  // Move to next step only if validation passes
  bool nextStep() {
    if (state.currentStep == 0) {
      if (state.name.isEmpty || state.email.isEmpty || state.phone.isEmpty) {
        state = state.copyWith(error: "Please fill all basic details.");
        return false;
      }
    } else if (state.currentStep == 1) {
       if (state.idProof == null || state.selfie == null) {
         state = state.copyWith(error: "ID Proof and Live Selfie are mandatory.");
         return false;
       }
       if (state.selectedSkills.isEmpty) {
         state = state.copyWith(error: "Please select at least one skill.");
         return false;
       }
    }

    state = state.copyWith(currentStep: state.currentStep + 1, error: null);
    return true;
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, error: null);
    }
  }

  // Final API Call Simulate
  Future<bool> submitRegistration(String password, DateTime dob, Map<String, dynamic> address) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.register(
        email: state.email,
        password: password, // Passed from UI
        role: 'worker',
        name: state.name,
        phone: state.phone,
        dateOfBirth: dob,
        address: address, // Can be refined to be part of state if needed
        skills: state.selectedSkills,
        experience: 5, // Placeholder or add to state
        governmentId: state.idProof,
        selfie: state.selfie,
      );

      state = state.copyWith(isLoading: false);

      if (result['success'] == true) {
        state = state.copyWith(status: 'pending');
        return true;
      } else {
        state = state.copyWith(error: result['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

// 🔌 PROVIDER: global access point
final workerRegistrationProvider = NotifierProvider<WorkerRegistrationNotifier, WorkerRegistrationState>(() {
  return WorkerRegistrationNotifier();
});
