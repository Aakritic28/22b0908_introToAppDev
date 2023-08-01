import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(LoginScreen());

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Login',
              style: TextStyle(
                  color:Colors.black,
              )),
          backgroundColor: Colors.yellow
      ),
      body: Container(
        color:Color.fromARGB(255, 206, 245, 89),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    // Perform login logic here
                    login();
                  }
                },
                child: Text('Login'
                  ,style: TextStyle(
                      
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white
                  ),),
              ),
              SizedBox(height: 30),
              TextButton(onPressed: (){
                final auth = FirebaseAuth.instance;
                auth.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
              },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                        
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white
                    ),
                  ))
            ],
          ),

        ),
      ),
    );
  }
  Future<void> login() async{
    final auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
  }
}