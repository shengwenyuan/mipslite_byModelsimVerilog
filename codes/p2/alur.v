module alur (aluResult, alurOut);
    input [31:0] aluResult;
    output reg [31:0] alurOut;

    always @(*) begin
        alurOut = aluResult;
    end
endmodule
