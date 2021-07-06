module switch (din, dout);
    input [31:0] din;
    output reg [31:0] dout;
    always @(*) begin
        dout = din;
    end
endmodule
