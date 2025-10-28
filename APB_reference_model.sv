`include "APB_DEFINE.sv"
interface intf (input PCLK);
  logic PSEL;
  logic PRESETn;
  logic PENABLE;
  logic PWRITE;
  logic PREADY;
  logic PSLVERR;
  logic [`DATA_WIDTH-31:0] PWDATA;
  logic [`DATA_WIDTH-31:0] PRDATA;
  logic [`ADDR_WIDTH-31:0] PADDR;
  
  clocking DRV_CB @(posedge PCLK);
    default input #1 output #0;
    output PSEL,PENABLE,PWDATA,PADDR,PWRITE,PRESETn;
    input  PREADY,PRDATA,PSLVERR;
  endclocking 
  
  clocking MON_CB @(posedge PCLK);
    default input #1 output #0;
    input PSEL,PENABLE,PWDATA,PADDR,PWRITE;
    input  PREADY,PRDATA,PSLVERR;
  endclocking 


endinterface
