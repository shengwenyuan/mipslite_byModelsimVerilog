module gpr (
    clk, rst, rw, 
    ReadReg1, ReadReg2, WriteReg, WriteData,
    ReadData1, ReadData2
);
    input clk, rst, rw;
    input [4:0] ReadReg1, ReadReg2, WriteReg;
    input [31:0] WriteData;
    output [31:0] ReadData1, ReadData2;
    reg [31:0] registerFile[31:0];

    integer i;
    initial begin
        for(i=0; i<=31; i=i+1) registerFile[i] <= 0;
    end

    assign ReadData1 = registerFile[ReadReg1];    
    assign ReadData2 = registerFile[ReadReg2];    

    always @(posedge clk, negedge rst) begin
        if(!rst)begin
            for(i=1; i<=31; i=i+1) registerFile[i] <= 0;
        end
        else if(rw && WriteReg!=0) begin
            registerFile[WriteReg] <= WriteData;
        end
    end

endmodule

