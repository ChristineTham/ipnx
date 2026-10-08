/* ipnx: size_t is used below and nothing this file includes declares it;
   new.h, malloc.h and stddef.h say the same, and cfront takes it twice. */
typedef unsigned size_t;
extern "C" {
	extern void* memccpy(void*, const void*, int, size_t);
	extern void* memchr(const void*, int, size_t);
	extern int memcmp(const void*, const void*, size_t);
	extern void* memcpy(void*, const void*, size_t);
	extern void* memset(void*, int, size_t);
	extern void* memmove(void*, const void*, size_t);
}
