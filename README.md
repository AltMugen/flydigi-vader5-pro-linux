# Flydigi Vader 5 Pro on Linux

[Русский](#русский) · [English](#english)

## Русский

Настройка Flydigi Vader 5 Pro с USB-донглом `37d7:2401` для нативного Steam (в том числе Steam RT3) на Fedora GNOME. SDL читает расширенные кнопки и гироскоп через HID-интерфейс 1. В экспериментальном варианте вибрация уходит через отдельный Xbox-интерфейс 0. `xpad` отключается от интерфейса 0, чтобы Steam не видел второй геймпад.

### Состояние и ограничения

- Путь вибрации через Xbox endpoint **собран, но не проверен на реальном донгле**. Маленький пользовательский сервис отправляет стандартный 8-байтный пакет на endpoint `0x05`; SDL передаёт ему значения моторов через сокет в `XDG_RUNTIME_DIR`. В этом пути нет тройного залпа, задержки 20–22 мс или записи вибрации в HID-интерфейс 1.
- Сборка закреплена за SDL `release-3.4.4`. Патч хранится в [`patches/sdl-flydigi-vader5-linux.patch`](patches/sdl-flydigi-vader5-linux.patch), а не генерируется заменами текста в установщике.
- По умолчанию собирается 64-битная библиотека для `steamrt64` и `ubuntu12_64`. Для 32-битной поставьте multilib-зависимости и запустите `BUILD_32=1 ./build.sh`. Без неё `ubuntu12_32` пропускается.
- Библиотека, собранная на Fedora, может требовать её версию glibc. Перед применением к другой системе проверьте `readelf --version-info` или соберите в совместимом Steam Runtime SDK. Указанный [разбор Steam Runtime](https://github.com/DuncanTPerkins/vader5-pro-linux-fix/issues/8) также сообщает о минимальной прошивке Vader 5 Pro `0x7141`.
- Steam обновляет свои SDL-файлы. После обновления клиента закройте Steam и выполните `vader5 update`.

### Сборка и установка (Fedora)

```bash
sudo dnf install git gcc cmake ninja-build pkgconf-pkg-config libusb1-devel \
  libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel \
  libXrandr-devel libXrender-devel libXinerama-devel libXScrnSaver-devel libXtst-devel
./build.sh
./install.sh
```

`build.sh` использует `SDL_SOURCE_DIR`, `BUILD_DIR` и `OUTPUT_DIR`, если они заданы. Он работает в отдельном каталоге сборки и не меняет исходный checkout SDL. `install.sh` ставит правило udev, пользовательский сервис и команду `~/.local/bin/vader5`. Закройте Steam до запуска установки. При первой подмене библиотек `vader5 update` сохраняет исходный файл как `libSDL3.so.0.vader5-original` в соответствующем каталоге Steam. Если новая библиотека больше исходной или рядом нет штатного `sdl3_shim.so`, подмена прерывается.

```bash
vader5 native   # Steam + Xbox rumble bridge
vader5 padctl   # Только если padctl уже установлен как user service
vader5 update   # Повторно применить SDL после обновления Steam
vader5 status
systemctl --user status vader5-rumble
journalctl --user -u vader5-rumble -b
```

После переключения переподключите донгл. Сервис Xbox-вибрации работает только в режиме `native`. Для `padctl` проект больше не скачивает непроверенный бинарный релиз автоматически: установите и настройте [padctl](https://github.com/BANANASJIM/padctl) отдельно, если он нужен.

### Steam Input и кнопка R в Isaac

Если лепесток назначен клавише `R` в конфигурации Steam Input для игры, GNOME Wayland может запросить «доступ к рабочему столу» при попытке Steam имитировать клавиатуру через механизм ввода рабочего стола. Это разрешение относится к синтетическому вводу клавиши, а не к чтению лепестка SDL. Исправление вибрации не устраняет этот запрос. Проверьте, что Steam применяет именно конфигурацию Isaac и что в Desktop Layout нет дублирующего назначения. [У Steam есть сообщения о подобных запросах даже во время игры](https://github.com/ValveSoftware/steam-for-linux/issues/13208). Разрешение портала следует оценивать отдельно; скрипты проекта его не меняют.

### Устройство и диагностика

На физическом донгле проверьте: Steam показывает один Vader 5 Pro, дополнительные кнопки и гироскоп видны; `vader5-rumble` активен; вибрация начинается и прекращается без залипания; при вибрации не теряются нажатия. Если endpoint занят, сервис сообщит `Interface 0 unavailable` в журнале. Протокол Xbox endpoint описан в [исследовании донгла](https://github.com/Chillsmeit/vader5pro-remap-driver/blob/main/docs/protocol.md). Формат расширенного ввода и альтернативной вибрации на интерфейсе 1 задокументирован в [padctl](https://github.com/BANANASJIM/padctl/blob/main/docs/src/devices/flydigi-flydigi-vader-5-pro.md).

## English

This repository configures the Flydigi Vader 5 Pro `37d7:2401` dongle for native Steam. SDL reads extra buttons and gyro through HID interface 1. An experimental user service sends rumble to the separate Xbox interface 0 while `xpad` is unbound, avoiding a duplicate controller. The Xbox rumble route compiles successfully but still needs a test on the physical dongle.

On Fedora, install the build dependencies shown above, then run `./build.sh` and `./install.sh` with Steam closed. Use `vader5 native`, `vader5 padctl` (when padctl is installed separately), `vader5 update`, and `vader5 status`. Steam's original SDL files are backed up beside the replaced files. The default build is 64-bit; set `BUILD_32=1` after installing multilib dependencies to add 32-bit Steam support.

Steam Input keyboard mappings such as an Isaac paddle bound to `R` can trigger GNOME Wayland's desktop input permission prompt. This is separate from SDL controller reading and rumble; this project does not change portal permissions.
