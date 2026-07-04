`ifndef SV_AXI4_DRIVER_SV
 `define SV_AXI4_DRIVER_SV

class sv_axi4_driver extends uvm_driver#(.REQ(sv_axi4_item_drv)) implements sv_axi4_reset_handler;

   sv_axi4_agent_config agent_config;

   sv_axi4_vif vif   ;
  
   sv_axi4_item_drv aw_q[$];

   sv_axi4_item_drv w_q[$];

   sv_axi4_item_drv ar_q[$];

   //outstanding trackers 

   sv_axi4_item_drv write_outstanding[int];

   sv_axi4_item_drv read_outstanding[int];

   //semaphores to limit outstanding transactions

   semaphore write_sem ;

   semaphore read_sem ;
    
 
    `uvm_component_utils(sv_axi4_driver)

    function new(string name="",uvm_component parent);
    super.new(name,parent);

    write_sem = new(4);
    read_sem = new(4);

    endfunction 
 

virtual task run_phase(uvm_phase phase);
   vif = agent_config.get_vif();
  
   forever begin

        `uvm_info("DRV", "Waiting for reset release", UVM_LOW)
        wait_reset_end();

        `uvm_info("DRV", "Reset released - starting driver threads", UVM_LOW)

        fork

            // Main dispatcher
            get_and_dispatch();

            // AXI write channels
            drive_aw();
            drive_w();
            handle_b();

            // AXI read channels
            drive_ar();
            handle_r();

            // Reset watcher
            begin
                wait_reset_start();
                `uvm_info("DRV", "Reset detected", UVM_LOW)
            end

        join_any

        `uvm_info("DRV", "Stopping all driver threads", UVM_LOW)

        disable fork;

        handle_reset(phase);

    end
  endtask


protected virtual task get_and_dispatch();

  sv_axi4_item_drv item ;

  `uvm_info("DRV","Entered get_and_dispatch",UVM_NONE)
  
  forever begin
    
       `uvm_info("DRV","Waiting for seq_item_port.get()",UVM_NONE)
    
      seq_item_port.get(item);
    
        `uvm_info("DRV","Received item",UVM_NONE)

        if(item.dir == SV_AXI4_WRITE) begin
      //   write_sem.get(1);
          
          `uvm_info("DRV","Before write_sem.get",UVM_NONE)
write_sem.get(1);
`uvm_info("DRV","After write_sem.get",UVM_NONE)
          
          `uvm_info("DRV",
$sformatf("dir=%0d id=%0d", item.dir, item.id),
UVM_NONE)

          write_outstanding [item.id] = item ;

         aw_q.push_back(item);
          
          `uvm_info("DRV",
$sformatf("AW queue size=%0d",aw_q.size()),
UVM_NONE)
         w_q.push_back(item);
          `uvm_info("DRV",
$sformatf("W queue size=%0d",w_q.size()),
UVM_NONE)

        end
        else begin
          read_sem.get(1);

          read_outstanding [item.id] = item;
          ar_q.push_back (item) ;
          `uvm_info("DRV",
$sformatf("AR queue size=%0d",ar_q.size()),
UVM_NONE)

        end
  end

endtask

protected virtual task drive_aw();
  
  sv_axi4_item_drv item ;
  
    `uvm_info("DRV","Entered drive_aw",UVM_NONE)

   //just required in the begening. can be shifted to reset.
    vif.awvalid <= 0;
    vif.awaddr <= 0;
    vif.awid <= 0;
    vif.awlen   <= 0;   
    vif.awsize  <= 0;   
    vif.awburst <= 0;   
  
  forever begin
    
    @(posedge vif.aclk);
    

    while(aw_q.size() == 0) begin
        @(posedge vif.aclk);
    end
   
   item = aw_q.pop_front();

    `uvm_info("UVM_DEBUG",$sformatf("Driving write address ID: %0d",item.id),UVM_NONE);

    vif.awvalid <= 1;
    vif.awaddr <= item.addr;
    vif.awid <= item.id;
    vif.awlen   <= item.burst_len;   
    vif.awsize  <= item.burst_size;   
    vif.awburst <= item.burst_type;   
    
     @(posedge vif.aclk);

    
    while(vif.awready !== 1) begin
        @(posedge vif.aclk);
    end

    
    vif.awvalid <= 0;
    vif.awaddr <= 0;
    vif.awid <= 0;
    vif.awlen   <= 0;   
    vif.awsize  <= 0;   
    vif.awburst <= 0;   
    
    @(posedge vif.aclk);   
    
    
  end

