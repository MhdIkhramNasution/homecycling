import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';

class VoucherDetailPage extends StatefulWidget {
  final int voucherId;
  final String title;
  final String image;
  final int points;

  const VoucherDetailPage({
    super.key,
    required this.voucherId,
    required this.title,
    required this.image,
    required this.points,
  });

  @override
  State<VoucherDetailPage> createState() => _VoucherDetailPageState();
}

class _VoucherDetailPageState extends State<VoucherDetailPage> {
  // ── State ──────────────────────────────────────────────
  String? _voucherCode;      // null  → belum di-load
  bool _isLoadingCode = true; // sedang fetch /voucher-code
  bool _isRedeeming = false;  // sedang fetch /redeem-voucher
  bool _isRedeemed = false;   // sudah berhasil redeem

  // ── Lifecycle ──────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadVoucherCode();
  }

  // ── Load existing voucher code (if already redeemed) ──
  Future<void> _loadVoucherCode() async {
    try {
      // Backend: GET /voucher-code/{username}/{voucher_id}
      final response = await http.get(
        Uri.parse(
          "https://backendai-production-b126.up.railway.app/voucher-code"
              "/${UserSession.username}"
              "/${widget.voucherId}",
        ),
      );

      final data = jsonDecode(response.body);
      final code = data["voucher_code"] as String? ?? "";

      if (code.isNotEmpty) {
        setState(() {
          _voucherCode = code;
          _isRedeemed = true;
        });
      }
    } catch (e) {
      debugPrint("voucher-code: $e");
    } finally {
      setState(() => _isLoadingCode = false);
    }
  }

  // ── Redeem voucher ─────────────────────────────────────
  Future<void> _redeemVoucher() async {
    setState(() => _isRedeeming = true);

    try {
      final response = await http.post(
        Uri.parse("https://backendai-production-b126.up.railway.app/redeem-voucher"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": UserSession.username,
          "voucher_id": widget.voucherId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        final code = data["voucher_code"] as String;

        // Update UI langsung — kode muncul di card
        setState(() {
          _voucherCode = code;
          _isRedeemed = true;
        });

        // Tampilkan dialog sukses
        if (mounted) _showSuccessDialog(code);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Redeem gagal")),
          );
        }
      }
    } catch (e) {
      debugPrint("redeem-voucher: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isRedeeming = false);
    }
  }

  // ── Dialog sukses ──────────────────────────────────────
  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Sukses"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Voucher Berhasil Ditukarkan 🎉",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      /// ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF74A830),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                widget.image,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/images/voucher_a_images.png",
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            /// SUB INFO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Special Discount",
                  style: TextStyle(color: Color(0xFF74A830)),
                ),
                Text(
                  "Valid Until 1 Jan 2027",
                  style: TextStyle(color: Color(0xFF74A830)),
                ),
              ],
            ),

            /// ================= VOUCHER CODE CARD =================
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF74A830)),
              ),
              child: Column(
                children: [
                  const Text(
                    "Voucher Code",
                    style: TextStyle(
                      color: Color(0xFF74A830),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Loading state
                  if (_isLoadingCode)
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF74A830),
                      ),
                    )

                  // Kode sudah tersedia
                  else if (_voucherCode != null)
                    Text(
                      _voucherCode!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Color(0xFF577E24),
                      ),
                    )

                  // Belum di-redeem
                  else
                    const Text(
                      "Tap Redeem to get code",
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// ================= HOW TO USE =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF74A830)),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "How to Use",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _rowCheck("Use during checkout"),
                  _rowCheck("Valid before expiration"),
                  _rowCheck("One-time using only"),
                  const Divider(height: 25),
                  const Text(
                    "Terms & Conditions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _rowDot("Not exchangeable for cash"),
                  _rowDot("Cannot be combined with other promotions"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= REDEEM BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRedeemed
                      ? Colors.grey.shade400
                      : const Color(0xFF577E24),
                  foregroundColor: Colors.white,
                ),
                // Nonaktifkan tombol saat loading, redeeming, atau sudah diredeem
                onPressed: (_isLoadingCode || _isRedeeming || _isRedeemed)
                    ? null
                    : _redeemVoucher,
                child: _isRedeeming
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  _isRedeemed
                      ? "Already Redeemed"
                      : "Redeem (${widget.points} pts)",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────
  Widget _rowCheck(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF74A830), size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _rowDot(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF74A830)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}