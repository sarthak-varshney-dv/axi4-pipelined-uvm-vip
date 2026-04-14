`ifndef SV_AXI4_SEQUENCE_BASE_SV
 `define SV_AXI4_SEQUENCE_BASE_SV

class sv_axi4_sequence_base extends uvm_sequence#(.REQ(sv_axi4_item_drv));

`uvm_declare_p_sequencer(sv_axi4_sequencer)

`uvm_object_utils(sv_axi4_sequence_base)

function new(string name="");
super.new(name);

endfunction
    
endclass


`endif