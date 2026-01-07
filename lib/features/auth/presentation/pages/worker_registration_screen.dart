import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../data/auth_service.dart';
import 'otp_verification_screen.dart';
import '../../../../widgets/custom_feedback_popup.dart';


class WorkerRegistrationScreen extends StatefulWidget {
  const WorkerRegistrationScreen({super.key});

  static const routeName = '/register/worker';

  @override
  State<WorkerRegistrationScreen> createState() => _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends State<WorkerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _fullNameController = TextEditingController();
  DateTime? _dateOfBirth;
  final _phoneController = TextEditingController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isLocationLoading = false;


  File? _governmentIdFile;
  File? _selfieFile;

  final _currentAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  double? _latitude;
  double? _longitude;

  String? _primarySkill;
  final _experienceController = TextEditingController();

  final List<String> _skills = [
    'Plumber',
    'Electrician',
    'Driver',
    'Carpenter',
    'Painter',
    'Mason',
    'Welder',
    'Mechanic',
    'AC Technician',
    'Appliance Repair',
    'Other',
  ];

  final List<String> _idTypes = [
    'Aadhar Card',
    'Passport',
    'Voter ID',
    'Driving License',
  ];
  String? _selectedIdType;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _currentAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _experienceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _isLocationLoading = false);
        CustomFeedbackPopup.show(
          context,
          title: 'Location Disabled',
          message: 'Please enable location services to continue',
          type: FeedbackType.error,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() => _isLocationLoading = false);
          CustomFeedbackPopup.show(
            context,
            title: 'Permission Denied',
            message: 'Location permissions are required for registration',
            type: FeedbackType.error,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _isLocationLoading = false);
        CustomFeedbackPopup.show(
          context,
          title: 'Need Permission',
          message: 'Please enable location permissions in settings',
          type: FeedbackType.info,
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLocationLoading = false;
      });

      if (!mounted) return;
      CustomFeedbackPopup.show(
        context,
        title: 'Location Captured',
        message: 'Your current location has been successfully detected',
        type: FeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLocationLoading = false);
      CustomFeedbackPopup.show(
        context,
        title: 'Location Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _pickImage(ImageSource source, bool isSelfie) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        if (isSelfie) {
          _selfieFile = File(image.path);
        } else {
          _governmentIdFile = File(image.path);
        }
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _governmentIdFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (!mounted) return;
      CustomFeedbackPopup.show(
        context,
        title: 'Selection Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.colors.primary,
              onPrimary: AppTheme.colors.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_governmentIdFile == null) {
      CustomFeedbackPopup.show(
        context,
        title: 'ID Required',
        message: 'Please upload a government ID for verification',
        type: FeedbackType.error,
      );
      return;
    }
    if (_selfieFile == null) {
      CustomFeedbackPopup.show(
        context,
        title: 'Selfie Required',
        message: 'Please take a selfie for identity verification',
        type: FeedbackType.error,
      );
      return;
    }
    if (_latitude == null || _longitude == null) {
      CustomFeedbackPopup.show(
        context,
        title: 'Location Required',
        message: 'Please capture your location to register',
        type: FeedbackType.error,
      );
      return;
    }
    if (_primarySkill == null) {
      CustomFeedbackPopup.show(
        context,
        title: 'Skill Required',
        message: 'Please select your primary skill to proceed',
        type: FeedbackType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final address = {
        'street': _currentAddressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'coordinates': {
          'latitude': _latitude,
          'longitude': _longitude,
        },
      };

      final List<String> skills = _primarySkill != null ? [_primarySkill!] : [];
      final experience = int.tryParse(_experienceController.text.trim());

      final result = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'worker', 
        name: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        address: address,
        skills: skills,
        experience: experience,
        governmentId: _governmentIdFile,
        selfie: _selfieFile,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        CustomFeedbackPopup.show(
          context,
          title: 'Welcome Aboard!',
          message: result['message'] ?? 'Registration successful!',
          type: FeedbackType.success,
          onConfirm: () {
            // Navigate to OTP Verification
            Navigator.of(context).pushNamed(
              OTPVerificationScreen.routeName,
              arguments: {
                'email': _emailController.text.trim(),
                'flowType': 'registration',
              },
            );
          },
        );
      } else {
        CustomFeedbackPopup.show(
          context,
          title: 'Registration Failed',
          message: result['message'] ?? 'Please check your details and try again.',
          type: FeedbackType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomFeedbackPopup.show(
        context,
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Join as Worker',
          style: TextStyle(
            color: AppTheme.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppTheme.colors.primary),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.colors.surface,
              AppTheme.colors.jobCardSecondary.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionCard(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  children: [
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter your legal name',
                      icon: Icons.person_outline,
                      validator: (value) => 
                        value == null || value.isEmpty ? 'Please enter your full name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Date of Birth',
                      value: _dateOfBirth,
                      onTap: _selectDateOfBirth,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Contact Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                        value != null && value.length < 10 ? 'Enter valid number' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                        value == null || !value.contains('@') ? 'Enter valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a password',
                      icon: Icons.lock_outline,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppTheme.colors.primary,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      validator: (value) =>
                         value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildSectionCard(
                  title: 'Skills & Experience',
                  icon: Icons.work_outline,
                  children: [
                    _buildDropdown(
                      label: 'Primary Skill',
                      value: _primarySkill,
                      items: _skills,
                      onChanged: (val) => setState(() => _primarySkill = val),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _experienceController,
                      label: 'Experience (Years)',
                      hint: 'e.g. 5',
                      icon: Icons.history_edu_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                         value == null || value.isEmpty ? 'Enter experience' : null,
                    ),
                  ],
                ),
                 const SizedBox(height: 24),

                _buildSectionCard(
                  title: 'Address & Location',
                  icon: Icons.location_on_outlined,
                  children: [
                    _buildTextField(
                      controller: _currentAddressController,
                      label: 'Current Address',
                      hint: 'Full residential address',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                      validator: (value) =>
                         value == null || value.isEmpty ? 'Enter address' : null,
                    ),
                    _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Enter your city',
                      icon: Icons.location_city_outlined,
                      validator: (value) =>
                         value == null || value.isEmpty ? 'Enter city' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'Enter your state',
                      icon: Icons.map_outlined,
                      validator: (value) =>
                         value == null || value.isEmpty ? 'Enter state' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      hint: 'Postal code',
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                        value == null || value.isEmpty ? 'Enter pincode' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLocationButton(),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionCard(
                  title: 'Verification',
                  icon: Icons.verified_user_outlined,
                  children: [
                    _buildDropdown(
                      label: 'ID Type',
                      value: _selectedIdType,
                      items: _idTypes,
                      onChanged: (val) => setState(() => _selectedIdType = val),
                    ),
                     const SizedBox(height: 16),
                      _buildFileUpload(
                        label: 'Upload ID Proof',
                        file: _governmentIdFile,
                        onCameraTap: () => _pickImage(ImageSource.camera, false),
                        onGalleryTap: () => _pickImage(ImageSource.gallery, false),
                        onDocumentTap: _pickDocument,
                        onRemove: () => setState(() => _governmentIdFile = null),
                        icon: Icons.assignment_ind_outlined,
                      ),
                    const SizedBox(height: 16),
                      _buildFileUpload(
                        label: 'Take a Selfie',
                        file: _selfieFile,
                        onCameraTap: () => _pickImage(ImageSource.camera, true),
                        onGalleryTap: () => _pickImage(ImageSource.gallery, true),
                        onRemove: () => setState(() => _selfieFile = null),
                        icon: Icons.camera_front_outlined,
                      ),
                  ],
                ),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: AppTheme.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 4,
                    shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppTheme.colors.primary.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.colors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: AppTheme.colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.colors.onSurface.withValues(alpha: 0.4)),
        prefixIcon: Icon(icon, color: AppTheme.colors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.colors.jobCardSecondary.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.colors.primary),
          filled: true,
          fillColor: AppTheme.colors.jobCardSecondary.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Select date',
          style: TextStyle(
            color: value != null ? AppTheme.colors.onSurface : AppTheme.colors.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.arrow_drop_down_circle_outlined, color: AppTheme.colors.primary),
        filled: true,
        fillColor: AppTheme.colors.jobCardSecondary.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select option' : null,
    );
  }

  Widget _buildFileUpload({
    required String label,
    required File? file,
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
    VoidCallback? onDocumentTap,
    required VoidCallback onRemove, // Added callback
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.jobCardSecondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.colors.primary.withValues(alpha: 0.3),
          style: BorderStyle.none,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colors.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (file != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.colors.success.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppTheme.colors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.colors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove, // Call the remove callback
                    icon: const Icon(Icons.close, size: 20),
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCameraTap,
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGalleryTap,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (onDocumentTap != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDocumentTap,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.jobCardSecondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             children: [
               Icon(Icons.my_location, color: AppTheme.colors.primary),
               const SizedBox(width: 8),
               Text(
                 'Location',
                 style: TextStyle(
                   fontWeight: FontWeight.w600,
                   color: AppTheme.colors.onSurface.withValues(alpha: 0.8),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 12),
           if (_latitude != null)
             Container(
               padding: const EdgeInsets.all(12),
               margin: const EdgeInsets.only(bottom: 12),
               decoration: BoxDecoration(
                 color: AppTheme.colors.success.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: AppTheme.colors.success.withValues(alpha: 0.5)),
               ),
               child: Row(
                 children: [
                   Icon(Icons.check_circle_outline, color: AppTheme.colors.success, size: 20),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       'Location Detected Successfully',
                       style: TextStyle(color: AppTheme.colors.success, fontWeight: FontWeight.w500),
                     ),
                   ),
                 ],
               ),
             ),
           SizedBox(
             width: double.infinity,
             child: OutlinedButton(
                onPressed: _isLocationLoading ? null : _getCurrentLocation,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLocationLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_searching, color: AppTheme.colors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _latitude != null ? 'Update Location' : 'Detect Current Location',
                            style: TextStyle(color: AppTheme.colors.primary),
                          ),
                        ],
                      ),
              ),
           ),
        ],
      ),
    );
  }
}
