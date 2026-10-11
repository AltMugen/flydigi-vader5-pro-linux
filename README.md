# Flydigi Vader 5 Pro Linux Setup & Fixes

[English](#english) | [Русский](#русский)

---

## English

Linux support and custom fixes for **Flydigi Vader 5 Pro** (2.4G dongle USB ID `37d7:2401`).

### What this repository includes

- **SDL3 input and rumble fix**: SDL reads the extra controls and gyro from HID interface 1. Rumble is sent through the dongle's separate Xbox interface 0. The `xpad` driver is detached from that interface to avoid a duplicate controller. The previous repeated-burst rumble implementation is no longer used.
- **Switcher utility (`vader5`)**: Switch between Steam Native mode and Padctl mode. The command output follows the system language (English or Russian).
- **SDL build and installer**: Builds a patched SDL3 from the pinned `release-3.4.4` tag, installs the rumble service and udev rules, and patches Steam's SDL libraries.

The Xbox rumble path was tested with the dongle: SDL detected the controller, a rumble pulse reached the motors, and a stop command stopped them. The bridge sends 8-byte reports to interrupt OUT endpoint `0x05`.

### Prerequisites (Dependencies)

Before running `install.sh`, install the build dependencies for your distribution:

- **Ubuntu / Debian / Pop!_OS / Linux Mint**:
  ```bash
  sudo apt update && sudo apt install -y git build-essential cmake ninja-build pkg-config libusb-1.0-0-dev libx11-dev libxext-dev libxcursor-dev libxi-dev libxfixes-dev libxrandr-dev libxrender-dev libxinerama-dev libxss-dev libxtst-dev
  ```
- **Fedora / Nobara / Bazzite**:
  ```bash
  sudo dnf install -y git gcc gcc-c++ cmake ninja-build pkgconf-pkg-config libusb1-devel libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXScrnSaver-devel libXtst-devel
  ```
- **Arch Linux / Manjaro / EndeavourOS**:
  ```bash
  sudo pacman -S --needed git base-devel cmake ninja pkgconf libusb libx11 libxext libxcursor libxi libxfixes libxrandr libxrender libxinerama libxss libxtst
  ```
- **openSUSE**:
  ```bash
  sudo zypper install -y git gcc gcc-c++ cmake ninja pkgconf-pkg-config libusb-1_0-devel libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXss-devel libXtst-devel
  ```

### Padctl

The installer no longer downloads or configures Padctl. Install it separately if you need its virtual Xbox controller or custom mappings. Its default configuration behaves like an Xbox Elite Series 2 controller. For custom paddle mappings, macros, or stick curves, edit `~/.config/padctl/config.toml` or use the Padctl CLI. See the [Padctl documentation](https://github.com/BANANASJIM/padctl).

### Credits & References

- [BANANASJIM/padctl](https://github.com/BANANASJIM/padctl) — Research on the Vader 5 Pro dongle and its HID input interface.
- [firefloc, vader5-pro-linux-fix issue #8](https://github.com/DuncanTPerkins/vader5-pro-linux-fix/issues/8) — Steam SDL replacement and file-size adjustment method.
- [Vader 5 Pro dongle protocol](https://github.com/Chillsmeit/vader5pro-remap-driver/blob/main/docs/protocol.md) — Xbox interface report format.

### Installation

```bash
git clone https://github.com/AltMugen/flydigi-vader5-pro-linux.git
cd flydigi-vader5-pro-linux
chmod +x build.sh install.sh vader5
./build.sh
```

Close Steam before installing the patched libraries:

```bash
./install.sh
```

The default build is 64-bit. To build the 32-bit SDL library as well, install your distribution's multilib dependencies and run `BUILD_32=1 ./build.sh`.

Steam's original SDL library is saved beside the patched file as `libSDL3.so.0.vader5-original`. The updater will not replace a library if the patched SDL is larger than the original or the Steam `sdl3_shim.so` file is missing.

`vader5 update` changes files under the current user's Steam directory and does not need root when that directory is user-owned. Installing the udev rule and switching modes use `sudo`.

### CLI Usage (`vader5`)

```bash
vader5 native   # (or 'vader5 n') Switch to Steam Native mode
vader5 padctl   # (or 'vader5 p') Switch to Padctl mode
vader5 update   # (or 'vader5 u') Re-apply patched SDL3 libraries to Steam
vader5 status   # (or 'vader5 s') Show the current mode
```

The Vader 5 Pro dongle firmware must be at least `0x7141`; the tested dongle reported `0x7153`.

---

## Русский

Поддержка и исправления для **Flydigi Vader 5 Pro** на Linux (2.4G-донгл, USB ID `37d7:2401`).

### Что входит в репозиторий

- **Фикс ввода и вибрации SDL3**: SDL читает дополнительные кнопки и гироскоп через HID-интерфейс 1. Вибрация отправляется через отдельный Xbox-интерфейс 0 донгла. Драйвер `xpad` отключается от этого интерфейса, чтобы Steam не видел второй геймпад. Прежняя схема вибрации повторными залпами больше не используется.
- **Утилита переключения (`vader5`)**: Переключение между режимами Steam Native и Padctl. Сообщения утилиты выводятся на языке системы — русском или английском.
- **Сборка SDL и установщик**: Собирает пропатченную SDL3 из закреплённого тега `release-3.4.4`, устанавливает сервис вибрации и правила `udev`, затем обновляет библиотеки SDL в Steam.

Вибрация через Xbox-интерфейс проверена на донгле: SDL обнаружила контроллер, тестовый импульс вызвал вибрацию, команда остановки остановила моторы. Сервис отправляет 8-байтные команды на interrupt OUT endpoint `0x05`.

### Требования (Зависимости)

Перед запуском `install.sh` установите зависимости для своей системы:

- **Ubuntu / Debian / Pop!_OS / Linux Mint**:
  ```bash
  sudo apt update && sudo apt install -y git build-essential cmake ninja-build pkg-config libusb-1.0-0-dev libx11-dev libxext-dev libxcursor-dev libxi-dev libxfixes-dev libxrandr-dev libxrender-dev libxinerama-dev libxss-dev libxtst-dev
  ```
- **Fedora / Nobara / Bazzite**:
  ```bash
  sudo dnf install -y git gcc gcc-c++ cmake ninja-build pkgconf-pkg-config libusb1-devel libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXScrnSaver-devel libXtst-devel
  ```
- **Arch Linux / Manjaro / EndeavourOS**:
  ```bash
  sudo pacman -S --needed git base-devel cmake ninja pkgconf libusb libx11 libxext libxcursor libxi libxfixes libxrandr libxrender libxinerama libxss libxtst
  ```
- **openSUSE**:
  ```bash
  sudo zypper install -y git gcc gcc-c++ cmake ninja pkgconf-pkg-config libusb-1_0-devel libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXss-devel libXtst-devel
  ```

### Padctl

Установщик больше не скачивает и не настраивает Padctl автоматически. Если нужен виртуальный Xbox-геймпад или собственные назначения, установите Padctl отдельно. По умолчанию он работает как Xbox Elite Series 2. Для настройки лепестков, макросов и кривых стиков отредактируйте `~/.config/padctl/config.toml` или воспользуйтесь CLI. Инструкции есть в [документации Padctl](https://github.com/BANANASJIM/padctl).

### Благодарности и ссылки

- [BANANASJIM/padctl](https://github.com/BANANASJIM/padctl) — Исследование донгла Vader 5 Pro и его HID-интерфейса ввода.
- [firefloc, vader5-pro-linux-fix issue #8](https://github.com/DuncanTPerkins/vader5-pro-linux-fix/issues/8) — Метод подмены SDL в Steam с подгонкой размера файла.
- [Протокол донгла Vader 5 Pro](https://github.com/Chillsmeit/vader5pro-remap-driver/blob/main/docs/protocol.md) — Формат команд Xbox-интерфейса.

### Установка

```bash
git clone https://github.com/AltMugen/flydigi-vader5-pro-linux.git
cd flydigi-vader5-pro-linux
chmod +x build.sh install.sh vader5
./build.sh
```

Перед установкой пропатченных библиотек закройте Steam:

```bash
./install.sh
```

По умолчанию собирается 64-битная SDL. Чтобы собрать также 32-битную библиотеку, установите multilib-зависимости своего дистрибутива и запустите `BUILD_32=1 ./build.sh`.

Оригинальная библиотека Steam сохраняется рядом с пропатченной под именем `libSDL3.so.0.vader5-original`. Обновление не заменит библиотеку, если новая SDL больше оригинала или отсутствует штатный файл Steam `sdl3_shim.so`.

`vader5 update` меняет файлы в каталоге Steam текущего пользователя и не требует root, если каталог принадлежит пользователю. Установка правила `udev` и переключение режимов используют `sudo`.

### Использование (`vader5`)

```bash
vader5 native   # (или 'vader5 n') Включить нативный режим Steam
vader5 padctl   # (или 'vader5 p') Включить режим Padctl
vader5 update   # (или 'vader5 u') Обновить пропатченные библиотеки SDL3 в Steam
vader5 status   # (или 'vader5 s') Показать текущий режим
```

Прошивка донгла Vader 5 Pro должна быть не ниже `0x7141`; на проверенном донгле была версия `0x7153`.
