// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Create username:`
  String get createUsername {
    return Intl.message(
      'Create username:',
      name: 'createUsername',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Create passcode`
  String get createPasscode {
    return Intl.message(
      'Create passcode',
      name: 'createPasscode',
      desc: '',
      args: [],
    );
  }

  /// `Repeat passcode`
  String get repeatPasscode {
    return Intl.message(
      'Repeat passcode',
      name: 'repeatPasscode',
      desc: '',
      args: [],
    );
  }

  /// `Enter passcode`
  String get enterPasscode {
    return Intl.message(
      'Enter passcode',
      name: 'enterPasscode',
      desc: '',
      args: [],
    );
  }

  /// `type...`
  String get hint {
    return Intl.message(
      'type...',
      name: 'hint',
      desc: '',
      args: [],
    );
  }

  /// `User with this username is already exist`
  String get userExistError {
    return Intl.message(
      'User with this username is already exist',
      name: 'userExistError',
      desc: '',
      args: [],
    );
  }

  /// `Passcode did not match`
  String get passcodeNotMatch {
    return Intl.message(
      'Passcode did not match',
      name: 'passcodeNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Invalid passcode`
  String get invalidPasscode {
    return Intl.message(
      'Invalid passcode',
      name: 'invalidPasscode',
      desc: '',
      args: [],
    );
  }

  /// `User does not exist or passcode is incorrect`
  String get loginFailure {
    return Intl.message(
      'User does not exist or passcode is incorrect',
      name: 'loginFailure',
      desc: '',
      args: [],
    );
  }

  /// `Hello to`
  String get labelHelloTo {
    return Intl.message(
      'Hello to',
      name: 'labelHelloTo',
      desc: '',
      args: [],
    );
  }

  /// `!`
  String get labelExclamationSign {
    return Intl.message(
      '!',
      name: 'labelExclamationSign',
      desc: '',
      args: [],
    );
  }

  /// `Please save this file to be able to back up your account later.`
  String get labelPleaseSaveThisFile {
    return Intl.message(
      'Please save this file to be able to back up your account later.',
      name: 'labelPleaseSaveThisFile',
      desc: '',
      args: [],
    );
  }

  /// `Address:`
  String get labelAddress {
    return Intl.message(
      'Address:',
      name: 'labelAddress',
      desc: '',
      args: [],
    );
  }

  /// `Username:`
  String get labelUsername {
    return Intl.message(
      'Username:',
      name: 'labelUsername',
      desc: '',
      args: [],
    );
  }

  /// `unknown`
  String get labelUnknown {
    return Intl.message(
      'unknown',
      name: 'labelUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get labelContinue {
    return Intl.message(
      'Continue',
      name: 'labelContinue',
      desc: '',
      args: [],
    );
  }

  /// `Identify`
  String get labelIdentify {
    return Intl.message(
      'Identify',
      name: 'labelIdentify',
      desc: '',
      args: [],
    );
  }

  /// `Contact List`
  String get labelContactList {
    return Intl.message(
      'Contact List',
      name: 'labelContactList',
      desc: '',
      args: [],
    );
  }

  /// `Users nearby`
  String get labelUsersNearby {
    return Intl.message(
      'Users nearby',
      name: 'labelUsersNearby',
      desc: '',
      args: [],
    );
  }

  /// `Add this user to Contact List?`
  String get labelAddThisUserToContactList {
    return Intl.message(
      'Add this user to Contact List?',
      name: 'labelAddThisUserToContactList',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get labelNo {
    return Intl.message(
      'No',
      name: 'labelNo',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get labelYes {
    return Intl.message(
      'Yes',
      name: 'labelYes',
      desc: '',
      args: [],
    );
  }

  /// `Can't find any users nearby`
  String get labelCantFindAnyUsersNearby {
    return Intl.message(
      'Can\'t find any users nearby',
      name: 'labelCantFindAnyUsersNearby',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get labelSend {
    return Intl.message(
      'Send',
      name: 'labelSend',
      desc: '',
      args: [],
    );
  }

  /// `Pick File`
  String get pickFile {
    return Intl.message(
      'Pick File',
      name: 'pickFile',
      desc: '',
      args: [],
    );
  }

  /// `Volla Messenger`
  String get vollaMessenger {
    return Intl.message(
      'Volla Messenger',
      name: 'vollaMessenger',
      desc: '',
      args: [],
    );
  }

  /// `Secured By`
  String get securedBy {
    return Intl.message(
      'Secured By',
      name: 'securedBy',
      desc: '',
      args: [],
    );
  }

  /// `Enter your username`
  String get enterUserName {
    return Intl.message(
      'Enter your username',
      name: 'enterUserName',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message(
      'User',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `Message...`
  String get message {
    return Intl.message(
      'Message...',
      name: 'message',
      desc: '',
      args: [],
    );
  }

  /// `Radio`
  String get radio {
    return Intl.message(
      'Radio',
      name: 'radio',
      desc: '',
      args: [],
    );
  }

  /// `Frequency`
  String get Frequency {
    return Intl.message(
      'Frequency',
      name: 'Frequency',
      desc: '',
      args: [],
    );
  }

  /// `Tx Power`
  String get txPower {
    return Intl.message(
      'Tx Power',
      name: 'txPower',
      desc: '',
      args: [],
    );
  }

  /// `Channel`
  String get Channel {
    return Intl.message(
      'Channel',
      name: 'Channel',
      desc: '',
      args: [],
    );
  }

  /// `Channel spacing`
  String get ChannelSpacing {
    return Intl.message(
      'Channel spacing',
      name: 'ChannelSpacing',
      desc: '',
      args: [],
    );
  }

  /// `OFDM Option`
  String get OFDMOption {
    return Intl.message(
      'OFDM Option',
      name: 'OFDMOption',
      desc: '',
      args: [],
    );
  }

  /// `OFDM MCS`
  String get OFDMRate {
    return Intl.message(
      'OFDM MCS',
      name: 'OFDMRate',
      desc: '',
      args: [],
    );
  }

  /// `Option 1`
  String get opt1 {
    return Intl.message(
      'Option 1',
      name: 'opt1',
      desc: '',
      args: [],
    );
  }

  /// `Option 2`
  String get opt2 {
    return Intl.message(
      'Option 2',
      name: 'opt2',
      desc: '',
      args: [],
    );
  }

  /// `Option 3`
  String get opt3 {
    return Intl.message(
      'Option 3',
      name: 'opt3',
      desc: '',
      args: [],
    );
  }

  /// `Option 4`
  String get opt4 {
    return Intl.message(
      'Option 4',
      name: 'opt4',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
