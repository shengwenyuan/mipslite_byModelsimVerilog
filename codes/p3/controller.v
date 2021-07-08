module controller (
    clk, rst,
    funct, opeCode, moveCode, zero, overflow, IntReq,
    PCWr, IRWr, M2Rsel, GPRsel, ExtOp, DMWr, NPCop, ALUsrc, ALUop, ALUsign, GPRWr, byteOp,
    EPCWr, EXLWr, wen, eretOp, mfc0Op
);
    input clk, rst;
    input [5:0] funct;
    input [5:0] opeCode;
    input [4:0] moveCode;
    input zero, overflow, IntReq;
    output reg PCWr, IRWr, DMWr, GPRWr, EPCWr, EXLWr, ALUsrc, ALUsign, byteOp, wen, eretOp, mfc0Op;
    output reg [1:0] M2Rsel, GPRsel, ALUop, ExtOp, NPCop;

    wire addu = (funct == 6'b100001)&(opeCode == 6'b000000);
    wire subu = (funct == 6'b100011)&(opeCode == 6'b000000);
    wire slt = (funct == 6'b101010)&(opeCode == 6'b000000);
    wire jr = (funct == 6'b001000)&(opeCode == 6'b000000);
    wire ori = (opeCode == 6'b001101);
    wire lw = (opeCode == 6'b100011);
    wire lb = (opeCode == 6'b100000);
    wire sw = (opeCode == 6'b101011);
    wire sb = (opeCode == 6'b101000);
    wire beq = (opeCode == 6'b000100);
    wire lui = (opeCode == 6'b001111);
    wire j = (opeCode == 6'b000010);
    wire jal = (opeCode == 6'b000011);
    wire addi = (opeCode == 6'b001000);
    wire addiu = (opeCode == 6'b001001);
    wire mtc0 = (opeCode == 6'b010000)&(moveCode == 5'b00100);
    wire mfc0 = (opeCode == 6'b010000)&(moveCode == 5'b00000);
    wire eret = (funct == 6'b011000)&(opeCode == 6'b010000);

    parameter [2:0] FETCH = 3'b000,
                    DCD = 3'b001,
                    EXE = 3'b010,
                    MA = 3'b011,
                    WB = 3'b100,
                    ITRPT = 3'b111,
                    INTJ = 3'b110;

    reg [2:0] nowState;
    reg [2:0] nextState;

    always @(posedge clk, negedge rst) begin
        if(~rst)begin 
            nowState <= FETCH;
        end
        else nowState <= nextState;
    end

    always @(*) begin
        case(nowState)         
            FETCH:begin//0
                nextState = DCD;
                $display("[ctrl]from fetch to decode");
            end

            DCD:begin//1
                if(jal|mfc0)begin
                    nextState = WB;
                    $display("[ctrl]from decode to writeback");
                end
                else begin
                    nextState = EXE;
                    $display("[ctrl]from decode to execute");
                end
            end

            EXE:begin//2
                if(beq|j|jr|eret) begin
                    if(IntReq) nextState = ITRPT;
                    else nextState = FETCH;
                    $display("[ctrl]from execute to fetch");                    
                end
                else if(addu|subu|addi|addiu|ori|lui|slt) begin
                    nextState = WB;
                    $display("[ctrl]from execute to writeback"); 
                end
                //else if(lw|lb|sw|sb|mtc0) begin
                else begin
                    nextState = MA;
                    $display("[ctrl]from execute to memoryaccess");                     
                end
            end

            MA:begin//3
                if(lw|lb) begin
                    nextState = WB;
                    $display("[ctrl]from memoryaccess to writeback");                        
                end
                else begin
                    if(IntReq) nextState = ITRPT;
                    else nextState = FETCH;
                    $display("[ctrl]from memoryaccess to fetch");                    
                end
            end

            WB:begin//4
                if(IntReq) nextState = ITRPT;
                else nextState = FETCH;
                $display("[ctrl]from writeback to fetch");
            end

            ITRPT:begin
                nextState = INTJ;
            end

            INTJ:begin
                nextState = FETCH;
            end
        endcase
    end

    always@(*) begin
        case(nowState)
            FETCH:begin//0
                PCWr = 1;
                IRWr = 1;
                DMWr = 0;
                GPRWr = 0;
                EPCWr = 0;
                wen = 0;
                //00:pc+4
                NPCop[0] = 0;
                NPCop[1] = 0;
                eretOp = 0;
            end

            DCD:begin//1
                PCWr = 0;
                IRWr = 0;
                DMWr = 0;
                GPRWr = 0;
                EPCWr = 0;
                wen = 0;
                ExtOp[0] = lw|lb|sw|sb|addi;//01:sign ext
                ExtOp[1] = lui;             //10:lui ext
                mfc0Op = mfc0;
            end

            EXE:begin//2
                PCWr = beq|j|jr|eret;
                IRWr = 0;
                DMWr = 0;
                GPRWr = 0;
                EPCWr = 0;
                EXLWr = (eret)? 0 : EXLWr;
                wen = 0;
                ALUsrc = ori|lw|lb|sw|sb|lui|addi|addiu;
                ALUop[0] = subu|beq|slt;
                ALUop[1] = ori|slt;
                ALUsign = addi|slt;
                //00:pc+4 01:beq 10:j|jal 11:jr|eret
                NPCop[0] = beq|jr|eret;
                NPCop[1] = j|jal|jr|eret;
                eretOp = eret;
            end
            
            MA:begin//3
                PCWr = 0;
                IRWr = 0;
                DMWr = sw|sb;
                GPRWr = 0;
                EPCWr = 0;
                wen = mtc0;
                byteOp = lb|sb;
            end

            WB:begin//4
                PCWr = jal;
                IRWr = 0;
                DMWr = 0;
                GPRWr = addu|subu|addi|addiu|slt|ori|lw|lb|lui|jal|mfc0;
                EPCWr = 0;
                wen = 0;
                //00reg: 01:dm 10:npc 11:1
                M2Rsel[0] = lw|lb|overflow;
                M2Rsel[1] = jal|overflow;
                //00:[15:11] 01:[20:16] 10:$31 11:$30overflow
                GPRsel[0] = ori|lw|lb|lui|addi|addiu|mfc0;
                GPRsel[1] = jal|overflow;
                //00:pc+4 01:beq 10:j|jal 11:jr
                NPCop[0] = beq|jr;
                NPCop[1] = j|jal|jr;
            end
            ITRPT:begin
                PCWr = 0;
                IRWr = 0;
                DMWr = 0;
                GPRWr = 0;
                EPCWr = 1;
                EXLWr = 1;
                wen = 1;
            end

            INTJ:begin
                PCWr = 1;
                IRWr = 0;
                DMWr = 0;
                GPRWr = 0;
                EPCWr = 1;
                EXLWr = 1;
                wen = 1;
                //00:pc+4 01:beq 10:j|jal 11:jr
                NPCop[0] = beq|jr;
                NPCop[1] = j|jal|jr;                
            end
        endcase
    end

endmodule





