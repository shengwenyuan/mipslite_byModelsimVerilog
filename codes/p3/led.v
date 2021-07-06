module led (din, din_refresh, dout);
    input [31:0] din, din_refresh;
    output reg [31:0] dout;

    initial begin
        dout = din;
    end

    always @(*) begin
        dout = din_refresh;
    end
endmodule
