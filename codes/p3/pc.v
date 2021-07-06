module pc (clk, rst, PCWr, result, address);
    input clk, rst, PCWr;
    input [31:0]result;
    output reg[31:0] address;
    
    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            address <= 32'h0000_3000;
        end
        else if(PCWr) begin
            address <= result;
        end
        else address <= address;
    end

endmodule



