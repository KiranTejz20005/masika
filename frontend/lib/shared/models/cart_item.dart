import 'product.dart';

class CartItem {
  CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get total => product.price * quantity;
}
