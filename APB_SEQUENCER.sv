//sequencer just pass transaction to driver

class APB_SEQUENCER extends uvm_sequencer #(APB_TRANS);
  `uvm_component_utils(APB_SEQUENCER)

  function new(string name="APB_SEQUENCER",uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
endclass
