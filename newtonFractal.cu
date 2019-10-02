#include "newtonFractal.cuh"
#include "structs.h"
#include "cuda_runtime.h"
#include "cuda_error_helper.hpp"


__global__ void initialiseFramebuffer(unsigned char* frameBuffer, int width, int height) {
	// Initializes framebuffer to black
	unsigned int threadIndex = blockDim.x * blockIdx.x + threadIdx.x;

	if (threadIndex >= 4 * width * height) {
		return;
	}

	if (threadIndex % 4 == 3) {
		frameBuffer[threadIndex] = 255;
	}
	else {
		frameBuffer[threadIndex] = 0;
	}
}

__global__ void dummyKernel(unsigned char* frameBuffer, int width, int heigth) {
	unsigned int index = blockDim.x * blockIdx.x + threadIdx.x;
	if (threadIdx.x < 128) {
		frameBuffer[4 * index] = 0;
		frameBuffer[4 * index + 1] = 0;
		frameBuffer[4 * index + 2] = 0;
	}
}

__global__ void newtonFractal1(unsigned const int width, unsigned const int height, 
	const float scale,
	unsigned char* frameBuffer) {
	unsigned int index = blockDim.x * blockIdx.x + threadIdx.x;
	// Initial guess
	cuFloatComplex z = make_cuComplex(scale * (-1.0 + 2.0 * ((float)(index%width) / (float)width)), scale * (-1.0 + 2.0 * floorf(index / width) / (float)height));
	// Do 10 steps of newton
	for (unsigned int i = 0; i < 40; i++) {
		z = cuCsubf(z, cuCdivf(cuCsubf(1000000000*cuCmulf(z,cuCmulf(z,z)), make_cuFloatComplex(1,0)), 3000000000 * cuCmulf(z,z)));
	}
	// Find closest result
	int result = -1;
	cuFloatComplex zeros[3] = {
		0.001 * make_cuFloatComplex(1.0f,0.0f),
		0.001 * make_cuFloatComplex(-0.5f, 0.8660254037844f),
		0.001 * make_cuFloatComplex(-0.5f, -0.8660254037844f) };
	for (unsigned int i = 0; i < 3; i++) {
		if (cuCnormf(cuCsubf(z, zeros[i])) < 1e-8) {
			result = i;
		}
	}
	if (result != -1) {
		frameBuffer[4 * index + 0] = 0;
		frameBuffer[4 * index + 1] = 0;
		frameBuffer[4 * index + 2] = 0;
		frameBuffer[4 * index + result] = 255;
	}
}

std::vector<unsigned char> makefb(unsigned int width, unsigned int height) {
	unsigned char* frameBuffer = new unsigned char[width * height * 4];
	unsigned char* device_frameBuffer;
	checkCudaErrors(cudaMalloc(&device_frameBuffer, width * height * 4 * sizeof(unsigned char)));
	const unsigned int initialisationBlockSize = 256;
	 
	unsigned int blockCountFrameBuffer = ((width * height * 4) / initialisationBlockSize);
	initialiseFramebuffer<<<blockCountFrameBuffer, initialisationBlockSize>>> (device_frameBuffer, width, height);
	checkCudaErrors(cudaDeviceSynchronize());
	
	unsigned int blockSize = 256;
	unsigned int gridSize = width * height / blockSize;
	//dummyKernel<<<gridSize, blockSize>>> (device_frameBuffer, width, height);
	//checkCudaErrors(cudaDeviceSynchronize())
	newtonFractal1<<<gridSize, blockSize>>>(width, height,
		0.00001f,
		device_frameBuffer
		);
	checkCudaErrors(cudaDeviceSynchronize());
	std::vector<unsigned char> outputFramebuffer(frameBuffer, frameBuffer + (width * height * 4));
	checkCudaErrors(cudaMemcpy(outputFramebuffer.data(), device_frameBuffer, width * height * 4 * sizeof(unsigned char), cudaMemcpyDeviceToHost));
	checkCudaErrors(cudaDeviceSynchronize());
	cudaDeviceReset();
	return outputFramebuffer;
}
