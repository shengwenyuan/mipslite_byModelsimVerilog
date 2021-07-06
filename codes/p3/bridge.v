module bridge (
    weCPU, IRQ,
    prAddr, prRD, prWD, 
    devAddr, switchRD, ledRD, timerRD, devWD, 
    HWint, weTimer, weLed, weSwitch
);
    //pure assignments
    input weCPU;    //==DMWr
    input IRQ;
    input [13:0] prAddr;
    input [31:0] switchRD, ledRD, timerRD;
    input [31:0] prWD;
    output devAddr;
    output [31:0] prRD;
    output [31:0] devWD;
    output[5:0] HWint;
    output weTimer, weLed, weSwitch;

    wire hitTimer, hitLed, hitSwitch;
    assign hitTimer = (prAddr==14'h3F00);
    assign hitLed = (prAddr==14'h3F04);
    assign hitSwitch = (prAddr==14'h0000_7F08);

    assign prRD = hitTimer? switchRD :
                  hitLed? ledRD : switchRD;

    assign weTimer = weCPU & hitTimer;
    assign weLed = weCPU & hitLed;
    assign weSwitch = weCPU & hitSwitch;                  
    assign devWD = prWD; 

    assign devAddr = prAddr;

    assign HWint = {{5{1'b0}}, IRQ};
endmodule