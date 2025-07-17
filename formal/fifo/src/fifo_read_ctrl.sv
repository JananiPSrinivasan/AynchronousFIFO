/*
    Read Control determines 
    1. The incrementing of the read pointer
    2. The Gray code conversion for the address 
    3. Read address for the memory
    4. Watch for the "empty" flag

*/

`include "fifo_pkg.sv"
module fifo_read_ctrl  #( parameter ADDR_WIDTH = fifo_pkg::ADDR_WIDTH)(
    input logic clk,
    input logic rst_n,
    input logic rd_en,
    input logic [ADDR_WIDTH:0] wr_gr_ptr_sync,

    output logic empty,
    output logic [ADDR_WIDTH:0]rd_gray_ptr,
    output logic [ADDR_WIDTH-1:0] rd_addr

);

logic [ADDR_WIDTH:0] rd_bin_ptr;


// 1. Start with the pointer increment logic

always_ff @ (posedge clk or negedge rst_n)begin
    if (!rst_n) begin 
        rd_bin_ptr <= '0;
    end
    else if (!empty && rd_en) begin
        rd_bin_ptr <= rd_bin_ptr+1;
    end
end


// 2. Convert the binary write pointer to Gray code.
//    Gray code is used to safely transfer the pointer value across asynchronous clock domains,
//    as it ensures only one bit changes at a time, reducing metastability risk.
//
//    Conversion rule:
//      - Retain the most significant bit (MSB) as-is.
//      - For all other bits, perform bitwise XOR between adjacent binary bits:
//        Gray[i] = Binary[i+1] ^ Binary[i]


assign rd_gray_ptr = rd_bin_ptr ^ (rd_bin_ptr>>1);

// 3. Extract the memory read address from the binary pointer.
//    Since the memory depth is 2^ADDR_WIDTH, only the lower ADDR_WIDTH bits
//    of the binary write pointer are needed to address the memory location.
//    The MSB of the binary pointer is used solely for wrap-around tracking
//    and full/empty detection — not for addressing the memory.

assign rd_addr = rd_bin_ptr[ADDR_WIDTH-1:0];

// 4. Check for empty condition

assign empty = (rd_gray_ptr == wr_gr_ptr_sync);


endmodule
