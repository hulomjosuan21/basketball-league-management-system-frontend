import 'package:flutter/material.dart';

class PaymentCancelledScreen extends StatelessWidget {
  const PaymentCancelledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Cancelled")),
      body: const Center(
        child: Text("❌ Your payment was cancelled."),
      ),
    );
  }
}
