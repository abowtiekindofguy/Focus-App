import 'package:flutter/material.dart';
import 'main.dart';
import 'track.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'validator.dart';


class Authentication{
  static Future<User?> registerUsingEmailPassword(String name, String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
    return user;
  }


  static Future<User?> signInWithEmailAndPassword(String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return null;
    }
    return user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<String> getEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user!.email!;
  } 

  static Future<String> getName() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user!.displayName??"User";
  }

  static Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<User?> refreshUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user!.reload();
    return FirebaseAuth.instance.currentUser;
  }

}

// Login SCreens
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final _loginFormKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Email",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: true,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Password",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.0),
                      _isProcessing
                          ? CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isProcessing = true;
                                      });

                                      if (_loginFormKey.currentState!.validate()) {
                                        User? user = await Authentication.signInWithEmailAndPassword(
                                          _emailTextController.text,
                                          _passwordTextController.text,
                                        );

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        if (user != null) {
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) => HomeScreen(currentUserId: user.email,name: user.displayName,),
                                            ),
                                            ModalRoute.withName('/home'),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Sign in',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                // add register button
                                SizedBox(width: 24.0),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Register',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nameTextController,
                        focusNode: _focusName,
                        validator: (value) => Validator.validateName(
                          name: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Name",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Email",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: true,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Password",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.0),
                      _isProcessing
                          ? CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isProcessing = true;
                                      });

                                      if (_registerFormKey.currentState!
                                          .validate()) {
                                        User? user = await Authentication
                                            .registerUsingEmailPassword( _nameTextController.text, _emailTextController.text, _passwordTextController.text,
                                        );

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        if (user != null) {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  // ProfilePage(user: user),
                                                  HomeScreen(currentUserId: user.email,name: user.displayName,),
                                            ),
                                            ModalRoute.withName('/'),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}







// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     checkCurrentUser();
//   }

//   Future<void> checkCurrentUser() async {
//     final User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       // User is already logged in, navigate to the next screen
//       WidgetsBinding.instance!.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       });
//     }
//   }

//   Future<void> _signIn() async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text.trim();

//     try {
//       final UserCredential userCredential =
//           await _auth.signInWithEmailAndPassword(email: email, password: password);
//       // If login is successful, navigate to the next screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     } catch (error) {
//       setState(() {
//         // If login fails, display an error message
//         _errorMessage = 'Invalid email or password';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: _auth.authStateChanges(),
//       builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//         if (snapshot.hasData) {
//           WidgetsBinding.instance!.addPostFrameCallback((_) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => HomeScreen()),
//             );
//           });
//           return Container();
//         } else {
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('Login Screen'),
//             ),
//             body: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(labelText: 'Email'),
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         return null;
//                       },
//                     ),
//                     TextFormField(
//                       controller: _passwordController,
//                       decoration: InputDecoration(labelText: 'Password'),
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 16.0),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           _signIn();
//                         }
//                       },
//                       child: Text('Sign In'),
//                     ),
//                     SizedBox(height: 8.0),
//                     Text(
//                       _errorMessage,
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }


// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>{
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     checkCurrentUser();
//   }

//   void checkCurrentUser() async {
//     final User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       Navigator.of(context).pushReplacementNamed('/home');
//     }
//   }

//   Future<void> _signIn() async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text.trim();
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//       Navigator.of(context).pushReplacementNamed('/home');
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _errorMessage = e.message!;
//       });
//     }

//   }

//   @override 
//   Widget build(BuildContext context){
//     return StreamBuilder(stream: _auth.authStateChanges(), 
//     builder: (BuildContext context, AsyncSnapshot<User?> snapshot){
//       if (snapshot.connectionState == ConnectionState.waiting){
//         return const Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       }
//       if (snapshot.hasData){
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.of(context).pushReplacementNamed('/home');
//         });
//         return Container();
//       } else {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Login'),
            
//           ),


//           body: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(labelText: 'Email'),
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         return null;
//                       },
//                     ),
//                     TextFormField(
//                       controller: _passwordController,
//                       decoration: InputDecoration(labelText: 'Password'),
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 16.0),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           _signIn();
//                         }
//                       },
//                       child: Text('Sign In'),
//                     ),
//                     SizedBox(height: 8.0),
//                     Text(
//                       _errorMessage,
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ),
//               )
//           ),
//         );
//       }

//     } );
//   }
// }


