# Flydigi Vader 5 Pro Linux Setup & Fixes

[English](#english) | [Русский](#русский)

---

## English

Linux support and custom fixes for **Flydigi Vader 5 Pro** (2.4G dongle USB ID `37d7:2401`).

### What this repository includes
- **Custom SDL3 Rumble & Input Sticking Fix**: Introduces a **2x Burst (22ms safety window) & Deduplication algorithm** into the patched SDL3 library. This eliminates input drops and rumble sticking caused by the Flydigi 2.4G receiver's ~18ms hardware pause on vendor channel IF1.
- **Switcher Utility (`vader5`)**: Toggle between Steam Native mode and Padctl mode.
- **Automated Installer**: Downloads `padctl`, compiles the patched SDL3 library, and sets up udev rules.

### Prerequisites (Dependencies)
Before running `install.sh`, make sure build dependencies are installed on your Linux distribution:

- **Ubuntu / Debian / Pop!_OS / Linux Mint**:
  ```bash
  sudo apt update && sudo apt install -y git build-essential cmake ninja-build python3 wget curl libx11-dev libxext-dev libxcursor-dev libxi-dev libxfixes-dev libxrandr-dev libxrender-dev libxinerama-dev libxss-dev libxtst-dev
  ```
- **Fedora / Nobara / Bazzite**:
  ```bash
  sudo dnf install -y git gcc gcc-c++ cmake ninja-build python3 wget curl libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXScrnSaver-devel libXtst-devel
  ```
- **Arch Linux / Manjaro / EndeavourOS**:
  ```bash
  sudo pacman -S --needed git base-devel cmake ninja python wget curl libx11 libxext libxcursor libxi libxfixes libxrandr libxrender libxinerama libxss libxtst
  ```
- **openSUSE**:
  ```bash
  sudo zypper install -y git gcc gcc-c++ cmake ninja python3 wget curl libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXss-devel libXtst-devel
  ```

### Important Note About Padctl Configuration
While `install.sh` automatically fetches and installs the `padctl` daemon, **`padctl` requires separate configuration for custom button mappings, macros, or stick curves**.
- Default `padctl` config behaves as a standard Xbox Elite Series 2 controller.
- To configure custom paddle mappings or profiles in Padctl mode, edit `~/.config/padctl/config.toml` or use `padctl` CLI.
- Refer to the official [padctl documentation](https://github.com/BANANASJIM/padctl) for mapping syntax.

### Credits & References
- [BANANASJIM/padctl](https://github.com/BANANASJIM/padctl) — For research and diagnosing the ~18ms hardware receiver freeze on vendor channel IF1 ([Issue #503](https://github.com/BANANASJIM/padctl/issues/503), [PR #505](https://github.com/BANANASJIM/padctl/pull/505), [PR #506](https://github.com/BANANASJIM/padctl/pull/506), [PR #508](https://github.com/BANANASJIM/padctl/pull/508)).
- **firefloc** ([vader5-pro-linux-fix Issue #8](https://github.com/DuncanTPerkins/vader5-pro-linux-fix/issues/8)) — For the Steam direct replace & size truncation methodology (`truncate`) to bypass Steam verification loops.

### Installation
```bash
git clone https://github.com/AltMugen/flydigi-vader5-pro-linux.git
cd flydigi-vader5-pro-linux
chmod +x install.sh vader5
./install.sh
```

### CLI Usage (`vader5`)
```bash
vader5 native   # (or 'vader5 n') Switch to Steam Native mode
vader5 padctl   # (or 'vader5 p') Switch to Padctl mode (Virtual Xbox Elite)
vader5 update   # (or 'vader5 u') Re-apply patched SDL3 libraries to Steam
vader5 status   # (or 'vader5 s') Show current active mode
```

---

## Русский

Поддержка и исправление багов для **Flydigi Vader 5 Pro** на Linux (2.4G донгл USB ID `37d7:2401`).

### Что входит в репозиторий
- **Фикс вибрации и залипаний для SDL3 в Steam**: Внедрен алгоритм **Двойного залпа (2x Burst с окном безопасности 22 мс) и дедупликации** в библиотеку SDL3. Решает проблему потери нажатий и залипания вибрации, вызванную аппаратным зависанием донгла Flydigi (~18 мс на команду) на вендорном канале IF1.
- **Утилита переключения (`vader5`)**: Переключение между нативным режимом Steam и режимом Padctl.
- **Автоматический установщик**: Скачивает `padctl`, компилирует пропатченный SDL3 и устанавливает правила `udev`.

### Требования (Зависимости)
Перед запуском `install.sh` убедитесь, что в вашей системе установлены необходимые инструменты сборки:

- **Ubuntu / Debian / Pop!_OS / Linux Mint**:
  ```bash
  sudo apt update && sudo apt install -y git build-essential cmake ninja-build python3 wget curl libx11-dev libxext-dev libxcursor-dev libxi-dev libxfixes-dev libxrandr-dev libxrender-dev libxinerama-dev libxss-dev libxtst-dev
  ```
- **Fedora / Nobara / Bazzite**:
  ```bash
  sudo dnf install -y git gcc gcc-c++ cmake ninja-build python3 wget curl libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXScrnSaver-devel libXtst-devel
  ```
- **Arch Linux / Manjaro / EndeavourOS**:
  ```bash
  sudo pacman -S --needed git base-devel cmake ninja python wget curl libx11 libxext libxcursor libxi libxfixes libxrandr libxrender libxinerama libxss libxtst
  ```
- **openSUSE**:
  ```bash
  sudo zypper install -y git gcc gcc-c++ cmake ninja python3 wget curl libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXss-devel libXtst-devel
  ```

### Важное примечание по настройке Padctl
Скрипт `install.sh` автоматически скачивает и запускает `padctl`, но **сам `padctl` требует отдельной настройки для кастомных маппингов, макросов или кривых стиков**.
- По умолчанию `padctl` работает как стандартный геймпад Xbox Elite Series 2.
- Для настройки лепестков и профилей в режиме Padctl редактируйте `~/.config/padctl/config.toml` или используйте CLI `padctl`.
- Подробную документацию смотрите в официальном [репозитории padctl](https://github.com/BANANASJIM/padctl).

### Благодарности и ссылки
- [BANANASJIM/padctl](https://github.com/BANANASJIM/padctl) — За исследование и обнаружение 18-миллисекундного аппаратного зависания приемника Flydigi при отправке команд вибрации ([Issue #503](https://github.com/BANANASJIM/padctl/issues/503), [PR #505](https://github.com/BANANASJIM/padctl/pull/505), [PR #506](https://github.com/BANANASJIM/padctl/pull/506), [PR #508](https://github.com/BANANASJIM/padctl/pull/508)).
- **firefloc** ([vader5-pro-linux-fix Issue #8](https://github.com/DuncanTPerkins/vader5-pro-linux-fix/issues/8)) — За метод прямой подмены библиотек в Steam с подгонкой размера файлов (`truncate`).

### Установка
```bash
git clone https://github.com/AltMugen/flydigi-vader5-pro-linux.git
cd flydigi-vader5-pro-linux
chmod +x install.sh vader5
./install.sh
```

### Использование (`vader5`)
```bash
vader5 native   # (или 'vader5 n') Включить нативный режим Steam
vader5 padctl   # (или 'vader5 p') Включить режим Padctl (Xbox Elite)
vader5 update   # (или 'vader5 u') Обновить пропатченные библиотеки в Steam
vader5 status   # (или 'vader5 s') Показать текущий активный режим
