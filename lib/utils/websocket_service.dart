import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  late WebSocketChannel _channel;
  Function(String)? onMessageReceived;
  bool _isConnected = false;

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal() {
    _startWebSocket('ws://christianloach.com:8080'); //server url goeshere
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
