import 'package:flutter/material.dart';
import 'package:nc_abcs_boardgame_frontend/components/game_screen.dart';
import 'package:nc_abcs_boardgame_frontend/utils/websocket_service.dart';
import 'package:nc_abcs_boardgame_frontend/game/user.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final WebSocketService _webSocketService = WebSocketService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(context),
                  _input(context, _webSocketService),
                ],
              ))),
    );
  }
}

_header(context) {
  return const Column(
    children: [
      Text(
        "Welcome to ABCs' Chess Game!",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

_input(context, webSocketService) {
  final controller = TextEditingController();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
            hintText: "Username",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person)),
      ),
      const SizedBox(
        height: 10,
      ),
      ElevatedButton(
        onPressed: () {
          if (controller.text.isNotEmpty) {
            user.username = controller.text;
            webSocketService.sendMessage('user:${user.username}');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GameScreen(username: controller.text)));
          } else {
            showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Please enter your username'),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.purple,
        ),
        child: const Text(
          "Start the game",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    ],
  );
}


// move: move
// or
// username:  
// or
// action: resign / offerDraw

// [command, payload] = message.split(":")

// if (command == move)  