module npc (PCsrc, zero, EPCWr, ReadData1, instruction, nowPC, nextPC);
    input zero, EPCWr;
    input [1:0] PCsrc;
    input [31:0] ReadData1, instruction;
    input [31:0] nowPC;
    output [31:0] nextPC;
    wire [31:0] tmp;
    assign tmp = {{16{instruction[15]}}, instruction[15:0]}<<2;
    
    //00:pc+4 01:beq 10:j|jal 11:jr 
    assign nextPC = (PCsrc==2'b00)? nowPC+4:
                    (PCsrc==2'b01)? zero? nowPC+tmp : nowPC :
                    (PCsrc==2'b10)? ((EPCWr==1'b1)? 32'h0000_4180 : {nowPC[31:28], instruction[25:0], 2'b00}) :
                    (PCsrc==2'b11)? ReadData1: nowPC+4;
    
    
endmodule



