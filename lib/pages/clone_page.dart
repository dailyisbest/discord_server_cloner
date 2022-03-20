import 'dart:convert';

import 'package:discord_server_cloner/providers/clone_provider.dart';
import 'package:discord_server_cloner/util/cloner_constants.dart';
import 'package:discord_server_cloner/util/rate_limited.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

class ClonePage extends StatefulWidget {
  const ClonePage({Key? key}) : super(key: key);

  @override
  State<ClonePage> createState() => _ClonePageState();
}

class _ClonePageState extends State<ClonePage> {

  var serverIdController = TextEditingController();

  var sharedRateLimited = SharedReturnedRateLimited(5, const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
  }

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

    // get guild to clone

    var guildToClone = await getGuildToClone();

    if (isDisconnected()) {
      return;
    }

    // get guild icon

    var newServerIcon = await getGuildIcon(guildToClone);

    if (isDisconnected()) {
      return;
    }

    // get roles list

    var toCreateRolesList = await getRolesList(guildToClone);

    if (isDisconnected()) {
      return;
    }

    // get channels list

    var toCreateChannelsList = await getChannelsList(guildToClone["id"]);

    if (isDisconnected()) {
      return;
    }

    // create guild

    var newGuildJsonBody = await createGuild(guildToClone, newServerIcon, toCreateChannelsList, toCreateRolesList);

    if (newGuildJsonBody is String) {

      if (newGuildJsonBody == "limit") {

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("There is an error, maybe you have servers limit"),
            )
        );

