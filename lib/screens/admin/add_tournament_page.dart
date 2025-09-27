import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tournament.dart';
import '../../utils/app_theme.dart';
import '../../widgets/image_upload_widget.dart';
import '../../services/tournament_service.dart';

class AddTournamentPage extends StatefulWidget {
  final Function(Tournament)? onTournamentCreated;

  const AddTournamentPage({super.key, this.onTournamentCreated});

  @override
  State<AddTournamentPage> createState() => _AddTournamentPageState();
}

class _AddTournamentPageState extends State<AddTournamentPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _imageUrlController =
      TextEditingController(); // Keep for backward compatibility
  final _organizerController = TextEditingController();
  final _rulesController = TextEditingController();
  final _prizesController = TextEditingController();
  final _contactController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationDeadline;
  String? _selectedCategory;
  TournamentFormat _selectedFormat = TournamentFormat.singleElimination;
  TournamentMode _selectedMode = TournamentMode.online;

  // Image handling
  XFile? _selectedImage;
  String _imageUrl = '';

  // Tournament service
  final TournamentService _tournamentService = TournamentService();

  final List<String> _availableCategories = [
    'E-Sports',
    'Gaming',
    'Sports',
    'Academic',
    'Technology',
    'Creative',
    'Strategy',
    'Action',
    'Battle Royale',
    'MOBA',
    'FPS',
    'Racing',
    'Puzzle',
    'Card Games',
    'Board Games',
    'Mobile Gaming',
    'PC Gaming',
    'Console Gaming',
    'PUBG Mobile',
    'Free Fire',
    'Call of Duty Mobile',
    'Valorant',
    'Counter-Strike',
    'League of Legends',
    'Dota 2',
    'Fortnite',
    'Apex Legends',
    'Chess',
    'Cricket',
    'Football',
    'Basketball',
    'Tennis',
    'Badminton',
    'Table Tennis',
    'Swimming',
    'Athletics',
    'Coding Competition',
    'Hackathon',
    'Quiz Competition',
    'Debate',
    'Art Competition',
    'Photography',
    'Writing Competition',
    'Music Competition',
  ];

  bool _isLoading = false;
  int _currentStep = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _entryFeeController.dispose();
    _maxParticipantsController.dispose();
    _imageUrlController.dispose();
    _organizerController.dispose();
    _rulesController.dispose();
    _prizesController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create Tournament',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDarkColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppTheme.primaryColor.withOpacity(0.1),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _validateAndSubmit,
              icon: const Icon(Icons.save_alt, color: AppTheme.primaryColor),
              label: const Text(
                'Create',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: AppTheme.primaryColor),
              ),
              child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        if (details.stepIndex > 0)
                          OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (details.stepIndex < 3)
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Next'),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _validateAndSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.create),
                            label: Text(
                              _isLoading ? 'Creating...' : 'Create Tournament',
                            ),
                          ),
                      ],
                    ),
                  );
                },
                steps: [
                  // Step 1: Basic Information
                  Step(
                    title: const Text('Basic Information'),
                    content: _buildBasicInfoStep(),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                  ),

                  // Step 2: Tournament Details
                  Step(
                    title: const Text('Tournament Details'),
                    content: _buildTournamentDetailsStep(),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
                        ? StepState.complete
                        : _currentStep == 1
                        ? StepState.indexed
                        : StepState.disabled,
                  ),

                  // Step 3: Schedule & Registration
                  Step(
                    title: const Text('Schedule & Registration'),
                    content: _buildScheduleStep(),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2
                        ? StepState.complete
                        : _currentStep == 2
                        ? StepState.indexed
                        : StepState.disabled,
                  ),

                  // Step 4: Additional Information
                  Step(
                    title: const Text('Additional Information'),
                    content: _buildAdditionalInfoStep(),
                    isActive: _currentStep >= 3,
                    state: _currentStep == 3
                        ? StepState.indexed
                        : StepState.disabled,
                  ),
                ],
                onStepContinue: () {
                  if (_currentStep < 3) {
                    if (_validateCurrentStep()) {
                      setState(() => _currentStep++);
                    }
                  } else {
                    _validateAndSubmit();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedCard([
          _buildTextFormField(
            controller: _nameController,
            label: 'Tournament Name',
            icon: Icons.emoji_events,
            hint: 'Enter tournament name',
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter tournament name' : null,
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _descriptionController,
            label: 'Description',
            icon: Icons.description,
            hint: 'Enter tournament description',
            maxLines: 4,
            maxLength: 500,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter description' : null,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _organizerController,
            label: 'Organizer',
            icon: Icons.person_outline,
            hint: 'Enter organizer name',
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter organizer name' : null,
          ),
        ]),

        const SizedBox(height: 16),

        _buildAnimatedCard([_buildCategorySelection()]),
      ],
    );
  }

  Widget _buildTournamentDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedCard([
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _entryFeeController,
                  label: 'Entry Fee (₹)',
                  icon: Icons.currency_rupee,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter entry fee' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFormField(
                  controller: _maxParticipantsController,
                  label: 'Max Participants',
                  icon: Icons.group,
                  hint: '100',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter max participants'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormatSelection(),
          const SizedBox(height: 16),
          _buildModeSelection(),
        ]),

        const SizedBox(height: 16),

        _buildAnimatedCard([
          _buildTextFormField(
            controller: _locationController,
            label: 'Location/Platform',
            icon: Icons.location_on,
            hint: 'Enter venue or platform details',
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter location' : null,
          ),
          const SizedBox(height: 16),
          ImageUploadWidget(
            label: 'Tournament Image',
            hint: 'Upload an image or enter URL',
            isRequired: true,
            onImageSelected: (image) {
              setState(() {
                _selectedImage = image;
                if (image != null) {
                  _imageUrl = ''; // Clear URL when image is selected
                }
              });
            },
            onImageUrlChanged: (url) {
              setState(() {
                _imageUrl = url;
                if (url.isNotEmpty) {
                  _selectedImage = null; // Clear image when URL is entered
                }
              });
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildScheduleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedCard([
          _buildDateSelector(
            'Start Date & Time',
            _startDate,
            (date) => setState(() => _startDate = date),
            Icons.event_available,
          ),
          const SizedBox(height: 16),
          _buildDateSelector(
            'End Date & Time',
            _endDate,
            (date) => setState(() => _endDate = date),
            Icons.event_busy,
          ),
          const SizedBox(height: 16),
          _buildDateSelector(
            'Registration Deadline',
            _registrationDeadline,
            (date) => setState(() => _registrationDeadline = date),
            Icons.access_time,
          ),
        ]),
      ],
    );
  }

  Widget _buildAdditionalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedCard([
          _buildTextFormField(
            controller: _rulesController,
            label: 'Tournament Rules',
            icon: Icons.rule,
            hint: 'Enter tournament rules and regulations',
            maxLines: 5,
            maxLength: 1000,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _prizesController,
            label: 'Prizes & Rewards',
            icon: Icons.emoji_events,
            hint: 'Enter prize distribution details',
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _contactController,
            label: 'Contact Information',
            icon: Icons.contact_phone,
            hint: 'Enter contact details for queries',
            maxLines: 2,
            maxLength: 200,
          ),
        ]),
      ],
    );
  }

  Widget _buildAnimatedCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        counterText: maxLength != null ? null : '',
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tournament Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Category',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              icon: Container(
                margin: const EdgeInsets.only(right: 16),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDarkColor,
              ),
              items: _availableCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDarkColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return _availableCategories.map<Widget>((String value) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDarkColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList();
              },
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a tournament category';
                }
                return null;
              },
              isExpanded: true,
              isDense: false,
              menuMaxHeight: 400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tournament Format',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        ...TournamentFormat.values.map((format) {
          return RadioListTile<TournamentFormat>(
            title: Text(_formatToString(format)),
            value: format,
            groupValue: _selectedFormat,
            onChanged: (value) => setState(() => _selectedFormat = value!),
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tournament Mode',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: TournamentMode.values.map((mode) {
            final isSelected = _selectedMode == mode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(
                      _modeToString(mode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedMode = mode),
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.primaryColor,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => _selectDateTime(context, selectedDate, onDateSelected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? _formatDateTime(selectedDate)
                        : 'Select $label',
                    style: TextStyle(
                      color: selectedDate != null
                          ? AppTheme.textDarkColor
                          : Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: selectedDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onSelected,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: AppTheme.primaryColor),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onSelected(dateTime);
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            _organizerController.text.isNotEmpty &&
            _selectedCategory != null &&
            _selectedCategory!.isNotEmpty;
      case 1:
        return _entryFeeController.text.isNotEmpty &&
            _maxParticipantsController.text.isNotEmpty &&
            _locationController.text.isNotEmpty &&
            (_selectedImage != null || _imageUrl.isNotEmpty);
      case 2:
        return _startDate != null &&
            _endDate != null &&
            _registrationDeadline != null;
      case 3:
        return true; // Additional info is optional
      default:
        return false;
    }
  }

  void _validateAndSubmit() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null ||
        _registrationDeadline == null ||
        _selectedCategory == null ||
        _selectedCategory!.isEmpty ||
        (_selectedImage == null && _imageUrl.isEmpty)) {
      _showErrorSnackBar(
        'Please fill all required fields and select/upload an image',
      );
      return;
    }

    if (_startDate!.isBefore(DateTime.now())) {
      _showErrorSnackBar('Start date must be in the future');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showErrorSnackBar('End date must be after start date');
      return;
    }

    if (_registrationDeadline!.isAfter(_startDate!)) {
      _showErrorSnackBar('Registration deadline must be before start date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create tournament object
      final tournament = Tournament(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        entryFee: double.parse(_entryFeeController.text),
        maxParticipants: int.parse(_maxParticipantsController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        registrationDeadline: _registrationDeadline!,
        imageUrl: _imageUrl.isNotEmpty ? _imageUrl : null,
        status: TournamentStatus.upcoming,
        organizer: _organizerController.text.trim(),
        categories: _selectedCategory != null ? [_selectedCategory!] : [],
        format: _selectedFormat,
        mode: _selectedMode,
        rules: _rulesController.text.isNotEmpty
            ? _rulesController.text.trim()
            : null,
        prizes: _prizesController.text.isNotEmpty
            ? _prizesController.text.trim()
            : null,
        contactInfo: _contactController.text.isNotEmpty
            ? _contactController.text.trim()
            : null,
      );

      // Create tournament using TournamentService
      final tournamentId = await _tournamentService.createTournament(
        tournament: tournament,
        imageFile: _selectedImage,
      );

      print('Tournament created with ID: $tournamentId');

      // Call callback if provided
      widget.onTournamentCreated?.call(tournament);

      if (mounted) {
        _showSuccessSnackBar('Tournament created successfully!');
        Navigator.of(context).pop(tournament);
      }
    } catch (e) {
      print('Error creating tournament: $e');
      _showErrorSnackBar('Failed to create tournament: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatToString(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.singleElimination:
        return 'Single Elimination';
      case TournamentFormat.doubleElimination:
        return 'Double Elimination';
      case TournamentFormat.roundRobin:
        return 'Round Robin';
      case TournamentFormat.swiss:
        return 'Swiss System';
    }
  }

  String _modeToString(TournamentMode mode) {
    switch (mode) {
      case TournamentMode.online:
        return 'Online';
      case TournamentMode.offline:
        return 'Offline';
      case TournamentMode.hybrid:
        return 'Hybrid';
    }
  }
}
