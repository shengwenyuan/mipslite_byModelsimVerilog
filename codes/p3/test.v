module test;
  reg clk, rst;
  // reg [31:0] switchIn, ledIn;

  system system_(clk, rst);
  
  initial begin                                     //0011_000
    $readmemh("p3-main.txt", system_.mips_.im_8k_.im, 16'h1000);
    clk=0; 
    rst=1;
    #1 rst=0;
    #1 rst=1;
    $readmemh("p3-int.txt", system_.mips_.im_8k_.im, 16'h180);
  end
  
  always
    #20 clk=~clk;
endmodule
    
