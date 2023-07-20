import 'package:flutter/material.dart';
import 'category.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

// HomePage - Updated

// HomePage - Updated as StatefulWidget

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dummy data for demonstration
  final List<Category> categories = [
    Category(name: 'Groceries', amount: -100),
    Category(name: 'Salary', amount: 50000),
    Category(name: 'Water Bill', amount: -500),
    Category(name: 'Electricity', amount: -8000),
  ];

  double totalExpenses = 0.0;

  void updateTotalExpenses() {
    totalExpenses = categories.fold(0.0, (sum, category) => sum + category.amount);
  }

  @override
  void initState() {
    super.initState();
    updateTotalExpenses(); // Calculate total expenses initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            fontFamily: 'Trajan Pro',
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/login.jpg'),
            ),
            SizedBox(height: 20),
            Text(
              'USER LOGIN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,

              ),
            ),
            SizedBox(height: 50),
            Container(
              width: 350,
              height: 80,
              color: Colors.purple,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Expenses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  Text(
                    'Rs ${totalExpenses.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down, size: 36),
              onPressed: () async {
                final newCategory = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryPage(
                      categories,
                      onCategoryAdded: (category) {
                        setState(() {
                          categories.add(category);
                          updateTotalExpenses(); // Update total expenses
                        });
                      },
                    ),
                  ),
                );

                // Handle the newCategory if needed (optional)
                if (newCategory != null) {
                  // You can perform additional actions with the newCategory here if needed.
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
