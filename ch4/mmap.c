#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>

/**
 * mmapcopy - copy the contents of a file on disk into stdout
 *
 * @fd the file descriptor
 * @size the size of the file in bytes
 */
void mmapcopy(int fd, size_t size);

int main(int argc, char *argv[])
{
    struct stat stat;
    int fd;

    if (argc != 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        exit(0);
    }

    fd = open(argv[1], O_RDONLY, 0);
    fstat(fd, &stat);
    mmapcopy(fd, stat.st_size);
    return 0;
}

void mmapcopy(int fd, size_t size)
{
    char *buf;
    buf = mmap(0, size, PROT_READ, MAP_PRIVATE, fd, 0);
    write(1, buf, size);
    return;
}
