import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';

class EditScreen extends StatefulWidget {
  final Item? existingItem;
  const EditScreen({super.key, this.existingItem});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  late String _type;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _type = item?.type ?? 'note';
    _titleController = TextEditingController(text: item?.title ?? '');
    _contentController = TextEditingController(text: item?.content ?? '');
    _tagsController = TextEditingController(text: item?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _contentController.text = picked.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final now = DateTime.now();

    try {
      if (_isEditing) {
        final updated = widget.existingItem!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tags: tags,
          updatedAt: now,
        );
        await SupabaseService.instance.updateItem(updated);
      } else {
        final newItem = Item(
          id: const Uuid().v4(),
          type: _type,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tags: tags,
          createdAt: now,
          updatedAt: now,
        );
        await SupabaseService.instance.insertItem(newItem);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save. Check your connection and try again.'),
          ),
        );
        setState(() => isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit item' : 'New item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isSaving ? null : _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (!_isEditing) ...[
              _sectionCard(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'note',
                      label: Text('Note'),
                      icon: Icon(Icons.notes),
                    ),
                    ButtonSegment(
                      value: 'link',
                      label: Text('Link'),
                      icon: Icon(Icons.link),
                    ),
                    ButtonSegment(
                      value: 'image',
                      label: Text('Image'),
                      icon: Icon(Icons.image),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() => _type = selection.first);
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Title is required'
                            : null,
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slide,
                          child: child,
                        ),
                      );
                    },
                    child: _type == 'image'
                        ? Column(
                            key: const ValueKey('image-fields'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library),
                                label: Text(
                                  _contentController.text.isEmpty
                                      ? 'Pick an image'
                                      : 'Change image',
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                child: _contentController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          _contentController.text,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: scheme.outline),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          )
                        : TextFormField(
                            key: ValueKey('$_type-fields'),
                            controller: _contentController,
                            decoration: _inputDecoration(
                              labelText: _type == 'link' ? 'URL' : 'Content',
                            ),
                            maxLines: _type == 'link' ? 1 : 6,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'This field is required'
                                    : null,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              child: TextFormField(
                controller: _tagsController,
                decoration: _inputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'e.g. work, read-later',
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: isSaving ? null : _save,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isSaving
                    ? const SizedBox(
                        key: ValueKey('saving'),
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.save_outlined,
                        key: ValueKey('save'),
                      ),
              ),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  isSaving ? 'Saving...' : 'Save',
                  key: ValueKey(isSaving),
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
