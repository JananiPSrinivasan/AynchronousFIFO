/*
    Write Control determines 
    1. The incrementing of the write pointer
    2. The Gray code conversion for the address 
    3. Write address location to store the data for the memory
    4. Stop writing if the FULL flag is encountered

*/


`include fifo_pkg.sv
module fifo_write_ctrl #(parameter ADDR_WIDTH = fifo_pkg::ADDR_WIDTH )(
    input logic clk,
    input logic rst_n, // active-low 
    input logic wr_en, 
    input logic [ADDR_WIDTH:0] rd_ptr_sync, // pointer to synchronise data from read domain

    output logic full,
    output logic [ADDR_WIDTH:0] wr_gray_ptr, // 0 to addr_width to track empty/full and wrap-around events
    output logic [ADDR_WIDTH-1:0] wr_addr // 
);

logic [ADDR_WIDTH:0] wr_bin_ptr; // binary write pointer 


// 1. Start with the pointer increment logic

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin // if reset_n is active, perform reset operation by
        wr_bin_ptr <= '0; // settin write binary pointer to 0
    end
    else if (wr_en && !full) begin // if write is enabled and the FIFO flag is not full
        wr_bin_ptr <= wr_bin_ptr+1; // increment the write binary pointer by one
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

assign wr_gray_ptr = wr_bin_ptr ^ (wr_bin_ptr>>1);

// 3. Extract the memory write address from the binary pointer.
//    Since the memory depth is 2^ADDR_WIDTH, only the lower ADDR_WIDTH bits
//    of the binary write pointer are needed to address the memory location.
//    The MSB of the binary pointer is used solely for wrap-around tracking
//    and full/empty detection — not for addressing the memory.

assign wr_addr = wr_bin_ptr[ADDR_WIDTH-1:0];


// 4. FULL condition detection:
//    The FIFO is considered FULL when the next write pointer (in Gray code)
//    equals the synchronized read pointer, with the two MSBs inverted.
//    This condition detects the "wrap-around" scenario where the write pointer
//    has caught up to the read pointer but is one full cycle ahead.
//
//    Specifically:
//      - Invert the two MSBs of the synchronized read pointer
//      - Keep the remaining bits unchanged
//      - If this modified value matches the current Gray-coded write pointer,
//        it means the FIFO is full


assign full = (wr_gray_ptr == {~rd_ptr_sync[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_sync[ADDR_WIDTH-2:0]});



endmodule