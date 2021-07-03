module test;
  reg clk, rst;
  mips mips_(clk, rst);
  
  initial begin
    $readmemh("p1-testh.txt", mips_.im_1k_.im);
     clk=0; 
     rst=1;
    #1 rst=0;
    #1 rst=1;
  end
  
  always
    #20 clk=~clk;
endmodule
    
