import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_models.dart';

class MealService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.php'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Category> categories = [];
      for (var category in data['categories']) {
        categories.add(Category.fromJson(category));
      }
      return categories;
    } else {
      throw Exception('Неуспешно вчитување на категориите');
    }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/filter.php?c=$category')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null) return [];
      
      List<Meal> meals = [];
      for (var meal in data['meals']) {
        meals.add(Meal.fromJson(meal));
      }
      return meals;
    } else {
      throw Exception('Неуспешно вчитување на јадењата');
    }
  }

  Future<MealDetail?> getMealDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null) return null;
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Неуспешно вчитување на деталите за рецептот');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search.php?s=$query'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null) return [];
      
      List<Meal> meals = [];
      for (var meal in data['meals']) {
        meals.add(Meal.fromJson(meal));
      }
      return meals;
    } else {
      throw Exception('Неуспешно пребарување на јадењата');
    }
  }

  Future<MealDetail?> getRandomMeal() async {
    final response = await http.get(Uri.parse('$baseUrl/random.php'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null) return null;
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Неуспешно вчитување на рандом рецептот');
    }
  }
}