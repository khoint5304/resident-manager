import "package:flutter/material.dart";
import "package:flutter_localization/flutter_localization.dart";
import "package:fluttertoast/fluttertoast.dart";

import "config.dart";
import "translations.dart";

/// Screen width breakpoints from https://getbootstrap.com/docs/5.0/layout/breakpoints/
class ScreenWidth {
  static const SMALL = 576;
  static const MEDIUM = 768;
  static const LARGE = 992;
  static const EXTRA_LARGE = 1200;
  static const EXTRA_EXTRA_LARGE = 1400;
}

class Date {
  final int year;
  final int month;
  final int day;

  const Date(this.year, this.month, this.day);

  Date.fromDateTime(DateTime datetime)
      : year = datetime.year,
        month = datetime.month,
        day = datetime.day;

  Date.now() : this.fromDateTime(DateTime.now());

  String format(String fmt) {
    fmt = fmt.replaceAll("yyyy", year.toString());
    fmt = fmt.replaceAll("mm", month.toString().padLeft(2, "0"));
    fmt = fmt.replaceAll("dd", day.toString().padLeft(2, "0"));
    return fmt;
  }

  String toJson() => format("yyyy-mm-dd");

  DateTime toDateTime() => DateTime(year, month, day);

  @override
  String toString() => format("yyyy-mm-dd");

  /// Parse string in format `yyyy*mm*dd`.
  static Date? parse(String str) {
    try {
      return Date(
        int.parse(str.substring(0, 4)),
        int.parse(str.substring(5, 7)),
        int.parse(str.substring(8, 10)),
      );
    } catch (_) {
      return null;
    }
  }

  /// Parse string in format `dd*mm*yyyy`.
  static Date? parseFriendly(String str) {
    try {
      return Date(
        int.parse(str.substring(6, 10)),
        int.parse(str.substring(3, 5)),
        int.parse(str.substring(0, 2)),
      );
    } catch (_) {
      return null;
    }
  }
}

Future<bool> showToastSafe({
  required String msg,
  Toast? toastLength,
  int timeInSecForIosWeb = 1,
  double? fontSize,
  String? fontAsset,
  ToastGravity? gravity,
  Color? backgroundColor,
  Color? textColor,
  bool webShowClose = false,
  dynamic webBgColor = "linear-gradient(to right, #00b09b, #96c93d)",
  dynamic webPosition = "right",
}) async {
  try {
    // Fluttertoast.showToast hang in flutter test? No issue URLs found yet.
    return await Fluttertoast.showToast(
          msg: msg,
          toastLength: toastLength,
          timeInSecForIosWeb: timeInSecForIosWeb,
          fontSize: fontSize,
          fontAsset: fontAsset,
          gravity: gravity,
          backgroundColor: backgroundColor,
          textColor: textColor,
          webShowClose: webShowClose,
          webBgColor: webBgColor,
          webPosition: webPosition,
        ) ??
        false;
  } catch (_) {
    return false;
  }
}

DateTime fromEpoch(Duration dt) {
  return epoch.add(dt);
}

DateTime snowflakeTime(int id) {
  return fromEpoch(Duration(milliseconds: id >> (8 * 3)));
}

class FieldLabel extends StatelessWidget {
  final String _label;
  final TextStyle? _style;
  final bool _required;

  const FieldLabel(String label, {super.key, TextStyle? style, bool required = false})
      : _label = label,
        _style = style,
        _required = required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: _label,
        style: _style,
        children: _required ? const [TextSpan(text: " *", style: TextStyle(color: Colors.red))] : [],
      ),
    );
  }
}

String? nameValidator(BuildContext context, {required bool required, required String? value}) {
  if (value == null || value.isEmpty) {
    if (required) {
      return AppLocale.MissingName.getString(context);
    }

    return null;
  }

  if (value.length > 255) {
    return AppLocale.InvalidNameLength.getString(context);
  }

  return null;
}

