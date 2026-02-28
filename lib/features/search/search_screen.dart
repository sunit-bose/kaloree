import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../../models/meal_analysis.dart';
import '../meal_info/meal_info_screen.dart';
import '../../app/theme.dart';

/// Search Screen - manual food lookup from Indian food database
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _selectedItems = <FoodItem>[];
  List<IndianFood>? _searchResults;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled
      _loadMorePopularFoods();
    }
  }

  Future<void> _loadMorePopularFoods() async {
    if (_isLoadingMore || _searchResults != null) return;
    
    setState(() => _isLoadingMore = true);
    // The _PopularFoods widget will handle pagination
    setState(() => _isLoadingMore = false);
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = null);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final database = ref.read(databaseProvider);
      final results = await database.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _addToSelection(IndianFood food) {
    final item = FoodItem(
      name: food.name,
      portion: food.servingSize,
      portionGrams: food.servingGrams,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      fiber: food.fiber,
    );

    setState(() {
      _selectedItems.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${food.name}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFromSelection(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _proceed() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one item')),
      );
      return;
    }

    final analysis = MealAnalysis(
      items: _selectedItems,
      confidence: 'high',
      source: 'search',
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MealInfoScreen(analysis: analysis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Food'),
      ),
      body: Column(
        children: [
          // Powered by OpenFoodFacts nudge + Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // OpenFoodFacts attribution
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Powered by OpenFoodFacts',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search input
                TextField(
                  controller: _searchController,
                  onChanged: _search,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search Indian foods...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _search('');
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // Selected items
          if (_selectedItems.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedItems.length,
                itemBuilder: (context, index) {
                  final item = _selectedItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(item.name),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeFromSelection(index),
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: theme.primaryColor),
                    ),
                  );
                },
              ),
            ),

          if (_selectedItems.isNotEmpty) const Divider(),

          // Search results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults == null
                    ? _PopularFoods(
                        onSelect: _addToSelection,
                        scrollController: _scrollController,
                      )
                    : _searchResults!.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('No results found', style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            cacheExtent: 200,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Bottom padding for last item
                            itemCount: _searchResults!.length,
                            itemBuilder: (context, index) {
                              final food = _searchResults![index];
                              return _FoodSearchCard(
                                food: food,
                                onAdd: () => _addToSelection(food),
                              );
                            },
                          ),
          ),

          // Bottom bar
          if (_selectedItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_selectedItems.length} items',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            '${_selectedItems.fold(0, (sum, item) => sum + item.calories)} kcal',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _proceed,
                      child: const Text('Continue'),
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

class _FoodSearchCard extends ConsumerStatefulWidget {
  final IndianFood food;
  final VoidCallback onAdd;

  const _FoodSearchCard({required this.food, required this.onAdd});

  @override
  ConsumerState<_FoodSearchCard> createState() => _FoodSearchCardState();
}

class _FoodSearchCardState extends ConsumerState<_FoodSearchCard> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final database = ref.read(databaseProvider);
    final isFav = await database.isFavorite(widget.food.name);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final database = ref.read(databaseProvider);
    
    setState(() => _isLoading = true);
    
    if (_isFavorite) {
      await database.removeFromFavoritesByName(widget.food.name);
    } else {
      final item = FoodItem(
        name: widget.food.name,
        portion: widget.food.servingSize,
        portionGrams: widget.food.servingGrams,
        calories: widget.food.calories,
        protein: widget.food.protein,
        carbs: widget.food.carbs,
        fat: widget.food.fat,
        fiber: widget.food.fiber,
      );
      await database.addToFavorites(item);
    }
    
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final food = widget.food;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.onAdd,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${food.servingSize} • ${food.region}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _NutrientChip(value: '${food.protein.toStringAsFixed(0)}g P', color: AppTheme.proteinColor),
                        const SizedBox(width: 6),
                        _NutrientChip(value: '${food.carbs.toStringAsFixed(0)}g C', color: AppTheme.carbsColor),
                        const SizedBox(width: 6),
                        _NutrientChip(value: '${food.fat.toStringAsFixed(0)}g F', color: AppTheme.fatColor),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${food.calories}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
                  Text('kcal', style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(width: 8),
              // Heart icon for favorites
              GestureDetector(
                onTap: _toggleFavorite,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red.shade300,
                          ),
                        )
                      : Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey.shade400,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 4),
              // Add icon
              Icon(Icons.add_circle_outline, color: theme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final String value;
  final Color color;

  const _NutrientChip({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _PopularFoods extends ConsumerStatefulWidget {
  final Function(IndianFood) onSelect;
  final ScrollController scrollController;

  const _PopularFoods({
    required this.onSelect,
    required this.scrollController,
  });

  @override
  ConsumerState<_PopularFoods> createState() => _PopularFoodsState();
}

class _PopularFoodsState extends ConsumerState<_PopularFoods> {
  final List<IndianFood> _allFoods = [];
  int _displayCount = 15;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more (increase display count)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _displayCount += 10;
          if (_displayCount >= _allFoods.length) {
            _hasMore = false;
          }
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final database = ref.watch(databaseProvider);

    return FutureBuilder<List<IndianFood>>(
      future: database.searchFoods(''), // Returns all available foods
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_allFoods.isEmpty) {
          _allFoods.addAll(snapshot.data!);
          _hasMore = _allFoods.length > _displayCount;
        }

        final displayFoods = _allFoods.take(_displayCount).toList();

        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Bottom padding for last item
          itemCount: displayFoods.length + 2, // +1 for header, +1 for loading indicator
          itemBuilder: (context, index) {
            if (index == 0) {
              // Header
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text('Popular Foods', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_allFoods.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (index == displayFoods.length + 1) {
              // Loading indicator at bottom
              if (_isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (!_hasMore) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'All foods loaded 🎉',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            final food = displayFoods[index - 1];
            return _FoodSearchCard(
              food: food,
              onAdd: () => widget.onSelect(food),
            );
          },
        );
      },
    );
  }
}
