# Guía de instalación — Flutter + Android SDK (Linux)

Requisitos para compilar y correr **note-think** en este entorno.

## 1. Dependencias del sistema

```bash
sudo apt update
sudo apt install -y \
  curl git unzip zip xz-utils \
  clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev \
  libstdc++-12-dev
```

## 2. Instalar Flutter SDK

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

Verifica:

```bash
flutter --version
```

## 3. Instalar Java (JDK 17)

```bash
sudo apt install -y openjdk-17-jdk
```

Confirma:

```bash
java -version   # debe decir 17.x
```

## 4. Instalar Android SDK

### Opción A — Android Studio (recomendado si tienes entorno gráfico)

1. Descarga Android Studio desde https://developer.android.com/studio
2. Extrae a `/opt/android-studio` y corre `./bin/studio.sh`
3. En el setup wizard deja que instale el SDK, la plataforma y un emulador
4. Acepta las licencias cuando te las pida

### Opción B — Solo command-line tools (headless / servidor)

```bash
mkdir -p ~/Android/Sdk/cmdline-tools
cd ~/Android/Sdk/cmdline-tools

# Descarga el zip (verifica la versión vigente en
# https://developer.android.com/studio#command-line-tools-only)
curl -o cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip cmdtools.zip
mv cmdline-tools latest

# Instala platform + build-tools + platform-tools
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

## 5. Variables de entorno (persistentes)

Añade al final de `~/.bashrc`:

```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$HOME/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"
export CHROME_EXECUTABLE="/usr/bin/google-chrome"   # solo si usas flutter web/devtools
```

Recarga:

```bash
source ~/.bashrc
```

## 6. Verificar

```bash
flutter doctor
```

Debes ver checks en verde (o amarillo aceptable) para:
- Flutter
- Android toolchain
- Chrome / Linux desktop (opcional)

Acepta las licencias de Android si `flutter doctor` lo pide:

```bash
flutter doctor --android-licenses
```

## 7. Emulador / dispositivo (para correr la app)

- **Emulador**: crea uno desde Android Studio (`Device Manager`), o vía CLI:
  ```bash
  sdkmanager "system-images;android-34;google_apis;x86_64"
  avdmanager create avd -n pixel -k "system-images;android-34;google_apis;x86_64"
  emulator -avd pixel
  ```
- **Dispositivo físico**: activa depuración USB y conecta el teléfono.
  ```bash
  adb devices
  ```

## 8. Correr el proyecto

Una vez terminada la instalación y con el código de la Fase 1 en el repo:

```bash
cd note-think
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera el código de Isar
flutter run
```
