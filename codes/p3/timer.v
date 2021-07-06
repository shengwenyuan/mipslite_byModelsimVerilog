module timer (clk, rst, we, addr, din, IRQ, dout);
    input clk, rst, we;
    input [1:0] addr;
    input [31:0] din;
    output IRQ;
    output [31:0] dout;

    reg [31:0] t_registerFile[2:0];
    parameter CTRL = 2'b00,
              PRESET = 2'b01,
              COUNT = 2'b10;

    assign IRQ = (t_registerFile[COUNT] == 32'h0000_0000);

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            t_registerFile[CTRL] = 32'h0000_0009;
            t_registerFile[PRESET] = 32'h0000_0000;
            t_registerFile[COUNT] = 32'h0000_0000;
        end
        else if(we) begin
            case(addr)
            CTRL: {t_registerFile[CTRL][3], t_registerFile[CTRL][2:1], t_registerFile[CTRL][0]} = {din[3], 2'b00, din[0]};
            PRESET: 
            endcase
        end
    end
endmodule
