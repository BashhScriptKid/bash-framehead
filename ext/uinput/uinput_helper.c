/*
 * uinput_helper.c — Minimal uinput helper for bash-framehead
 *
 * Usage:
 *   uinput_helper create <name>                         Create virtual device
 *   uinput_helper destroy <fd_path>                     Destroy virtual device
 *   uinput_helper key <fd_path> <code> <value>          Emit key event
 *   uinput_helper mouse <fd_path> <dx> <dy>             Emit relative mouse
 *   uinput_helper abs <fd_path> <code> <value>          Emit absolute axis
 *   uinput_helper event <fd_path> <type> <code> <value> Emit raw event
 *
 * Compile: gcc -o uinput_helper uinput_helper.c
 * No dependencies beyond libc.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/uinput.h>
#include <errno.h>

#define die(...) do { fprintf(stderr, __VA_ARGS__); exit(1); } while(0)

static void emit(int fd, int type, int code, int value) {
    struct input_event ev;
    memset(&ev, 0, sizeof(ev));
    ev.type = type;
    ev.code = code;
    ev.value = value;
    if (write(fd, &ev, sizeof(ev)) < 0)
        die("emit: write failed: %s\n", strerror(errno));
}

static void emit_syn(int fd) {
    emit(fd, EV_SYN, SYN_REPORT, 0);
}

static int do_create(const char *name) {
    int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd < 0)
        die("create: open /dev/uinput failed: %s\n", strerror(errno));

    /* Enable event types */
    if (ioctl(fd, UI_SET_EVBIT, EV_KEY) < 0)
        die("create: UI_SET_EVBIT EV_KEY failed\n");

    /* Enable all keys */
    int i;
    for (i = 0; i < KEY_MAX; i++)
        ioctl(fd, UI_SET_KEYBIT, i);

    /* Enable relative axes (mouse) */
    if (ioctl(fd, UI_SET_EVBIT, EV_REL) < 0)
        die("create: UI_SET_EVBIT EV_REL failed\n");
    ioctl(fd, UI_SET_RELBIT, REL_X);
    ioctl(fd, UI_SET_RELBIT, REL_Y);
    ioctl(fd, UI_SET_RELBIT, REL_WHEEL);

    /* Enable absolute axes (touchscreen/gamepad) */
    if (ioctl(fd, UI_SET_EVBIT, EV_ABS) < 0)
        die("create: UI_SET_EVBIT EV_ABS failed\n");
    ioctl(fd, UI_SET_ABSBIT, ABS_X);
    ioctl(fd, UI_SET_ABSBIT, ABS_Y);

    /* Enable syn */
    ioctl(fd, UI_SET_EVBIT, EV_SYN);

    /* Configure device */
    struct uinput_user_dev uidev;
    memset(&uidev, 0, sizeof(uidev));
    strncpy(uidev.name, name, UINPUT_MAX_NAME_SIZE - 1);
    uidev.id.bustype = BUS_USB;
    uidev.id.vendor  = 0x1234;
    uidev.id.product = 0x5678;
    uidev.id.version = 1;

    /* ABS axis ranges */
    uidev.absmin[ABS_X] = 0;
    uidev.absmax[ABS_X] = 32767;
    uidev.absmin[ABS_Y] = 0;
    uidev.absmax[ABS_Y] = 32767;

    if (write(fd, &uidev, sizeof(uidev)) < 0)
        die("create: write uidev failed: %s\n", strerror(errno));

    if (ioctl(fd, UI_DEV_CREATE) < 0)
        die("create: UI_DEV_CREATE failed: %s\n", strerror(errno));

    /* Print the fd path for reuse */
    printf("/dev/uinput\n");
    return 0;
}

static int do_destroy(const char *path) {
    int fd = open(path, O_WRONLY | O_NONBLOCK);
    if (fd < 0)
        die("destroy: open %s failed: %s\n", path, strerror(errno));

    if (ioctl(fd, UI_DEV_DESTROY) < 0)
        die("destroy: UI_DEV_DESTROY failed: %s\n", strerror(errno));

    close(fd);
    return 0;
}

static int do_key(const char *path, int code, int value) {
    int fd = open(path, O_WRONLY | O_NONBLOCK);
    if (fd < 0)
        die("key: open %s failed: %s\n", path, strerror(errno));

    emit(fd, EV_KEY, code, value);
    emit_syn(fd);
    close(fd);
    return 0;
}

static int do_mouse(const char *path, int dx, int dy) {
    int fd = open(path, O_WRONLY | O_NONBLOCK);
    if (fd < 0)
        die("mouse: open %s failed: %s\n", path, strerror(errno));

    emit(fd, EV_REL, REL_X, dx);
    emit(fd, EV_REL, REL_Y, dy);
    emit_syn(fd);
    close(fd);
    return 0;
}

static int do_abs(const char *path, int code, int value) {
    int fd = open(path, O_WRONLY | O_NONBLOCK);
    if (fd < 0)
        die("abs: open %s failed: %s\n", path, strerror(errno));

    emit(fd, EV_ABS, code, value);
    emit_syn(fd);
    close(fd);
    return 0;
}

static int do_event(const char *path, int type, int code, int value) {
    int fd = open(path, O_WRONLY | O_NONBLOCK);
    if (fd < 0)
        die("event: open %s failed: %s\n", path, strerror(errno));

    emit(fd, type, code, value);
    emit_syn(fd);
    close(fd);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr,
            "Usage: %s <command> [args...]\n"
            "\n"
            "Commands:\n"
            "  create <name>                         Create virtual device\n"
            "  destroy <fd_path>                     Destroy virtual device\n"
            "  key <fd_path> <code> <value>          Emit key event\n"
            "  mouse <fd_path> <dx> <dy>             Emit relative mouse\n"
            "  abs <fd_path> <code> <value>          Emit absolute axis\n"
            "  event <fd_path> <type> <code> <value> Emit raw event\n",
            argv[0]);
        return 1;
    }

    const char *cmd = argv[1];

    if (strcmp(cmd, "create") == 0) {
        if (argc < 3) die("create: missing name\n");
        return do_create(argv[2]);
    }

    if (strcmp(cmd, "destroy") == 0) {
        if (argc < 3) die("destroy: missing fd_path\n");
        return do_destroy(argv[2]);
    }

    if (strcmp(cmd, "key") == 0) {
        if (argc < 5) die("key: missing args (fd_path code value)\n");
        return do_key(argv[2], atoi(argv[3]), atoi(argv[4]));
    }

    if (strcmp(cmd, "mouse") == 0) {
        if (argc < 5) die("mouse: missing args (fd_path dx dy)\n");
        return do_mouse(argv[2], atoi(argv[3]), atoi(argv[4]));
    }

    if (strcmp(cmd, "abs") == 0) {
        if (argc < 5) die("abs: missing args (fd_path code value)\n");
        return do_abs(argv[2], atoi(argv[3]), atoi(argv[4]));
    }

    if (strcmp(cmd, "event") == 0) {
        if (argc < 6) die("event: missing args (fd_path type code value)\n");
        return do_event(argv[2], atoi(argv[3]), atoi(argv[4]), atoi(argv[5]));
    }

    die("unknown command: %s\n", cmd);
    return 1;
}
