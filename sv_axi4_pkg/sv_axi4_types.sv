`ifndef SV_AXI4_TYPES_SV
 `define SV_AXI4_TYPES_SV

typedef virtual sv_axi4_interface sv_axi4_vif;

typedef bit[`SV_AXI4_MAX_DATA_WIDTH-1:0] sv_axi4_data;

typedef bit[`SV_AXI4_MAX_ADDR_WIDTH-1:0] sv_axi4_addr;

typedef bit[`SV_AXI4_MAX_ID_WIDTH-1:0] sv_axi4_id;


typedef enum {SV_AXI4_READ=0 , SV_AXI4_WRITE=1} sv_axi4_dir;

typedef enum {SV_AXI4_ERR=1 , SV_AXI4_OK=0}  sv_axi4_response;


typedef enum bit [1:0] { FIXED = 2'b00, INCR  = 2'b01, WRAP  = 2'b10 } sv_axi4_burst;

`endif