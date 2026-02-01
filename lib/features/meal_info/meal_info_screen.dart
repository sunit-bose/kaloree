import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/meal_analysis.dart';
import '../../services/database_service.dart';
import '../../app/theme.dart';

// Provider to trigger diary refresh
final diaryRefreshProvider = StateProvider<int>((ref) => 0);

/// Meal Info Screen - displays analyzed meal with editing capability
class MealInfoScreen extends ConsumerStatefulWidget {
  final MealAnalysis analysis;

  const MealInfoScreen({super.key, required this.analysis});

  @override
  ConsumerState<MealInfoScreen> createState() => _MealInfoScreenState();
}

class _MealInfoScreenState extends ConsumerState<MealInfoScreen> {
  late List<FoodItem> _items;
  MealType? _selectedMealType;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.analysis.items);
    // Only auto-infer meal type for manual search, not for camera/AI
    if (widget.analysis.source == 'search') {
      _inferMealType();
    }
    // For camera/AI, leave it null to make it mandatory
  }

  void _inferMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      _selectedMealType = MealType.breakfast;
    } else if (hour >= 11 && hour < 15) {
      _selectedMealType = MealType.lunch;
    } else if (hour >= 15 && hour < 18) {
      _selectedMealType = MealType.snack;
    } else {
      _selectedMealType = MealType.dinner;
    }
  }

  int get _totalCalories => _items.fold(0, (sum, item) => sum + item.calories);
  double get _totalProtein => _items.fold(0.0, (sum, item) => sum + item.protein);
  double get _totalCarbs => _items.fold(0.0, (sum, item) => sum + item.carbs);
  double get _totalFat => _items.fold(0.0, (sum, item) => sum + item.fat);

  void _editItem(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditItemSheet(
        item: _items[index],
        onSave: (updatedItem) {
          setState(() => _items[index] = updatedItem.copyWith(isEdited: true));
        },
        onDelete: () {
          setState(() => _items.removeAt(index));
        },
      ),
    );
  }

  void _addManualItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditItemSheet(
        item: null,
        onSave: (newItem) {
          setState(() => _items.add(newItem));
        },
        onDelete: null,
      ),
    );
  }

  Future<void> _saveToLog() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item')),
      );
      return;
    }

    // Make meal type mandatory
    if (_selectedMealType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a meal type')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final database = ref.read(databaseProvider);
      final analysis = MealAnalysis(
        items: _items,
        confidence: widget.analysis.confidence,
        source: widget.analysis.source,
      );

      await database.saveMeal(analysis, _selectedMealType, customDate: _selectedDate);

      // Trigger diary refresh
      ref.read(diaryRefreshProvider.notifier).state++;

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meal saved to log!'),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get _displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) return 'Today';
    if (selected == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(_selectedDate);
  }

  String get _displayTime {
    return DateFormat('h:mm a').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Details'),
        actions: [
          TextButton.icon(
            onPressed: _addManualItem,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary card with gradient
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGradient.colors[0].withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '$_totalCalories',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                  const Text(
                    'calories 🔥',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MacroChip(label: 'Protein 💪', value: '${_totalProtein.toStringAsFixed(1)}g', color: AppTheme.proteinColor),
                      _MacroChip(label: 'Carbs ⚡', value: '${_totalCarbs.toStringAsFixed(1)}g', color: AppTheme.carbsColor),
                      _MacroChip(label: 'Fat 🥑', value: '${_totalFat.toStringAsFixed(1)}g', color: AppTheme.fatColor),
                    ],
                  ),
                ],
              ),
            ),

            // Date and Time selectors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Date selector
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          // Preserve current time when date is selected
                          setState(() => _selectedDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            _selectedDate.hour,
                            _selectedDate.minute,
                            _selectedDate.second,
                          ));
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20, color: theme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  _displayDate,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time selector
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDate),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            picked.hour,
                            picked.minute,
                          ));
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 20, color: theme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  _displayTime,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Meal type selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Save as:', style: theme.textTheme.titleMedium),
                      if (_selectedMealType == null) ...[
                        const SizedBox(width: 8),
                        Text('*', style: TextStyle(color: Colors.red, fontSize: 18)),
                      ],
                    ],
                  ),
                  if (_selectedMealType == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Please select a meal type',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: MealType.values.map((type) {
                        final isSelected = _selectedMealType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(type.displayName),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedMealType = type),
                            selectedColor: theme.primaryColor.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Items list
            _items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No items detected', style: TextStyle(color: Colors.grey.shade500)),
                        TextButton.icon(
                          onPressed: _addManualItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add manually'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) => _FoodItemCard(
                      item: _items[index],
                      onTap: () => _editItem(index),
                    ),
                  ),

            const SizedBox(height: 16),

            // Action buttons - Retry Scan and Save to Log
            Container(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : () {
                          Navigator.of(context).pop(); // Go back to camera
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Scan'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveToLog,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save to Log'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _FoodItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${item.portion} (${item.portionGrams}g)', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _NutrientTag(value: '${item.protein.toStringAsFixed(1)}g P', color: AppTheme.proteinColor),
                        const SizedBox(width: 8),
                        _NutrientTag(value: '${item.carbs.toStringAsFixed(1)}g C', color: AppTheme.carbsColor),
                        const SizedBox(width: 8),
                        _NutrientTag(value: '${item.fat.toStringAsFixed(1)}g F', color: AppTheme.fatColor),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('${item.calories}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.primaryColor)),
                  Text('kcal', style: theme.textTheme.bodySmall),
                ],
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientTag extends StatelessWidget {
  final String value;
  final Color color;

  const _NutrientTag({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _EditItemSheet extends StatefulWidget {
  final FoodItem? item;
  final Function(FoodItem) onSave;
  final VoidCallback? onDelete;

  const _EditItemSheet({required this.item, required this.onSave, this.onDelete});

  @override
  State<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<_EditItemSheet> {
  late TextEditingController _nameController;
  late TextEditingController _portionController;
  late TextEditingController _gramsController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _portionController = TextEditingController(text: item?.portion ?? '1 serving');
    _gramsController = TextEditingController(text: item?.portionGrams.toString() ?? '100');
    _caloriesController = TextEditingController(text: item?.calories.toString() ?? '0');
    _proteinController = TextEditingController(text: item?.protein.toString() ?? '0');
    _carbsController = TextEditingController(text: item?.carbs.toString() ?? '0');
    _fatController = TextEditingController(text: item?.fat.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _portionController.dispose();
    _gramsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    widget.onSave(FoodItem(
      name: _nameController.text.trim(),
      portion: _portionController.text.trim(),
      portionGrams: int.tryParse(_gramsController.text) ?? 100,
      calories: int.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      fiber: 0,
      isEdited: true,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.item == null ? 'Add Item' : 'Edit Item', style: theme.textTheme.headlineMedium),
                if (widget.onDelete != null)
                  IconButton(
                    onPressed: () { widget.onDelete!(); Navigator.pop(context); },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Food Name'), textCapitalization: TextCapitalization.words),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(flex: 2, child: TextField(controller: _portionController, decoration: const InputDecoration(labelText: 'Portion'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _gramsController, decoration: const InputDecoration(labelText: 'Grams'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _caloriesController, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _proteinController, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _carbsController, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _fatController, decoration: const InputDecoration(labelText: 'Fat (g)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(widget.item == null ? 'Add Item' : 'Save Changes'))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
