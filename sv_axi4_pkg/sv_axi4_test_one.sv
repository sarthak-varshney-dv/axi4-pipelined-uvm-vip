`ifndef SV_AXI4_TEST_ONE_SV
 `define SV_AXI4_TEST_ONE_SV

class sv_axi4_test_one extends sv_axi4_test_base;

  
  `uvm_component_utils(sv_axi4_test_one)
  
  function new(string name="" , uvm_component parent);
      super.new(name,parent);
      
   endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    
    phase.raise_objection(this,"test_done");
    
      #(100ns)
      
    repeat(5) begin
      sv_axi4_sequence_simple seq = sv_axi4_sequence_simple::type_id::create("seq");
      
      void'(seq.randomize() with {
      dir = SV_AXI4_WRITE });
      
      seq.start(env.axi4_agent.sequencer);
    end
      
    
    phase.drop_objection(this,"test_done");
  
  endtask  

endclass

`endif