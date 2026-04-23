#!/bin/sh

echo Input log:

read desc #input log

toGroupChatFlag="内测";

#fvm flutter clean
#fvm flutter pub get

#android
fvm flutter build apk --debug --target=./lib/main.dart
curl -F "file=@./build/app/outputs/flutter-apk/app-debug.apk" \
-F "uKey=cda7d399501828f448da791de101d0f7" \
-F "_api_key=ac56533053cf5bb75c1f6bd168dac51b" \
-F "updateDescription=${toGroupChatFlag}：$region - dev\n$desc" \
https://www.pgyer.com/apiv1/app/upload
# ios
fvm flutter build ipa --target=./lib/main.dart --export-method ad-hoc # development（default），ad-hoc，app-store，enterprise
curl -F "file=@./build/ios/ipa/flutter_baji_example.ipa" \
-F "uKey=cda7d399501828f448da791de101d0f7" \
-F "_api_key=ac56533053cf5bb75c1f6bd168dac51b" \
-F "updateDescription=${toGroupChatFlag}：dev\n$desc" \
https://www.pgyer.com/apiv1/app/upload