import 'package:flutter/material.dart';
import 'shop_page.dart';

class BuyVoucherPage extends StatefulWidget {
  const BuyVoucherPage({super.key});

  @override
  State<BuyVoucherPage> createState() => _BuyVoucherPageState();
}

class _BuyVoucherPageState extends State<BuyVoucherPage> {
  bool isChecked = false;

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
              MaterialPageRoute(builder: (_) => const ShopPage()),
            );
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ================= IMAGE =================
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          "assets/images/buy_voucher_term.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ================= TITLE =================
                    const Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// ================= TEXT =================
                    const Text(
                      "The voucher applies a Rp1,000 discount on every purchase.",
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "• Valid until December 31, 2026\n"
                      "• Can only be used once per transaction.\n"
                      "• Cannot be combined with other promotions.\n"
                      "• Cannot be exchanged for cash or other products.\n"
                      "• Expired vouchers cannot be used again.",
                      style: TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 30),

                    /// ================= CHECKBOX =================
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: const Color(0xFF74A830),
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            "I agree to the terms & conditions",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// ================= BUTTON =================
                    GestureDetector(
                      onTap: isChecked
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Voucher Purchased!"),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: isChecked
                              ? const Color(0xFF577E24)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "Buy Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
