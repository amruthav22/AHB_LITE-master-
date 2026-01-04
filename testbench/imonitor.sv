// ============================================================================
// AHB Monitor Class - Clean Implementation
// ============================================================================

class ahb_imonitor;
  
  ahb_packet ref_pkt;
  
  mailbox #(ahb_packet) mbx_drv2ref;
  mailbox #(ahb_packet) mbx_ref2scb;
  
  virtual ahb_interface.IMON vif;
  
  // Constructor
  function new(mailbox #(ahb_packet) mbx_drv2ref,
               mailbox #(ahb_packet) mbx_ref2scb,
               virtual ahb_interface.IMON vif);
    this.mbx_drv2ref = mbx_drv2ref;
    this.mbx_ref2scb = mbx_ref2scb;
    this.vif = vif;
  endfunction
  
  logic [31:0] next_addr;
  
  // Main monitoring task
  task start();
    $display("@%0t [MONITOR] RUN STARTED\n", $time);
    
    repeat(256) begin
      @(vif.imon_cb);
      
      mbx_drv2ref.get(ref_pkt);
      //ref_pkt = new;
      
      // Sample input signals from DUT
      ref_pkt.BUSREQ  = vif.imon_cb.BUSREQ;
      ref_pkt.HGRANT  = vif.imon_cb.HGRANT;
      ref_pkt.ADDREQ  = vif.imon_cb.ADDREQ;
      ref_pkt.WRITE   = vif.imon_cb.HWRITE;
      ref_pkt.TRANS   = vif.imon_cb.TRANS;
      ref_pkt.HREADY  = vif.imon_cb.HREADY;
      ref_pkt.ADDR    = vif.imon_cb.ADDR;
      ref_pkt.SIZE    = vif.imon_cb.SIZE;
      ref_pkt.BURST   = vif.imon_cb.BURST;
      ref_pkt.HRESP   = vif.imon_cb.HRESP;
      ref_pkt.SEL     = vif.imon_cb.SEL;
      ref_pkt.HRDATA  = vif.imon_cb.HRDATA;
      ref_pkt.WDATA   = vif.imon_cb.WDATA;
      
      // Reset condition
      if (ahb_top.HRESETn == 0) begin
        ref_pkt.HBUSREQ_IN = 0;
        ref_pkt.HWRITE_IN  = 0;
        ref_pkt.HADDR_IN   = 0;
        ref_pkt.HWDATA_IN  = 0;
        ref_pkt.HSIZE_IN   = 0;
        ref_pkt.HBURST_IN  = 0;
        ref_pkt.HSEL_IN    = 0;
        ref_pkt.HTRANS_IN  = 0;
      end
      
      // Write operation
      if (vif.imon_cb.WRITE == 1) begin
        int unsigned bytes, wrap;
        logic [31:0] base;
        
        case(ref_pkt.TRANS)
          2'b00: begin  // IDLE
            ref_pkt.HBUSREQ_IN = 0;
            ref_pkt.HWRITE_IN  = 0;
            ref_pkt.HWDATA_IN  = 0;
            ref_pkt.HADDR_IN   = 0;
            ref_pkt.HBURST_IN  = 0;
            ref_pkt.HTRANS_IN  = 0;
            ref_pkt.HSEL_IN    = 0;
          end
          
          2'b01: begin  // BUSY
            if (vif.imon_cb.HGRANT == 1 && vif.imon_cb.HREADY == 1 && 
                vif.imon_cb.BUSREQ == 1 && vif.imon_cb.SEL == 2'b11 && 
                vif.imon_cb.HRESP == 0) begin
              ref_pkt.HBUSREQ_IN = ref_pkt.HBUSREQ;
              ref_pkt.HWRITE_IN  = ref_pkt.HWRITE;
              ref_pkt.HWDATA_IN  = ref_pkt.HWDATA;
              ref_pkt.HBURST_IN  = ref_pkt.HBURST;
              ref_pkt.HTRANS_IN  = ref_pkt.HTRANS;
              ref_pkt.HADDR_IN   = ref_pkt.HADDR;
              ref_pkt.HSIZE_IN   = ref_pkt.HSIZE;
              ref_pkt.HSEL_IN    = ref_pkt.HSEL;
              // ref_pkt.HLOCK_IN = ref_pkt.HLOCK;
            end
          end
          
          2'b10: begin  // NON-SEQ
            if (vif.imon_cb.HREADY == 1 && vif.imon_cb.HGRANT == 1 && 
                vif.imon_cb.HRESP == 0 && vif.imon_cb.BUSREQ == 1 && 
                vif.imon_cb.ADDREQ == 0 && vif.imon_cb.SEL == 2'b11) begin
              if (vif.imon_cb.HREADY == 1) begin
                ref_pkt.HBUSREQ_IN = ref_pkt.BUSREQ;
                ref_pkt.HWDATA_IN  = ref_pkt.WDATA;
                ref_pkt.HWRITE_IN  = ref_pkt.WRITE;
                ref_pkt.HBURST_IN  = ref_pkt.BURST;
                ref_pkt.HTRANS_IN  = ref_pkt.TRANS;
                ref_pkt.HADDR_IN   = next_addr;
                ref_pkt.HSIZE_IN   = ref_pkt.SIZE;
                ref_pkt.HSEL_IN    = ref_pkt.SEL;
                // ref_pkt.HLOCK_IN = ref_pkt.HLOCK;
                next_addr = ref_pkt.ADDR;
              end
            end
          end
          
          2'b11: begin  // SEQ
            if (vif.imon_cb.HREADY == 1 && vif.imon_cb.HGRANT == 1 && 
                vif.imon_cb.HRESP == 0 && vif.imon_cb.BUSREQ == 1 && 
                vif.imon_cb.ADDREQ == 0 && vif.imon_cb.SEL == 2'b11) begin
              if (vif.imon_cb.HREADY == 1) begin
                ref_pkt.HBUSREQ_IN = ref_pkt.BUSREQ;
                ref_pkt.HWDATA_IN  = ref_pkt.WDATA;
                ref_pkt.HWRITE_IN  = ref_pkt.WRITE;
                ref_pkt.HBURST_IN  = ref_pkt.BURST;
                ref_pkt.HTRANS_IN  = ref_pkt.TRANS;
                ref_pkt.HADDR_IN   = next_addr;
                ref_pkt.HSIZE_IN   = ref_pkt.SIZE;
                ref_pkt.HSEL_IN    = ref_pkt.SEL;
                // ref_pkt.HLOCK_IN = ref_pkt.HLOCK;
                next_addr = ref_pkt.ADDR;
              end
              
              bytes = 1 << ref_pkt.SIZE;
              
              case(ref_pkt.BURST)
                3'b000: begin  // SINGLE
                  next_addr = next_addr + bytes;
                  ref_pkt.HADDR = next_addr;
                end
                
                3'b001: begin  // INCREMENT 4
                  for (int i = 0; i < 4; i++) begin
                    next_addr = next_addr + bytes;
                    ref_pkt.HADDR = next_addr;
                  end
                end
                
                3'b011: begin  // INCREMENT 8
                  for (int i = 0; i < 8; i++) begin
                    next_addr = next_addr + bytes;
                    ref_pkt.HADDR = next_addr;
                  end
                end
                
                3'b101: begin  // INCREMENT 16
                  for (int i = 0; i < 16; i++) begin
                    next_addr = next_addr + bytes;
                    ref_pkt.HADDR = next_addr;
                  end
                end
                
                3'b010: begin  // WRAP 4
                  wrap = 4 * bytes;
                  base = ref_pkt.ADDR & ~(wrap - 1);
                  next_addr = base | ((next_addr + bytes) & (wrap - 1));
                end
                
                3'b100: begin  // WRAP 8
                  wrap = 8 * bytes;
                  base = ref_pkt.ADDR & ~(wrap - 1);
                  next_addr = base | ((next_addr + bytes) & (wrap - 1));
                end
                
                3'b110: begin  // WRAP 16
                  wrap = 16 * bytes;
                  base = ref_pkt.ADDR & ~(wrap - 1);
                  next_addr = base | ((next_addr + bytes) & (wrap - 1));
                end
                
                default: begin
                  ref_pkt.HWDATA_IN = 0;
                end
              endcase
            end
          end
        endcase
      end
      
      // Read operation
      else if (vif.imon_cb.WRITE == 0) begin
        int unsigned bytes, wrap;
        logic [31:0] base;
        
        case(ref_pkt.TRANS)
          2'b00: begin  // IDLE
            ref_pkt.HBUSREQ_IN = 0;
            ref_pkt.HWRITE_IN  = 0;
            ref_pkt.HWDATA_IN  = 0;
            ref_pkt.HBURST_IN  = 0;
            ref_pkt.HTRANS_IN  = 0;
            ref_pkt.HADDR_IN   = 0;
            ref_pkt.HSIZE_IN   = 0;
            ref_pkt.HSEL_IN    = 0;
          end
          
          2'b01: begin  // BUSY
            if (vif.imon_cb.HREADY == 1 && vif.imon_cb.HGRANT == 1 && 
                vif.imon_cb.HRESP == 0 && vif.imon_cb.BUSREQ == 1 && 
                vif.imon_cb.SEL == 2'b11) begin
              ref_pkt.HBUSREQ_IN = ref_pkt.HBUSREQ;
              ref_pkt.HWRITE_IN  = ref_pkt.HWRITE;
              ref_pkt.HBURST_IN  = ref_pkt.HBURST;
              ref_pkt.HTRANS_IN  = ref_pkt.HTRANS;
              ref_pkt.HADDR_IN   = ref_pkt.HADDR;
              ref_pkt.HSIZE_IN   = ref_pkt.HSIZE;
              ref_pkt.HSEL_IN    = ref_pkt.HSEL;
            end
          end
          
          2'b10: begin  // NON-SEQ
            if (vif.imon_cb.HREADY == 1 && vif.imon_cb.HGRANT == 1 && 
                vif.imon_cb.HRESP == 0 && vif.imon_cb.BUSREQ == 1 && 
                vif.imon_cb.ADDREQ == 0 && vif.imon_cb.SEL == 2'b11) begin
              if (vif.imon_cb.HREADY == 1) begin
                ref_pkt.HBUSREQ_IN = ref_pkt.BUSREQ;
                ref_pkt.HWDATA_IN  = ref_pkt.WDATA;
                ref_pkt.HWRITE_IN  = ref_pkt.WRITE;
                ref_pkt.HBURST_IN  = ref_pkt.BURST;
                ref_pkt.HTRANS_IN  = ref_pkt.TRANS;
                ref_pkt.HADDR_IN   = next_addr;
                ref_pkt.HSIZE_IN   = ref_pkt.SIZE;
                ref_pkt.HSEL_IN    = ref_pkt.SEL;
                next_addr = ref_pkt.ADDR;
              end
            end
          end
          
          2'b11: begin  // SEQ
            if (vif.imon_cb.HREADY == 1 && vif.imon_cb.HGRANT == 1 && 
                vif.imon_cb.HRESP == 0 && vif.imon_cb.BUSREQ == 1 && 
                vif.imon_cb.ADDREQ == 0 && vif.imon_cb.SEL == 2'b11) begin
              if (vif.imon_cb.HREADY == 1) begin
                ref_pkt.HBUSREQ_IN = ref_pkt.BUSREQ;
                ref_pkt.HWDATA_IN  = ref_pkt.WDATA;
                ref_pkt.HWRITE_IN  = ref_pkt.WRITE;
                ref_pkt.HBURST_IN  = ref_pkt.BURST;
                ref_pkt.HTRANS_IN  = ref_pkt.TRANS;
                ref_pkt.HADDR_IN   = next_addr;
                ref_pkt.HSIZE_IN   = ref_pkt.SIZE;
                ref_pkt.HSEL_IN    = ref_pkt.SEL;
                next_addr = ref_pkt.ADDR;
              end
              
              bytes = 1 << ref_pkt.SIZE;
              
              case(ref_pkt.BURST)
                3'b000: begin  // SINGLE INCREMENT
                  next_addr = next_addr + bytes;
                  ref_pkt.HADDR = next_addr;
                end
                
                3'b001: begin  // INCREMENT 4
                  for (int i = 0; i < 4; i++) begin
                    next_addr = next_addr + bytes;
                    ref_pkt.HADDR = next_addr;
                  end
                end
                
                3'b011: begin  // INCREMENT 8
                  for (int i = 0; i < 8; i++) begin
                    next_addr = next_addr + bytes;
                    ref_pkt.HADDR = next_addr;
                  end
                end
                
                3'b101: begin  // INCREMENT 16
                  for (int i = 0; i < 16; i++) begin
                    next_addr = next_addr + bytes;
                    ref_pkt.HADDR = next_addr;
                  end
                end
                
                3'b010: begin  // WRAP 4
                  wrap = 4 * bytes;
                  base = ref_pkt.ADDR & ~(wrap - 1);
                  next_addr = base | ((next_addr + bytes) & (wrap - 1));
                end
                
                3'b100: begin  // WRAP 8
                  wrap = 8 * bytes;
                  base = ref_pkt.ADDR & ~(wrap - 1);
                  next_addr = base | ((next_addr + bytes) & (wrap - 1));
                end
                
                3'b110: begin  // WRAP 16
                  wrap = 16 * bytes;
                  base = ref_pkt.ADDR & ~(wrap - 1);
                  next_addr = base | ((next_addr + bytes) & (wrap - 1));
                end
                
                default: begin
                  ref_pkt.HWDATA_IN = 0;
                end
              endcase
            end
          end
        endcase
      end
      
      mbx_ref2scb.put(ref_pkt);
    end
    
    $display("@%0t [MONITOR] RUN FINISHED\n", $time);
  endtask

endclass
