//compare actual and expected
class APB_SCOREBOARD extends uvm_scoreboard;

  `uvm_component_utils(APB_SCOREBOARD)

  // Receives DUT actual transactions (from monitor)
  uvm_analysis_imp #(APB_TRANS, APB_SCOREBOARD) ap_port;

  // Receives golden transactions (from reference model)
  uvm_blocking_put_imp #(APB_TRANS, APB_SCOREBOARD) get_port;

  // Queues to store transactions until match
  APB_TRANS actual_q[$];
  APB_TRANS expected_q[$];

  
  // Constructor
  
  function new(string name="APB_SCOREBOARD", uvm_component parent);
    super.new(name, parent);
    ap_port  = new("ap_port", this);
    get_port = new("get_port", this);
  endfunction

  
  // Write: called when monitor sends DUT actual transaction
  
  function void write(APB_TRANS trans);
    actual_q.push_back(trans);
    `uvm_info(get_type_name(),
      $sformatf("SCOREBOARD: Received DUT transaction ADDR=0x%0h DATA=0x%0h",
                trans.PADDR, (trans.PWRITE ? trans.PWDATA : trans.PRDATA)),
      UVM_LOW)
    compare();
  endfunction

  
  // Put: called when reference model sends golden transaction
  
  task put(APB_TRANS ref_trans);
    expected_q.push_back(ref_trans);
    `uvm_info(get_type_name(),
      $sformatf("SCOREBOARD: Received GOLDEN transaction ADDR=0x%0h DATA=0x%0h",
                ref_trans.PADDR, ref_trans.PRDATA),
      UVM_LOW)
    compare();
  endtask

  
  // Compare DUT actual vs Reference expected
  
  function void compare();
    if (actual_q.size() > 0 && expected_q.size() > 0) begin
      APB_TRANS act = actual_q.pop_front();
      APB_TRANS exp = expected_q.pop_front();

      if (!act.PWRITE) begin 
        if (act.PRDATA !== exp.PRDATA) begin
          `uvm_error(get_type_name(),
            $sformatf("Mismatch at ADDR=0x%0h: Expected=0x%0h, Got=0x%0h",
                      exp.PADDR, exp.PRDATA, act.PRDATA))
        end else begin
          `uvm_info(get_type_name(),
                    $sformatf("Match at ADDR=0x%0h: DATA=0x%0h (PASS------------)",
                      exp.PADDR, exp.PRDATA),
            UVM_LOW)
        end
      end
    end
  endfunction

endclass



