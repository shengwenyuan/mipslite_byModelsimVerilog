module mips(clk, rst, PrDIn, HWint, weCPU, PrAddr, PrDOut);
    input clk;   // clock
    input rst;   // reset
    input [31:0] PrDIn; //from bridge.prRD
    input [5:0] HWint;  //from bridge.HWint
    output weCPU;  //to bridge.weCPU
    output [31:0] PrAddr;   //to bridge.prAddr
    output [31:0] PrDOut;   //to bridge.prWD

    //pc
    wire [31:0] nowPC;
    //npc
    wire [31:0] nextPC;
    wire [31:0] jmp2addr;
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
    wire PCWr, IRWr, DMWr, GPRWr, EPCWr, EXLWr, ALUsrc, ALUsign, byteOp, wen, eretOp, mfc0Op;
    wire [1:0] M2Rsel, GPRsel, ALUop, ExtOp, NPCop;
    //cp0
    wire [4:0] cp0sel;
    wire IntReq;
    wire [31:0] epcout;
    wire [31:0] cp0Out;


    assign ope1 = busA;
    assign ope2 = (ALUsrc)? immediate_32 : busB;
    assign WriteReg = (GPRsel==2'b00)? instruction[15:11] :
                      (GPRsel==2'b01)? instruction[20:16] :
                      (GPRsel==2'b10)? 5'b11111 :
                      (GPRsel==2'b11)? 5'b11110 : 5'b11110;
    assign WriteData = (mfc0Op==1'b1) ? cp0Out :
                       (M2Rsel==2'b00)? alurOut :
                       (M2Rsel==2'b01)? ((alurOut > 32'h0000_4000)? PrDIn : writeback) :
                       (M2Rsel==2'b10)? nowPC :
                       (M2Rsel==2'b11)? 32'b1 : 32'b1;
    assign cp0sel = (EPCWr)? 5'b01110 : instruction[15:11];

    assign weCPU = DMWr;
    assign PrAddr = alurOut;
    assign PrDOut = busB;
    assign jmp2addr = (eretOp)? epcout : busA;

    //************ multi-periods processor *************
    pc pc_(clk, rst, PCWr, nextPC, nowPC);

    npc npc_(NPCop, zero, EPCWr, jmp2addr, instruction, nowPC, nextPC);

    im_8k im_8k_(nowPC[12:0], temp_instruct);

    ir ir_(clk, IRWr, temp_instruct, instruction);

    gpr gpr_(
    clk, rst, GPRWr, 
    instruction[25:21], instruction[20:16], WriteReg, WriteData,
    ReadData1, ReadData2);

    ar ar_(ReadData1, busA);
    br br_(ReadData2, busB);

    alu alu_(ope1, ope2, ALUop, ALUsign, aluResult, zero, overflow);
    
    ext ext_(instruction[15:0], ExtOp, immediate_32);

    alur alur_(aluResult, alurOut);
    
    dm_12k dm_12k_(alurOut[13:0], busB, DMWr, byteOp, clk, dmOut);
    
    dr dr_(clk, dmOut, writeback);
    
    controller controller_(
    clk, rst,
    instruction[5:0], instruction[31:26], instruction[25:21], zero, overflow, IntReq,
    PCWr, IRWr, M2Rsel, GPRsel, ExtOp, DMWr, NPCop, ALUsrc, ALUop, ALUsign, GPRWr, byteOp, EPCWr, EXLWr, wen, eretOp, mfc0Op);

    //*********** co-processor *************
    cp0 cp0_(
    clk, rst, wen, EXLWr, (~EXLWr),
    cp0sel, HWint, busB, (nowPC+4),
    IntReq, epcout, cp0Out);

endmodule


