`include "sv_axi4_pkg.sv"

module testbench();
  
  import uvm_pkg::*;
  import sv_axi4_pkg::*;
  
  
  reg clk;
  
 // always #5 clk=~clk;   //for clock. cristan has declared clong in a long form
  
  initial begin
    clk =0;
    forever begin
      clk= #5ns ~clk;
    end
  end
  
  
  initial begin
    axi4_if.areset_n=1;
    #3;
    axi4_if.areset_n=0;
    #30;
    axi4_if.areset_n=1;
  end
  
  //axi4 INTERFACE HANDLE
    sv_axi4_interface axi4_if(.aclk(clk));

  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
     
  uvm_config_db#(virtual sv_axi4_interface)::set(null,"uvm_test_top.env.axi4_agent","vif",axi4_if);
  //when instantiate axi4_agent, use name axi4_agent 
    
    
    run_test("  ");
  end
  
    axi4_slave dut(
    .reset_n(axi4_if.areset_n),
    
    // WRITE ADDRESS CHANNEL
    .awvalid(axi4_if.awvalid),
    .awready(axi4_if.awready),
    .awid(axi4_if.awid),
    .awlen(axi4_if.awlen),
    .awsize(axi4_if.awsize),
    .awaddr(axi4_if.awaddr),
    .awburst(axi4_if.awburst),

    // WRITE DATA CHANNEL
    .wvalid(axi4_if.wvalid),
    .wready(axi4_if.wready),
    .wdata(axi4_if.wdata),
    .wstrb(axi4_if.wstrb),
    .wlast(axi4_if.wlast),

  // WRITE RESPONSE CHANNEL
    .bid(axi4_if.bid),
    .bresp(axi4_if.bresp),
    .bvalid(axi4_if.bvalid),
    .bready(axi4_if.bready),

      // READ ADDRESS CHANNEL
    .arid(axi4_if.arid),
    .araddr(axi4_if.araddr),
    .arlen(axi4_if.arlen),
    .arsize(axi4_if.arsize),
    .arburst(axi4_if.arburst),
    .arvalid(axi4_if.arvalid),
    .arready(axi4_if.arready),

      // READ DATA CHANNEL
    .rid(axi4_if.rid),
    .rdata(axi4_if.rdata),
    .rresp(axi4_if.rresp),
    .rlast(axi4_if.rlast),
    .rvalid(axi4_if.rvalid),
    .rready(axi4_if.rready),

  );
  
  
  
endmodule