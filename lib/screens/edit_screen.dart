import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../services/database_service.dart';
import 'package:image_picker/image_picker.dart';

class EditScreen extends StatefulWidget {
  final Item? existingItem;
  const EditScreen({super.key, this.existingItem});
 
  @override
  State<EditScreen> createState() => _EditScreenState();
}
 
class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();

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
    if (picked != null) {
      setState(() => _contentController.text = picked.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
 
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
 
    final now = DateTime.now();
    
    if (_isEditing) {
      final updated = widget.existingItem!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: tags,
        updatedAt: now,
      );
      await DatabaseService.instance.updateItem(updated);
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
      await DatabaseService.instance.insertItem(newItem);
    }

    if (mounted) Navigator.pop(context, true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit item' : 'New item'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!_isEditing)
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'note', label: Text('Note'), icon: Icon(Icons.notes)),
                    ButtonSegment(value: 'link', label: Text('Link'), icon: Icon(Icons.link)),
                    ButtonSegment(value: 'image', label: Text('Image'), icon: Icon(Icons.image)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) => setState(() => _type = selection.first),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              if (_type == 'image') ...[
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: Text(_contentController.text.isEmpty ? 'Pick an image' : 'Change image'),
                ),
                if (_contentController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_contentController.text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
              ] else
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: _type == 'link' ? 'URL' : 'Content',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: _type == 'link' ? 1 : 6,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'This field is required' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'e.g. work, read-later',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}


