import 'package:user_repository/user_repository.dart';

/// Room naming utility class.
class RoomNameUtil {

  /// Returns a [String] of joined [Usr]s list.
  static String getUserNames(List<Usr> users) {
    int maxChars = 33;
    String finalString = "";

    for (Usr user in users) {
      String newChars = "${user.name}, ";

      if (finalString.length + newChars.length <= maxChars) {
        finalString += newChars;
      } else {
        return finalString.substring(0, finalString.length - 2);
      }
    }
    
    return finalString.substring(0, finalString.length - 2);
  }
}