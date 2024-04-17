class Validator {
  static String? validateName({String? name}) {
    if (name == null) {
      return null;
    }
    if (name.isEmpty) {
      return 'Name can\'t be empty';
    }

    return null;
  }

  static String? validateEmail({String? email}) {
    if (email == null) {
      return null;
    }
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Enter a correct email';
    }

    return null;
  }

  static String? validatePassword({String? password}) {
    if (password == null) {
      return null;
    }
    if (password.isEmpty) {
      return 'Password can\'t be empty';
    } else if (password.length < 6) {
      return 'Enter a password with length at least 6';
    }

    return null;
  }

  static String? validateConfirmPassword(
      {String? password, String? confirmPassword}) {
    if (confirmPassword == null) {
      return null;
    }
    if (confirmPassword.isEmpty) {
      return 'Confirm Password can\'t be empty';
    } else if (confirmPassword != password) {
      return 'Passwords don\'t match';
    }

    return null;
  }

  static String? validatePhoneNumber({String? phoneNumber}) {
    if (phoneNumber == null) {
      return null;
    }
    RegExp phoneRegExp = RegExp(r"^\d{10}$");

    if (phoneNumber.isEmpty) {
      return 'Phone Number can\'t be empty';
    } else if (!phoneRegExp.hasMatch(phoneNumber)) {
      return 'Enter a correct phone number';
    }

    return null;
  }

  static String? validateDateOfBirth({String? dateOfBirth}) {
    if (dateOfBirth == null) {
      return null;
    }
    RegExp dateRegExp = RegExp(r"^\d{2}/\d{2}/\d{4}$");

    if (dateOfBirth.isEmpty) {
      return 'Date of Birth can\'t be empty';
    } else if (!dateRegExp.hasMatch(dateOfBirth)) {
      return 'Enter a correct date of birth';
    }

    return null;
  }

  static String? validateNumberInput ({String? number}) {
    if (number == null) {
      return null;
    }
    RegExp numberRegExp = RegExp(r"^\d+$");

    if (number.isEmpty) {
      return 'This field can\'t be empty';
    } else if (!numberRegExp.hasMatch(number)) {
      return 'Enter a correct number';
    }

    return null;
  }

  static String? validateTextInput ({String? text}) {
    if (text == null) {
      return null;
    }

    if (text.isEmpty) {
      return 'This field can\'t be empty';
    }

    return null;
  }
}