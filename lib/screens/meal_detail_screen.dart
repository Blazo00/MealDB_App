import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_models.dart';
import '../services/meal_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({Key? key, required this.mealId}) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealService _mealService = MealService();
  MealDetail? _meal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealDetails();
  }

  Future<void> _loadMealDetails() async {
    try {
      final meal = await _mealService.getMealDetails(widget.mealId);
      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  Future<void> _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не може да се отвори YouTube')),
      );
    }
  }

  Future<void> _showRandomMeal() async {
    try {
      final meal = await _mealService.getRandomMeal();
      if (meal != null) {
        Navigator.pushReplacement(
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
        title: Text(_meal?.strMeal ?? 'Детали'),
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
          : _meal == null
              ? const Center(child: Text('Рецептот не е пронајден'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _meal!.strMealThumb,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _meal!.strMeal,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Chip(
                                  label: Text(_meal!.strCategory),
                                  backgroundColor: Colors.blue.shade100,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(_meal!.strArea),
                                  backgroundColor: Colors.green.shade100,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Состојки:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._meal!.ingredients.entries.map((entry) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    '• ${entry.value} ${entry.key}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )),
                            const SizedBox(height: 24),
                            const Text(
                              'Инструкции:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _meal!.strInstructions,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            if (_meal!.strYoutube != null) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Видео:',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _launchYouTube(_meal!.strYoutube!),
                                icon: const Icon(Icons.play_circle_outline),
                                label: const Text('Погледнете на YouTube'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}