module fifo_formal;

  parameter DATA_WIDTH = fifo_pkg::DATA_WIDTH;
  parameter ADDR_WIDTH = fifo_pkg::ADDR_WIDTH;

  logic wr_clk, rd_clk;
  logic wr_rst_n = 0, rd_rst_n = 0;

  logic wr_en, rd_en;
  logic [DATA_WIDTH-1:0] wr_data;
  logic [DATA_WIDTH-1:0] rd_data;
  logic full, empty;
`ifndef VERILATOR
  // Clock generation
  always #5  wr_clk = ~wr_clk;  // 100 MHz
  always #8  rd_clk = ~rd_clk;  // 62.5 MHz
`endif
  // DUT instantiation
fifo_async #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut (
    .wr_clk(wr_clk),
    .wr_rst_n(wr_rst_n),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .full(full),

    .rd_clk(rd_clk),
    .rd_rst_n(rd_rst_n),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .empty(empty)
  );
`ifndef VERILATOR
  // Initial reset
  initial begin
    wr_rst_n = 0;
    rd_rst_n = 0;
    #20;
    wr_rst_n = 1;
    rd_rst_n = 1;
  end
`endif
  // Symbolic input data (used by formal tools)
  `ifndef VERILATOR 
    always_comb wr_data = $anyseq;
  `endif

  // Assumptions: never write when full or read when empty
  always_ff @(posedge wr_clk) begin
    if (full) assume (!wr_en);
  end

  always_ff @(posedge rd_clk) begin
    if (empty) assume (!rd_en);
  end

  // Cover: prove that data can flow through the FIFO
  // Cover: prove that data can flow through the FIFO
  always_ff @(posedge wr_clk)
    cover (wr_en && !full);

  always_ff @(posedge rd_clk)
    cover (rd_en && !empty);


endmodule

