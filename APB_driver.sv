//passing transaction

class APB_DRIVER extends uvm_driver #(APB_TRANS);

  
  // Factory Registration
  
  `uvm_component_utils(APB_DRIVER)

  
  // Data Members
  
  virtual intf inf;    // Virtual interface handle
  APB_TRANS req;       // Transaction handle

 
  // Constructor
  
  function new(string name = "APB_DRIVER", uvm_component parent);
    super.new(name, parent);
  endfunction

  
  // Build Phase
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual intf)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Interface not set in config DB")
  endfunction

  // Run Phase
  
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      send_to_dut(req);
      seq_item_port.item_done();
    end
  endtask

  
  // Drive Task : Implements APB handshake
  
  task send_to_dut(APB_TRANS req);

    
    // SETUP PHASE (PSEL=1, PENABLE=0)
    
    @(posedge inf.PCLK);
    inf.DRV_CB.PADDR   <= req.PADDR;
    inf.DRV_CB.PWDATA  <= req.PWDATA;
    inf.DRV_CB.PWRITE  <= req.PWRITE;
    inf.DRV_CB.PSEL    <= 1;
    inf.DRV_CB.PENABLE <= 0;
    inf.DRV_CB.PRESETn <= 1;

    
    // ENABLE PHASE (PENABLE=1, wait for PREADY)
    
    @(posedge inf.PCLK);
    inf.DRV_CB.PENABLE <= 1;

   // Wait until slave is ready
   wait (inf.DRV_CB.PREADY == 1);


//     Complete transfer: deassert signals

   // @(posedge inf.PCLK);
    inf.DRV_CB.PSEL    <= 1;
    inf.DRV_CB.PENABLE <= 0;

    `uvm_info(get_type_name(),
      $sformatf("APB %s transfer completed: ADDR=0x%0h, DATA=0x%0h",
                 (req.PWRITE ? "WRITE" : "READ"),
                 req.PADDR,
                 (req.PWRITE ? req.PWDATA : inf.DRV_CB.PRDATA)),
      UVM_MEDIUM)

  endtask

endclass
