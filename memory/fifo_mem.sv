`include "fifo_pkg.sv"

module fifo_mem #(
  parameter ADDR_WIDTH = fifo_pkg :: ADDR_WIDTH,
  parameter DATA_WIDTH = fifo_pkg :: DATA_WIDTH
)(
    input logic wr_clk,
    input logic wr_en,
    input logic [ADDR_WIDTH-1:0]wr_addr,
    input logic [DATA_WIDTH-1:0]wr_data,

    input logic rd_clk,
    input logic [ADDR_WIDTH-1:0]rd_addr,
    output logic [DATA_WIDTH-1:0]rd_data

);

logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

always_ff @ (posedge wr_clk) begin
    if (wr_en) begin
        mem[wr_addr] <= wr_data;
    end
end

always_ff @ (posedge rd_clk) begin
    rd_data <= mem[rd_addr];
end

endmodule
