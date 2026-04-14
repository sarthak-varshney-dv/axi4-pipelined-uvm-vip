`ifndef SV_AXI4_DRIVER_SV
 `define SV_AXI4_DRIVER_SV

class sv_axi4_driver extends uvm_driver#(.REQ(sv_axi4_item_drv)) implements sv_axi4_reset_handler;

   sv_axi4_agent_config agent_config;
   
   sv_axi4_item_drv aw_q[$];

   sv_axi4_item_drv w_q[$];

   sv_axi4_item_drv ar_q[$];

   //outstanding trackers 

   sv_axi4_item_drv write_outstanding[int];

   sv_axi4_item_drv read_outstanding[int];

   //semaphores to limit outstanding transactions

   semaphore write_sem ;

   semaphore read_sem ;
    
 protected process process_drive_transaction;
 
    `uvm_component_utils(sv_axi4_driver)

    function new(string name="",uvm_component parent);
    super.new(name,parent);

    write_sem = new(4);
    read_sem = new(4);

    endfunction 

virtual task run_phase(uvm_phase phase);
 forever begin 
    fork 
        begin
            wait_reset_end();
            drive_transactions(); 
            disable fork;
        end
    join
 end

  endtask
  
protected virtual task drive_transactions();

fork
    begin
        process_drive_transaction=process::self();
            
                get_and_dispatch();

                //write side
                drive_aw();
                drive_w();
                drive_b();

                //read side
                drive_ar();
                handle_r();

    end

join_none

endtask

protected virtual task get_and_dispatch();

  sv_axi4_item_drv item ;

  forever begin
    
      seq_item_port.get(item);

        if(item.dir == SV_AXI4_WRITE) begin
         write_sem.get(1);

          write_outstanding [item.id] = item ;

         aw_q.push_back(item);
         w_q.push_back(item);

        end
        else begin
          read_sem.get(1);

          read_outstanding [item.id] = item;
          ar_q.push_back (item) ;

        end
  end

endtask

protected virtual task drive_aw();
  
  sv_axi4_item_drv item ;

   //just required in the begening. can be shifted to reset.
    vif.awvalid <= 0;
    vif.awaddr <= 0;
    vif.awid <= 0;
  
  forever begin
    
    @(posedge vif.aclk)
    

    while(aw_q.size() == 0) begin
        @(posedge vif.aclk);
    end
   
   item = aw_q.pop_front();

   `uvm_info("UVM_DEBUG",$sformatf("Driving write address ID: %0d",item.id,UVM_NONE));

    vif.awvalid <= 1;
    vif.awaddr <= item.addr;
    vif.awid <= item.id;

    
    while(vif.awready !== 0) begin
        @(posedge vif.aclk);
    end
   
    @(posedge vif.aclk);

    
    vif.awvalid <= 0;
    vif.awaddr <= 0;
    vif.awid <= 0;
    
    
  end

endtask

protected virtual task drive_w();

sv_axi4_item_drv item ;

   //just required in the begening. can be shifted to reset.
    vif.wvalid <= 0;
    vif.waddr <= 0;
    vif.wdata <= 0;
    vif.wlast <= 0;

  
  forever begin
    
    @(posedge vif.aclk)
    

        while(aw_q.size() == 0) begin
            @(posedge vif.aclk);
        end
      
      item = w_q.pop_front();

      `uvm_info("UVM_DEBUG",$sformatf("Driving write data ID: %0d",item.id,UVM_NONE));

    foreach(item.data[i]) begin 

        vif.wvalid <= 1;
        vif.waddr <= item.data[i];
        vif.last<= (i == txn.data.size()-1);

        while(vif.awready !== 0) begin
            @(posedge vif.clk);
        end

         @(posedge vif.clk);

    end

    
    vif.wvalid <= 0;
    vif.waddr <= 0;
    vif.wdata <= 0;
    vif.wlast <= 0;

  end
   


endtask



virtual task wait_reset_end();

  agent_config.wait_reset_end();

endtask

virtual function void handle_reset(uvm_phase phase);
  sv_axi4_vif = agent_config.get_vif();

  if(process_drive_transaction != null) begin
    process_drive_transaction.kill();

    process_drive_transaction = null;
  end

  vif.psel <= 0;
  vif.penable <= 0;
  vif.write <= 0;
  vif.paddr <= 0;
  vif.pwdata <= 0;

endfunction


endclass 
 `endif