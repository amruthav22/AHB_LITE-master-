module ahb_top;
  bit HCLK;
  bit HRESETn;
  
  // ================= CLOCK GENERATION =================
  initial begin
    HCLK = 0;
    forever #5 HCLK = ~HCLK;
  end
  
  // ================= RESET GENERATION =================
  initial begin
    HRESETn = 0;
    repeat (3) @(posedge HCLK);
    HRESETn = 1;
  end
  
  // ================= INTERFACE INSTANCE =================
  ahb_interface ahbi (
    .HCLK(HCLK),
    .HRESETn(HRESETn)
  );
  
  // ================= DUT INSTANCE =================
  ahb_design dut (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    // Inputs
    .HGRANT(ahbi.HGRANT),
    .HREADY(ahbi.HREADY),
    .BUSREQ(ahbi.BUSREQ),
    .ADDREQ(ahbi.ADDREQ),
    .HWRITE(ahbi.HWRITE),
    .ADDR(ahbi.ADDR),
    .HWDATA(ahbi.WDATA),
    .HSIZE(ahbi.SIZE),
    .HBURST(ahbi.BURST),
    .HRESP(ahbi.HRESP),
    .HSEL(ahbi.SEL),
    .HTRANS(ahbi.TRANS),
    // Outputs
    .HBUSREQ(ahbi.HBUSREQ),
    .HLOCK(ahbi.HLOCK),
    .HWRITE_out(ahbi.HWRITE_out),
    .HADDR(ahbi.HADDR),
    .HWDATA_out(ahbi.HWDATA),
    .HTRANS_out(ahbi.HTRANS),
    .HSEL_out(ahbi.HSEL),
    .HSIZE_out(ahbi.HSIZE),
    .HBURST_out(ahbi.HBURST)
  );
  
  // ================= PROGRAM BLOCK =================
  ahb_program ahbp(ahbi);
  
  // ================= VCD DUMP FOR WAVEFORMS =================
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, ahb_top);
  end
  
endmodule
