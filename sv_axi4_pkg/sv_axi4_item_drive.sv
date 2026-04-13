``ifndef SV_AXI4_ITEM_DRV_SV
 `define SV_AXI4_ITEM_DRV_SV

class sv_axi4_item_drv extends sv_axi4_item_base;
  
  
rand sv_axi4_id         id;
rand sv_axi4_dir        dir;
rand sv_axi4_addr       addr;        // starting address
rand logic [7:0]        burst_len;   // number of beats MINUS 1
rand logic [2:0]        burst_size;  // bytes per beat (as power of 2)
rand sv_axi4_burst      burst_type;  // FIXED, INCR, or WRAP
rand sv_axi4_data       wdata[];     // dynamic array — one entry per beat

  // Response fields (B / R)
  sv_axi4_response                           bresp;       // write response
  sv_axi4_response                           rresp[];     // read response per beat
  bit  [`SV_AXI4_MAX_DATA_WIDTH:0]           rdata[];     // read data per beat

  //delays
  rand int unsigned               pre_addr_delay;  // cycles before asserting AW/ARvalid
  rand int unsigned               pre_data_delay;  // cycles before asserting Wvalid (write)
  rand int unsigned               pre_resp_delay;  // slave: cycles before asserting Bvalid/Rvalid

constraint c_data_array_size {
    wdata.size() == burst_len + 1;
    
}
  
constraint c_burst_size {
    burst_size <= $clog2(DATA_WIDTH / 8);
}

constraint c_4k_boundary {
    if (burst_type == INCR) {
        (addr & 32'hFFFFF000) == 
        ((addr + ((burst_len + 1) * (1 << burst_size)) - 1) & 32'hFFFFF000);
    }
}

  `uvm_object_utils(sv_axi4_item_drv)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual function string convert2string();
    string result = $sformatf("dir: %0s , ADDR: %0x",dir.name(), addr);
    
    return result;
  endfunction
endclass




`endif