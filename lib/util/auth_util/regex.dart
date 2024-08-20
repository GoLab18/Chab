/// Returns an error message regarding email's requirements,
/// if all are met, falls back to a null value
String? validateEmail(String? email) {
  if (email!.isEmpty) {
    return "Email must be provided";
  } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(email)) {
    return "Incorrect email";
  }

  // Email is valid
  return null;
}

/// Returns an error message regarding password's requirements,
/// if all are met, falls back to a null value
String? validatePassword(String? password) {
  if (password!.isEmpty) return 'Password must be provided';
  
  if (!RegExp(r'^.{8,}$').hasMatch(password)) {
    return 'At least 8 characters long';
  }
  if (!RegExp(r'^(?=.*?[A-Z])').hasMatch(password)) {
    return 'At least one uppercase letter';
  }
  if (!RegExp(r'^(?=.*?[a-z])').hasMatch(password)) {
    return 'At least one lowercase letter';
  }
  if (!RegExp(r'^(?=.*?[0-9])').hasMatch(password)) {
    return 'At least one digit';
  }
  if (!RegExp(r'^(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])').hasMatch(password)) {
    return 'At least one special character';
  }

  // Password is valid
  return null;
}

/// Returns an error message regarding confirmation password's requirements,
/// if all are met, falls back to a null value
String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (password!.isEmpty) return 'Password must be confirmed';

  if (password != confirmPassword) return 'Passwords don\'t match';

  // Confirmation password is valid
  return null;
}

/// Returns an error message regarding username's requirements,
/// if all are met, falls back to a null value
String? validateUsername(String? name) {
  if (name!.isEmpty) return 'Username must be provided';

  // Username valid
  return null;
}
