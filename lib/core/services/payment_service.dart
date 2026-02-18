import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  PaymentService() {
    _razorpay = Razorpay();
  }

  late Razorpay _razorpay;

  void dispose() {
    _razorpay.clear();
  }

  void openCheckout({
    required int amountPaise,
    required String name,
    required String description,
    required String email,
    required String contact,
    required void Function(String paymentId) onSuccess,
    required void Function(String message) onError,
  }) {
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) => onSuccess(response.paymentId ?? ''),
    );
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (PaymentFailureResponse response) =>
          onError(response.message ?? 'Payment failed'),
    );
    final options = {
      'key': 'rzp_test_1234567890',
      'amount': amountPaise,
      'name': name,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
    };
    _razorpay.open(options);
  }
}
