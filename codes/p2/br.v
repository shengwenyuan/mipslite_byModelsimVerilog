module br(ReadData2, busB);
    input [31:0] ReadData2;
    output reg [31:0] busB;

    always @(*) begin
        busB = ReadData2;
    end
endmodule