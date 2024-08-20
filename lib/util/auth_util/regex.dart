/// Returns an error message regarding email's requirements
/// If all are met, falls back to a null value
String? validateEmail(String? email) {
  if (email!.isEmpty) {
    return "Email must be provided";
  } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(email)) {
    return "Incorrect email";
  }

  // Email is valid
  return null;
}

/// Returns an error message regarding password's requirements
/// If all are met, falls back to a null value
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
