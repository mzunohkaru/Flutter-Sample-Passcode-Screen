import 'dart:async';

import 'package:flutter/material.dart';
import 'package:password_memo_app/utils/utils.dart';
import 'package:password_memo_app/view/home_view.dart';

import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログイン画面"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _defaultLockScreenButton(context),
          ],
        ),
      ),
    );
  }

  _defaultLockScreenButton(BuildContext context) => MaterialButton(
        color: Theme.of(context).primaryColor,
        child: const Text(
          'ロックを解除する',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _showLockScreen(
            context,
            opaque: false,
            cancelButton: const Text(
              'キャンセル',
              style: TextStyle(fontSize: 16, color: Colors.white),
              semanticsLabel: 'Cancel',
            ),
          );
        },
      );

  _showLockScreen(
    BuildContext context, {
    required bool opaque,
    CircleUIConfig? circleUIConfig,
    KeyboardUIConfig? keyboardUIConfig,
    required Widget cancelButton,
    List<String>? digits,
  }) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            title: const Text(
              'パスワードを入力してください',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: const Text(
              '戻す',
              style: TextStyle(fontSize: 16, color: Colors.white),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
            passwordDigits: 6,
            bottomWidget: _buildPasscodeRestoreButton(),
          ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) async {
    bool isValid = storedPasscode == enteredPasscode;
    debugPrint('入力されたパスワード' + enteredPasscode);

    if (isValid) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeView(),
        ),
      );
    } else {
      _verificationNotifier.add(isValid);
    }
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  _buildPasscodeRestoreButton() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0, top: 20.0),
          child: TextButton(
            onPressed: _resetAppPassword,
            child: const Text(
              "パスコードをリセットする",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
            // splashColor: Colors.white.withOpacity(0.4),
            // highlightColor: Colors.white.withOpacity(0.2),
            // ),
          ),
        ),
      );

  _resetAppPassword() {
    Navigator.maybePop(context).then((result) {
      if (!result) {
        return;
      }
      _showRestoreDialog(() {
        Navigator.maybePop(context);
      });
    });
  }

  _showRestoreDialog(VoidCallback onCancel) => QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      animType: QuickAlertAnimType.slideInLeft,
      title: '注意',
      text: 'パスコードをリセットすると元には戻せません。',
      confirmBtnText: '理解しました',
      cancelBtnText: 'キャンセル',
      onConfirmBtnTap: () {},
      onCancelBtnTap: onCancel,
      showCancelBtn: true,
      barrierDismissible: false);
}
