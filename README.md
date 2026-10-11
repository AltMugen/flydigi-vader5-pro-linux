# Flydigi Vader 5 Pro Linux Setup & Fixes

[English](#english) | [Русский](#русский)

---

## English

Linux support and custom fixes for **Flydigi Vader 5 Pro** (2.4G dongle USB ID `37d7:2401`).

### What this repository includes

- **SDL3 input and rumble fix**: SDL reads the extra controls and gyro from HID interface 1. Rumble is sent through the dongle's separate Xbox interface 0. The `xpad` driver is detached from that interface to avoid a duplicate controller. The Steam RT3 client (`steamrt64`) is patched alongside the legacy Steam libraries.
- **Switcher utility (`vader5`)**: Switch between Steam Native mode and Padctl mode; the selected mode persists after reboot. The command output follows the system language (English or Russian).
- **SDL build and installer**: Builds a patched SDL3 from the pinned `release-3.4.4` tag, installs the rumble service and udev rules, and patches Steam's SDL libraries.

### Prerequisites (Dependencies)

Before running `install.sh`, install the build dependencies for your distribution:

- **Ubuntu / Debian / Pop!_OS / Linux Mint**:
  ```bash
  sudo apt update && sudo apt install -y git build-essential cmake ninja-build pkg-config curl wget tar patchelf libusb-1.0-0-dev libx11-dev libxext-dev libxcursor-dev libxi-dev libxfixes-dev libxrandr-dev libxrender-dev libxinerama-dev libxss-dev libxtst-dev
  ```
- **Fedora / Nobara / Bazzite**:
  ```bash
  sudo dnf install -y git gcc gcc-c++ cmake ninja-build pkgconf-pkg-config curl wget tar patchelf libusb1-devel libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXScrnSaver-devel libXtst-devel
  ```
- **Arch Linux / Manjaro / EndeavourOS**:
  ```bash
  sudo pacman -S --needed git base-devel cmake ninja pkgconf curl wget tar patchelf libusb libx11 libxext libxcursor libxi libxfixes libxrandr libxrender libxinerama libxss libxtst
  ```
- **openSUSE**:
  ```bash
  sudo zypper install -y git gcc gcc-c++ cmake ninja pkgconf-pkg-config curl wget tar patchelf libusb-1_0-devel libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXss-devel libXtst-devel
  ```

### Important Note About Padctl Configuration

The installer downloads and installs the latest Padctl binary by default. To install the SDL driver without Padctl, run `SKIP_PADCTL=1 ./install.sh`. Padctl still needs separate configuration for custom button mappings, macros, or stick curves.

- Its default configuration behaves like an Xbox Elite Series 2 controller.
- For custom paddle mappings or profiles, edit `~/.config/padctl/config.toml` or use the `padctl` CLI.
- See the official [Padctl documentation](https://github.com/BANANASJIM/padctl).

### Credits & References

- [BANANASJIM/padctl](https://github.com/BANANASJIM/padctl) — Research on the Vader 5 Pro dongle and its HID input interface.
- [firefloc, vader5-pro-linux-fix issue #8](https://github.com/DuncanTPerkins/vader5-pro-linux-fix/issues/8) — Steam SDL replacement and file-size adjustment method.

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

Steam's original SDL libraries are backed up under `~/.local/share/vader5-driver/sdl/originals`, outside Steam's directories. The updater uses the original in-place copy and `truncate` method to preserve each library's size. It will not replace a library if the patched SDL is larger than the original. The original `sdl3_shim.so` is kept in the same backup directory; Steam receives the SDL shim built with this project. Both files use `$ORIGIN` so SteamRT3 can resolve the shim inside its isolated loader namespace.

`vader5 update` changes files under the current user's Steam directory and does not need root when that directory is user-owned. Installing the udev rule and switching modes use `sudo`.

### CLI Usage (`vader5`)

```bash
vader5 native   # (or 'vader5 n') Switch to Steam Native mode
vader5 padctl   # (or 'vader5 p') Switch to Padctl mode
vader5 update   # (or 'vader5 u') Re-apply patched SDL3 libraries to Steam
vader5 status   # (or 'vader5 s') Show the current mode
```

The Vader 5 Pro controller firmware must be at least `7.1.4.1` (`0x7141`) for this SDL driver.

---

## Русский

Поддержка и исправления для **Flydigi Vader 5 Pro** на Linux (2.4G-донгл, USB ID `37d7:2401`).

### Что входит в репозиторий

- **Фикс ввода и вибрации SDL3**: SDL читает дополнительные кнопки и гироскоп через HID-интерфейс 1. Вибрация отправляется через отдельный Xbox-интерфейс 0 донгла. Драйвер `xpad` отключается от этого интерфейса, чтобы Steam не видел второй геймпад. Патч применяется также к клиенту Steam RT3 (`steamrt64`) и legacy-библиотекам Steam.
- **Утилита переключения (`vader5`)**: Переключение между режимами Steam Native и Padctl; выбранный режим сохраняется после перезагрузки. Сообщения утилиты выводятся на языке системы — русском или английском.
- **Сборка SDL и установщик**: Собирает пропатченную SDL3 из закреплённого тега `release-3.4.4`, устанавливает сервис вибрации и правила `udev`, затем обновляет библиотеки SDL в Steam.

### Требования (Зависимости)

Перед запуском `install.sh` установите зависимости для своей системы:

- **Ubuntu / Debian / Pop!_OS / Linux Mint**:
  ```bash
  sudo apt update && sudo apt install -y git build-essential cmake ninja-build pkg-config curl wget tar patchelf libusb-1.0-0-dev libx11-dev libxext-dev libxcursor-dev libxi-dev libxfixes-dev libxrandr-dev libxrender-dev libxinerama-dev libxss-dev libxtst-dev
  ```
- **Fedora / Nobara / Bazzite**:
  ```bash
  sudo dnf install -y git gcc gcc-c++ cmake ninja-build pkgconf-pkg-config curl wget tar patchelf libusb1-devel libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXScrnSaver-devel libXtst-devel
  ```
- **Arch Linux / Manjaro / EndeavourOS**:
  ```bash
  sudo pacman -S --needed git base-devel cmake ninja pkgconf curl wget tar patchelf libusb libx11 libxext libxcursor libxi libxfixes libxrandr libxrender libxinerama libxss libxtst
  ```
- **openSUSE**:
  ```bash
  sudo zypper install -y git gcc gcc-c++ cmake ninja pkgconf-pkg-config curl wget tar patchelf libusb-1_0-devel libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXss-devel libXtst-devel
  ```

### Важное примечание по настройке Padctl

По умолчанию установщик скачивает и устанавливает последнюю версию Padctl. Чтобы установить SDL-драйвер без Padctl, запустите `SKIP_PADCTL=1 ./install.sh`. Для собственных назначений кнопок, макросов или кривых стиков Padctl нужно настроить отдельно.

- По умолчанию он работает как Xbox Elite Series 2.
- Для настройки лепестков и профилей редактируйте `~/.config/padctl/config.toml` или используйте CLI `padctl`.
- Синтаксис настроек описан в официальной [документации Padctl](https://github.com/BANANASJIM/padctl).

### Благодарности и ссылки

- [BANANASJIM/padctl](https://github.com/BANANASJIM/padctl) — Исследование донгла Vader 5 Pro и его HID-интерфейса ввода.
- [firefloc, vader5-pro-linux-fix issue #8](https://github.com/DuncanTPerkins/vader5-pro-linux-fix/issues/8) — Метод подмены SDL в Steam с подгонкой размера файла.

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

Оригинальные библиотеки Steam сохраняются в `~/.local/share/vader5-driver/sdl/originals`, за пределами каталогов Steam. Для сохранения исходного размера применяется прежняя схема копирования на месте и `truncate`. Исходный `sdl3_shim.so` хранится там же; в Steam копируется shim, собранный вместе с проектом. У SDL и shim настроен поиск библиотек через `$ORIGIN`, чтобы SteamRT3 находил shim в изолированном загрузчике. Обновление не заменит библиотеку, если новая SDL больше оригинала.

`vader5 update` меняет файлы в каталоге Steam текущего пользователя и не требует root, если каталог принадлежит пользователю. Установка правила `udev` и переключение режимов используют `sudo`.

### Использование (`vader5`)

```bash
vader5 native   # (или 'vader5 n') Включить нативный режим Steam
vader5 padctl   # (или 'vader5 p') Включить режим Padctl
vader5 update   # (или 'vader5 u') Обновить пропатченные библиотеки SDL3 в Steam
vader5 status   # (или 'vader5 s') Показать текущий режим
```

Для этого SDL-драйвера нужна прошивка геймпада Vader 5 Pro не ниже `7.1.4.1` (`0x7141`).
