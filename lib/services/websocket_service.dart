import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  static IOWebSocketChannel? channel;

  static bool isConnected = false;

  static void connect(
      String username,
      Function(Map<String, dynamic>) onMessage,
      ) {
    try {
      print("================================");
      print("CONNECTING WEBSOCKET");
      print("USERNAME : $username");
      print("================================");

      channel = IOWebSocketChannel.connect(
        Uri.parse(
          'wss://backendai-production-b126.up.railway.app/ws/$username',
        ),
      );

      channel!.stream.listen(
            (data) {
          print("WS MESSAGE : $data");

          try {
            final decoded = jsonDecode(data);

            if (decoded is Map<String, dynamic>) {
              onMessage(decoded);
            }
          } catch (e) {
            print("JSON ERROR : $e");
          }
        },

        onError: (error) {
          isConnected = false;

          print("================================");
          print("WS ERROR");
          print(error);
          print("================================");
        },

        onDone: () {
          isConnected = false;

          print("================================");
          print("WS CLOSED");
          print("================================");
        },

        cancelOnError: true,
      );

      isConnected = true;

      print("WS CONNECTED");
    } catch (e) {
      print("CONNECT ERROR : $e");
    }
  }

  static void send(String message) {
    if (channel != null && isConnected) {
      try {
        channel!.sink.add(message);
      } catch (e) {
        print("SEND ERROR : $e");
      }
    }
  }

  static void disconnect() {
    try {
      channel?.sink.close();
      isConnected = false;

      print("WS DISCONNECTED");
    } catch (e) {
      print("DISCONNECT ERROR : $e");
    }
  }
}