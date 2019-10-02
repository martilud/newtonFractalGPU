#pragma once
#include <cmath>
#include <complex>
#include <vector>
#include "cuComplex.cu"



struct polynomial {
	unsigned int degree;
	cuFloatComplex* coeff;
	cuFloatComplex* diffcoeff;
	cuFloatComplex* zeros;
};

struct instance {
	float xmin;
	float xmax;
	float ymin;
	float ymax;
	polynomial poly;
};