        return;

      }

    }

    if (isDisconnected()) {
      return;
    }

    // create emojis

    var emojisResult = await createEmojis(guildToClone, newGuildJsonBody);

    if (emojisResult is String) {

      if (emojisResult == "disconnected") {

        return;

      }

    }

    if (isDisconnected()) {
      return;
    }

    // clone messages if enabled

    if (context.read<CloneProvider>().isMessagesCloningEnabled) {

      await cloneMessages(newGuildJsonBody, toCreateChannelsList);

    }

  }

  Future<dynamic> getGuildToClone() async {

    var guildToCloneResponse = await http.get(
        Uri.parse("${ClonerConstants.endpoint}/guilds/${context.read<CloneProvider>().guildId}"),
        headers: {
          "Authorization": context.read<CloneProvider>().token,
          "Content-Type": "application/json",
        }
    );

    return jsonDecode(guildToCloneResponse.body);

  }

  Future<dynamic> getGuildIcon(dynamic guildToClone) async {

    var oldIconBytesResponse = await http.get(Uri.parse("https://cdn.discordapp.com/icons/${guildToClone["id"]}/${guildToClone["icon"]}"));

    var oldIconBytes = oldIconBytesResponse.bodyBytes;

    return "data:image/png;base64,${base64Encode(oldIconBytes)}.png?size=240";

  }

  Future<List<dynamic>> getRolesList(dynamic guildToClone) async {

    var toCreateRolesList = (guildToClone["roles"] as List<dynamic>);

    toCreateRolesList.sort((a, b) {
      return (a["position"] as int).compareTo(b["position"]);
    });

    return toCreateRolesList;

  }

  Future<List<dynamic>> getChannelsList(String guildId) async {

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

        if (element["bitrate"] != null) {

          if ((element["bitrate"] as int) > 96000) {

            element["bitrate"] = 96000;

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

    return toCreateChannelsList;

  }

  Future<dynamic> createGuild(dynamic guildToClone, String newServerIcon, List<dynamic> toCreateChannelsList, List<dynamic> toCreateRolesList) async {

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

    var newGuildJsonBody = jsonDecode(newGuild.body);

    if (newGuildJsonBody["message"] != null) {

      return "limit";

    }

    return newGuildJsonBody;

  }

  Future<dynamic> createEmojis(dynamic guildToClone, dynamic newGuildJsonBody) async {

    for (var oldServerEmoji in guildToClone["emojis"] as List<dynamic>) {

      var oldEmojiBytesResponse = await http.get(Uri.parse("https://cdn.discordapp.com/emojis/${oldServerEmoji["id"]}${(oldServerEmoji["animated"] as bool) ? ".gif" : ".png"}"));

      var oldImageBytes = oldEmojiBytesResponse.bodyBytes;

      var newEmojiImage = "data:image/webp;base64,${base64Encode(oldImageBytes)}";

      await http.post(
          Uri.parse("${ClonerConstants.endpoint}/guilds/${newGuildJsonBody["id"]}/emojis"),
          headers: {
            "Authorization": context.read<CloneProvider>().token,
            "Content-Type": "application/json",
          },
          body: jsonEncode(
              {
                "name": oldServerEmoji["name"],
                "image": newEmojiImage
              }
          )
      );

      if (isDisconnected()) {
        return "disconnected";
      }

    }

  }

  Future<dynamic> cloneMessages(dynamic newGuildJsonBody, dynamic toCreateChannelsList) async {

    // get new guild channels

    var allChannelsFromNewGuildJson = await getChannelsList(newGuildJsonBody["id"].toString());

    //clone messages

    for (var channels in IterableZip<dynamic>([toCreateChannelsList, allChannelsFromNewGuildJson])) {

      if (isDisconnected()) {
        return "disconnected";
      }

      if ((channels[0]["type"] as int) == 0) {

        var webhookJson = await sharedRateLimited(() async {
          var webhookResponse = await http.post(
              Uri.parse("${ClonerConstants.endpoint}/channels/${channels[1]["id"]}/webhooks"),
              headers: {
                "Authorization": context.read<CloneProvider>().token,
                "Content-Type": "application/json",
              },
              body: jsonEncode({
                "name": "Cloner"
              })
          );

          var webhookJson = jsonDecode(webhookResponse.body);

          debugPrint("WebhookJson: $webhookJson");

          return webhookJson;
        }, [], {});

        if (webhookJson is List) {
          webhookJson = (webhookJson as List).first;
        }

        print("WebhookJson: $webhookJson");

        channelMessagesStream(channels[0]["id"]).listen((message) async {

          dynamic messageContent = "Unknown content";
          dynamic messageUsername = "Unknown username";
          dynamic messageAuthorAvatarUrl = "Unknown avatar";
          dynamic messageEmbeds = "Unknown embeds";
          dynamic messageAttachments = "Unknown attachments";

          await sharedRateLimited(() async {

            if (message != null) {

              messageContent = message["content"] ?? "Unknown content";

              if (message["author"] != null) {

                messageUsername = message["author"]["username"] ?? "Unknown username";
                messageAuthorAvatarUrl = "https://cdn.discordapp.com/avatars/${message["author"]["id"] ?? "Unknown id"}/${message["author"]["avatar"] ?? "Unknown avatar"}.png";

              }

              messageEmbeds = message["embeds"] ?? "Unknown embeds";
              messageAttachments = message["attachments"] ?? "Unknown attachments";

            }

            // await http.post(
            //     Uri.parse("${ClonerConstants.endpoint}/webhooks/${webhookJson["id"]}/${webhookJson["token"]}"),
            //     headers: {
            //       "Authorization": context.read<CloneProvider>().token,
            //       "Content-Type": "application/json",
            //     },
            //     body: jsonEncode({
            //       "content": message["content"],
            //       "username": message["author"]["username"],
            //       "avatar_url": "https://cdn.discordapp.com/avatars/${message["author"]["id"]}/${message["author"]["avatar"]}.png",
            //       "embeds": message["embeds"],
            //       "attachments": message["attachments"]
            //     })
            // );

          }, [], {});

          print("Channel: ${channels[0]["name"]} Message: $messageContent Author: $messageUsername");

        });

      }

    }

  }

  Stream<dynamic> channelMessagesStream(String channelId) async* {

    if (isDisconnected()) {
      return;
    }

    var messagesFromChannel = await sharedRateLimited((String channelId, String limit, String after) async {

      var messageResponse = await http.get(
        Uri.parse("${ClonerConstants.endpoint}/channels/$channelId/messages?limit=$limit&after=$after"),
        headers: {
          "Authorization": context.read<CloneProvider>().token,
          "Content-Type": "application/json",
        },
      );

      debugPrint("LastMessagesResponse: ${messageResponse.body}");

      var messagesJson = jsonDecode(messageResponse.body);

      debugPrint("LastMessagesResponseSerialized: $messagesJson");

      return messagesJson;
    }, [channelId, "1", "1"], {});

    // var messagesFromChannel = await getMessagesFromChannel([channelId, "1", "1"], {});

    print("MessagesFromChannel[0]: $messagesFromChannel");

    var firstMessageJson = (messagesFromChannel is List) ? (messagesFromChannel as List<dynamic>) : messagesFromChannel;

    if (firstMessageJson is List) {

      if (firstMessageJson.isNotEmpty) {

        firstMessageJson = firstMessageJson.first;

        print("MessagesFromChannel[0] Updated: $firstMessageJson");

        yield firstMessageJson;

      }

    } else {

      // firstMessageJson = 0;

      print("MessagesFromChannel[0] Updated: $firstMessageJson");

      yield firstMessageJson;

    }

    var lastMessage = firstMessageJson;

    // debugPrint("First message: ${firstMessageJson.toString()}");

    while (true) {

      // debugPrint("LastMessage: $lastMessage");

      var messagesJson = await sharedRateLimited((String channelId, String limit, String after) async {

        var messageResponse = await http.get(
          Uri.parse("${ClonerConstants.endpoint}/channels/$channelId/messages?limit=$limit&after=$after"),
          headers: {
            "Authorization": context.read<CloneProvider>().token,
            "Content-Type": "application/json",
          },
        );

        var messagesJson = jsonDecode(messageResponse.body);

        return messagesJson;

      }, [channelId, "100", "${lastMessage["id"]}"], {});

      // var messagesJson = await getMessagesFromChannel([channelId, "100", "${lastMessage["id"]}"], {});

      debugPrint("MessagesJSON: $messagesJson");

      if (messagesJson is List) {

        for (var msg in (messagesJson as List<dynamic>).reversed.toList()) {

          debugPrint("Message emitted: $msg");

          yield (msg is List) ? msg.first : msg;

        }

      } else {

        debugPrint("Message emitted: $messagesJson");

        yield messagesJson;

      }

      try {

        lastMessage = (messagesJson as List<dynamic>).reversed.toList().last;

        print("NewLastMessage: $lastMessage");

      } catch (exc) {
        break;
      }

    }

  }

  bool isDisconnected() {

    return !context.read<CloneProvider>().isLoggedIn;

  }

}
