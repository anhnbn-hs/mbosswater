import 'package:cloud_firestore/cloud_firestore.dart';

class GuaranteeCheck {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<bool> isProductGuaranteeActivated(String productID) async {
    try {
      final querySnapshot = await firebaseFirestore
          .collection("guarantees")
          .where("product.id", isEqualTo: productID)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle errors appropriately (e.g., log the error, show a message, etc.)
      print("Error checking product guarantee: $e");
      return false;
    }
  }
}
