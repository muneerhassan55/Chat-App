# Chat App

A real-time one-to-one chat app built with Flutter and Firebase. Users create an account, set up a profile with a cropped photo, search for other users and chat in real time.

## Features

- Email sign up and login with Firebase Auth
- Profile completion with name and profile photo (pick, crop and upload to Firebase Storage)
- Search users by email
- Chat rooms created on the first message and reused after that
- Real-time messages with Cloud Firestore streams
- Recent chats list on the home screen

## Tech stack

Flutter · Dart · Firebase Auth · Cloud Firestore · Firebase Storage · image_picker · image_cropper · uuid

## Data model

```
users/{uid}                       name, email, profile picture
chatrooms/{chatroomId}            participants, last message
chatrooms/{chatroomId}/messages   sender, text, created time, seen
```

## Project structure

```
lib/
  model/     user, chat room and message models
  pages/     login, sign up, complete profile, home, search, chat room
  widgets/   shared dialogs
```

## Getting started

1. Install Flutter (3.x) and run `flutter pub get`.
2. Run `flutterfire configure` to connect your own Firebase project, then enable Email/Password sign-in, Firestore and Storage.
3. Run `flutter run`.

## License

Released under the [MIT License](LICENSE).
