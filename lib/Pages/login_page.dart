import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as images;
import 'package:flutter_application_2/Pages/home_page.dart';
import 'package:flutter_application_2/service/auth_service.dart';
import 'package:flutter_application_2/utils/preference.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool obs = true;
  bool _rememberMe = false;
  final _debouncer = _Debouncer(
    milliseconds: 500,
  ); // Para evitar búsquedas con cada tecla

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    // Escuchar cambios en el campo de email
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: images.AssetImage('assets/images/logo.png')),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'email@email.com',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: obs,
                          decoration: InputDecoration(
                            hintText: '********',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye_outlined),
                              onPressed: () {
                                setState(() {
                                  obs = !obs;
                                });
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                  _saveCredentials();
                                });
                              },
                            ),
                            Text('Recordarme'),
                            Spacer(),
                            //TextButton(
                            //  onPressed: () {},
                            //  child: Text('¿Olvidaste la contraseña?'),
                            //),
                          ],
                        ),
                        SizedBox(height: 30),
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                child: Text(
                                  'Iniciar Sesion',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Color(0xff142047),
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(height: 25, width: double.infinity),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    //try {
    ResponseResult result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (result.success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(dni: result.data!['dni']),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    }
    // } catch (e) {
    //   if (mounted) {
    //     print('Login failed: $e');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Login failed: $e'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveCredentials() async {
    await PreferenceUtils.saveCredentials(
      _emailController.text.trim(),
      _passwordController.text,
      _rememberMe,
    );
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await PreferenceUtils.getSavedCredentials();

    if (credentials['email'] != null && credentials['email']!.isNotEmpty) {
      setState(() {
        _emailController.text = credentials['email']!;
        _passwordController.text = credentials['password'] ?? '';
        _rememberMe = credentials['remember'] == 'true';
      });
    }
  }

  void _onEmailChanged() {
    _debouncer.run(() async {
      if (_emailController.text.isEmpty) return;

      final credentials = await PreferenceUtils.getSavedCredentials();

      if (credentials['email'] == _emailController.text.trim() &&
          credentials['password'] != null &&
          credentials['password']!.isNotEmpty) {
        setState(() {
          _passwordController.text = credentials['password']!;
          _rememberMe = credentials['remember'] == 'true';
        });
      } else {
        setState(() {
          _passwordController.text = '';
          _rememberMe = false;
        });
      }
    });
  }
}

// class Contenido extends StatelessWidget {
//   Contenido({
//     Key? key,
//     required this.emailController,
//     required this.passwordController,
//   }) : super(key: key);
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Login',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 30,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 5),
//           Text(
//             'Bienvenido',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 10,
//               letterSpacing: 1.5,
//             ),
//           ),
//           SizedBox(height: 5),
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Email',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 TextFormField(
//                   controller: widget.emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     hintText: 'email@email.com',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   'Password',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 TextFormField(
//                   controller: widget.passwordController,
//                   obscureText: widget.obscureText,
//                   decoration: InputDecoration(
//                     hintText: '********',
//                     border: OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.remove_red_eye_outlined),
//                       onPressed: () {
//                         setState(() {
//                           obs = !obs;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _rememberMe,
//                       onChanged: (value) {
//                         setState(() {
//                           _rememberMe = value ?? false;
//                           _saveCredentials();
//                         });
//                       },
//                     ),
//                     Text('Recordarme'),
//                     Spacer(),
//                     //TextButton(
//                     //  onPressed: () {},
//                     //  child: Text('¿Olvidaste la contraseña?'),
//                     //),
//                   ],
//                 ),
//                 SizedBox(height: 30),
//                 Column(
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _login,
//                         child: Text(
//                           'Iniciar Sesion',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ButtonStyle(
//                           backgroundColor: MaterialStateProperty.all<Color>(
//                             Color(0xff142047),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 25, width: double.infinity),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// }

// class Datos extends StatefulWidget {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final void Function()? onPressedLogin;
//   final bool isLoading;
//   final bool obscureText;
//   Datos({
//     Key? key,
//     required this.emailController,
//     required this.passwordController,
//     required this.onPressedLogin,
//     required this.isLoading,
//     required this.obscureText,
//   });

//   @override
//   _DatosState createState() => _DatosState();
// }

// class _DatosState extends State<Datos> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Email',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 5),
//           TextFormField(
//             controller: widget.emailController,
//             keyboardType: TextInputType.emailAddress,
//             decoration: InputDecoration(
//               hintText: 'email@email.com',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 5),
//           Text(
//             'Password',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 5),
//           TextFormField(
//             controller: widget.passwordController,
//             obscureText: widget.obscureText,
//             decoration: InputDecoration(
//               hintText: '********',
//               border: OutlineInputBorder(),
//               suffixIcon: IconButton(
//                 icon: Icon(Icons.remove_red_eye_outlined),
//                 onPressed: () {
//                   setState(() {
//                     obs = !obs;
//                   });
//                 },
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               Checkbox(
//                 value: _rememberMe,
//                 onChanged: (value) {
//                   setState(() {
//                     _rememberMe = value ?? false;
//                     _saveCredentials();
//                   });
//                 },
//               ),
//               Text('Recordarme'),
//               Spacer(),
//               //TextButton(
//               //  onPressed: () {},
//               //  child: Text('¿Olvidaste la contraseña?'),
//               //),
//             ],
//           ),
//           SizedBox(height: 30),
//           Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : widget.onPressedLogin,
//                   child: Text(
//                     'Iniciar Sesion',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all<Color>(
//                       Color(0xff142047),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 25, width: double.infinity),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class _Debouncer {
  final int milliseconds;
  VoidCallback? _callback;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback callback) {
    _callback = callback;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), _execute);
  }

  void _execute() {
    if (_callback != null) {
      _callback!();
    }
  }
}
