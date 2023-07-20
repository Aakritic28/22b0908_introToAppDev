import 'package:flutter/material.dart';

class Category {
  final String name;
  final double amount;

  Category({required this.name, required this.amount});
}

class CategoryPage extends StatefulWidget {
  final List<Category> categories;
  final void Function(Category) onCategoryAdded; // Callback function

  CategoryPage(this.categories, {required this.onCategoryAdded});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text('Rs ${category.amount.toStringAsFixed(2)}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog();
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog() {
    String categoryName = '';
    double categoryAmount = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add New Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  categoryName = value;
                },
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              TextField(
                onChanged: (value) {
                  categoryAmount = double.tryParse(value) ?? 0.0;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Category Amount'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (categoryName.isNotEmpty && categoryAmount > 0) {
                  final newCategory =
                  Category(name: categoryName, amount: categoryAmount);
                  widget.onCategoryAdded(newCategory); // Callback to add the category
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.purple, // Change the button background color
                onPrimary: Colors.white, // Change the button text color
              ),
              child: Text(
                'Add',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}