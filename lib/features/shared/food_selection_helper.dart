import '../../models/meal_analysis.dart';

/// Pure helper class for food selection logic
/// 
/// This class handles ONLY selection state management and analysis creation.
/// UI concerns (snackbars, navigation) remain in the screens.
/// 
/// Used by:
/// - SearchScreen
/// - FavoritesScreen
/// 
/// Example usage:
/// ```dart
/// final _selectionHelper = FoodSelectionHelper();
/// 
/// void _addToSelection(FoodItem item) {
///   _selectionHelper.addItem(item);
///   setState(() {}); // Screen handles rebuild
///   ScaffoldMessenger.of(context).showSnackBar(...); // Screen handles UI
/// }
/// ```
class FoodSelectionHelper {
  final List<FoodItem> _selectedItems = [];
  
  /// Read-only access to selected items
  List<FoodItem> get selectedItems => List.unmodifiable(_selectedItems);
  
  /// Mutable access for ListView.builder itemCount
  int get count => _selectedItems.length;
  
  /// Get item at index (for ListView.builder)
  FoodItem itemAt(int index) => _selectedItems[index];
  
  /// Total calories of selected items
  int get totalCalories => 
      _selectedItems.fold(0, (sum, item) => sum + item.calories);
  
  /// Check if any items are selected
  bool get hasSelection => _selectedItems.isNotEmpty;
  
  /// Check if selection is empty
  bool get isEmpty => _selectedItems.isEmpty;
  
  /// Add item to selection
  /// Returns the added item for convenience (e.g., for snackbar message)
  FoodItem addItem(FoodItem item) {
    _selectedItems.add(item);
    return item;
  }
  
  /// Remove item at index
  /// Returns removed item or null if index is invalid
  FoodItem? removeAt(int index) {
    if (index < 0 || index >= _selectedItems.length) return null;
    return _selectedItems.removeAt(index);
  }
  
  /// Clear all selections
  void clear() => _selectedItems.clear();
  
  /// Build MealAnalysis from current selection
  /// Returns null if selection is empty
  /// 
  /// [source] - The source identifier ('search', 'favorites', etc.)
  MealAnalysis? buildAnalysis({required String source}) {
    if (_selectedItems.isEmpty) return null;
    
    return MealAnalysis(
      items: List.from(_selectedItems), // Create a copy
      confidence: 'high',
      source: source,
    );
  }
  
  /// Validate selection (at least one item)
  /// Use before proceeding to MealInfoScreen
  bool validate() => _selectedItems.isNotEmpty;
}
