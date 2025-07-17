module sync_gray(#parameter WIDTH=3)(
    input logic clk,
    input logic rst_n,
    input logic [WIDTH-1:0]d,
    output logic [WIDTH-1:0]q
);

logic [WIDTH-1:0] stage1;

always_ff @ (posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        stage1 <= '0;
        q<='0;
    end
    else begin
        stage1 <= d;
        q <= stage1;
    end
end
    
endmodule
