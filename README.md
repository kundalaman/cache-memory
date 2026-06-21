# cache-memory

# Cache Memory Controller in Verilog

This project implements a simplified 2-Way Set Associative Cache Controller using Verilog HDL to understand how modern processors interact with cache and main memory. The cache acts as a small and fast memory placed between the CPU and RAM, reducing the average memory access time. The design supports basic read and write operations and is capable of detecting cache hits and cache misses. During a cache hit, data is directly returned from the cache, while during a cache miss, the controller fetches the required data from the main memory and updates the cache.

The cache architecture consists of data arrays, tag arrays, valid bits, dirty bits, and an LRU (Least Recently Used) replacement mechanism. Valid bits indicate whether a cache line contains useful data, while dirty bits track whether the cached data has been modified and needs to be written back to memory before replacement. The LRU policy is used to decide which cache line should be replaced during a miss, helping to improve cache efficiency and reduce unnecessary memory accesses.

A Finite State Machine (FSM) was designed to control the complete cache operation. The FSM contains four states: IDLE, COMPARE_TAG, WRITE_BACK, and ALLOCATE. Depending on the CPU request and cache status, the controller moves between these states to compare tags, handle cache misses, write modified data back to memory, allocate new cache blocks, and return data to the processor. During cache misses, the CPU is stalled temporarily until the required memory operation is completed.
