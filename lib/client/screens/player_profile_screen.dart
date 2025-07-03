import 'package:bogoballers/client/screens/notification_screen.dart';
import 'package:bogoballers/client/screens/player_document_screen.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/helpers/logout.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/services/player_services.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/theme/datime_picker.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/image_picker.dart';
import 'package:bogoballers/core/widgets/setting_menu_list.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:flutter/material.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final player = getIt<EntityState<PlayerModel>>().entity;

    return Scaffold(
      appBar: AppBar(backgroundColor: appColors.gray200),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: appColors.accent900,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              FlexibleNetworkImage(
                enableViewImageFull: true,
                isCircular: true,
                imageUrl: player?.profile_image_url,
                enableEdit: true,
                onEdit: _handleEdit,
                size: 120,
              ),
              const SizedBox(height: Sizes.spaceMd),
              SizedBox(
                child: Text(
                  player?.full_name ?? orNoData,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.fontSizeMd,
                  ),
                ),
              ),
              const SizedBox(height: Sizes.spaceMd),
              SizedBox(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.spaceLg,
                      vertical: Sizes.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.accent400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      player?.user.email ?? orNoData,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appColors.accent900,
                        fontWeight: FontWeight.w400,
                        fontSize: Sizes.fontSizeSm,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.spaceLg),
              Padding(
                padding: const EdgeInsets.all(Sizes.spaceSm),
                child: SettingsMenuList(
                  items: [
                    SettingsMenuItem(
                      icon: Icons.person,
                      label: 'Profile',
                      content: ProfileEditContent(originalPlayer: player!),
                    ),
                    SettingsMenuItem(
                      icon: Icons.person,
                      label: 'Basketball Profile',
                      content: BasketballProfileEditContent(
                        originalPlayer: player,
                      ),
                    ),
                    SettingsMenuItem(
                      icon: Icons.notifications,
                      label: 'Notifications',
                      onTap: _handleGotoNotification,
                    ),
                    SettingsMenuItem(
                      icon: Icons.file_upload_sharp,
                      label: 'Documents',
                      content: ProfileEditDocuments(originalPlayer: player),
                    ),
                    SettingsMenuItem(
                      icon: Icons.settings,
                      label: 'Account Settings',
                      onTap: () {
                        // Navigate to another screen
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.all(Sizes.spaceSm),
                child: AppButton(
                  label: "Logout",
                  onPressed: () => handleLogout(
                    context: context,
                    route: '/administrator/login/sreen',
                  ),
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGotoNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(enableBack: true),
      ),
    );
  }

  Future<String?> _handleEdit() async {
    return null;
  }
}

class ProfileEditDocuments extends StatefulWidget {
  final PlayerModel originalPlayer;
  const ProfileEditDocuments({super.key, required this.originalPlayer});

  @override
  State<ProfileEditDocuments> createState() => _ProfileEditDocumentsState();
}

class _ProfileEditDocumentsState extends State<ProfileEditDocuments> {
  final AppImagePickerController _document1 = AppImagePickerController();
  final AppImagePickerController _document2 = AppImagePickerController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppImagePicker(controller: _document1, aspectRatio: 9 / 16, width: 180),
        SizedBox(height: Sizes.spaceSm),
        AppButton(
          label: 'Select image',
          onPressed: _document1.pickImage,
          size: ButtonSize.sm,
        ),
        SizedBox(height: Sizes.spaceSm),
        AppImagePicker(controller: _document2, aspectRatio: 9 / 16, width: 180),
        SizedBox(height: Sizes.spaceSm),
        AppButton(
          label: 'Select image',
          onPressed: _document2.pickImage,
          size: ButtonSize.sm,
        ),
      ],
    );
  }
}

class ProfileEditContent extends StatefulWidget {
  final PlayerModel originalPlayer;

  const ProfileEditContent({super.key, required this.originalPlayer});

  @override
  State<ProfileEditContent> createState() => _ProfileEditContentState();
}

class _ProfileEditContentState extends State<ProfileEditContent> {
  late PlayerModel editedPlayer;

  final fullNameController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  DateTime? birthDate;

  bool isLoading = false;

