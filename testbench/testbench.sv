// Interface (updated to match your DUT exactly; removed unnecessary HRDATA since DUT doesn't use it)
interface ahb_interface (
  input bit HCLK,
  input bit HRESETn
);
  // Inputs to DUT
  logic HGRANT, HREADY, BUSREQ, ADDREQ, HWRITE;
  logic [31:0] ADDR, HWDATA;
  logic [2:0] HSIZE, HBURST;
  logic [1:0] HRESP, HSEL, HTRANS;
  
  // Outputs from DUT
  logic HBUSREQ, HLOCK, HWRITE_out;
  logic [31:0] HADDR, HWDATA_out;
  logic [1:0] HTRANS_out, HSEL_out;
  logic [2:0] HSIZE_out, HBURST_out;
  
  // Clocking block for driver
  clocking drv_cb @(posedge HCLK);
    output HGRANT, HREADY, BUSREQ, ADDREQ, HWRITE, ADDR, HWDATA, HSIZE, HBURST, HRESP, HSEL, HTRANS;
  endclocking
  
  modport DRV (clocking drv_cb);
endinterface

// Top module with complete stimulus
module ahb_top;
  bit HCLK;
  bit HRESETn;
  
  // Clock generation
  initial begin
    HCLK = 0;
    forever #5 HCLK = ~HCLK;  // 100 MHz clock
  end
  
  // Reset generation
  initial begin
    HRESETn = 0;
    #20 HRESETn = 1;  // Deassert reset after 20ns
  end
  
  // Interface instance
  ahb_interface ahb_if (.HCLK(HCLK), .HRESETn(HRESETn));
  
  // DUT instance
  ahb_design dut (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    // Inputs
    .HGRANT(ahb_if.HGRANT),
    .HREADY(ahb_if.HREADY),
    .BUSREQ(ahb_if.BUSREQ),
    .ADDREQ(ahb_if.ADDREQ),
    .HWRITE(ahb_if.HWRITE),
    .ADDR(ahb_if.ADDR),
    .HWDATA(ahb_if.HWDATA),
    .HSIZE(ahb_if.HSIZE),
    .HBURST(ahb_if.HBURST),
    .HRESP(ahb_if.HRESP),
    .HSEL(ahb_if.HSEL),
    .HTRANS(ahb_if.HTRANS),
    // Outputs
    .HBUSREQ(ahb_if.HBUSREQ),
    .HLOCK(ahb_if.HLOCK),
    .HWRITE_out(ahb_if.HWRITE_out),
    .HADDR(ahb_if.HADDR),
    .HWDATA_out(ahb_if.HWDATA_out),
    .HTRANS_out(ahb_if.HTRANS_out),
    .HSEL_out(ahb_if.HSEL_out),
    .HSIZE_out(ahb_if.HSIZE_out),
    .HBURST_out(ahb_if.HBURST_out)
  );
  
  // Stimulus: Drive all inputs for a simple write transaction
  initial begin
    // Initialize all inputs to known values (avoid 'X')
    ahb_if.HGRANT = 0;
    ahb_if.HREADY = 0;
    ahb_if.BUSREQ = 0;
    ahb_if.ADDREQ = 0;
    ahb_if.HWRITE = 0;
    ahb_if.ADDR = 32'h0;
    ahb_if.HWDATA = 32'h0;
    ahb_if.HSIZE = 3'b000;
    ahb_if.HBURST = 3'b000;
    ahb_if.HRESP = 2'b00;  // OKAY response
    ahb_if.HSEL = 2'b00;
    ahb_if.HTRANS = 2'b00;  // IDLE
    
    // Wait for reset deassert
    @(posedge HRESETn);
    #10;  // Small delay after reset
    
    // Start bus request
    ahb_if.BUSREQ = 1;
    ahb_if.ADDREQ = 0;  // No lock needed for simple transfer
    #10;
    
    // Grant access and set ready
    ahb_if.HGRANT = 1;
    ahb_if.HREADY = 1;
    #10;
    
    // Set up address phase for write (NONSEQ, word size, single burst)
    ahb_if.HWRITE = 1;  // Write
    ahb_if.ADDR = 32'h00001000;  // Example address
    ahb_if.HSIZE = 3'b010;  // 32-bit word
    ahb_if.HBURST = 3'b111;  // Single
    ahb_if.HSEL = 2'b11;  // Select slave (assuming 2-bit select)
    ahb_if.HTRANS = 2'b10;  // NONSEQ
    #10;
    
    // Data phase: Provide write data (pipelined in next cycle)
    ahb_if.HWDATA = 32'hDEADBEEF;
    #10;
    
    // Complete transfer (keep ready high, no error)
    ahb_if.HREADY = 1;
    ahb_if.HRESP = 2'b00;  // OKAY
    #20;
    
    // End request and idle
    ahb_if.BUSREQ = 0;
    ahb_if.HGRANT = 0;
    ahb_if.HREADY = 1;
    ahb_if.HTRANS = 2'b00;  // IDLE
    // After first transfer (~150 ns)
#50;
// New transfer: Read, no lock
ahb_if.BUSREQ = 1;
ahb_if.ADDREQ = 0;  // No lock
ahb_if.HWRITE = 0;  // Read
ahb_if.ADDR = 32'h20000000;
#50;
ahb_if.HRESP = 2'b00;  // Force OKAY


    #200;
    
  $finish; 
  end
  
  // Waveform dump (essential for EDA Playground waveforms)
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, ahb_top);  // Dump all signals
  end
endmodule
