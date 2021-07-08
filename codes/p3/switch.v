module switch (we, din, dout);
    input we;
    input [31:0] din;
    output reg [31:0] dout;

    initial begin
        dout = 32'h0000_1234;
    end

    always @(*) begin
        if(we) dout = din;
    end
endmodule
