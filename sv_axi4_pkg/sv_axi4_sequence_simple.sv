`ifndef SV_AXI4_SEQUENCE_SIMPLE_SV
 `define SV_AXI4_SEQUENCE_SIMPLE_SV

class sv_axi4_sequence_simple extends sv_axi4_sequence_base;

rand sv_axi4_item_drv item , rsp;

`uvm_object_utils(sv_axi4_sequence_simple)

function new(string name="");
super.new(name);

 item= sv_axi4_item_drv::type_id::create("item");

 
endfunction

task body();

//`uvm_send(item)

// get_response(rsp); //for driver sequencer handshake completion

   //   `uvm_info("UVM_DEBUG", 
   //             $sformatf("Received (sequencer handshake) rsp id=%0d ", rsp.id),
   //     UVM_LOW)

  
  `uvm_info("SEQ","Entered body",UVM_NONE)

  `uvm_info("SEQ","Before uvm_send",UVM_NONE)

  `uvm_send(item)

  `uvm_info("SEQ","After uvm_send",UVM_NONE)

  `uvm_info("SEQ","Before get_response",UVM_NONE)

  get_response(rsp);

  `uvm_info("SEQ","After get_response",UVM_NONE)

endtask

endclass


`endif