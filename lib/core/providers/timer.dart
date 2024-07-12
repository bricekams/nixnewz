import 'dart:async';

import 'package:flutter/cupertino.dart';

class TimerProvider with ChangeNotifier {
  bool canRequestEmailCode = true;
  int emailCodeTimer = 0;

  void startEmailTimer () {
    canRequestEmailCode = false;
    emailCodeTimer = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if(emailCodeTimer<1) {
        canRequestEmailCode = true;
        emailCodeTimer = 0;
        timer.cancel();
      }else {
        emailCodeTimer--;
      }
      notifyListeners();
    });
  }

  set setCanRequestEmailCode(bool value) {
    canRequestEmailCode = value;
    emailCodeTimer = 0;
    notifyListeners();
  }
}
