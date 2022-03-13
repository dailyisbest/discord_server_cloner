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
                    fillColor: MaterialStateProperty.all(context.watch<CloneProvider>().tryingToClone ? Colors.grey : Colors.green),
                    value: context.watch<CloneProvider>().isMessagesCloningEnabled,
                    onChanged: context.watch<CloneProvider>().tryingToClone ? null : (isEnabled) {

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
                  style: ElevatedButton.styleFrom(
                      onSurface: context.watch<CloneProvider>().tryingToClone ? Colors.grey : Colors.green
                  ),
                  onPressed: context.watch<CloneProvider>().tryingToClone ? null : () {

                    context.read<CloneProvider>().setTryingStates(login: false, disconnect: false, clone: true);

                    cloneGuild(context.read<CloneProvider>().guildId).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Server cloning ended"),
                          )
                      );
                      context.read<CloneProvider>().setTryingStates(login: false, disconnect: false, clone: false);
                    });

                  },
                  child: const Text("Clone"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      onSurface: context.watch<CloneProvider>().tryingToDisconnect ? Colors.grey : Colors.green
                  ),
                  onPressed: context.watch<CloneProvider>().tryingToDisconnect ? null : () {

                    context.read<CloneProvider>().setTryingStates(login: false, disconnect: true, clone: false);

                    Navigator.pushNamed(context, "/login");

                    context.read<CloneProvider>().setLogged(false);

                    context.read<CloneProvider>().setTryingStates(login: false, disconnect: false, clone: false);

                  },
                  child: const Text("Disconnect"),
                ),
              )
            ],
          ),
        )
    );
  }

  Future<void> cloneGuild(String guildId) async {

    // // get guild to clone
    //
    // var guildToCloneResponse = await http.get(
    //     Uri.parse("${ClonerConstants.endpoint}/guilds/${context.read<CloneProvider>().guildId}"),
    //     headers: {
    //       "Authorization": context.read<CloneProvider>().token,
    //       "Content-Type": "application/json",
    //     }
    // );
    //
    // var guildToClone = jsonDecode(guildToCloneResponse.body);
    //
    // debugPrint(guildToClone.toString());
    //
    // if (isDisconnected()) {
    //   return;
    // }
    //
    // // get guild icon
    //
    // var oldIconBytesResponse = await http.get(Uri.parse("https://cdn.discordapp.com/icons/${guildToClone["id"]}/${guildToClone["icon"]}"));
    //
    // var oldIconBytes = oldIconBytesResponse.bodyBytes;
    //
    // var newServerIcon = "data:image/png;base64,${base64Encode(oldIconBytes)}.png?size=240";
    //
    // if (isDisconnected()) {
    //   return;
    // }
    //
    // // get roles list
    //
    // var toCreateRolesList = (guildToClone["roles"] as List<dynamic>);
    //
    // toCreateRolesList.sort((a, b) {
    //   return (a["position"] as int).compareTo(b["position"]);
    // });
    //
    // if (isDisconnected()) {
    //   return;
    // }
    //
    // // get channels list
    //
    // var toCreateChannelsList = <dynamic>[];
    //
    // var channelsFromGuildResponse = await http.get(
    //   Uri.parse("${ClonerConstants.endpoint}/guilds/$guildId/channels"),
    //   headers: {
    //     "Authorization": context.read<CloneProvider>().token,
    //     "Content-Type": "application/json",
    //   }
    // );
    //
    // var channelsFromGuildJson = jsonDecode(channelsFromGuildResponse.body);
    //
    // var categoryChannelsFromGuildJson = <dynamic>[];
    //
    // var otherChannelsFromGuildJson = <dynamic>[];
    //
    // for (var element in (channelsFromGuildJson as List<dynamic>)) {
    //
    //   if ((element["type"] as int) == 4) {
    //
    //     categoryChannelsFromGuildJson.add(element);
    //
    //   } else {
    //
    //     if ((element["type"] as int) == 13) {
    //
    //       if ((element["user_limit"] as int) > 99) {
    //
    //         element["user_limit"] = 0;
    //
    //       }
    //
    //     }
    //
    //     if (element["bitrate"] != null) {
    //
    //       if ((element["bitrate"] as int) > 96000) {
    //
    //         element["bitrate"] = 96000;
    //
    //       }
    //
    //     }
    //
    //     if ((element["type"] as int) != 0 && (element["type"] as int) != 2 && (element["type"] as int) != 4) {
    //
    //       element["type"] = 0;
    //
    //     }
    //
    //     otherChannelsFromGuildJson.add(element);
    //
    //   }
    //
    // }
    //
    // var allChannelsFromGuildJson = <dynamic>[];
    //
    // otherChannelsFromGuildJson.sort((a, b) {
    //   return (a["position"] as int).compareTo(b["position"]);
    // });
    //
    // categoryChannelsFromGuildJson.sort((a, b) {
    //   return (a["position"] as int).compareTo(b["position"]);
    // });
    //
    // allChannelsFromGuildJson = categoryChannelsFromGuildJson + otherChannelsFromGuildJson;
    //
    // toCreateChannelsList = allChannelsFromGuildJson;
    //
    // var counter = 0;
    //
    // for (var elem in toCreateChannelsList) {
    //
    //   debugPrint(counter.toString());
    //   counter++;
    //
    //   debugPrint("toCreateChannelsList: name: ${elem["name"]} position: ${elem["position"]} parent_id: ${elem["parent_id"]} user_limit: ${elem["user_limit"]}");
    //
    // }
    //
    // if (isDisconnected()) {
    //   return;
    // }
    //
    // // create guild
    //
    // var newGuild = await http.post(
    //     Uri.parse("${ClonerConstants.endpoint}/guilds"),
    //     headers: {
    //       "Authorization": context.read<CloneProvider>().token,
    //       "Content-Type": "application/json",
    //     },
    //     body: jsonEncode(
    //         {
    //           "name": guildToClone["name"],
    //           "icon": newServerIcon,
    //           "channels": toCreateChannelsList,
    //           "roles": toCreateRolesList
    //         }
    //     )
    // );
    //
    // debugPrint("NewGuildBody: ${newGuild.body}");
    //
    // var newGuildJsonBody = jsonDecode(newGuild.body);
    //
    // if (newGuildJsonBody["message"] != null) {
    //
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text("There is an error, maybe you have servers limit"),
    //       )
    //   );
    //
    //   return;
    //
    // }
    //
    // if (isDisconnected()) {
    //   return;
    // }
    //
    // // create emojis
    //
    // for (var oldServerEmoji in guildToClone["emojis"] as List<dynamic>) {
    //
    //   var oldEmojiBytesResponse = await http.get(Uri.parse("https://cdn.discordapp.com/emojis/${oldServerEmoji["id"]}${(oldServerEmoji["animated"] as bool) ? ".gif" : ".png"}"));
    //
    //   var oldImageBytes = oldEmojiBytesResponse.bodyBytes;
    //
    //   var newEmojiImage = "data:image/webp;base64,${base64Encode(oldImageBytes)}";
    //
    //   await http.post(
    //     Uri.parse("${ClonerConstants.endpoint}/guilds/${newGuildJsonBody["id"]}/emojis"),
    //       headers: {
    //         "Authorization": context.read<CloneProvider>().token,
    //         "Content-Type": "application/json",
    //       },
    //       body: jsonEncode(
    //           {
    //             "name": oldServerEmoji["name"],
    //             "image": newEmojiImage
    //           }
    //       )
    //   );
    //
    //   if (isDisconnected()) {
    //     return;
    //   }
    //
    // }
    //
    // if (isDisconnected()) {
    //   return;
    // }

    if (context.read<CloneProvider>().isMessagesCloningEnabled) {

      // clone messages

      var channelMessages = await channelMessagesStream().toList();

      channelMessages = channelMessages.reversed.toList();

      for (var msg in channelMessages) {

        debugPrint(msg["content"].toString());

      }

    }

  }

  Stream<dynamic> channelMessagesStream() async* {

    var firstMessageResponse = await http.get(
      Uri.parse("${ClonerConstants.endpoint}/channels/879384177978511394/messages?limit=1"),
      headers: {
        "Authorization": context.read<CloneProvider>().token,
        "Content-Type": "application/json",
      },
    );

    var firstMessageJson = jsonDecode(firstMessageResponse.body)[0];

    yield firstMessageJson;

    dynamic lastMessage = firstMessageJson;

    while (true) {

      var messagesResponse = await http.get(
        Uri.parse("${ClonerConstants.endpoint}/channels/879384177978511394/messages?limit=100&before=${lastMessage["id"]}"),
        headers: {
          "Authorization": context.read<CloneProvider>().token,
          "Content-Type": "application/json",
        },
      );

      var messagesJson = jsonDecode(messagesResponse.body);

      for (var msg in (messagesJson as List<dynamic>)) {

        // debugPrint(msg["content"].toString());

        yield msg;

      }

      try {

        lastMessage = (messagesJson as List<dynamic>).last;

      } catch (exc) {
        break;
      }

    }

  }

  bool isDisconnected() {

    return !context.read<CloneProvider>().isLoggedIn;

  }

}