  bool get hasChanges =>
      editedPlayer.toJsonForUpdate(widget.originalPlayer).isNotEmpty;

  @override
  void initState() {
    super.initState();
    editedPlayer = widget.originalPlayer;

    fullNameController.text = widget.originalPlayer.full_name;
    genderController.text = widget.originalPlayer.gender;
    addressController.text = widget.originalPlayer.player_address;
    birthDate = widget.originalPlayer.birth_date;

    fullNameController.addListener(_update);
    genderController.addListener(_update);
    addressController.addListener(_update);
  }

  void _update() {
    setState(() {
      editedPlayer = editedPlayer.copyWith(
        full_name: fullNameController.text,
        gender: genderController.text,
        player_address: addressController.text,
        birth_date: birthDate,
      );
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    genderController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: fullNameController,
          decoration: InputDecoration(
            label: Text("Full name"),
            helperText: "Format: [First Name] [Last Name]",
          ),
        ),
        const SizedBox(height: Sizes.spaceMd),

        DropdownButtonFormField<String>(
          value: genderController.text.isNotEmpty
              ? genderController.text
              : null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            label: Text("Gender"),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: const [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
          ],
          onChanged: (value) {
            if (value != null) {
              genderController.text = value;
              _update();
            }
          },
        ),
        const SizedBox(height: Sizes.spaceMd),
        DateTimePickerField(
          selectedDate: birthDate,
          labelText: "Birthdate",
          helperText: "You must be at least 4 years old to continue.",
          onChanged: (value) {
            birthDate = value;
            _update();
          },
        ),
        const SizedBox(height: Sizes.spaceMd),
        TextField(
          controller: addressController,
          decoration: InputDecoration(
            label: Text("Address"),
            helperText:
                "Format: Brgy. [Barangay], [City/Municipality], [Province]",
          ),
        ),
        const SizedBox(height: Sizes.spaceSm),

        if (hasChanges)
          AppButton(
            label: isLoading ? "Updating..." : "Save Changes",
            onPressed: _handleUpdate,
            size: ButtonSize.sm,
            isDisabled: isLoading,
          ),
      ],
    );
  }

  Future<void> _handleUpdate() async {
    try {
      setState(() => isLoading = true);
      final json = editedPlayer.toJsonForUpdate(widget.originalPlayer);
      final response = await PlayerServices.updatePlayer(
        player_id: widget.originalPlayer.player_id,
        json: json,
      );
      if (context.mounted) {
        showAppSnackbar(
          context,
          message: response.message,
          title: "Success",
          variant: SnackbarVariant.success,
        );
        setState(() {
          widget.originalPlayer.full_name = editedPlayer.full_name;
          widget.originalPlayer.gender = editedPlayer.gender;
          widget.originalPlayer.player_address = editedPlayer.player_address;
          widget.originalPlayer.birth_date = editedPlayer.birth_date;

          editedPlayer = widget.originalPlayer;
          getIt<EntityState<PlayerModel>>().setEntity(editedPlayer);

          fullNameController.text = editedPlayer.full_name;
          genderController.text = editedPlayer.gender;
          addressController.text = editedPlayer.player_address;
          birthDate = editedPlayer.birth_date;
        });
      }
    } catch (e) {
      if (context.mounted) {
        handleErrorCallBack(e, (message) {
          showAppSnackbar(
            context,
            message: message,
            title: "Error",
            variant: SnackbarVariant.error,
          );
        });
      }
    } finally {
      if (context.mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}

class BasketballProfileEditContent extends StatefulWidget {
  final PlayerModel originalPlayer;

  const BasketballProfileEditContent({super.key, required this.originalPlayer});

  @override
  State<BasketballProfileEditContent> createState() =>
      _BasketballProfileEditContentState();
}

class _BasketballProfileEditContentState
    extends State<BasketballProfileEditContent> {
  late PlayerModel editedPlayer;

  final jerseyNameController = TextEditingController();
  final jerseyNumberController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  String? selectedPosition;
  final List<String> positionOptions = ['Guard', 'Forward', 'Center'];
  Set<String> selectedPositions = {};
  bool isLoading = false;

  bool get hasChanges =>
      editedPlayer.toJsonForUpdate(widget.originalPlayer).isNotEmpty;

  @override
  void initState() {
    super.initState();
    editedPlayer = widget.originalPlayer;

    jerseyNameController.text = widget.originalPlayer.jersey_name;
    jerseyNumberController.text = widget.originalPlayer.jersey_number
        .toString();
    heightController.text = widget.originalPlayer.height_in?.toString() ?? '';
    weightController.text = widget.originalPlayer.weight_kg?.toString() ?? '';
    selectedPositions = widget.originalPlayer.position
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    jerseyNameController.addListener(_update);
    jerseyNumberController.addListener(_update);
    heightController.addListener(_update);
    weightController.addListener(_update);
  }

  void _update() {
    setState(() {
      editedPlayer = editedPlayer.copyWith(
        jersey_name: jerseyNameController.text,
        jersey_number: double.tryParse(jerseyNumberController.text) ?? 0,
        height_in: double.tryParse(heightController.text),
        weight_kg: double.tryParse(weightController.text),
        position: selectedPosition ?? '',
      );
    });
  }

  Widget _buildPositionChips() {
    return Wrap(
      spacing: 8,
      children: positionOptions.map((pos) {
        final isSelected = selectedPositions.contains(pos);
        return ChoiceChip(
          label: Text(pos),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (selectedPositions.length < 2) {
                  selectedPositions.add(pos);
                }
              } else {
                selectedPositions.remove(pos);
              }

              editedPlayer = editedPlayer.copyWith(
                position: selectedPositions.join(', '),
              );
            });
          },
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    jerseyNameController.dispose();
    jerseyNumberController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: jerseyNameController,
          decoration: const InputDecoration(label: Text("Jersey Name")),
        ),
        const SizedBox(height: Sizes.spaceMd),

        TextField(
          controller: jerseyNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(label: Text("Jersey Number")),
        ),
        const SizedBox(height: Sizes.spaceMd),
        Text("Position", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _buildPositionChips(),

        const SizedBox(height: Sizes.spaceMd),

        TextField(
          controller: heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            label: Text("Height (inches)"),
            helperText: "E.g., 70 for 5'10\"",
          ),
        ),
        const SizedBox(height: Sizes.spaceMd),

        TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(label: Text("Weight (kg)")),
        ),
        const SizedBox(height: Sizes.spaceSm),

        if (hasChanges)
          AppButton(
            label: isLoading ? "Updating..." : "Save Changes",
            onPressed: _handleUpdate,
            size: ButtonSize.sm,
            isDisabled: isLoading,
          ),
      ],
    );
  }

  Future<void> _handleUpdate() async {
    try {
      setState(() => isLoading = true);
      final json = editedPlayer.toJsonForUpdate(widget.originalPlayer);
      final response = await PlayerServices.updatePlayer(
        player_id: widget.originalPlayer.player_id,
        json: json,
      );
      if (context.mounted) {
        showAppSnackbar(
          context,
          message: response.message,
          title: "Success",
          variant: SnackbarVariant.success,
        );
        setState(() {
          widget.originalPlayer.jersey_name = editedPlayer.jersey_name;
          widget.originalPlayer.jersey_number = editedPlayer.jersey_number;
          widget.originalPlayer.position = editedPlayer.position;
          widget.originalPlayer.height_in = editedPlayer.height_in;
          widget.originalPlayer.weight_kg = editedPlayer.weight_kg;

          editedPlayer = widget.originalPlayer;
          getIt<EntityState<PlayerModel>>().setEntity(editedPlayer);

          jerseyNameController.text = editedPlayer.jersey_name;
          jerseyNumberController.text = editedPlayer.jersey_number.toString();
          heightController.text = editedPlayer.height_in?.toString() ?? '';
          weightController.text = editedPlayer.weight_kg?.toString() ?? '';
          selectedPosition = editedPlayer.position;
        });
      }
    } catch (e) {
      if (context.mounted) {
        handleErrorCallBack(e, (message) {
          showAppSnackbar(
            context,
            message: message,
            title: "Error",
            variant: SnackbarVariant.error,
          );
        });
      }
    } finally {
      if (context.mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
