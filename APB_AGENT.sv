//connection between seq and drv
class APB_AGENT extends uvm_agent;

  
  // Factory Registration
  
  `uvm_component_utils(APB_AGENT)

  
  // Sub-components
  
  APB_DRIVER    driver;
  APB_MONITOR   monitor;
  APB_SEQUENCER sequencer;

  
  // Constructor
  
  function new(string name = "APB_AGENT", uvm_component parent);
    super.new(name, parent);
  endfunction

  
  // Build Phase
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Always create monitor (even in passive mode)
    monitor   = APB_MONITOR::type_id::create("monitor", this);
      driver    = APB_DRIVER::type_id::create("driver", this);
      sequencer = APB_SEQUENCER::type_id::create("sequencer", this);
  endfunction
  
  
  // Connect Phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass

