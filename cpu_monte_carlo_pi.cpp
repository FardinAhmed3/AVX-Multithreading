/* Monte Carlo Simulation for a PI approximation
Uses CPU Multithreading & Concurrency via kernel level scheduling*/

#include <iostream>
#include <vector>
#include <thread>
#include <random>

using namespace std;

int main() {
    unsigned long totalIterations;
    cout << "Enter total number of iterations: ";
    cin >> totalIterations;

    unsigned int numThreads = thread::hardware_concurrency();
    if (numThreads == 0) numThreads = 2; // Fallback if hardware_concurrency is 0

    // Calculate iterations per thread.
    unsigned long iterationsPerThread = totalIterations / numThreads;
    unsigned long remainder = totalIterations % numThreads;

    vector<thread> threads;
    vector<unsigned long> counts(numThreads, 0);

    for (unsigned int i = 0; i < numThreads; i++) {
       
        unsigned long iterations = iterationsPerThread + (i < remainder ? 1 : 0);

        threads.emplace_back([i, iterations, &counts]() {
            // Each thread uses its own random engine seeded from random_device.
            random_device rd;
            mt19937 gen(rd());
            uniform_real_distribution<double> dis(0.0, 1.0);
            unsigned long localCount = 0;

            for (unsigned long j = 0; j < iterations; j++) {
                double x = dis(gen);
                double y = dis(gen);
                if (x * x + y * y <= 1.0)
                    localCount++;
            }
            counts[i] = localCount;
        });
    }

    // Join all threads
    for (auto &t : threads)
        t.join();

    unsigned long totalInside = 0;
    for (unsigned long count : counts)
        totalInside += count;

    double piEstimate = 4.0 * static_cast<double>(totalInside) / totalIterations;
    cout << "Estimated Pi = " << piEstimate << endl;

    return 0;
}
