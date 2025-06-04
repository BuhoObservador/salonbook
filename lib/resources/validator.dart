class Validator {
  static String? validateName({required String? name}) {
    if (name == null) {
      return null;
    }

    if (name.isEmpty) {
      return 'Please enter your name';
    } else if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null;
  }

  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }

    RegExp emailRegExp = RegExp(r"^\S+@\S+\.\S+$");

    if (email.isEmpty) {
      return "Email is required";
    } else if (!emailRegExp.hasMatch(email)) {
      return "Please enter a valid email";
    }

    return null;
  }

  static String? validatePassword({required String? password, required bool register}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return "Password is required";
    }

    if(register) {
      RegExp passwdRegExp = RegExp(r"^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[\d])(?=.*?[!@#\$&*~_]).{8,}$");
      if (!passwdRegExp.hasMatch(password)) {
        return "Password must contain:\n• At least 8 characters\n• Uppercase & lowercase letters\n• At least one number\n• At least one special character";
      }
    }

    return null;
  }

  static String? validatePhoneNumber({required String? phoneNumber}) {
    if (phoneNumber == null) {
      return null;
    }

    if (phoneNumber.isEmpty) {
      return "Phone number is required";
    }

    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 6 || digitsOnly.length > 15) {
      return "Please enter a valid phone number";
    }

    return null;
  }
}