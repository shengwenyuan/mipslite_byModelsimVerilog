module mips(clk, rst);
    input clk;   // clock
    input rst;   // reset
    //wire [31:0]
    //pc
    wire [31:0] nowPC;
    //npc
    wire [31:0] nextPC;
    //im
    wire [31:0] temp_instruct;
    //ir
    wire [31:0] instruction;
    //gpr
    wire [4:0] WriteReg;
    wire [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;
    //ar,br
    wire [31:0] busA, busB;
    //alu
    wire [31:0] ope1, ope2;
    wire [31:0] aluResult;
    wire zero, overflow;
    //ext
    wire [31:0] immediate_32;
    //alur
    wire [31:0] alurOut;
    //dm
    wire [31:0] dmOut;
    //dr
    wire [31:0] writeback;
    //controller
    wire PCWr, IRWr, DMWr, GPRWr, ALUsrc, ALUsign, byteOp;
    wire [1:0] M2Rsel, GPRsel, ALUop, ExtOp, NPCop;

    assign ope1 = busA;
    assign ope2 = (ALUsrc)? immediate_32 : busB;
    assign WriteReg = (GPRsel==2'b00)? instruction[15:11] :
                      (GPRsel==2'b01)? instruction[20:16] :
                      (GPRsel==2'b10)? 5'b11111 :
                      (GPRsel==2'b11)? 5'b11110 : 5'b11110;
    assign WriteData = (M2Rsel==2'b00)? alurOut :
                       (M2Rsel==2'b01)? writeback :
                       (M2Rsel==2'b10)? nowPC :
                       (M2Rsel==2'b11)? 32'b1 : 32'b1;

//************modules*************
    pc pc_(clk, rst, PCWr, nextPC, nowPC);

    npc npc_(NPCop, zero, busA, instruction, nowPC, nextPC);

    im_1k im_1k_(nowPC[9:0], temp_instruct);

    ir ir_(clk, IRWr, temp_instruct, instruction);

    gpr gpr_(
    clk, rst, GPRWr, overflow,
    instruction[25:21], instruction[20:16], WriteReg, WriteData,
    ReadData1, ReadData2);

    ar ar_(ReadData1, busA);
    br br_(ReadData2, busB);

    alu alu_(ope1, ope2, ALUop, ALUsign, aluResult, zero, overflow);
    
    ext ext_(instruction[15:0], ExtOp, immediate_32);

    alur alur_(aluResult, alurOut);
    
    dm_1k dm_1k_(alurOut[9:0], busB, DMWr, byteOp, clk, dmOut);
    
    dr dr_(clk, dmOut, writeback);
    
    controller controller_(
    clk, rst,
    instruction[5:0], instruction[31:26], zero, overflow,
    PCWr, IRWr, M2Rsel, GPRsel, ExtOp, DMWr, NPCop, ALUsrc, ALUop, ALUsign, GPRWr, byteOp);

endmodule


