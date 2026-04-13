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

// wdata arrays must match burst_len+1 beats
constraint c_data_array_size {
    wdata.size() == burst_len + 1;
    
}
  
 // burst_size must not exceed log2(DATA_WIDTH/8)  
constraint c_burst_size {
    burst_size <= $clog2(DATA_WIDTH / 8);
}


// WRAP burst: len must be 2,4,8,16 beats only
  constraint c_wrap_len {
    (burst_type == WRAP) -> (burst_len inside {1, 3, 7, 15});
  }

   // FIXED burst: max 16 beats per AXI4 spec
  constraint c_fixed_len {
    (burst_type == FIXED) -> (burst_len <= 15);
  }

  // WRAP burst: address must be naturally aligned to total transfer size
  constraint c_wrap_align {
    if (burst_type == WRAP) {
      addr % ((burst_len + 1) * (1 << burst_size)) == 0;
    }
  }


  // 4KB boundary: INCR burst must not cross 4KB boundary
constraint c_4k_boundary {
    if (burst_type == INCR) {
        (addr & 32'hFFFFF000) == 
        ((addr + ((burst_len + 1) * (1 << burst_size)) - 1) & 32'hFFFFF000);
    }
}

// Reasonable randomized delays
  constraint c_delays {
    addr_delay inside {[0:8]};
    data_delay inside {[0:8]};
    resp_delay inside {[0:4]};
  }

  `uvm_object_utils(sv_axi4_item_drv)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  function void post_randomize();
    if (dir == AXI4_READ) begin
      rresp = new[burst_len + 1];
      rdata = new[burst_len + 1];
      foreach (rresp[i]) rresp[i] = OKAY;
    end
  endfunction
  
  virtual function string convert2string();
    string result = $sformatf("dir: %0s , ADDR: %0x",dir.name(), addr);
    
    return result;
  endfunction
endclass




`endif