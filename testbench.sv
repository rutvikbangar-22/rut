
here we design APB protocol project
// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"    // UVM macros
`include "APB_PKG.sv"        // APB package

import uvm_pkg::*;           // Import UVM package
import pkg::*;               // Import user-defined package 

module tb;

  // Clock & Reset
  bit PCLK;
  bit PRESETn;

  // Instantiate Interface (driven by testbench and connected to DUT)
  intf inf(PCLK);

  
  // Clock Generation.
  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;   // Generate 100MHz clock (10ns period)
  end

  
  // Reset Generation
 
  initial begin
    PRESETn=32'h0;
    #20;
     PRESETn = 32'h1;           // Release reset after 20ns
  end

  
  // DUT Instantiation
  
  
  apb_slave dut (
    .PCLK    (inf.PCLK),
    .PRESETn (inf.PRESETn),
    .PSEL    (inf.PSEL),
    .PENABLE (inf.PENABLE),
    .PWRITE  (inf.PWRITE),
    .PADDR   (inf.PADDR),
    .PWDATA  (inf.PWDATA),
    .PRDATA  (inf.PRDATA),
    .PSLVERR (inf.PSLVERR),
    .PREADY  (inf.PREADY)
  );

  
  // UVM Configuration Setup
  
  initial begin
    // Pass virtual interface to UVM components
    uvm_config_db#(virtual intf)::set(null, "*", "inf", inf);
  end

  
  // Dumping Waveforms
  
  initial begin
    $dumpfile("dump.vcd");$dumpvars;end
  
  initial begin
    run_test("APB_TEST");
  end

endmodule


