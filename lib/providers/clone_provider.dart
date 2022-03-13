import 'package:flutter/material.dart';

class CloneProvider with ChangeNotifier {

  String token = "";

  bool isLoggedIn = false;

  String discriminatedName = "";

  String guildId = "";

  bool isMessagesCloningEnabled = false;

  bool tryingToLogin = false;

  bool tryingToDisconnect = false;

  bool tryingToClone = false;

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

  void setTryingStates({ required bool login, required bool disconnect, required bool clone }) {

    tryingToLogin = login;

    tryingToDisconnect = disconnect;

    tryingToClone = clone;

    notifyListeners();

  }

}
