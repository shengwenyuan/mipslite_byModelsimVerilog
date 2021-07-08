module dm_12k( addr, din, we, byteOp, clk, dout );
    input [13:0] addr;  // address bus
    input [31:0] din;   // 32-bit input data
    input we, byteOp;    // memory write enable
    input clk;   // clock
    output [31:0] dout;  // 32-bit memory output
    reg [7:0] dm[12287:0];

    assign dout = (byteOp)? {{24{dm[addr][7]}}, dm[addr]} : 
                            {dm[addr+3], dm[addr+2], dm[addr+1], dm[addr]};

    integer i;
    initial begin
        for(i=0; i<=12287; i=i+1) dm[i] <= 0;
    end
      

    always @(posedge clk) begin
        if(we) begin
            if(byteOp) dm[addr] <= din[7:0];
            else {dm[addr+3], dm[addr+2], dm[addr+1], dm[addr]} <= din;
        end
        
    end

endmodule






