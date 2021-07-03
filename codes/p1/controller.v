module controller (
    funct, opeCode,
    RegDst, ALUsrc, ALUop, ALUsign, Mem2Reg, RegWrite, MemWrite, ExtOp, PCsrc
);
    input [5:0] funct;
    input [5:0] opeCode;
    output RegDst, ALUsrc, Mem2Reg, RegWrite, ALUsign, MemWrite;
    output [1:0] ALUop, ExtOp, PCsrc;

    wire addu = (funct == 6'b100001)&(opeCode == 6'b000000);
    wire subu = (funct == 6'b100011)&(opeCode == 6'b000000);
    wire slt = (funct == 6'b101010)&(opeCode == 6'b000000);
    wire jr = (funct == 6'b001000)&(opeCode == 6'b000000);
    wire ori = (opeCode == 6'b001101);
    wire lw = (opeCode == 6'b100011);
    wire sw = (opeCode == 6'b101011);
    wire beq = (opeCode == 6'b000100);
    wire lui = (opeCode == 6'b001111);
    wire j = (opeCode == 6'b000010);
    wire jal = (opeCode == 6'b000011);
    wire addi = (opeCode == 6'b001000);
    wire addiu = (opeCode == 6'b001001);
    

    assign RegDst = addu|subu|slt;
    assign ALUsrc = ori|lw|sw|lui|addi|addiu;
    assign ALUop[0] = subu|beq|slt;
    assign ALUop[1] = ori|slt;
    assign ALUsign = addi|slt;
    assign Mem2Reg = lw;
    assign RegWrite = addu|subu|ori|lw|lui|addi|addiu|slt|jal;
    assign MemWrite = sw;
    //00:pc+4 01:beq 10:j|jal 11:jr
    assign PCsrc[0] = beq|jr;
    assign PCsrc[1] = j|jal|jr;
    assign ExtOp[0] = lw|sw|addi;
    assign ExtOp[1] = lui;
    
endmodule


