import 'package:discord_server_cloner/pages/clone_page.dart';
import 'package:discord_server_cloner/pages/login_page.dart';
import 'package:discord_server_cloner/providers/clone_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CloneProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Discord Server Cloner',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            color: Colors.red
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.all(Colors.green)
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color.fromARGB(255, 71, 71, 71),
            contentTextStyle: TextStyle(
              color: Colors.white
            )
          ),
          colorScheme: const ColorScheme.dark(
            primary: Colors.green,
            primaryContainer: Colors.green,
            secondary: Colors.red,
            secondaryContainer: Colors.redAccent
          )
        ),
        initialRoute: "/login",
        routes: {
          "/login": (context) => const LoginPage(),
          "/clone": (context) => const ClonePage()
        },
      ),
    );
  }
}
