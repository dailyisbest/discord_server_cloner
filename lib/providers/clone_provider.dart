import 'package:flutter/material.dart';

class CloneProvider with ChangeNotifier {

  String token = "";

  bool isLoggedIn = false;

  String discriminatedName = "";

  String guildId = "";

  bool isMessagesCloningEnabled = false;

  void setToken(String tokenToSet) {

    token = tokenToSet;

    notifyListeners();

  }

  void setLogged(bool isLogged) {

    isLoggedIn = isLogged;

    notifyListeners();

  }

  void setDiscriminatedName(String name) {

    discriminatedName = name;

    notifyListeners();

  }

  void setGuildId(String id) {

    guildId = id;

    notifyListeners();

  }

  void setMessagesCloningEnabled(bool isEnabled) {

    isMessagesCloningEnabled = isEnabled;

    notifyListeners();

  }

}