String? roomValidator(BuildContext context, {required bool required, required String? value}) {
  if (value == null || value.isEmpty) {
    if (required) {
      return AppLocale.MissingRoomNumber.getString(context);
    }

    return null;
  }

  final pattern = RegExp(r"^\d{1,6}$");
  if (!pattern.hasMatch(value)) {
    return AppLocale.InvalidRoomNumber.getString(context);
  }

  final roomInt = int.parse(value);
  if (roomInt < 0 || roomInt > 32767) {
    return AppLocale.InvalidRoomNumber.getString(context);
  }

  return null;
}

String? phoneValidator(BuildContext context, {required String? value}) {
  if (value != null && value.isNotEmpty) {
    final pattern = RegExp(r"^\+?[\d\s]+$");
    if (value.length > 15 || !pattern.hasMatch(value)) {
      return AppLocale.InvalidPhoneNumber.getString(context);
    }
  }

  return null;
}

String? emailValidator(BuildContext context, {required String? value}) {
  if (value != null && value.isNotEmpty) {
    final pattern = RegExp(r"^[\w\.-]+@[\w\.-]+\.[\w\.]+[\w\.]?$");
    if (value.length > 255 || !pattern.hasMatch(value)) {
      return AppLocale.InvalidEmail.getString(context);
    }
  }

  return null;
}

String? usernameValidator(BuildContext context, {required bool required, required String? value}) {
  if (value == null || value.isEmpty) {
    if (required) {
      return AppLocale.MissingUsername.getString(context);
    }

    return null;
  }

  if (value.length > 255) {
    return AppLocale.InvalidUsernameLength.getString(context);
  }

  return null;
}

String? passwordValidator(BuildContext context, {required bool required, required String? value}) {
  if (value == null || value.isEmpty) {
    if (required) {
      return AppLocale.MissingPassword.getString(context);
    }

    return null;
  }

  if (value.length < 8 || value.length > 255) {
    return AppLocale.InvalidPasswordLength.getString(context);
  }

  return null;
}

String? roomAreaValidator(BuildContext context, {required bool required, required String? value}) {
  if (value == null || value.isEmpty) {
    if (required) {
      return AppLocale.MissingRoomArea.getString(context);
    }

    return null;
  }

  final pattern = RegExp(r"^\d{1,9}$");
  if (!pattern.hasMatch(value)) {
    return AppLocale.InvalidRoomArea.getString(context);
  }

  final roomAreaInt = int.parse(value);
  if (roomAreaInt < 0 || roomAreaInt > 21474835) {
    return AppLocale.InvalidRoomArea.getString(context);
  }

  return null;
}

String? motorbikesCountValidator(BuildContext context, {required bool required, required String? value}) {
  if (value == null || value.isEmpty) {
    if (required) {
      return AppLocale.MissingMotorbikesCount.getString(context);
    }

    return null;
  }

  final pattern = RegExp(r"^\d{1,4}$");
  if (!pattern.hasMatch(value)) {
    return AppLocale.InvalidMotorbikesCount.getString(context);
  }

  final motorbikesCountInt = int.parse(value);
  if (motorbikesCountInt < 0 || motorbikesCountInt > 255) {
    return AppLocale.InvalidMotorbikesCount.getString(context);
  }

  return null;
}

String? carsCountValidator(BuildContext context, {required bool required, required String? value}) {
  if (value == null || value.isEmpty) {
    if (required) {
      return AppLocale.MissingCarsCount.getString(context);
    }

    return null;
  }

  final pattern = RegExp(r"^\d{1,4}$");
  if (!pattern.hasMatch(value)) {
    return AppLocale.InvalidCarsCount.getString(context);
  }

  final carsCountInt = int.parse(value);
  if (carsCountInt < 0 || carsCountInt > 255) {
    return AppLocale.InvalidCarsCount.getString(context);
  }

  return null;
}
