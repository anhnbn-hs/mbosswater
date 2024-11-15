import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/user_info/data/datasource/user_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class UserDatasourceImpl extends UserDatasource {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> fetchUserInformation(String userID) async {
    try {
      // Fetch the user document from Firestore by userID
      DocumentSnapshot userSnapshot =
          await _firebaseFirestore.collection('users').doc(userID).get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      print("Error fetching user information: $e");
      throw Exception("Failed to fetch user information");
    }
  }
}
