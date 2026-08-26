# Android release signing

STROT Android release builds never use Flutter's debug signing key. Supply these values through the local shell or the authorized CI secret store:

```text
STROT_ANDROID_KEYSTORE_PATH=/absolute/path/to/strot-release.jks
STROT_ANDROID_KEYSTORE_PASSWORD=
STROT_ANDROID_KEY_ALIAS=
STROT_ANDROID_KEY_PASSWORD=
```

The keystore path must be absolute and the keystore must remain outside Git. A release Gradle task fails before compilation when any value is absent. Debug builds do not require signing credentials.

Example local invocation after exporting the values:

```sh
flutter build appbundle --release
```

Do not place real values in `.env.example`, Gradle files, shell history, screenshots or audit reports.
