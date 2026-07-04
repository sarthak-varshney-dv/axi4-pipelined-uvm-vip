`ifndef SV_AXI4_AGENT_CONGIG_SV
 `define SV_AXI4_AGENT_CONGIG_SV

class sv_axi4_agent_config extends uvm_component;
  
  local sv_axi4_vif vif;

  local uvm_active_passive_enum active_passive;

  local bit has_checks;

  local bit has_coverage;

  local int unsigned stuck_threshold;
  
  `uvm_component_utils(sv_axi4_agent_config)
  
  function new(string name="" , uvm_component parent);
      super.new(name,parent);

      active_passive = UVM_ACTIVE;
      has_checks=1;
      has_coverage=1;

   endfunction
  
  
 virtual function void set_vif(sv_axi4_vif value);
    if(vif==null) begin
    vif=value;

    set_has_checks(get_has_checks());      //to set the has checks value in the interface only when vif is not null.
    end
    else begin
      `uvm_fatal("ALGORITHM_ISSUE","trying to set interface more than once")
    end
  endfunction
  
  virtual function sv_axi4_vif get_vif();
     return vif;
  endfunction

  virtual function uvm_active_passive_enum get_active_passive();
     return active_passive;
  endfunction

  virtual function void set_active_passive(uvm_active_passive_enum value);
     active_passive=value;
  endfunction

  virtual function void set_has_checks(bit value);
  has_checks=value;
  if(vif != null) begin                 // To synchronize has_cheks of agent config and the interface.
    vif.has_checks = has_checks;
  end
  endfunction

  virtual function bit get_has_checks();
  return has_checks;
  endfunction

  virtual function void set_has_coverage(bit value);
  has_coverage=value;

  
  endfunction

  virtual function bit get_has_coverage();
  return has_coverage;
  endfunction


  virtual task wait_reset_start();  //Asynchronous reset 
  if(vif.areset_n !==0)begin
   @(negedge vif.areset_n);
  end
  endtask

  virtual task wait_reset_end(); //synchronous
 //   while(vif.areset_n == 0) begin
 //   @(posedge vif.aclk) ;
 //  end
    
      `uvm_info("RST",
    $sformatf("Entered wait_reset_end areset_n=%0b", vif.areset_n),
    UVM_NONE)

  while(vif.areset_n == 0) begin
    @(posedge vif.aclk);

    `uvm_info("RST",
      $sformatf("Clock edge areset_n=%0b time=%0t", vif.areset_n, $time),
      UVM_NONE)
  end

  `uvm_info("RST",
    $sformatf("Leaving wait_reset_end at %0t", $time),
    UVM_NONE)
  endtask

  virtual task run_phase(uvm_phase phase);
    forever begin
    @(vif.has_checks) ;

    if(vif.has_checks != has_checks) begin
      `uvm_error("ALOGORITHM_ISSUE","can't chage value of has checks directly from the interface")
    end

    end
  
  endtask
endclass

`endif