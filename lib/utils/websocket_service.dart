import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:nc_abcs_boardgame_frontend/game/user.dart';
import 'package:nc_abcs_boardgame_frontend/game/server_state.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  late WebSocketChannel _channel;
  Function(String)? onMessageReceived;
  bool _isConnected = false;

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal() {
    _startWebSocket('ws://192.168.1.108:8080'); //server url goeshere
  }

  // TODO remove all these print statements maybe at some point

  void _startWebSocket(String url) async {
    if (_isConnected) return;

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;

    try {
      await _channel.ready;
      print('Connected to WebSocket');

      _channel.stream.listen(
        (message) {
          print('Received: $message');
          if (onMessageReceived != null) {
            onMessageReceived!(message);
            if (message.contains("user")) {
              final username = message.split(":")[1];
              final pieces = message.split(":")[2];
              print(message);
              if (user.username == username) {
                server.myUsername = username;
                server.myPieces = pieces;
                print("me: ${server.myUsername}, ${server.myPieces}");
              } else {
                server.opponentUsername = username;
                server.opponentPieces = pieces;
                print(
                    "ot: ${server.opponentUsername}, ${server.opponentPieces}");
              }
            }
          }
        },
        onDone: () {
          print("WebSocket closed");
          _isConnected = false;
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
      );
    } catch (error) {
      print('Error connecting to WebSocket: $error');
      _isConnected = false;
    }
  }

  void sendMessage(String message) {
    if (_channel.closeCode == null) {
      _channel.sink.add(message);
      print('Sent: $message');
    } else {
      print('WebSocket is closed. Cannot send message');
    }
  }

  void closeWebSocket() {
    _channel.sink.close();
    _isConnected = false;
    print('WebSocket closed');
  }
}
