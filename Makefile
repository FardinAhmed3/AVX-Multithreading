CXX = g++
NVCC = nvcc

CXXFLAGS = -O2 -std=c++11 -pthread
NVCCFLAGS = -O2 -std=c++11 -lcudart -lcurand

SRC_CPU = cpu_monte_carlo_pi.cpp
SRC_CUDA = cuda_monte_carlo_pi.cu

ifeq ($(OS),Windows_NT)
    OUT_CPU = cpu_monte_carlo_pi.exe
    OUT_CUDA = cuda_monte_carlo_pi.exe
else
    OUT_CPU = cpu_monte_carlo_pi.out
    OUT_CUDA = cuda_monte_carlo_pi.out
endif

all: cpu cuda

cpu: $(SRC_CPU)
	$(CXX) $(CXXFLAGS) -o $(OUT_CPU) $(SRC_CPU)

cuda: $(SRC_CUDA)
	$(NVCC) $(NVCCFLAGS) -o $(OUT_CUDA) $(SRC_CUDA)

clean:
	rm -f *.out *.exe
