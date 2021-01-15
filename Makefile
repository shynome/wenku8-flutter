icon-gen:
	flutter pub run flutter_launcher_icons:main
apk:
	flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
apk-serve:
	caddy file-server -listen :8080 -browse -root build/app/outputs/flutter-apk/
