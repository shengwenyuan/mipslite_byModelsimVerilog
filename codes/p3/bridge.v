module bridge (
    weCPU, IRQ,
    prAddr, switchRD, ledRD, timerRD, prWD, 
    devAddr, prRD, devWD, HWint,
    weTimer, weLed, weSwitch
);
    //pure assignments
    input weCPU;                            //from mips.DMWr
    input IRQ;                              //from hardware
    input [31:0] prAddr;                    //from cpu
    input [31:0] switchRD, ledRD, timerRD;  // from hardware
    input [31:0] prWD;                      //from cpu
    output [1:0] devAddr;                   //to hardware
    output [31:0] prRD;                     //to cpu
    output [31:0] devWD;                    //to hardware
    output[5:0] HWint;                      //to cpu
    output weTimer, weLed, weSwitch;


    wire hitTimer, hitLed, hitSwitch;

    assign hitTimer = (prAddr==32'h0000_7F00) | (prAddr==32'h0000_7F04);
    assign hitLed = (prAddr==32'h0000_7F10);
    assign hitSwitch = (prAddr==32'h0000_7F20);

    assign weTimer = weCPU & hitTimer;
    assign weLed = weCPU & hitLed;
    assign weSwitch = weCPU & hitSwitch; 

    assign prRD = hitTimer? switchRD :
                  hitLed? ledRD : switchRD;               
    assign devWD = prWD; 
    //write to devAddr 01:led 10:switch 11:timer
    assign devAddr[0] = weLed|weTimer;
    assign devAddr[1] = weSwitch|weTimer;
    assign HWint = {{5{1'b0}}, IRQ};
endmodule