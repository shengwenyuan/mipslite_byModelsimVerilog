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
            $display("R[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X,
                                %8X", 0, registerFile[1], registerFile[2], registerFile[3], registerFile[4], registerFile[5],
                                registerFile[6], registerFile[7]);
            $display("R[08-15]=%8X, %8X, %8X, %8X, %8X, %8X, %8X,
                                %8X", registerFile[8], registerFile[9], registerFile[10], registerFile[11], registerFile[12],
                                registerFile[13], registerFile[14], registerFile[15]);
            $display("R[16-23]=%8X, %8X, %8X, %8X, %8X, %8X, %8X,
                	               %8X", registerFile[16], registerFile[17], registerFile[18], registerFile[19], registerFile[20],
                                registerFile[21], registerFile[22], registerFile[23]);
            $display("R[24-31]=%8X, %8X, %8X, %8X, %8X, %8X, %8X,
                                %8X", registerFile[24], registerFile[25], registerFile[26], registerFile[27], registerFile[28],
                                registerFile[29], registerFile[30], registerFile[31]);
        end
    end

endmodule

