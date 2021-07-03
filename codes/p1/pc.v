module pc (clk, rst, result, address);
    input clk;
    input rst;
    input [31:0]result;
    output reg[31:0] address;
    
    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            address <= 32'h0000_3000;
        end
        else begin
            address <= result;
        end
    end

endmodule

