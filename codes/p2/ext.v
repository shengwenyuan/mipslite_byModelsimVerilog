module ext (immediate, ExtOp, result);
    input [15:0] immediate;
    input [1:0] ExtOp;
    output reg [31:0] result;

    always @(immediate, ExtOp) begin
        case(ExtOp)
        2'b00:begin
            result <= {16'h0000, immediate};
        end
        2'b01:begin
            result <= {{16{immediate[15]}}, immediate};
        end
        2'b10:begin         
            result <= {immediate, 16'h0000};
        end
        endcase
    end
endmodule


