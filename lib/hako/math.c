#include <math.h>

void dexp(int xlength, double *x, int skip)
{
	int i;
	for (i = 0; i < xlength; i += skip) {
		x[i] = exp(x[i]);
	}
}

void dhad(int xlength, double *x, int xskip, double *y, int yskip)
{
	int xi, yi = 0;
	for (xi = 0; xi < xlength; xi += xskip) {
		x[xi] *= y[yi];
		yi += yskip;
	}
}

void dpow(unsigned int xlength, double *x, int xskip, double y, double non_finite_alt)
{
	int xi;
	double z;
	for (xi = 0; xi < xlength; xi += xskip) {
		z = pow(x[xi], y);
		x[xi] = isfinite(z) ? z : non_finite_alt;
	}
}

void dsign(unsigned int xlength, double *x, int xskip, double *c, int cskip, double *p, int pskip, double *z, int zskip, double *n, int nskip)
{
	int xi, ci = 0, pi = 0, zi = 0, ni = 0;
	for (xi = 0; xi < xlength; xi += xskip) {
		if (c[ci] > 0) {
			x[xi] = p[pi];
		} else if (c[ci] == 0) {
			x[xi] = z[zi];
		} else {
			x[xi] = n[ni];
		}
		ci += cskip;
		pi += pskip;
		zi += zskip;
		ni += nskip;
	}
}
