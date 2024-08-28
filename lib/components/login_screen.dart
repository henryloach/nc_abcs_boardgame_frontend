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
  final TextEditingController _usernameController = TextEditingController();
  NetworkOption _networkOption = NetworkOption.network;
  bool _showInvalidUsername = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black87,
      title: const Text(
        "Northchess",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _buildLogo(),
            const SizedBox(height: 32),
            _buildStartGameForm(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        SvgPicture.asset(
          "assets/svg/black-pawn.svg",
          width: 100,
          colorFilter: const ColorFilter.mode(
            Colors.black87,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Northchess",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStartGameForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildUsernameInput(),
        if (_showInvalidUsername) _buildInvalidUsernameError(),
        const SizedBox(height: 24),
        _buildNetworkOptions(),
        const SizedBox(height: 24),
        _buildStartGameButton(),
      ],
    );
  }

  Widget _buildUsernameInput() {
    return TextFormField(
      controller: _usernameController,
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

  Widget _buildInvalidUsernameError() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          "* Username cannot be less than 3 letters",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNetworkOption(NetworkOption.network, 'Multiplayer'),
        const SizedBox(width: 16),
        _buildNetworkOption(NetworkOption.oneComputer, 'Offline'),
      ],
    );
  }

  Widget _buildNetworkOption(NetworkOption option, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: option,
          groupValue: _networkOption,
          onChanged: (NetworkOption? value) {
            setState(() {
              _networkOption = value!;
            });
          },
        ),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildStartGameButton() {
    return ElevatedButton(
      onPressed: _handleStartGame,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.black87,
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          "Start Game",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleStartGame() {
    setState(() {
      _showInvalidUsername = false;
    });

    if (_isUsernameValid()) {
      _startGame();
    } else {
      setState(() {
        _showInvalidUsername = true;
      });
    }
  }

  bool _isUsernameValid() {
    return _usernameController.text.length > 2;
  }

  void _startGame() {
    user.username = _usernameController.text;

    if (_networkOption == NetworkOption.network) {
      _webSocketService.sendMessage('user:${user.username}');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return GameScreen(
            username: _usernameController.text,
            networkOption: _networkOption,
          );
        },
      ),
    );
  }
}

enum NetworkOption { network, oneComputer }
