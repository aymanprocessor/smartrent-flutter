---
trigger: always_on
description: Trigger Flutter hot reload or hot restart after editing project files
---

# Flutter Hot Reload Rule
- Whenever you finish editing or creating any `.dart` file in a Flutter project, you MUST trigger a Hot Reload before marking the task as complete.
- If a terminal is running `flutter run`, send the `r` key to that active terminal session.
- If the app was started with `--pid-file=/tmp/flutter.pid`, run `kill -USR1 $(cat /tmp/flutter.pid)` in the terminal.
- If you modified dependencies in `pubspec.yaml` or changed global state/initializers in `main.dart`, trigger a Hot Restart (`R` or `kill -USR2`) instead.
