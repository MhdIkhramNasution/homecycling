import 'package:flutter/material.dart';
import 'goals_page.dart';

class GoalsDetailPage extends StatelessWidget {
  const GoalsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const GoalsPage(),
              ),
            );
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            /// CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    /// BADGE GRID
                    Row(
                      children: [

                        Expanded(
                          child: badgeItem(
                            "assets/icon/Eco-Starter_Badge.png",
                            "Eco-Starter",
                            true,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: badgeItem(
                            "assets/icon/Eco-Hero_Locked_Badge.png",
                            "Eco-Hero",
                            true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    badgeItem(
                      "assets/icon/Eco-Champion_Locked_Badge.png",
                      "Eco-Champion",
                      true,
                    ),

                    const SizedBox(height: 20),

                    /// NEXT BADGE CARD
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF74A830)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF74A830),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Next Badge",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 15),

                          nextBadgeItem(
                            "assets/icon/Eco-Hero_Badge.png",
                            "Eco-Hero",
                            "Reach 3 more levels to unlock this badge",
                          ),

                          const SizedBox(height: 10),

                          nextBadgeItem(
                            "assets/icon/Eco-Champion_Badge.png",
                            "Eco-Champion",
                            "Reach 13 more levels to unlock this badge",
                          ),

                        ],
                      ),
                    )

                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  /// BADGE ITEM
  Widget badgeItem(image, title, unlocked) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF74A830)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          Image.asset(
            image,
            height: 80,
            color: unlocked ? null : Colors.grey,
          ),

          const SizedBox(height: 10),

          Text(title),

        ],
      ),
    );
  }

  /// NEXT BADGE
  Widget nextBadgeItem(image, title, subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        children: [

          Image.asset(image, width: 40),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}