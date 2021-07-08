module system (clk, rst);
    input clk, rst;

    //mips
    wire weCPU;
    wire [31:0] PrAddr;
    wire [31:0] PrDOut;
    //bridge
    wire [5:0] HWint;
    wire [1:0] devAddr;
    wire weTimer, weLed, weSwitch;
    wire [31:0] PrDIn, devWD;
    //timer
    wire IRQ;
    wire [31:0] timerRD;
    //switch
    wire [31:0] switchRD;
    //led
    wire [31:0] ledRD;

    //***********modules*************
    mips mips_(clk, rst, PrDIn, HWint, weCPU, PrAddr, PrDOut);

    bridge bridge_ (
    weCPU, IRQ,
    PrAddr, switchRD, ledRD, timerRD, PrDOut, 
    devAddr, PrDIn, devWD, HWint,
    weTimer, weLed, weSwitch
);

    timer timer_ (clk, rst, weTimer, PrAddr[3:2], devWD, IRQ, timerRD);

    switch switch_ (weSwitch, devWD, switchRD);

    led led_ (weLed, devWD, ledRD);

endmodule
