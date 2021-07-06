module test;
  reg clk, rst;
  reg [31:0] switchIn, ledIn;

  mips mips_(clk, rst);
  
  initial begin
    $readmemh("p3-main.txt", mips_.im_1k_.im, 16'h1000);
    switchIn = 32'h0000_1234;
    ledIn = 32'h0000_1234;
    clk=0; 
    rst=1;
    #1 rst=0;
    #1 rst=1;
    $readmemh("p3-exc.txt", mips_.im_1k_.im, 16'h0180);
  end
  
  always
    #20 clk=~clk;
endmodule
    
