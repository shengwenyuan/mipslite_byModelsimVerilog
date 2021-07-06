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
    input [31:0] PC;
    output IntReq;
    output [31:0] epcout;
    output [31:0] dout;
    
    integer i;
    parameter SR = 4'b1100,
              CAUSE = 4'b1101,
              EPC = 4'b1110,
              PRID = 4'b1111;

    reg [31:0] co_registerFile[31:0];
    reg [15:10] im;
    reg exl, ie;
    assign IntReq = |(co_registerFile[CAUSE][15:0] & im) & ie & !exl;
    assign dout = co_registerFile[sel];
    assign epcout = co_registerFile[EPC];

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            for(i=1; i<=31; i=i+1) co_registerFile[i] <= 0;
        end
        else if(wen) begin  
            {im, exl, ie} <= {din[15:10], din[1], din[0]};
            case(sel) 
                SR: co_registerFile[SR] <= {16'b0, din[15:10], 8'b0, din[1], din[0]};
                CAUSE: co_registerFile[CAUSE] <= {16'b0, din[15:10], 10'b0};
                EPC: if(exl) co_registerFile[EPC] <=  {PC[31:2], 2'b00};
                PRID: co_registerFile[PRID] <= {32'h0000_ffff};
                default: co_registerFile[sel] <= {32'hffff_ffff};
            endcase
        end
    end

    always @(*) begin
        if(EXLset) exl <= 1'b1;
        if(EXLclr) exl <= 1'b0;
    end
endmodule