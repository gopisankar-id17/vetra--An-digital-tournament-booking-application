import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tournament.dart';
import '../../utils/app_theme.dart';
import '../../widgets/image_upload_widget.dart';
import '../../services/organizer_service.dart';
import '../../services/tournament_service.dart';
import '../../services/session_service.dart';

class OrganizerAddTournamentPage extends StatefulWidget {
  final Function(Tournament)? onTournamentCreated;

  const OrganizerAddTournamentPage({super.key, this.onTournamentCreated});

  @override
  State<OrganizerAddTournamentPage> createState() =>
      _OrganizerAddTournamentPageState();
}

class _OrganizerAddTournamentPageState extends State<OrganizerAddTournamentPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _imageUrlController = TextEditingController();
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
  XFile? _selectedImageFile;

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    _loadOrganizerData();
  }

  Future<void> _loadOrganizerData() async {
    try {
      final organizerData = await SessionService.getOrganizerSession();
      if (organizerData['name'] != null) {
        setState(() {
          _organizerController.text = organizerData['name']!;
          _contactController.text = organizerData['email'] ?? '';
        });
      }
    } catch (e) {
      // Handle error silently
    }
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
      appBar: AppBar(
        title: const Text(
          'Create New Tournament',
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
                        if (details.stepIndex < 3)
                          ElevatedButton.icon(
                            onPressed: details.onStepContinue,
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Next'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (details.stepIndex > 0)
                          OutlinedButton.icon(
                            onPressed: details.onStepCancel,
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _descriptionController,
            label: 'Description',
            icon: Icons.description,
            hint: 'Enter tournament description',
            maxLines: 3,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter description' : null,
          ),
        ]),

        const SizedBox(height: 16),

        _buildAnimatedCard([
          _buildTextFormField(
            controller: _locationController,
            label: 'Location/Platform',
            icon: Icons.location_on,
            hint: 'Enter location or platform name',
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter location' : null,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _organizerController,
            label: 'Organizer Name',
            icon: Icons.person,
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
          ImageUploadWidget(
            onImageSelected: (imagePath) {
              setState(() {
                _selectedImageFile = imagePath;
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
          _buildDateField(
            'Registration Deadline',
            _registrationDeadline,
            Icons.event_available,
            (date) => setState(() => _registrationDeadline = date),
            validator: () => _registrationDeadline == null
                ? 'Please select registration deadline'
                : null,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            'Tournament Start Date',
            _startDate,
            Icons.play_circle_outline,
            (date) => setState(() => _startDate = date),
            validator: () =>
                _startDate == null ? 'Please select start date' : null,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            'Tournament End Date',
            _endDate,
            Icons.stop_circle_outlined,
            (date) => setState(() => _endDate = date),
            validator: () => _endDate == null ? 'Please select end date' : null,
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
            maxLines: 4,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter tournament rules' : null,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _prizesController,
            label: 'Prizes & Rewards',
            icon: Icons.card_giftcard,
            hint: 'Enter prize details',
            maxLines: 3,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter prize details' : null,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _contactController,
            label: 'Contact Information',
            icon: Icons.contact_mail,
            hint: 'Enter contact details',
            validator: (value) => value?.isEmpty ?? true
                ? 'Please enter contact information'
                : null,
          ),
        ]),
      ],
    );
  }

  Widget _buildAnimatedCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              items: _availableCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
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
            title: Text(_getFormatDisplayName(format)),
            value: format,
            groupValue: _selectedFormat,
            onChanged: (value) => setState(() => _selectedFormat = value!),
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          );
        }),
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
        ...TournamentMode.values.map((mode) {
          return RadioListTile<TournamentMode>(
            title: Text(_getModeDisplayName(mode)),
            value: mode,
            groupValue: _selectedMode,
            onChanged: (value) => setState(() => _selectedMode = value!),
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    IconData icon,
    Function(DateTime?) onDateSelected, {
    String? Function()? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDarkColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : 'Select $label',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedDate != null
                        ? AppTheme.textDarkColor
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (validator != null && validator() != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              validator()!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  String _getFormatDisplayName(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.singleElimination:
        return 'Single Elimination';
      case TournamentFormat.doubleElimination:
        return 'Double Elimination';
      case TournamentFormat.roundRobin:
        return 'Round Robin';
      case TournamentFormat.swiss:
        return 'Swiss';
    }
  }

  String _getModeDisplayName(TournamentMode mode) {
    switch (mode) {
      case TournamentMode.online:
        return 'Online';
      case TournamentMode.offline:
        return 'Offline';
      case TournamentMode.hybrid:
        return 'Hybrid';
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            _locationController.text.isNotEmpty &&
            _organizerController.text.isNotEmpty &&
            _selectedCategory != null;
      case 1:
        return _entryFeeController.text.isNotEmpty &&
            _maxParticipantsController.text.isNotEmpty;
      case 2:
        return _registrationDeadline != null &&
            _startDate != null &&
            _endDate != null;
      case 3:
        return _rulesController.text.isNotEmpty &&
            _prizesController.text.isNotEmpty &&
            _contactController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _validateAndSubmit() async {
    if (!_formKey.currentState!.validate() || !_validateAllSteps()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current organizer
      final organizerData = await SessionService.getOrganizerSession();

      if (organizerData['id'] == null || organizerData['id']!.isEmpty) {
        throw Exception('Organizer session not found');
      }

      // Get organizer information first
      final organizer = await OrganizerService.getOrganizerById(
        organizerData['id']!,
      );
      if (organizer == null) {
        throw Exception('Organizer not found');
      }

      // Create tournament object with organizer info
      final tournament = Tournament(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categories: [_selectedCategory!],
        format: _selectedFormat,
        mode: _selectedMode,
        maxParticipants: int.parse(_maxParticipantsController.text),
        currentParticipants: 0,
        entryFee: double.parse(_entryFeeController.text),
        location: _locationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        registrationDeadline: _registrationDeadline!,
        organizer: organizer.organizationName,
        organizerId: organizerData['id']!,
        organizerName: organizer.organizationName,
        status: TournamentStatus.upcoming,
        rules: _rulesController.text.trim(),
        prizes: _prizesController.text.trim(),
        contactInfo: _contactController.text.trim().isNotEmpty
            ? _contactController.text.trim()
            : organizer.email,
        imageUrl: null, // Will be set by TournamentService if image is uploaded
        ticketTypes: {'General': double.parse(_entryFeeController.text)},
        participantsCount: 0,
        prizePool: 0.0,
        organizerPhotoUrl: '',
        organizerPastTournaments: 0,
        startTime:
            '${_startDate!.hour.toString().padLeft(2, '0')}:${_startDate!.minute.toString().padLeft(2, '0')}',
      );

      // Save tournament using TournamentService with image upload
      final tournamentService = TournamentService();
      final tournamentId = await tournamentService.createTournament(
        tournament: tournament,
        imageFile: _selectedImageFile,
      );

      // Add tournament to organizer's tournament list
      final addResult = await OrganizerService.addTournamentToOrganizer(
        organizerData['id']!,
        tournamentId,
      );

      if (!addResult) {
        // Log warning but don't fail the operation
      }

      if (tournamentId.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tournament created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Call callback if provided
          if (widget.onTournamentCreated != null) {
            final updatedTournament = Tournament(
              id: tournamentId,
              name: tournament.name,
              description: tournament.description,
              categories: tournament.categories,
              format: tournament.format,
              mode: tournament.mode,
              maxParticipants: tournament.maxParticipants,
              currentParticipants: tournament.currentParticipants,
              entryFee: tournament.entryFee,
              location: tournament.location,
              startDate: tournament.startDate,
              endDate: tournament.endDate,
              registrationDeadline: tournament.registrationDeadline,
              organizer: tournament.organizer,
              organizerId: tournament.organizerId,
              status: tournament.status,
              rules: tournament.rules,
              prizes: tournament.prizes,
              contactInfo: tournament.contactInfo,
              imageUrl: tournament.imageUrl,
              ticketTypes: tournament.ticketTypes,
              participantsCount: tournament.participantsCount,
              prizePool: tournament.prizePool,
              organizerPhotoUrl: tournament.organizerPhotoUrl,
              organizerPastTournaments: tournament.organizerPastTournaments,
              startTime: tournament.startTime,
            );
            widget.onTournamentCreated!(updatedTournament);
          }

          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Failed to create tournament');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating tournament: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateAllSteps() {
    for (int i = 0; i <= 3; i++) {
      final currentStep = _currentStep;
      _currentStep = i;
      if (!_validateCurrentStep()) {
        _currentStep = currentStep;
        return false;
      }
    }
    _currentStep = 3; // Set to last step after validation
    return true;
  }
}
