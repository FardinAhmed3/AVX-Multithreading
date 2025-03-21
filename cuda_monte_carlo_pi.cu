#include <iostream>
#include <random>
#include <cuda_runtime.h>
#include <curand_kernel.h>

__global__ void monteCarloPi(unsigned long long *d_count, unsigned long iterations, unsigned int seed) {
    unsigned long long localCount = 0;
    curandState state;
    curand_init(seed + threadIdx.x + blockIdx.x * blockDim.x, 0, 0, &state);
    
    for (unsigned long i = 0; i < iterations; i++) {
        double x = curand_uniform(&state);
        double y = curand_uniform(&state);
        if (x * x + y * y <= 1.0)
            localCount++;
    }
    atomicAdd(d_count, localCount);
}

int main() {
    unsigned long totalIterations;
    std::cout << "Enter total number of iterations: ";
    std::cin >> totalIterations;
    
    int numThreads = 256;
    int numBlocks = 1024;
    unsigned long iterationsPerThread = totalIterations / (numThreads * numBlocks);
    
    unsigned long long *d_count, h_count = 0;
    cudaMalloc(&d_count, sizeof(unsigned long long));
    cudaMemcpy(d_count, &h_count, sizeof(unsigned long long), cudaMemcpyHostToDevice);
    
    monteCarloPi<<<numBlocks, numThreads>>>(d_count, iterationsPerThread, time(0));
    cudaMemcpy(&h_count, d_count, sizeof(unsigned long long), cudaMemcpyDeviceToHost);
    
    double piEstimate = 4.0 * static_cast<double>(h_count) / totalIterations;
    std::cout << "Estimated Pi = " << piEstimate << std::endl;
    
    cudaFree(d_count);
    return 0;
}