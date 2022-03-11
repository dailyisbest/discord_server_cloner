import 'dart:convert';

import 'package:discord_server_cloner/providers/clone_provider.dart';
import 'package:discord_server_cloner/util/cloner_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  var tokenEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Discord Server Cloner",
                style: TextStyle(
                  fontSize: 26
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Enter your account token",
                style: TextStyle(
                  fontSize: 18
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: tokenEditingController,
                decoration: const InputDecoration(
                  labelText: "Token",
                  border: OutlineInputBorder()
                ),
                onChanged: (value) {
                  context.read<CloneProvider>().setToken(tokenEditingController.text);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {

                  http.get(
                    Uri.parse("${ClonerConstants.endpoint}/users/@me"),
                    headers: {
                      "Authorization": context.read<CloneProvider>().token,
                      "Content-Type": "application/json"
                    }
                  ).then((response) {

                    var jsonBody = jsonDecode(response.body);

                    if (jsonBody["username"] != null) {

                      context.read<CloneProvider>().setDiscriminatedName("${jsonBody["username"]}#${jsonBody["discriminator"]}");

                      Navigator.pushNamed(context, "/clone");

                    } else {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Specified token is invalid"),
                        )
                      );

                    }

                  });

                },
                child: const Text("Login"),
              ),
            )
          ],
        ),
      )
    );
  }
}
