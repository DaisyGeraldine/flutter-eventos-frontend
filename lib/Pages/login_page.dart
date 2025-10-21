import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as images;
import 'package:flutter_application_2/Pages/home_page.dart';
import 'package:flutter_application_2/service/auth_serivce.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: images.AssetImage('assets/images/logo.png')),

            //generame una imagen aleatoria de logo de la red

            // Fondo(),
            Contenido(
              emailcontroller: _emailcontroller,
              passwordcontroller: _passwordcontroller,
            ),
          ],
        ),
      ),
    );
  }
}

class Contenido extends StatefulWidget {
  Contenido({
    Key? key,
    required this.emailcontroller,
    required this.passwordcontroller,
  }) : super(key: key);
  final TextEditingController emailcontroller;
  final TextEditingController passwordcontroller;
  @override
  _ContenidoState createState() => _ContenidoState();
}

class _ContenidoState extends State<Contenido> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Datos(
            emailcontroller: widget.emailcontroller,
            passwordcontroller: widget.passwordcontroller,
          ),
        ],
      ),
    );
  }
}

class Datos extends StatefulWidget {
  Datos({
    Key? key,
    required this.emailcontroller,
    required this.passwordcontroller,
  }) : super(key: key);
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  @override
  _DatosState createState() => _DatosState();
}

class _DatosState extends State<Datos> {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool obs = true;
  bool _rememberMe = false;
  final _storage = FlutterSecureStorage();
  final _debouncer = _Debouncer(
    milliseconds: 500,
  ); // Para evitar búsquedas con cada tecla

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    // Escuchar cambios en el campo de email
    widget.emailcontroller.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    widget.emailcontroller.removeListener(_onEmailChanged);
    widget.emailcontroller.dispose();
    widget.passwordcontroller.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _debouncer.run(() async {
      if (widget.emailcontroller.text.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');

      if (savedEmail == widget.emailcontroller.text.trim()) {
        final savedPassword = await _storage.read(key: 'saved_password');
        if (savedPassword != null && savedPassword.isNotEmpty) {
          setState(() {
            widget.passwordcontroller.text = savedPassword;
            _rememberMe = true;
          });
        }
      } else {
        setState(() {
          widget.passwordcontroller.text = '';
          _rememberMe = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
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
            controller: widget.emailcontroller,
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
            controller: widget.passwordcontroller,
            obscureText: obs,
            decoration: InputDecoration(
              hintText: '********',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.remove_red_eye_outlined),
                onPressed: () {
                  print(obs);
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
                    backgroundColor: MaterialStateProperty.all<Color>(
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _authService.login(
        widget.emailcontroller.text.trim(),
        widget.passwordcontroller.text,
      );
      if (result.success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(dni: result.user!.dni),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', widget.emailcontroller.text.trim());
      await _storage.write(
        key: 'saved_password',
        value: widget.passwordcontroller.text,
      );
    } else {
      await prefs.remove('saved_email');
      await _storage.delete(key: 'saved_password');
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email') ?? '';

    if (email.isNotEmpty) {
      final password = await _storage.read(key: 'saved_password') ?? '';
      setState(() {
        widget.emailcontroller.text = email;
        widget.passwordcontroller.text = password;
        _rememberMe = true;
      });
    }
  }
}

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

class Remember extends StatefulWidget {
  @override
  _RememberState createState() => _RememberState();
}

class _RememberState extends State<Remember> {
  bool valor = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: valor,
          onChanged: (value) {
            setState(() {
              valor == false ? valor = true : valor = false;
            });
          },
        ),
        Text('Recordarme'),
        Spacer(),
        TextButton(onPressed: () {}, child: Text('¿Olvidaste la contraseña?')),
      ],
    );
  }
}

class Botones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _login,
            child: Text(
              'Iniciar Sesion',
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Color(0xff142047),
              ),
            ),
          ),
        ),
        SizedBox(height: 25, width: double.infinity),
      ],
    );
  }

  void _login() {}
}

class Fondo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
    );
  }
}
