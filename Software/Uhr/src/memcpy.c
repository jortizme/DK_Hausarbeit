// ---------------------------------------------------------------------------
// Memcpy function
// (c) Bernhard Lang, FH Osnabrueck
// ---------------------------------------------------------------------------

#include <string.h>
#include <stddef.h> // Include for size_t definition

void *memcpy(void *dest, const void *src, size_t count)
{
	char *dst8 = (char *)dest;
	char *src8 = (char *)src;

	while (count--) {
		*dst8++ = *src8++;
	}
	return dest;
}