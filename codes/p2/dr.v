module dr (clk, dmOut, writeback);
    input clk;
    input [31:0] dmOut;
    output reg [31:0] writeback;

    always @(posedge clk) begin
        writeback <= dmOut;
    end
endmodule
