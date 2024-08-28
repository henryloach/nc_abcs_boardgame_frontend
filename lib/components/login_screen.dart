import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nc_abcs_boardgame_frontend/components/game_screen.dart';
import 'package:nc_abcs_boardgame_frontend/utils/websocket_service.dart';
import 'package:nc_abcs_boardgame_frontend/game/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final WebSocketService _webSocketService = WebSocketService();

  NetworkOption? networkOption = NetworkOption.network;

  final controller = TextEditingController();

  final mainColor = Colors.red;

  bool showInvalidUsername = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: const Text(
            "Northchess",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const PawnIcon(),
                const SizedBox(height: 10),
                const Heading(),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InputField(controller: controller),
                    if (showInvalidUsername) ...[
                      const InvalidUsernameError(),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<NetworkOption>(
                              value: NetworkOption.network,
                              groupValue: networkOption,
                              onChanged: (NetworkOption? value) {
                                setState(() {
                                  networkOption = value;
                                });
                              },
                            ),
                            const Text(
                              'Multiplayer',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<NetworkOption>(
                              value: NetworkOption.oneComputer,
                              groupValue: networkOption,
                              onChanged: (NetworkOption? value) {
                                setState(() {
                                  networkOption = value;
                                });
                              },
                            ),
                            const Text(
                              'Offline',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showInvalidUsername = false;
                        });
                        if (controller.text.length > 2) {
                          user.username = controller.text;
                          if (networkOption == NetworkOption.network) {
                            _webSocketService
                                .sendMessage('user:${user.username}');
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                username: controller.text,
                                networkOption: networkOption!,
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            showInvalidUsername = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black87,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "Start Game",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InvalidUsernameError extends StatelessWidget {
  const InvalidUsernameError({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            "* Username cannot be less than 3 letters",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}

class PawnIcon extends StatelessWidget {
  const PawnIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/svg/black-pawn.svg",
      width: 100,
      colorFilter: const ColorFilter.mode(
        Colors.black87,
        BlendMode.srcIn,
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "Username",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide.none),
        fillColor: Colors.black12,
        filled: true,
        prefixIcon: const Icon(Icons.person),
      ),
    );
  }
}

class Heading extends StatelessWidget {
  const Heading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Northchess",
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w900,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }
}

enum NetworkOption { network, oneComputer }


// move: move
// or
// username:  
// or
// action: resign / offerDraw

// [command, payload] = message.split(":")

// if (command == move)  