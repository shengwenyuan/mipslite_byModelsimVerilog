module cp0 (
    clk, rst, wen, EXLset, EXLclr,
    sel, HWint, din, PC,
    IntReq, epcout, dout
);
    input clk, rst;
    input wen, EXLset, EXLclr;
    input [4:0] sel;
    input [5:0] HWint;
    input [31:0] din;
    input [31:0] PC;    //from main_processor.pc
    output IntReq;
    output [31:0] epcout;
    output [31:0] dout;
    
    integer i;
    parameter SR = 5'b01100,
              CAUSE = 5'b01101,
              EPC = 5'b01110,
              PRID = 5'b01111;

    reg [31:0] co_registerFile[31:0];
    reg [15:10] im;
    reg exl, ie;
    assign IntReq = |(HWint & im) & ie & (~exl);
    assign dout = co_registerFile[sel];
    assign epcout = co_registerFile[EPC];

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            for(i=0; i<=31; i=i+1) co_registerFile[i] <= 0;
        end
        else if(wen) begin  
            case(sel) 
                SR:begin
                    {im, exl, ie} = {din[15:10], din[1], din[0]};
                    co_registerFile[SR] = {16'b0, im, 8'b0, exl, ie};
                end
                CAUSE: co_registerFile[CAUSE] = {16'b0, HWint, 10'b0};
                EPC: if(exl) co_registerFile[EPC] = PC;
                PRID: co_registerFile[PRID] = din;
                default: co_registerFile[sel] = {32'hffff_ffff};
            endcase
        end
    end

    always @(*) begin
        if(EXLset) exl = 1'b1;
        if(EXLclr) exl = 1'b0;
    end
endmodule