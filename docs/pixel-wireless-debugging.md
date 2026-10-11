# Run Later on a Pixel 6a over Wi-Fi

Use `scripts/run_pixel_wireless.py` from any directory with Python 3, Android SDK platform-tools, and Flutter installed. The helper finds tools on PATH, in `android/local.properties`, or standard SDK locations. It never restarts ADB or touches the emulator.

1. Connect the computer and Pixel to the same Wi-Fi. On the Pixel, enable Developer options > Wireless debugging.
2. Inspect available devices/services:
   ```sh
   scripts/run_pixel_wireless.py --discover
   ```
3. If this computer is not paired, open **Pair device with pairing code** on your Pixel. Use its pairing address:
   ```sh
   scripts/run_pixel_wireless.py --pair-address HOST:PAIR_PORT --connect-address HOST:CONNECT_PORT
   ```
   The code is entered at a hidden terminal prompt, passed through ADB stdin, and never saved or printed by the helper. The connection address is shown on the main Wireless debugging screen and usually has a different port. Keep the pairing dialog open until pairing finishes.
4. For a paired phone:
   ```sh
   scripts/run_pixel_wireless.py --connect-address HOST:CONNECT_PORT
   ```
   With no address, the helper selects a single already-connected Pixel 6a, or displays mDNS services and asks you to enter the address from your phone. It never guesses which advertised endpoint belongs to you. Use `--device EXACT_SERIAL` to select among multiple connected Pixels.

The helper checks model `Pixel 6a`, manufacturer `Google`, and hardware `bluejay` before installing. `--connect-only` stops after verification. ADB commands have a configurable `--timeout` (20 seconds by default); APK transfer/install allows at least 300 seconds. Flutter remains interactive: `r` hot reload, `q` quit.

Deployment uses the existing `build/app/outputs/flutter-apk/app-debug.apk`, or an explicit `--apk /path/to/app-debug.apk`. Build a fresh debug APK separately with `flutter build apk --debug` when no other Gradle build is active. The helper does not run Gradle; the existing APK can be older than current source changes. Flutter runs with `-d EXACT_SERIAL --debug --use-application-binary APK`.

Before Flutter, the helper runs `adb -s EXACT_SERIAL install -r APK` and stops if it fails. This preserves existing app data and prevents Flutter from attempting recovery from a rejected install. If `INSTALL_FAILED_UPDATE_INCOMPATIBLE` appears, the phone's installed app has a different signing key. Keep that app and its data: obtain the original signing key, or separately configure a different application ID. The helper never uninstalls, clears data, downgrades, or changes signing configuration.

If discovery is empty, use the address shown on your Pixel. Ports can change when Wireless debugging is toggled. Corporate/guest Wi-Fi can block peer connections or mDNS; try a network that permits local device communication. No network scanning is performed.

Official Android instructions: [Connect to a device over Wi-Fi (Android 11+)](https://developer.android.com/tools/adb#connect-to-a-device-over-wi-fi-android-11+).
