import 'dart:convert';

import 'package:discord_server_cloner/providers/clone_provider.dart';
import 'package:discord_server_cloner/util/cloner_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ClonePage extends StatefulWidget {
  const ClonePage({Key? key}) : super(key: key);

  @override
  State<ClonePage> createState() => _ClonePageState();
}

class _ClonePageState extends State<ClonePage> {

  var serverIdController = TextEditingController();

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Using ${context.read<CloneProvider>().discriminatedName} account",
                  style: const TextStyle(
                      fontSize: 18
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Enter server ID and press clone button",
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: context.watch<CloneProvider>().isMessagesCloningEnabled,
                    onChanged: (isEnabled) {

                      context.read<CloneProvider>().setMessagesCloningEnabled(isEnabled!);

                    },
                  ),
                  const Text("Messages Cloning")
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: serverIdController,
                  decoration: const InputDecoration(
                      labelText: "Server ID",
                      border: OutlineInputBorder()
                  ),
                  onChanged: (value) {
                    context.read<CloneProvider>().setGuildId(serverIdController.text);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {

                    if (!context.read<CloneProvider>().isMessagesCloningEnabled) {

                      cloneGuild(context.read<CloneProvider>().guildId);

                    }

                  },
                  child: const Text("Clone"),
                ),
              )
            ],
          ),
        )
    );
  }

  Future<void> cloneGuild(String guildId) async {

    // get guild to clone

    var guildToCloneResponse = await http.get(
        Uri.parse("${ClonerConstants.endpoint}/guilds/${context.read<CloneProvider>().guildId}"),
        headers: {
          "Authorization": context.read<CloneProvider>().token,
          "Content-Type": "application/json",
        }
    );

    var guildToClone = jsonDecode(guildToCloneResponse.body);

    debugPrint(guildToClone.toString());

    // get guild icon

    var oldIconBytesResponse = await http.get(Uri.parse("https://cdn.discordapp.com/icons/${guildToClone["id"]}/${guildToClone["icon"]}"));

    var oldIconBytes = oldIconBytesResponse.bodyBytes;

    var newServerIcon = "data:image/png;base64,${base64Encode(oldIconBytes)}.png?size=240";

    // get roles list

    var toCreateRolesList = (guildToClone["roles"] as List<dynamic>);

    toCreateRolesList.sort((a, b) {
      return (a["position"] as int).compareTo(b["position"]);
    });

    // get channels list

    var toCreateChannelsList = <dynamic>[];

    var channelsFromGuildResponse = await http.get(
      Uri.parse("${ClonerConstants.endpoint}/guilds/$guildId/channels"),
      headers: {
        "Authorization": context.read<CloneProvider>().token,
        "Content-Type": "application/json",
      }
    );

    var channelsFromGuildJson = jsonDecode(channelsFromGuildResponse.body);

    var categoryChannelsFromGuildJson = <dynamic>[];

    var otherChannelsFromGuildJson = <dynamic>[];

    for (var element in (channelsFromGuildJson as List<dynamic>)) {

      if ((element["type"] as int) == 4) {

        categoryChannelsFromGuildJson.add(element);

      } else {

        if ((element["type"] as int) == 13) {

          if ((element["user_limit"] as int) > 99) {

            element["user_limit"] = 0;

          }

        }

        if ((element["type"] as int) != 0 && (element["type"] as int) != 2 && (element["type"] as int) != 4) {

          element["type"] = 0;

        }

        otherChannelsFromGuildJson.add(element);

      }

    }

    var allChannelsFromGuildJson = <dynamic>[];

    otherChannelsFromGuildJson.sort((a, b) {
      return (a["position"] as int).compareTo(b["position"]);
    });

    categoryChannelsFromGuildJson.sort((a, b) {
      return (a["position"] as int).compareTo(b["position"]);
    });

    allChannelsFromGuildJson = categoryChannelsFromGuildJson + otherChannelsFromGuildJson;

    toCreateChannelsList = allChannelsFromGuildJson;

    var counter = 0;

    for (var elem in toCreateChannelsList) {

      debugPrint(counter.toString());
      counter++;

      debugPrint("toCreateChannelsList: name: ${elem["name"]} position: ${elem["position"]} parent_id: ${elem["parent_id"]} user_limit: ${elem["user_limit"]}");

    }

    // create guild

    var newGuild = await http.post(
        Uri.parse("${ClonerConstants.endpoint}/guilds"),
        headers: {
          "Authorization": context.read<CloneProvider>().token,
          "Content-Type": "application/json",
        },
        body: jsonEncode(
            {
              "name": guildToClone["name"],
              "icon": newServerIcon,
              "channels": toCreateChannelsList,
              "roles": toCreateRolesList
            }
        )
    );

    debugPrint(newGuild.body);

    var newGuildJsonBody = jsonDecode(newGuild.body);

  }

}
