module ar(ReadData1, busA);
    input [31:0] ReadData1;
    output reg [31:0] busA;

    always @(*) begin
        busA = ReadData1;
    end