module timer (clk, rst, we, addr, din, IRQ, dout);
    input clk, rst, we;
    input [1:0] addr;
    input [31:0] din;
    output IRQ;
    output [31:0] dout;

    reg [31:0] t_registerFile[2:0];
    parameter CTRL = 2'b00, //[3]exl, [2:1]==2'b00, [0]count enable
              PRESET = 2'b01,
              COUNT = 2'b10;

    assign IRQ = (t_registerFile[COUNT] == 32'h0000_0000)&(t_registerFile[CTRL][3] == 1);
    assign dout = (addr == CTRL)? t_registerFile[CTRL] :
                  (addr == PRESET)? t_registerFile[PRESET] : t_registerFile[COUNT];

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            t_registerFile[CTRL] <= 32'h0000_0000;
            t_registerFile[PRESET] <= 32'h0000_1111;
            t_registerFile[COUNT] <= 32'h0000_1111;
        end
        else begin
            if(we) begin
                case(addr)
                CTRL: t_registerFile[CTRL] = din;
                PRESET: begin
                    t_registerFile[PRESET] = din;
                    t_registerFile[CTRL][0] = 1'b1; 
                    t_registerFile[COUNT] = t_registerFile[PRESET];
                end 
                default: $display("timer addr error");
                endcase
            end
            else if(t_registerFile[CTRL][0] == 1'b1) begin
                if(t_registerFile[COUNT] == 0) t_registerFile[CTRL][0] = 1'b0;
                else t_registerFile[COUNT] = t_registerFile[COUNT]-1;
            end

        end
    end
endmodule
