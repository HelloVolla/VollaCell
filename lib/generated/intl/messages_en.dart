// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "createPasscode":
            MessageLookupByLibrary.simpleMessage("Create passcode"),
        "createUsername":
            MessageLookupByLibrary.simpleMessage("Create username:"),
        "enterPasscode": MessageLookupByLibrary.simpleMessage("Enter passcode"),
        "hint": MessageLookupByLibrary.simpleMessage("type..."),
        "invalidPasscode":
            MessageLookupByLibrary.simpleMessage("Invalid passcode"),
        "labelAddThisUserToContactList": MessageLookupByLibrary.simpleMessage(
            "Add this user to Contact List?"),
        "labelAddress": MessageLookupByLibrary.simpleMessage("Address:"),
        "labelCantFindAnyUsersNearby": MessageLookupByLibrary.simpleMessage(
            "Can\'t find any users nearby"),
        "labelContactList":
            MessageLookupByLibrary.simpleMessage("Contact List"),
        "labelContinue": MessageLookupByLibrary.simpleMessage("Continue"),
        "labelExclamationSign": MessageLookupByLibrary.simpleMessage("!"),
        "labelHelloTo": MessageLookupByLibrary.simpleMessage("Hello to"),
        "labelIdentify": MessageLookupByLibrary.simpleMessage("Identify"),
        "labelNo": MessageLookupByLibrary.simpleMessage("No"),
        "labelPleaseSaveThisFile": MessageLookupByLibrary.simpleMessage(
            "Please save this file to be able to back up your account later."),
        "labelSend": MessageLookupByLibrary.simpleMessage("Send"),
        "labelUnknown": MessageLookupByLibrary.simpleMessage("unknown"),
        "labelUsername": MessageLookupByLibrary.simpleMessage("Username:"),
        "labelUsersNearby":
            MessageLookupByLibrary.simpleMessage("Users nearby"),
        "labelYes": MessageLookupByLibrary.simpleMessage("Yes"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginFailure": MessageLookupByLibrary.simpleMessage(
            "User does not exist or passcode is incorrect"),
        "passcodeNotMatch":
            MessageLookupByLibrary.simpleMessage("Passcode did not match"),
        "pickFile": MessageLookupByLibrary.simpleMessage("Pick File"),
        "repeatPasscode":
            MessageLookupByLibrary.simpleMessage("Repeat passcode"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "userExistError": MessageLookupByLibrary.simpleMessage(
            "User with this username is already exist"),
        "username": MessageLookupByLibrary.simpleMessage("Username")
      };
}
