import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() =>
      _NotificationPageState();
}

class _NotificationPageState
    extends State<NotificationPage> {

  List notifications = [];

  @override
  void initState() {
    super.initState();

    loadNotifications();
  }

  Future<void> loadNotifications() async {

    final data =
    await NotificationService
        .getNotifications();

    setState(() {

      notifications = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(
        0xFFF5F5F5,
      ),

      appBar: AppBar(

        title: const Text(
          "Notifications",
        ),

        backgroundColor:
        const Color(0xFF74A830),
      ),

      body: RefreshIndicator(

        onRefresh: loadNotifications,

        child: notifications.isEmpty

            ? ListView(

          children: const [

            SizedBox(height: 250),

            Center(
              child: Text(
                "No notifications",
              ),
            ),
          ],
        )

            : ListView.builder(

          itemCount:
          notifications.length,

          itemBuilder:
              (context, index) {

            final item =
            notifications[index];

            final isDanger =
                item["type"] ==
                    "danger";

            return Card(

              margin:
              const EdgeInsets.all(12),

              child: ListTile(

                leading: Icon(

                  isDanger
                      ? Icons.error
                      : Icons.warning,

                  color: isDanger
                      ? Colors.red
                      : Colors.orange,
                ),

                title: Text(
                  item["title"],
                ),

                subtitle: Text(
                  item["message"],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}