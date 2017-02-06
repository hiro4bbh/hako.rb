#include <math.h>

void dexp(unsigned int length, double *x, unsigned int skip)
{
	unsigned int i;
	for (i = 0; i < length; i += skip) {
		x[i] = exp(x[i]);
	}
}
