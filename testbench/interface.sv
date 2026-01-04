interface ahb_interface (
  input bit HCLK,
  input bit HRESETn
);
  // ================= INPUT SIGNALS (Driven to DUT) =================
  logic HGRANT, HREADY, BUSREQ, ADDREQ, HWRITE;
  logic [31:0] ADDR, WDATA, HRDATA;
  logic [2:0] SIZE, BURST;
  logic [1:0] HRESP, SEL, TRANS;
  
  // ================= OUTPUT SIGNALS (From DUT) =================
  logic HBUSREQ, HLOCK, HWRITE_out;
  logic [31:0] HADDR, HWDATA;
  logic [1:0] HTRANS, HSEL;
  logic [2:0] HSIZE, HBURST;
  
  // ================= DRIVER CLOCKING BLOCK =================
  clocking drv_cb @(posedge HCLK);
    output HGRANT, HREADY, BUSREQ, ADDREQ, HWRITE;
    output ADDR, WDATA, HRDATA;
    output SIZE, BURST;
    output HRESP, SEL, TRANS;
  endclocking
  
  // ================= INPUT MONITOR CLOCKING BLOCK =================
  clocking imon_cb @(posedge HCLK);
    input HGRANT, HREADY, BUSREQ, ADDREQ, HWRITE;
    input ADDR, WDATA, HRDATA;
    input SIZE, BURST;
    input HRESP, SEL, TRANS;
  endclocking
  
  // ================= OUTPUT MONITOR CLOCKING BLOCK =================
  clocking omon_cb @(posedge HCLK);
    input HBUSREQ, HLOCK, HWRITE_out;
    input HADDR, HWDATA;
    input HTRANS, HSEL;
    input HSIZE, HBURST;
  endclocking
  
  // ================= MODPORTS =================
  modport DRV (clocking drv_cb);
  modport IMON (clocking imon_cb);
  modport OMON (clocking omon_cb);
endinterface
