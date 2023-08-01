import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ExpenseDatabase {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref();
  final String _userId;

  ExpenseDatabase(this._userId);

  void addExpense(Expense expense) {
    final newExpenseRef = _databaseReference
        .child('users')
        .child(_userId)
        .child('expenses')
        .push();
    newExpenseRef.set({
      'category': expense.category,
      'amount': expense.amount,
    });
  }

  void removeExpense(String expenseKey) {
    _databaseReference
        .child('users')
        .child(_userId)
        .child('expenses')
        .child(expenseKey)
        .remove();
  }
}


class ExpenseProvider with ChangeNotifier {
  double _total = 0;
  List<Expense> _expenses = [];

  double get total => _total;
  List<Expense> get expenses => _expenses;

  final ExpenseDatabase _expenseDatabase;

  ExpenseProvider(this._expenseDatabase);

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _total += expense.amount;
    _expenseDatabase.addExpense(expense); // Updating
    notifyListeners();
  }

  void removeExpense(Expense expense, String expenseKey) {
    _expenses.remove(expense);
    _total -= expense.amount;
    _expenseDatabase.removeExpense(expenseKey); // Update Firebase Database
    notifyListeners();
  }
}

class Expense {
  final String category;
  final double amount;

  Expense({required this.category, required this.amount});
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // Get the user ID
          final userId = snapshot.data!.uid;

          // Create an instance of ExpenseDatabase
          final expenseDatabase = ExpenseDatabase(userId);

          return ChangeNotifierProvider(
            create: (_) => ExpenseProvider(expenseDatabase),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Budget Tracker',
              home: HomeScreen(),
              routes: {
                '/expense': (context) => ExpenseScreen(),
              },
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Budget Tracker',
          home: LoginScreen(),
        );
      },
    );
  }
}


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final total = expenseProvider.total;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget Tracker',
          style: TextStyle(
            color: Colors.purple,
            
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[100],
        centerTitle: true,
      ),
      body: Container(

        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.account_circle_sharp,
                size: 150,
              ),
              Text(
                'Welcome Back User',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.purple[900],
                    
                    fontWeight: FontWeight.bold
                ),
              ),
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Balance Left: ',
                        style: TextStyle(
                          
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Consumer<ExpenseProvider>(
                        builder: (context, expenseProvider, _) => Text(
                          expenseProvider.total.toString(),
                          style: TextStyle(
                            
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pushNamed(context, '/expense');
                  },
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();},
                child: const Text(
                    'Logout'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseScreen extends StatelessWidget {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();


  void addExpense(BuildContext context) {
    final category = categoryController.text.trim();
    double amount = double.tryParse(amountController.text.trim()) ?? 0.0;

    if (category.isNotEmpty && amount != 0) {
      final expense = Expense(category: category, amount: amount);
      Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);

      categoryController.clear();
      amountController.clear();
    }
  }

  void deleteExpense(BuildContext context, Expense expense, String expenseKey) {
    Provider.of<ExpenseProvider>(context, listen: false).removeExpense(expense, expenseKey); // Pass both the expense and the key
  }

  Future<void> openDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //contentPadding: EdgeInsets.all(20.0),
        title: Center(
            child:Text('New Entry',
                style:TextStyle(
                    color: Colors.amber,
                    fontSize: 28,
                    
                ))),

        content: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: categoryController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(
                      color: Colors.purple,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width:2.0),
                    borderRadius: BorderRadius.all(Radius.circular(30)),

                  ),
                  filled: true,
                  fillColor: Colors.purple[100],
                ),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(
                      color: Colors.purple,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                     
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width:2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  filled: true,
                  fillColor: Colors.purple[100],
                ),
                keyboardType: TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FloatingActionButton(
            onPressed: () {
              addExpense(context); // Calling add expense
              Navigator.pop(context); // Close the dialog after adding the expense
            },
            child: Icon(Icons.done_outline_rounded),
            backgroundColor: Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense',
          style: TextStyle(
            color: Colors.white,
            
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.purple[100],
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: Text(
                    'Balance Left: ',
                    style: TextStyle(
                      
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  trailing: Consumer<ExpenseProvider>(
                    builder: (context, expenseProvider, _) => Text(
                      expenseProvider.total.toString(),
                      style: TextStyle(
                        
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];
                    final expenseKey = ''; // Get the expense key here from your Firebase Database
                    return ExpenseCard(
                      expense: expense,
                      onDelete: () => deleteExpense(context, expense, expenseKey), // Pass both the expense and the key
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog(context); // Call the openDialog method with the context
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.amberAccent,
      ),

    );
  }
}

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseCard({
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          expense.category,
          style: TextStyle(
            color: Colors.purpleAccent,
            
            fontSize: 20,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${expense.amount}',
              style: TextStyle(
                color: Colors.purpleAccent,

                fontSize: 20,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      appId: '1:270770596013:android:7c852f3bcef0bf4f183e24',
      apiKey: 'AIzaSyCSIZkSC1toY1hJZpjTf1M7Gv985cO_TvM',
      projectId: 'tracker-1d06d',
      messagingSenderId: '270770596013',
      // Add other necessary options
    ),

  );
  runApp(BudgetTrackerApp());
}