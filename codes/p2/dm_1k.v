module dm_1k( addr, din, we, clk, dout );
    input [9:0] addr;  // address bus
    input [31:0] din;   // 32-bit input data
    input we;    // memory write enable
    input clk;   // clock
    output [31:0] dout;  // 32-bit memory output
    reg [7:0] dm[1023:0];

    assign dout = {dm[addr+3], dm[addr+2], dm[addr+1], dm[addr]};

    integer i;
    initial begin
        for(i=0; i<=1023; i=i+1) dm[i] <= 0;
    end
      

    always @(posedge clk) begin
        if(we) {dm[addr+3], dm[addr+2], dm[addr+1], dm[addr]} <= din;
    end

endmodule




