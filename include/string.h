#ifndef _STRING_H_
#define _STRING_H_

int strlen(char *s);
int strcmp(const char *str1, const char *str2);
int strncmp(const char *str1, const char *str2, int n);
char *strcpy(char *des, const char *src);
char *strncpy(char *des, const char *src, int n);
char *strcat(char *des, char *src);
char *strncat(char *des, const char *src, int nbytes);
char *strchr(char *s, char c);
char* safestrcpy(char *s, const char *t, int n);
void *memset(void *s, char ch, size_t n);
void *memmove(void *dst, const void *src, size_t n);
void *memcpy(void *dst, const void *src, size_t n);

void lowercase(char *s);



#endif
