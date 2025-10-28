//observe and analysis 
class APB_MONITOR extends uvm_monitor;

  
  // Factory Registration
  
  `uvm_component_utils(APB_MONITOR)

  
  // Ports and Variables
  
  uvm_analysis_port #(APB_TRANS) ap_port;   // Analysis port to broadcast transactions
  APB_TRANS req;                            // Transaction handle
  virtual intf inf;                         // Virtual interface handle

  
  // Constructor
  
  function new(string name = "APB_MONITOR", uvm_component parent);
    super.new(name, parent);
    ap_port = new("ap_port", this);
  endfunction

  
  // Build Phase
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual intf)::get(this, "", "inf", inf)) begin
      `uvm_fatal(get_type_name(), "Interface not set in config DB")
    end

    `uvm_info(get_type_name(), "Build phase completed, interface received", UVM_LOW)
  endfunction

  
  // Run Phase
  
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Run phase started", UVM_LOW)
    forever begin
      get_from_dut();
    end
  endtask

  
  // Task: get_from_dut
  // Description: Captures transactions from DUT and sends via analysis port
  
  task get_from_dut();
//     // Wait until valid APB transfer occurs
    @((inf.MON_CB) iff (inf.MON_CB.PSEL && inf.MON_CB.PENABLE && inf.MON_CB.PREADY));
    `uvm_info(get_type_name(),"Monitor Invoked",UVM_LOW)

    // Create transaction
    req = APB_TRANS::type_id::create("req");

    // Sample signals
    req.PADDR   = inf.MON_CB.PADDR;
    req.PWRITE  = inf.MON_CB.PWRITE;
    req.PSLVERR = inf.MON_CB.PSLVERR;

    if (inf.MON_CB.PWRITE) begin
      req.PWDATA = inf.MON_CB.PWDATA;
      `uvm_info(get_type_name(), $sformatf("Captured WRITE to addr=0x%0h data=0x%0h", 
                                           req.PADDR, req.PWDATA), UVM_MEDIUM)
    end
    else begin
      req.PRDATA = inf.MON_CB.PRDATA;
      `uvm_info(get_type_name(), $sformatf("Captured READ from addr=0x%0h data=0x%0h", 
                                           req.PADDR, req.PRDATA), UVM_MEDIUM)
    end

    // Send transaction via analysis port
    ap_port.write(req);

    // Debug print
    req.print();
  endtask

endclass
