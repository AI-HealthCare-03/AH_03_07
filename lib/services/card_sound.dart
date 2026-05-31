// 조건부 import — dart:js를 직접 import하지 않음 (Android/iOS 빌드 보호)
export 'card_sound_stub.dart'
    if (dart.library.js) 'card_sound_web.dart';
