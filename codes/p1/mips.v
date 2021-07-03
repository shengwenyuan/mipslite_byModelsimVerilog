module mips(clk, rst);
    input clk;   // clock
    input rst;   // reset
    
    //PC
    wire [31:0] instructAddr;
    //nPC
    wire [31:0] dstPC;
    //controller
    wire RegDst, ALUsrc, Mem2Reg, RegWrite, ALUsign, MemWrite;
    wire [1:0] ALUop, ExtOp, PCsrc;
    //gpr
    wire [31:0] ReadData1, ReadData2;
    wire [4:0] WriteReg; 
    //alu
    wire [31:0] aluResult;
    wire zero, overflow;
    wire [31:0] ope1, ope2;
    //im
    wire [31:0] instructOut;
    //dm
    wire [31:0] dmOut;
    wire [31:0] WriteData;
    //ext
    wire [31:0] immediate_32;

    assign WriteReg = (RegDst)? instructOut[15:11] : ((overflow)? 5'b11110 : ((PCsrc==2'b10)? 5'b11111 : instructOut[20:16]));
    assign ope1 = ReadData1;
    assign ope2 = (ALUsrc)? immediate_32 : ReadData2;
    assign WriteData = (Mem2Reg)? dmOut : ((overflow)? 32'b1 : ((PCsrc==2'b10)? instructAddr+4 : aluResult));

//************modules*************
    npc npc_(PCsrc, zero, ReadData1, instructOut, instructAddr, dstPC);//

    pc pc_(clk, rst, dstPC, instructAddr);//

    im_1k im_1k_(instructAddr[9:0], instructOut);//

    dm_1k dm_1k_(aluResult[9:0], ReadData2, MemWrite, clk, dmOut);

    gpr gpr_(
    clk, rst, RegWrite, 
    instructOut[25:21], instructOut[20:16], WriteReg, WriteData,
    ReadData1, ReadData2);//

    alu alu_(ope1, ope2, ALUop, ALUsign, aluResult, zero, overflow);//
    
    ext ext_(instructOut[15:0], ExtOp, immediate_32);//
    
    controller controller_(
    instructOut[5:0], instructOut[31:26],
    RegDst, ALUsrc, ALUop, ALUsign, Mem2Reg, RegWrite, MemWrite, ExtOp, PCsrc);//

endmodule

