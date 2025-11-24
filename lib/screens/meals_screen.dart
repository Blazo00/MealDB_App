import 'package:flutter/material.dart';
import '../models/meal_models.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/search_bar.dart';
import 'meal_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final String category;

  const MealsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final MealService _mealService = MealService();
  List<Meal> _meals = [];
  List<Meal> _filteredMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final meals = await _mealService.getMealsByCategory(widget.category);
      setState(() {
        _meals = meals;
        _filteredMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  Future<void> _searchMeals(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredMeals = _meals);
      return;
    }

    try {
      final searchResults = await _mealService.searchMeals(query);
      setState(() {
        _filteredMeals = searchResults
            .where((meal) => _meals.any((m) => m.idMeal == meal.idMeal))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  Future<void> _showRandomMeal() async {
    try {
      final meal = await _mealService.getRandomMeal();
      if (meal != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(mealId: meal.idMeal),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _showRandomMeal,
            tooltip: 'Рандом рецепт',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SearchBarWidget(
                  hintText: 'Пребарај јадења...',
                  onChanged: _searchMeals,
                ),
                Expanded(
                  child: _filteredMeals.isEmpty
                      ? const Center(
                          child: Text('Нема пронајдени јадења'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredMeals.length,
                          itemBuilder: (context, index) {
                            return MealCard(
                              meal: _filteredMeals[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MealDetailScreen(
                                      mealId: _filteredMeals[index].idMeal,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}