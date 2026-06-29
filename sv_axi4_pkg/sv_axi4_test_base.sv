`ifndef SV_AXI4_TEST_BASE_SV
 `define SV_AXI4_TEST_BASE_SV

class sv_axi4_test_base extends uvm_test;
  
  sv_axi4_env env;

  
  `uvm_component_utils(sv_axi4_test_base)
  
  function new(string name="" , uvm_component parent);
      super.new(name,parent);
      
   endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env=   sv_axi4_env::type_id::create("env",this);


  endfunction

endclass

`endif