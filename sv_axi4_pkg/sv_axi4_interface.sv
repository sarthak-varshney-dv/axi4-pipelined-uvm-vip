`ifndef SV_APB_INTERFACE_SV
 `define SV_APB_INTERFACE_SV

 `ifndef SV_AXI4_MAX_DATA_WIDTH
 `define SV_AXI4_MAX_DATA_WIDTH 32
   `endif

 `ifndef SV_AXI4_MAX_ADDR_WIDTH
 `define SV_AXI4_MAX_ADDR_WIDTH 32
   `endif

   `ifndef SV_AXI4_MAX_ID_WIDTH
 `define SV_AXI4_MAX_ID_WIDTH 4
   `endif

interface sv_apb_interface(input logic aclk);

 // Write Address Channel (AW)-
  logic [SV_AXI4_MAX_ID_WIDTH-1:0]      awid;
  logic [SV_AXI4_MAX_ADDR_WIDTH-1:0]    awaddr;
  logic [7:0]               awlen;
  logic [2:0]               awsize;
  logic [1:0]               awburst;
  logic                     awvalid;
  logic                     awready;

  // Write Data Channel (W)
  logic [SV_AXI4_MAX_DATA_WIDTH-1:0]    wdata;
  logic [SV_AXI4_MAX_DATA_WIDTH/8-1:0]  wstrb;
  logic                     wlast;
  logic                     wvalid;
  logic                     wready;

  // Write Response Channel (B)
  logic [SV_AXI4_MAX_ID_WIDTH-1:0]      bid;
  logic [1:0]               bresp;
  logic                     bvalid;
  logic                     bready;

  // Read Address Channel (AR)
  logic [SV_AXI4_MAX_ID_WIDTH-1:0]      arid;
  logic [SV_AXI4_MAX_ADDR_WIDTH-1:0]    araddr;
  logic [7:0]               arlen;
  logic [2:0]               arsize;
  logic [1:0]               arburst;
  logic                     arvalid;
  logic                     arready;

  // Read Data Channel (R)
  logic [SV_AXI4_MAX_ID_WIDTH-1:0]      rid;
  logic [SV_AXI4_MAX_DATA_WIDTH-1:0]    rdata;
  logic [1:0]               rresp;
  logic                     rlast;
  logic                     rvalid;
  logic                     rready;

  logic areset_n;
  
  bit has_checks;

  initial begin
    has_checks = 1;
  end


  // AWVALID must not go low until AWREADY is seen
  property p_awvalid_stable;
    @(posedge aclk) disable iff (!aresetn || !has_checks)
    (awvalid && !awready) |=> awvalid;
  endproperty
  assert property (p_awvalid_stable)
    else $error("[AXI4_IF] AWVALID de-asserted before AWREADY");

  property p_wvalid_stable;
    @(posedge aclk) disable iff (!aresetn || !has_checks)
    (wvalid && !wready) |=> wvalid;
  endproperty
  assert property (p_wvalid_stable)
    else $error("[AXI4_IF] WVALID de-asserted before WREADY");

  property p_arvalid_stable;
    @(posedge aclk) disable iff (!aresetn || !has_checks)
    (arvalid && !arready) |=> arvalid;
  endproperty
  assert property (p_arvalid_stable)
    else $error("[AXI4_IF] ARVALID de-asserted before ARREADY");

  property p_bvalid_stable;
    @(posedge aclk) disable iff (!aresetn || !has_checks)
    (bvalid && !bready) |=> bvalid;
  endproperty
  assert property (p_bvalid_stable)
    else $error("[AXI4_IF] BVALID de-asserted before BREADY");

  // X/Z checks on VALID signals after reset
  assert property (@(posedge aclk) disable iff (!aresetn || !has_checks) !$isunknown(awvalid))
    else $error("[AXI4_IF] AWVALID is X/Z");
  assert property (@(posedge aclk) disable iff (!aresetn || !has_checks) !$isunknown(wvalid))
    else $error("[AXI4_IF] WVALID is X/Z");
  assert property (@(posedge aclk) disable iff (!aresetn || !has_checks) !$isunknown(arvalid))
    else $error("[AXI4_IF] ARVALID is X/Z");

endinterface