endtask

protected virtual task drive_w();

sv_axi4_item_drv item ;
  
  `uvm_info("DRV","Entered drive_w",UVM_NONE)

   //just required in the begening. can be shifted to reset.
    vif.wvalid <= 0;
    vif.wdata <= 0;
    vif.wlast <= 0;
    vif.wstrb  <= 0; 

  
  forever begin
    
    @(posedge vif.aclk);
    

        while(w_q.size() == 0) begin
            @(posedge vif.aclk);
        end
      
      item = w_q.pop_front();

    `uvm_info("UVM_DEBUG",$sformatf("Driving write wdata ID: %0d",item.id),UVM_NONE);

    foreach(item.wdata[i]) begin 

        vif.wvalid <= 1;
        vif.wdata <= item.wdata[i];
        vif.wstrb  <= item.wstrb[i];
        vif.wlast<= (i == item.wdata.size()-1);
      
       @(posedge vif.aclk);

      while(vif.wready !== 1) begin
          @(posedge vif.aclk);
        end

     

    end

    
    vif.wvalid <= 0;
    vif.wdata <= 0;
    vif.wlast <= 0;
    
       @(posedge vif.aclk);  

  end
   
endtask

protected virtual task handle_b();
  
  sv_axi4_item_drv item ;
  
  `uvm_info("DRV","Entered handle_b",UVM_NONE)

   //just required in the begening. can be shifted to reset.
    vif.bready <= 0;
    
    forever begin
      @(posedge vif.aclk);

      while(vif.bvalid !==1)begin
      @(posedge vif.aclk);
      end

      item = write_outstanding[vif.bid] ;

      item.bresp = sv_axi4_response'(vif.bresp);

      vif.bready<=1 ;

      seq_item_port.put_response(item); //to complete sequencer driver handshake

      write_outstanding.delete(vif.bid);

      write_sem.put(1);
      
      @(posedge vif.aclk);
       vif.bready<=0 ;
      
    end

endtask

protected virtual task drive_ar();

 sv_axi4_item_drv item ;
  
  `uvm_info("DRV","Entered drive_ar",UVM_NONE)
 
   //just required in the begening. can be shifted to reset.
    vif.arid <= 0 ;
    vif.araddr <= 0 ;
    vif.arlen <= 0 ;
    vif.arsize <= 0 ;
    vif.arburst <= 0 ;
    vif.arvalid <= 0 ;

  forever begin
    @(posedge vif.aclk);

    while(ar_q.size()==0) begin
     @(posedge vif.aclk);
    end

    item = ar_q.pop_front();

    vif.arvalid <= 1 ;
    
    vif.arid <= item.id ;
    vif.araddr <= item.addr ;
    vif.arlen <= item.burst_len ;
    vif.arsize <= item.burst_size ;
    vif.arburst <= 2'(item.burst_type) ;
    
     @(posedge vif.aclk);

    while(vif.arready !== 1) begin
     @(posedge vif.aclk);
    end
    

    vif.arid <= 0 ;
    vif.araddr <= 0 ;
    vif.arlen <= 0 ;
    vif.arsize <= 0 ;
    vif.arburst <= 0 ;
    vif.arvalid <= 0 ;
    
    @(posedge vif.aclk);   
    
  end

endtask

protected virtual task  handle_r();

sv_axi4_item_drv item ;
  
  `uvm_info("DRV","Entered handle_r",UVM_NONE)

   //just required in the begening. can be shifted to reset.
vif.rready <=0 ;

forever begin
     @(posedge vif.aclk);

     while(vif.rvalid !==1)begin
      @(posedge vif.aclk);
      end
  
  item = read_outstanding[vif.rid];

  item.rdata.push_back(vif.rdata);
   
   vif.rready<=1 ;
  
  item.rresp.push_back(sv_axi4_response'(vif.rresp));

  if(vif.rlast == 1) begin

    seq_item_port.put_response(item);

    read_outstanding.delete(vif.rid);

    read_sem.put(1);
    
  end

      @(posedge vif.aclk);
       vif.rready <=0 ;

end

endtask


virtual task wait_reset_start();

    agent_config.wait_reset_start();

endtask

virtual task wait_reset_end();

  agent_config.wait_reset_end();

endtask

virtual function void handle_reset(uvm_phase phase);
 // sv_axi4_vif vif = agent_config.get_vif(); 
 aw_q.delete();
    w_q.delete();
    ar_q.delete();

    write_outstanding.delete();
    read_outstanding.delete();

endfunction


endclass 
 `endif