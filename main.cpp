#pragma once
#include "common/arrrgh.hpp"
#include "common/lodepng.h"
#include "newtonFractal.cuh"
#include "structs.h"

void makediff(cuFloatComplex * coeff, cuFloatComplex* diffcoeff, unsigned const int degree) {
	for (unsigned int i = 0; i < degree; i++) {
		diffcoeff[i] = (float)(i + 1) * coeff[i + 1];
	}
}

int main(int argc, const char **argv) {
	const std::string output("../output/newtonFractal.png");
	const unsigned int width = 3840;
	const unsigned int height = 2160;
	std::vector<unsigned char> frameBuffer;

	frameBuffer = makefb(width, height);
	std::cout << "Writing image to '" << output << "'..." << std::endl;

	unsigned error = lodepng::encode(output, frameBuffer, width, height);

	//if(error)
	//{
	//	std::cout << "An error occurred while writing the image file: " << error << ": " << lodepng_error_text(error) << std::endl;
	//}

	return 0;
}
