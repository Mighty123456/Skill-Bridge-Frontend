import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotationSelectionState {
  final bool isLoading;
  final String? error;
  
  // Step 7: Viewing List
  final List<Map<String, dynamic>> quotations;
  final String? selectedQuotationId;
  final bool isSelectionLocked;

  const QuotationSelectionState({
    this.isLoading = false,
    this.error,
    this.quotations = const [],
    this.selectedQuotationId,
    this.isSelectionLocked = false,
  });

  QuotationSelectionState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? quotations,
    String? selectedQuotationId,
    bool? isSelectionLocked,
  }) {
    return QuotationSelectionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      quotations: quotations ?? this.quotations,
      selectedQuotationId: selectedQuotationId ?? this.selectedQuotationId,
      isSelectionLocked: isSelectionLocked ?? this.isSelectionLocked,
    );
  }
}

class QuotationSelectionNotifier extends Notifier<QuotationSelectionState> {
  @override
  QuotationSelectionState build() {
    return const QuotationSelectionState();
  }

  Future<void> loadQuotations(String jobId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // API Simulate: Fetch quotes for this job
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockQuotes = [
        {
          'id': 'q1',
          'workerName': 'Rajesh Kumar',
          'price': 450.0,
          'timeline': 2, // days
          'hasVideo': true,
          'rating': 4.8,
        },
        {
          'id': 'q2',
          'workerName': 'Anil Singh',
          'price': 400.0,
          'timeline': 3,
          'hasVideo': false,
          'rating': 4.5,
        },
      ];
      
      state = state.copyWith(isLoading: false, quotations: mockQuotes);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Step 7: Select & Lock
  Future<bool> selectQuotation(String quotationId) async {
    if (state.isSelectionLocked) return false;

    state = state.copyWith(isLoading: true);
    try {
      // API call to confirm selection
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        isLoading: false,
        selectedQuotationId: quotationId,
        isSelectionLocked: true, // Lock others
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final quotationSelectionProvider = NotifierProvider<QuotationSelectionNotifier, QuotationSelectionState>(() {
  return QuotationSelectionNotifier();
});
