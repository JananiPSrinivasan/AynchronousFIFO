package fifo_pkg;
    parameter int DATA_WIDTH =8;
    parameter int ADDR_WIDTH = 3;
    parameter int DEPTH = 1 << ADDR_WIDTH; // left shift the binary number 1 by addr_width bits ie., 2^3 = 8
endpackage