class ErrorCheck {
  static bool validateEmail(String input) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    final RegExp phoneRegExp = RegExp(
      r'^\+?[0-9]{7,15}$',
    );

    return emailRegExp.hasMatch(input) || phoneRegExp.hasMatch(input);
  }

  static bool validatePassword(String password) {
    return password.length >= 8;
  }

  static bool validatePhone(String password) {
    return password.length >= 11;
  }

  static bool validateName(String password) {
    return password.isNotEmpty;
  }
}
