module im_8k( addr, dout );
    input [12:0] addr;  // address bus
    output [31:0] dout;  // 32-bit memory output
    reg [7:0] im[8191:0];
    //initial begin $readmemh("p2-testh.txt", mips_.im_1k_.im);end
    assign dout = {im[addr], im[addr+1], im[addr+2], im[addr+3]};
endmodule






