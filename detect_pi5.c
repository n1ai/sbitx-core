#include <stdio.h>
#include <string.h>
#include <errno.h>

#define MODEL_PATH_1 "/proc/device-tree/model"
#define MODEL_PATH_2 "/sys/firmware/devicetree/base/model"

int is_pi5(void) {
    const char *paths[] = { MODEL_PATH_1, MODEL_PATH_2 };
    char buf[256];

    for (size_t i = 0; i < sizeof(paths) / sizeof(paths[0]); i++) {
        FILE *f = fopen(paths[i], "r");
        if (!f)
            continue;

        size_t n = fread(buf, 1, sizeof(buf) - 1, f);
        fclose(f);

        if (n == 0)
            continue;

        buf[n] = '\0';

        /* Device-tree strings may contain trailing NULs */
        if (strstr(buf, "Raspberry Pi 5") != NULL)
            return 1;
    }

    return 0;
}

#if 0
int main(void) {
    if (is_pi5())
        puts("is a pi5");
    else
        puts("is not a pi5");

    return 0;
}
#endif
