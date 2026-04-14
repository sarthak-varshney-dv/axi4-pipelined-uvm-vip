`ifndef SV_AXI4_ENV_SV
 `define SV_AXI4_ENV_SV

class sv_axi4_env extends uvm_env;
  
  sv_axi4_agent axi4_agent;

  
  `uvm_component_utils(sv_axi4_env)
  
  function new(string name="" , uvm_component parent);
      super.new(name,parent);
      
   endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    axi4_agent=   sv_apb_agent::type_id::create("apb_agent",this);


  endfunction

endclass

`endif