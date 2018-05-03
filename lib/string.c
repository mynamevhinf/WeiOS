#include <include/types.h>
#include <include/string.h>

int strlen(char *s)
{
    if (!s)
        return -1;

    int i = 0;
    while (s[i++] != '\0')
        continue;
    return i-1;
}

int strcmp(const char *str1, const char *str2)
{
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return (int)((uchar)*str1 - (uchar)*str2);
}

int strncmp(const char *str1, const char *str2, int n)
{
    while ((n > 0) && (*str1) && (*str1 == *str2)) {
        n--;
        str1++;
        str2++;
    }
    if (!n)
        return 0;
    return (uchar)(*str1) - (uchar)(*str2);
}

char *strcpy(char *des, const char *src)
{
    if (!des || !src)
        return 0;

    char *r = des;
    while ((*des++ = *src++) != '\0') 
        continue;
    return r;
}

char *strncpy(char *des, const char *src, int n)
{
    if (!des || !src)
        return 0;

    while (((*des++ = *src++) != '\0') && --n > 0)
        continue;
    *des = '\0';
    return des;
}

char *strcat(char *des, char *src)
{
    int len = strlen(des);
    strcpy(des+len, src);
    return des;
}

char *strncat(char *des, const char *src, int nbytes)
{
    int len = strlen(des);
    strncpy(des+len, src, nbytes);
    return des;
}

char *strchr(char *s, char c)
{
    if (!s)
        return 0;

    while (*s) {
        if (*s == c)
            return s;
        s++;
    }
    return 0;
}

void *memset(void *s, char ch, size_t n)
{
    char *ts = s;
    for (int i = 0; i < n; i++)
        *ts++ = ch;
    return s;
}

void *memmove(void *dst, const void *src, size_t n)
{
    const char *s = src;
    char *d = dst;

    if (s < d && (s + n > d)) {
        s += n;
        d += n;
        while (n-- > 0)
            *--d = *--s;
    } else {
        while (n-- > 0)
            *d++ = *s++;
    }
    return dst;
}

void *memcpy(void *dst, const void *src, size_t n)
{
    return memmove(dst, src, n);
}

int memcmp(const void *v1, const void *v2, size_t n)
{
    const uint8_t *s1 = (const uint8_t *) v1;
    const uint8_t *s2 = (const uint8_t *) v2;

    while (n-- > 0) {
        if (*s1 != *s2)
            return (int) *s1 - (int) *s2;
        s1++, s2++;
    }

    return 0;
}

char* safestrcpy(char *s, const char *t, int n)
{
    char *os;

    os = s;
    if(n <= 0)
        return os;
    while(--n > 0 && (*s++ = *t++) != 0)
        ;
    *s = 0;
    return os;
}

void lowercase(char *s)
{
    if (!s)
        return;

    while (*s) {
        if (*s >= 'A' && *s <= 'a')
            *s |= 0x20; 
        s++;
    }
}
