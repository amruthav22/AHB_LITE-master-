// ============================================================================
// AHB Driver Class - Clean Implementation
// ============================================================================

class ahb_driver;
  
  ahb_packet drv_pkt;
  
  mailbox #(ahb_packet) mbx_gen2drv;
  mailbox #(ahb_packet) mbx_drv2ref;
  
  virtual ahb_interface.DRV vif;
  
  // Covergroup for functional coverage
  covergroup ahb_cg;
    HGRANT  : coverpoint drv_pkt.HGRANT {bins HGNT[] = {0, 1};}
    HREADY  : coverpoint drv_pkt.HREADY {bins HRDY[] = {0, 1};}
    BUSREQ  : coverpoint drv_pkt.BUSREQ {bins BREQ[] = {0, 1};}
    ADDREQ  : coverpoint drv_pkt.ADDREQ {bins AREQ[] = {0, 1};}
    WRITE   : coverpoint drv_pkt.WRITE  {bins WRT[]  = {0, 1};}
    ADDR    : coverpoint drv_pkt.ADDR   {bins ADD[]  = {[0:((2**32)-1)]};}
    WDATA   : coverpoint drv_pkt.WDATA  {bins WD[]   = {[0:((2**32)-1)]};}
    HRDATA  : coverpoint drv_pkt.HRDATA {bins HRD[]  = {[0:((2**32)-1)]};}
    SIZE    : coverpoint drv_pkt.SIZE   {bins SZ[]   = {[0:2]};}
    BURST   : coverpoint drv_pkt.BURST  {bins BRT[]  = {[0:7]};}
    HRESP   : coverpoint drv_pkt.HRESP  {bins HRSP[] = {0, 1};}
    SEL     : coverpoint drv_pkt.SEL    {bins SL[]   = {[0:3]};}
    TRANS   : coverpoint drv_pkt.TRANS  {bins TRN[]  = {[0:3]};}
    
    HWXHS   : cross TRANS, HREADY;
    HWXHS   : cross WRITE, HREADY;
    HWXHB   : cross WRITE, BURST;
    HSXHB   : cross SIZE, BURST;
    HRXHR   : cross HRESP, HREADY;
    HWXHR   : cross WRITE, HRESP;
    ADXHS   : cross ADDR, SIZE;
  endgroup
  
  // Constructor
  function new(mailbox #(ahb_packet) mbx_gen2drv,
               mailbox #(ahb_packet) mbx_drv2ref,
               virtual ahb_interface.DRV vif);
    this.mbx_gen2drv = mbx_gen2drv;
    this.mbx_drv2ref = mbx_drv2ref;
    this.vif = vif;
    drv_pkt = new;
    ahb_cg = new;
  endfunction
  
  // Main driver task
  // In the start() task, change signal assignments:
virtual task start();
  $display("@%0t [DRV] RUN STARTED", $time);
  
  repeat(256) begin
    @(vif.drv_cb);
    #1;
    mbx_gen2drv.get(drv_pkt);
    
    // Drive signals to interface
    vif.drv_cb.HGRANT <= drv_pkt.HGRANT;
    vif.drv_cb.HREADY <= drv_pkt.HREADY;
    vif.drv_cb.BUSREQ <= drv_pkt.BUSREQ;
    vif.drv_cb.ADDREQ <= drv_pkt.ADDREQ;
    vif.drv_cb.HWRITE <= drv_pkt.WRITE;  // Changed from WRITE
    vif.drv_cb.ADDR <= drv_pkt.ADDR;
    vif.drv_cb.WDATA <= drv_pkt.WDATA;
    vif.drv_cb.HRDATA <= drv_pkt.HRDATA;
    vif.drv_cb.SIZE <= drv_pkt.SIZE;
    vif.drv_cb.BURST <= drv_pkt.BURST;
    vif.drv_cb.HRESP <= drv_pkt.HRESP;
    vif.drv_cb.SEL <= drv_pkt.SEL;
    vif.drv_cb.TRANS <= drv_pkt.TRANS;
    
    // Send packet to reference model
    mbx_drv2ref.put(drv_pkt);
    
    // Print packet information
    drv_pkt.print();
    
    // Sample coverage
    ahb_cg.sample();
  end
  
  $display("@%0t [DRV] RUN FINISHED", $time);
endtask

endclass
