module led (we, din, dout);
    input we;
    input [31:0] din;
    output reg [31:0] dout;

    reg [31:0] dinStart;

    initial begin
        dinStart = 32'h0000_1111;
        dout = 32'h0000_1111;
    end

    always @(*) begin
        if(we) dout = din;
    end
endmodule
