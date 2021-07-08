module alu(ope1, ope2, ALUop, ALUsign, result, zero, overflow);
    input [31:0] ope1, ope2;
    input [1:0] ALUop;
    input ALUsign;
    output reg [31:0] result;
    output overflow;
    output zero;
    assign zero = (result == 0);
    assign overflow = ( ALUsign && ( (ope1[31]&ope2[31]&~result[31]) ||
                    (~ope1[31]&~ope2[31]&result[31]) ) );

    always @(ope1, ope2, ALUop) begin
        case (ALUop)
        //addu subu add or 
           2'b00:begin
                if(ALUsign) result <= $signed(ope1) + $signed(ope2);
                else result <= ope1 + ope2;
            end
            2'b01:result <= ope1 - ope2;
            2'b10:result <= ope1 | ope2;
            2'b11:if(ALUsign)begin
                result <= ($signed(ope1) < $signed(ope2));
                end
        endcase
    end

endmodule


