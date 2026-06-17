import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class WebSocketService {

  static IOWebSocketChannel? channel;

  static void connect(
      String username,
      Function(Map<String, dynamic>) onMessage,
      ) {

    print(
        "Connecting WS : $username"
    );

    channel = IOWebSocketChannel.connect(
      'ws://192.168.100.7:8000/ws/$username',
    );

    channel!.stream.listen(

          (data) {

        print(
            "WS MESSAGE : $data"
        );

        onMessage(
          jsonDecode(data),
        );
      },

      onError: (e) {

        print(
            "WS ERROR : $e"
        );
      },

      onDone: () {

        print(
            "WS CLOSED"
        );
      },
    );

    // keep alive
    channel!.sink.add(
        "connected"
    );
  }

  static void disconnect() {

    channel?.sink.close();
  }
}