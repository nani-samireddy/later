import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/speech/speech_model_store.dart';
import 'package:later/core/speech/voice_capture_controller.dart';

import 'voice_fake_session.dart';

void main() {
  test(
    'permission denial preserves manual draft and retry reaches listening',
    () async {
      final session = FakeVoiceSession()..denyPermission = true;
      final controller = VoiceCaptureController(
        session: session,
        initialText: 'pay 200 for books',
      );
      await controller.start();
      expect(controller.phase, VoiceCapturePhase.error);
      expect(controller.error, contains('denied'));
      expect(controller.text, 'pay 200 for books');
      expect(controller.canApply, true);
      session.denyPermission = false;
      await controller.start();
      expect(controller.phase, VoiceCapturePhase.listening);
      expect(controller.canApply, false);
      await controller.stop();
      expect(controller.phase, VoiceCapturePhase.review);
      expect(controller.canApply, false);
      controller.edit('call Maya tomorrow');
      expect(controller.canApply, true);
      controller.dispose();
    },
  );

  test(
    'review requires stop; uncertain money text stays intact for editing',
    () async {
      final session = FakeVoiceSession();
      final controller = VoiceCaptureController(session: session);
      await controller.start();
      session.text!('Maya owes me maybe 200 or 300 rupees');
      session.level!(0.25);
      expect(controller.heardSound, true);
      expect(controller.level, 0.25);
      expect(controller.canApply, false);
      controller.edit('ignored while listening');
      expect(controller.text, 'Maya owes me maybe 200 or 300 rupees');
      await controller.stop();
      expect(controller.canApply, true);
      controller.edit('Maya owes me 200 rupees');
      expect(controller.text, 'Maya owes me 200 rupees');
      controller.dispose();
    },
  );

  test(
    'cancel preparation completes into editable review and supports retry',
    () async {
      final session = FakeVoiceSession()..download = true;
      final controller = VoiceCaptureController(session: session);
      final starting = controller.start();
      expect(controller.phase, VoiceCapturePhase.downloading);
      expect(controller.progress!.fraction, 0.1);
      await controller.stop();
      await starting;
      expect(controller.phase, VoiceCapturePhase.review);
      session.download = false;
      await controller.start();
      expect(controller.phase, VoiceCapturePhase.listening);
      controller.dispose();
    },
  );

  test(
    'close cancels preparation once and ignores all late callbacks',
    () async {
      final session = FakeVoiceSession()..download = true;
      final controller = VoiceCaptureController(session: session);
      var notifications = 0;
      controller.addListener(() => notifications++);
      final starting = controller.start();
      await controller.close();
      await starting;
      final before = notifications;
      session.text!('late');
      session.listening!();
      session.level!(1);
      session.progress!(const SpeechDownloadProgress('model', 99, 100));
      session.error!(StateError('late'));
      expect(notifications, before);
      expect(controller.text, isEmpty);
      await controller.close();
      controller.dispose();
      expect(session.disposals, 1);
    },
  );
}
