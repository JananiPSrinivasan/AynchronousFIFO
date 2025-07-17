`include "fifo_pkg.sv"

module fifo_async #(parameter DATA_WIDTH = fifo_pkg :: DATA_WIDTH,
                    parameter ADDR_WIDTH = fifo_pkg:: ADDR_WIDTH
                    )(
                        input logic wr_clk,
                        input logic rd_clk,
                        
                        input logic wr_rst_n,
                        input logic rd_rst_n,

                        input logic rd_en,
                        input logic wr_en,

                        input logic[DATA_WIDTH-1:0] wr_data,
                        output logic [DATA_WIDTH-1:0] rd_data,

                        output logic full,
                        output logic empty
                    );

            //Internal signals
            logic [ADDR_WIDTH-1:0] rd_addr, wr_addr;
            logic [ADDR_WIDTH:0] wr_gray_ptr, rd_gray_ptr;
            logic [ADDR_WIDTH:0] wr_gr_ptr_sync_rd,rd_gr_ptr_sync_wr;

            //Write Control Logic
            fifo_write_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) write_ctrl(
                .clk           (wr_clk),
                .rst_n         (wr_rst_n),
                .wr_en         (wr_en),
                .rd_ptr_sync   (rd_gr_ptr_sync_wr),
                .full          (full),
                .wr_gray_ptr   (wr_gray_ptr),
                .wr_addr       (wr_addr)
            );
            
            // Read Control Logic
            fifo_read_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) read_ctrl(
                .clk              (rd_clk),
                .rst_n            (rd_rst_n),
                .rd_en            (rd_en),
                .wr_gr_ptr_sync   (wr_gr_ptr_sync_rd),
                .empty            (empty),
                .rd_gray_ptr      (rd_gray_ptr),
                .rd_addr          (rd_addr)
	    );

            // Memory 

            fifo_mem #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) mem(
                .wr_clk   (wr_clk),
                .wr_en    (wr_en & ~full),
                .wr_addr  (wr_addr),
                .wr_data  (wr_data),
                .rd_clk   (rd_clk),
                .rd_addr  (rd_addr),
                .rd_data  (rd_data)
            );

            //Synchronisation Logic
            sync_gray #(.WIDTH(ADDR_WIDTH+1)) wr_to_rd (
                .clk    (rd_clk),
                .rst_n  (rd_rst_n),
                .d      (wr_gray_ptr),
                .q      (wr_gr_ptr_sync_rd)

            );

            sync_gray #(.WIDTH(ADDR_WIDTH+1)) rd_to_wr (
                .clk    (wr_clk),
                .rst_n  (wr_rst_n),
                .d      (rd_gray_ptr),
                .q      (rd_gr_ptr_sync_wr)


            );
endmodule
