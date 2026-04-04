import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../core/network/api_client.dart';

class RazorpayService {
  late Razorpay _razorpay;
  String orderId = "";

  void init({required Function() onWaiting}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (_) {
      onWaiting(); // wait for webhook
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (_) {
      onWaiting(); // still wait (webhook will say failed)
    });
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> createOrder({required String userId}) async {
    try {
      log("Create order started");

      final res = await http.post(
        Uri.parse(createOrderApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to create order: ${res.statusCode}");
      }

      final data = jsonDecode(res.body);

      if (data == null || data["order_id"] == null) {
        throw Exception("Invalid response from server");
      }

      orderId = data["order_id"];
      log(data.toString());

      _razorpay.open({
        "key": "rzp_live_SXwi1jtJbTmZIR",
        "amount": data["amount"],
        "order_id": data["order_id"],
        "name": "Joining Fee",
        "description": "User joining payment",
        "prefill": {"contact": "9999999999", "email": "test@gmail.com"},
      });
    } catch (e, stackTrace) {
      log("Create order error: $e");
      log("StackTrace: $stackTrace");

      // yahan UI error bhi dikha sakte ho
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Payment failed. Please try again")),
      // );
    }
  }

  Future<void> createOrder2() async {
    try {
      log("Create order started");

      final res = await ApiClient.post("/payments/create-order-pataint", {});

      final data = res;

      if (data == null || data["order_id"] == null) {
        throw Exception("Invalid response from server");
      }

      orderId = data["order_id"];
      log(data.toString());

      _razorpay.open({
        "key": "rzp_live_SXwi1jtJbTmZIR",
        "amount": data["amount"],
        "order_id": data["order_id"],
        "name": "Joining Fee",
        "description": "User joining payment",
        "prefill": {"contact": "9999999999", "email": "test@gmail.com"},
      });
    } catch (e, stackTrace) {
      log("Create order error: $e");
      log("StackTrace: $stackTrace");

      // yahan UI error bhi dikha sakte ho
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Payment failed. Please try again")),
      // );
    }
  }

  Future<String> checkStatus({required BuildContext context}) async {
    final res = await http.get(Uri.parse("$paymentStatusApi/$orderId"));

    final data = jsonDecode(res.body);

    return data["status"];
  }
}
