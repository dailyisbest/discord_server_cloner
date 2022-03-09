import 'package:discord_server_cloner/pages/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.red
        ),
        // primarySwatch: Colors.blue,
        colorScheme: const ColorScheme.dark(
          primary: Colors.green,
          primaryContainer: Colors.green,
          secondary: Colors.red,
          secondaryContainer: Colors.redAccent
        )
      ),
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginPage()
      },
    );
  }
}
