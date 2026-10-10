// Experimental Xbox interface rumble bridge for the Vader 5 Pro dongle.
#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <libusb-1.0/libusb.h>
#include <poll.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <unistd.h>

static volatile sig_atomic_t running = 1;
static void stop_running(int signo) { (void)signo; running = 0; }

int main(void) {
    const char *runtime = getenv("XDG_RUNTIME_DIR");
    if (!runtime || runtime[0] != '/') {
        fprintf(stderr, "XDG_RUNTIME_DIR is required\n");
        return 1;
    }
    char path[sizeof(((struct sockaddr_un *)0)->sun_path)];
    if (snprintf(path, sizeof(path), "%s/vader5-rumble.sock", runtime) >= (int)sizeof(path)) return 1;
    int sock = socket(AF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC, 0);
    if (sock < 0) { perror("socket"); return 1; }
    struct sockaddr_un addr = {.sun_family = AF_UNIX};
    memcpy(addr.sun_path, path, strlen(path) + 1);
    struct stat st;
    if (lstat(path, &st) == 0) {
        if (!S_ISSOCK(st.st_mode) || st.st_uid != getuid()) {
            fprintf(stderr, "Refusing to replace existing socket\n");
            close(sock); return 1;
        }
        unlink(path);
    }
    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) { perror("bind"); close(sock); return 1; }
    chmod(path, 0600);
    signal(SIGINT, stop_running);
    signal(SIGTERM, stop_running);

    libusb_context *usb = NULL;
    if (libusb_init(&usb) != 0) { unlink(path); close(sock); return 1; }
    libusb_device_handle *pad = NULL;
    while (running) {
        uint8_t motors[2];
        struct pollfd pfd = {.fd = sock, .events = POLLIN};
        int polled = poll(&pfd, 1, 500);
        if (polled <= 0) continue;
        if (recv(sock, motors, sizeof(motors), 0) != sizeof(motors)) continue;
        if (!pad) {
            pad = libusb_open_device_with_vid_pid(usb, 0x37d7, 0x2401);
            if (!pad) { fprintf(stderr, "Vader 5 Pro USB dongle unavailable\n"); continue; }
            int rc = libusb_claim_interface(pad, 0);
            if (rc != 0) {
                fprintf(stderr, "Interface 0 unavailable: %s (is xpad bound?)\n", libusb_error_name(rc));
                libusb_close(pad); pad = NULL; continue;
            }
        }
        uint8_t packet[8] = {0x00, 0x08, 0x00, motors[0], motors[1], 0, 0, 0};
        int transferred = 0;
        int rc = libusb_interrupt_transfer(pad, 0x05, packet, sizeof(packet), &transferred, 100);
        if (rc != 0 || transferred != sizeof(packet)) {
            fprintf(stderr, "Xbox rumble write failed: %s\n", libusb_error_name(rc));
            libusb_release_interface(pad, 0);
            libusb_close(pad); pad = NULL;
        }
    }
    if (pad) {
        uint8_t off[8] = {0, 8, 0, 0, 0, 0, 0, 0};
        int transferred = 0;
        libusb_interrupt_transfer(pad, 0x05, off, sizeof(off), &transferred, 100);
        libusb_release_interface(pad, 0);
        libusb_close(pad);
    }
    libusb_exit(usb);
    unlink(path);
    close(sock);
    return 0;
}
