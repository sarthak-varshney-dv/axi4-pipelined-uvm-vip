``ifndef SV_AXI4_ITEM_BASE_SV
 `define SV_AXI4_ITEM_BASE_SV

class sv_axi4_item_base extends uvm_sequence_item;
  

  
  `uvm_object_utils(sv_axi4_item_base)
  
  function new(string name="");
    super.new(name);
  endfunction
  
 // virtual function string convert2string();
   // string result = $sformatf("dir: %0s , ADDR: %0x",dir.name(), addr);
    
    //return result;
 // endfunction
endclass

`endif