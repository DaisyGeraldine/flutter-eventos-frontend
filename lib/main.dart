import 'package:flutter/material.dart';
import 'package:flutter_application_2/Pages/calendar_page.dart';
import 'package:flutter_application_2/Pages/check_hours.dart';
import 'package:flutter_application_2/Pages/event_page.dart';
import 'package:flutter_application_2/Pages/login_page.dart';
import 'package:flutter_application_2/Pages/messages_page.dart';
import 'package:flutter_application_2/Pages/personal_page.dart';
import 'package:flutter_application_2/Pages/store_page.dart';
import 'package:flutter_application_2/Pages/tasks_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      //home: LoginPage(),
      routes: {
        '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/calendario': (context) => CalendarPage(),
        '/horas': (context) => Checkhours(),
        '/almacen': (context) => StorePage(),
        '/personal': (context) => PersonalPage(),
        '/tareas': (context) => TasksPage(),
        '/eventos': (context) => EventsPage(),
        '/mensajes': (context) => MessagesPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff142047),
        drawerTheme: DrawerThemeData(
          scrimColor: Colors.black54.withOpacity(0.5),
          elevation: 4,
        ),
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          color: Color(0xff142047),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: TextTheme(
          bodySmall: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
          bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
          titleSmall: TextStyle(color: Colors.black87, fontSize: 14),
          headlineLarge: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
