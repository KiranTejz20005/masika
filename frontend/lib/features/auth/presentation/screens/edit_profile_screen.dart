import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';

/// Edit name and profile photo; saves to Supabase and updates local state.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const _maroon = Color(0xFF8B3037);
  static const _cardBg = Color(0xFFFDFCFC);
  static const _inputBg = Color(0xFFF0EFEF);
  static const _textDark = Color(0xFF333333);

  late final TextEditingController _nameController;
  String? _avatarUrl;
  File? _pickedFile;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile?.name ?? '');
    _avatarUrl = profile?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
    if (x != null && mounted) {
      setState(() {
        _pickedFile = File(x.path);
        _errorMessage = null;
      });
    }
  }

  Future<String?> _uploadAvatar(String uid) async {
    if (_pickedFile == null) return _avatarUrl;
    try {
      final client = Supabase.instance.client;
      final path = '$uid/avatar.jpg';
      await client.storage.from('avatars').upload(
            path,
            _pickedFile!,
            fileOptions: const FileOptions(upsert: true),
          );
      final url = client.storage.from('avatars').getPublicUrl(path);
      return url;
    } catch (_) {
      return _avatarUrl;
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your name');
      return;
    }
    final profile = ref.read(userProfileProvider);
    if (profile == null || profile.id.isEmpty) {
      setState(() => _errorMessage = 'Not signed in');
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final url = await _uploadAvatar(profile.id);
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.updateUserProfile(profile.id, {
        'name': name,
        if (url != null) 'avatarUrl': url,
      });
      final updated = profile.copyWith(name: name, avatarUrl: url);
      await ref.read(userProfileProvider.notifier).setProfile(updated);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _maroon, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _saving ? null : _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: const Color(0xFFF0EBEC),
                        backgroundImage: _pickedFile != null
                            ? FileImage(_pickedFile!)
                            : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? NetworkImage(_avatarUrl!)
                                : null),
                        child: _pickedFile == null && (_avatarUrl == null || _avatarUrl!.isEmpty)
                            ? const Icon(Icons.person_rounded, color: _maroon, size: 48)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: _maroon,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Tap to change photo',
                  style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'FULL NAME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B4B4B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _inputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textDark),
                  decoration: const InputDecoration(
                    hintText: 'Your name',
                    hintStyle: TextStyle(color: Color(0xFF9B9B9B), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: (_) => setState(() => _errorMessage = null),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 13, color: Colors.red),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: _maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
