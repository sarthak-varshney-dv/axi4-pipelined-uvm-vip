`ifndef SV_AXI4_AGENT_SV
 `define SV_AXI4_AGENT_SV

class sv_axi4_agent extends uvm_agent implements sv_axi4_reset_handler ;
  
  //handler of agent config
  sv_axi4_agent_config agent_config;
  
  //interface handler
  sv_axi4_vif vif;
  
  //sequencer handler
  sv_axi4_sequencer sequencer;
  
  //driver handler
  sv_axi4_driver driver;

  //monitor handler
  sv_axi4_monitor monitor;
  
  //coverage handler
  sv_axi4_coverage coverage;

  `uvm_component_utils(sv_axi4_agent)
  
  function new(string name="" , uvm_component parent);
      super.new(name,parent);
      
   endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent_config = sv_axi4_agent_config::type_id::create("agent_config",this);

if(agent_config.get_active_passive == UVM_ACTIVE) begin
    sequencer    = sv_axi4_sequencer::type_id::create("sequencer",this);
    driver       = sv_axi4_driver::type_id::create("driver",this);
end

    monitor      = sv_axi4_monitor::type_id::create("monitor",this);

    if(agent_config.get_has_coverage()) begin
      coverage = sv_axi4_coverage::type_id::create("coverage");
      coverage.agent_config=agent_config;
    end
    

  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if( uvm_config_db#(sv_axi4_vif)::get(this,"","vif",vif) == 0 ) begin
      `uvm_fatal("axi4_NO_VIF","interfacenot received from testbench");
    end
      else begin
        agent_config.set_vif(vif);
      end

      if(agent_config.get_active_passive()==UVM_ACTIVE) begin 

        sequencer.seq_item_export.connect(driver.seq_item_port);
        driver.agent_config=agent_config;
      end
      
      monitor.agent_config=agent_config;

      if(agent_config.get_has_checks) begin
      coverage.port_item.connect(monitor.output_port);
    end
  endfunction
  
virtual function void handle_reset(uvm_phase phase) 

 uvm_component children[$];

 get_children(children);

  sv_axi4_reset_handler handler;
  foreach(children[idx]) begin
    if($cast(handler,children[idx])) begin
      handler.handle_reset();
    end
  end
endfunction

  virtual task wait_reset_start()  //Asynchronous reset 
    agent_config.wait_reset_start();
  endtask

  virtual task wait_reset_end() //synchronous
    agent_config.wait_reset_end();
  
  endtask

virtual task run_phase(uvm_phase phase)
forever begin

  wait_reset_start();
  handle_reset();
  wait_reset_end();

end
endtask
endclass

`endif

