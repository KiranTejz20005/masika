import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Upload Video Screen - Pixel perfect implementation
/// Features: Video upload area, title, description, category chips, visibility toggle
class UploadVideoScreen extends ConsumerStatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  ConsumerState<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends ConsumerState<UploadVideoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Prenatal';
  bool _isPublic = true;
  bool _isUploading = false;

  // Design colors
  static const _maroon = Color(0xFF8C1D3F);
  static const _white = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F8F8);
  static const _textGray = Color(0xFF6B6B6B);
  static const _labelGray = Color(0xFF4B4B4B);


  final List<String> _categories = [
    'Prenatal',
    'PCOS',
    'Postnatal',
    'General Wellness',
    'Menstrual Health',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectVideo() {
    // Simulate video selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video selected (demo)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _publishVideo() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a video title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    
    // Simulate upload process
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    setState(() => _isUploading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video published successfully!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _maroon),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Upload Video',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Area
              _buildUploadArea(),
              const SizedBox(height: 24),
              
              // Video Title
              _buildLabel('Video Title'),
              const SizedBox(height: 8),
              _buildTitleInput(),
              const SizedBox(height: 20),
              
              // Description
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildDescriptionInput(),
              const SizedBox(height: 24),
              
              // Category
              _buildLabel('Category'),
              const SizedBox(height: 12),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              
              // Public Visibility Toggle
              _buildVisibilityToggle(),
              const SizedBox(height: 32),
              
              // Publish Button
              _buildPublishButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _selectVideo,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _labelGray.withValues(alpha: 0.2),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _maroon.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam,
                size: 28,
                color: _maroon,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Drag and drop or tap to upload',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _labelGray,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ensure your video is in MP4 or MOV format\n(max 500MB)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _textGray.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _maroon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Select Video',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _maroon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _labelGray,
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _labelGray.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(
          fontSize: 15,
          color: _labelGray,
        ),
        decoration: InputDecoration(
          hintText: 'e.g., Understanding First Trimester Nutrition',
          hintStyle: TextStyle(
            fontSize: 15,
            color: _textGray.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _labelGray.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 4,
        style: const TextStyle(
          fontSize: 15,
          color: _labelGray,
        ),
        decoration: InputDecoration(
          hintText: 'Provide a brief summary for your patients...',
          hintStyle: TextStyle(
            fontSize: 15,
            color: _textGray.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _maroon : _white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _maroon : _labelGray.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? _white : _labelGray,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _labelGray.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Public Visibility',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _labelGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Visible to all Masika users',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPublic,
            onChanged: (value) => setState(() => _isPublic = value),
            activeThumbColor: _maroon,
            activeTrackColor: _maroon.withValues(alpha: 0.3),
            inactiveThumbColor: _white,
            inactiveTrackColor: _labelGray.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: _isUploading ? null : _publishVideo,
        style: FilledButton.styleFrom(
          backgroundColor: _maroon,
          foregroundColor: _white,
          disabledBackgroundColor: _maroon.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          elevation: 0,
        ),
        child: _isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: _white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Publish Video',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
