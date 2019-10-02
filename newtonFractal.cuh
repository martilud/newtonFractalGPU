#pragma once
#include <vector>
#include "cuComplex.cu"
#include "structs.h"


cuFloatComplex evalPoly(cuFloatComplex x, cuFloatComplex*coeff, unsigned int degree);

std::vector<unsigned char> makefb(
	unsigned int width,
	unsigned int height);

