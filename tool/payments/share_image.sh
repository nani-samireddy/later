#!/bin/sh
# Usage: share_image.sh content://media/external/images/media/123 [cold|warm]
# Import fixture through device gallery first. A content URI exercises Android's
# real ACTION_SEND and read grant; a file:// URI is not a representative share.
set -eu
uri=${1:?Provide a readable device MediaStore content URI}
mode=${2:-warm}
case "$uri" in content://*) ;; *) echo 'Expected content:// URI' >&2; exit 2;; esac
case "$mode" in cold) adb shell am force-stop com.nanisamireddy.later ;; warm) ;; *) exit 2;; esac
adb shell am start -W -n com.nanisamireddy.later/.MainActivity -a android.intent.action.SEND -t image/png -d "$uri" --eu android.intent.extra.STREAM "$uri" --grant-read-uri-permission
