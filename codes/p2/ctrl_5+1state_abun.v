module controller (
    clk, rst,
    funct, opeCode, zero, overflow,
    PCWr, IRWr, M2Rsel, GPRsel, ExtOp, DMWr, NPCop, ALUsrc, ALUop, ALUsign, GPRWr, byteOp
);
    input clk, rst;
    input [5:0] funct;
    input [5:0] opeCode;
    input zero, overflow;
    output reg PCWr, IRWr, DMWr, GPRWr, ALUsrc, ALUsign, byteOp;
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

    parameter [2:0] FETCH = 3'b000,
                    DCD = 3'b001,
                    EXE = 3'b010,
                    MA = 3'b011,
                    WB = 3'b100,
                    PRESTART = 3'b111;

    reg [2:0] nowState;
    reg [2:0] nextState;
    reg [2:0] defaulter = 0;

    always @(posedge clk, negedge rst) begin
        if(~rst)begin 
            nowState <= PRESTART;
        end
        else nowState <= nextState;
    end

    always @(*) begin
        case(nowState)
            // PRESTART:begin
            //     nextState = DCD;
            //     $display("start ~");
            // end
          
            FETCH:begin//0
                nextState = DCD;
                $display("[ctrl]from fetch to decode");
            end

            DCD:begin//1
                if(jal)begin
                    nextState = WB;
                    $display("[ctrl]from decode to writeback");
                end
                else begin
                    nextState = EXE;
                    $display("[ctrl]from decode to execute");
                end
            end

            EXE:begin//2
                if(beq|j|jr) begin
                    nextState = FETCH;
                    $display("[ctrl]from execute to fetch");                    
                end
                else if(addu|subu|addi|addiu|ori|lui|slt) begin
                    nextState = WB;
                    $display("[ctrl]from execute to writeback"); 
                end
                //else if(lw|lb|sw|sb) begin
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
                    nextState = FETCH;
                    $display("[ctrl]from memoryaccess to fetch");                    
                end
            end

            WB:begin//4
                nextState = FETCH;
                $display("[ctrl]from writeback to fetch");
            end
        endcase
    end

    always@(*) begin
        case(nowState)
            // PRESTART:begin//7
            //     PCWr = 0;
            //     IRWr = 1;
            //     DMWr = 0;
            //     GPRWr = 0;
            //     //00:pc+4 01:beq 10:j|jal 11:jr
            //     NPCop[0] = beq|jr;
            //     NPCop[1] = j|jal|jr;
            end
            FETCH:begin//0
                PCWr = 1;
                IRWr = 1;
                DMWr = 0;
                GPRWr = 0;
                //00:pc+4
                NPCop[0] = 0;
                NPCop[1] = 0;
            end

            DCD:begin//1
                PCWr = 0;
                IRWr = 0;
                DMWr = 0;
                GPRWr = 0;
                ExtOp[0] = lw|lb|sw|sb|addi;//01:sign ext
                ExtOp[1] = lui;             //10:lui ext
            end

            EXE:begin//2
                PCWr = j|jr;
                IRWr = 0;
                DMWr = 0;
                GPRWr = 0;
                ALUsrc = ori|lw|lb|sw|sb|lui|addi|addiu;
                ALUop[0] = subu|beq|slt;
                ALUop[1] = ori|slt;
                ALUsign = addi|slt;
                //00:pc+4 01:beq 10:j|jal 11:jr
                NPCop[0] = beq|jr;
                NPCop[1] = j|jal|jr;
            end
            
            MA:begin//3
                PCWr = 0;
                IRWr = 0;
                DMWr = sw|sb;
                GPRWr = 0;
                byteOp = lb|sb;
            end

            WB:begin//4
                PCWr = jal;
                IRWr = 0;
                DMWr = 0;
                GPRWr = addu|subu|addi|addiu|slt|ori|lw|lb|lui|jal;
                //00reg: 01:dm 10:npc 11:1
                M2Rsel[0] = lw|lb|overflow;
                M2Rsel[1] = jal|overflow;
                //00:[15:11] 01:[20:16] 10:$31 11:$30overflow
                GPRsel[0] = ori|lw|lb|lui|addi|addiu;
                GPRsel[1] = jal|overflow;
                //00:pc+4 01:beq 10:j|jal 11:jr
                NPCop[0] = beq|jr;
                NPCop[1] = j|jal|jr;
            end
        endcase
    end

endmodule





