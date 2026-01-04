// 
class ahb_packet;
  
  // ==================== RANDOMIZING INPUT SIGNALS ====================
  rand bit        HGRANT, HREADY, BUSREQ, ADDREQ, WRITE;
  rand bit [31:0] ADDR, WDATA, HRDATA;
  rand bit [2:0]  SIZE, BURST;
  rand bit [1:0]  HRESP, SEL, TRANS;
  
  // ==================== NON-RANDOMIZING OUTPUT SIGNALS ====================
  logic        HBUSREQ, HLOCK, HWRITE;
  logic [1:0]  HTRANS, HSEL;
  logic [31:0] HADDR, HWDATA;
  logic [2:0]  HSIZE, HBURST;
  
  // ==================== MONITOR OUTPUT SIGNALS ====================
  logic        HBUSREQ_IN, HLOCK_IN, HWRITE_IN;
  logic [1:0]  HTRANS_IN, HSEL_IN;
  logic [31:0] HADDR_IN, HWDATA_IN;
  logic [2:0]  HSIZE_IN, HBURST_IN;
  
  rand int transfer;
  
  // ==================== SIZE CONSTRAINT ====================
  constraint size_range {
    SIZE inside {[0:2]};
  }
  
  // ==================== BURST CONSTRAINT ====================
  constraint burst_range {
    BURST inside {[0:7]};
  }
  
  // ==================== TRANS CONSTRAINT ====================
  constraint trans_constraint {
    transfer inside {0, 1, 2, 3};
  }
  
  constraint trans_range {
    if (transfer == 0) TRANS == 2'b00;  // IDLE
    if (transfer == 1) TRANS == 2'b01;  // BUSY
    if (transfer == 2) TRANS == 2'b10;  // NON-SEQ
    if (transfer == 3) TRANS == 2'b11;  // SEQ
  }
  
  // ==================== RESPONSE CONSTRAINT ====================
  constraint response_range {
    HRESP inside {[0:1]};
  }
  
  // ==================== CONTROL SIGNALS CONSTRAINT ====================
  constraint grbt {
    HGRANT inside {[0:1]};
    HREADY inside {[0:1]};
    BUSREQ inside {[0:1]};
    ADDREQ inside {[0:1]};
    WRITE  inside {[0:1]};
    
    HGRANT dist {1:=/70, 0:=/30};
    HREADY dist {1:=/70, 0:=/30};
    BUSREQ dist {1:=/70, 0:=/30};
  }
  
  // ==================== ADDRESS CONSTRAINT ====================
  constraint addr_range {
    ADDR inside {[0:((2**32)-1)]};  // 2^32 combinations for address
    WDATA inside {[0:((2**32)-1)]}; // 2^32 combinations for wdata
    HRDATA inside {[0:((2**32)-1)]};
  }
  
  constraint sel_constraint {
    SEL inside {[0:3]};
  }
  
  // ==================== VIRTUAL PRINT FUNCTION ====================
  virtual function void print(string tag = "Packet");
    $display("\n%0d HGRANT=%b, HREADY=%b, BUSREQ=%b, ADDREQ=%b, WRITE=%b, ADDR=%d, WDATA=%d, SIZE=%d, BURST=%d, HRESP=%b, SEL=%b, TRANS=%b, HRDATA=%d",
             $time, HGRANT, HREADY, BUSREQ, ADDREQ, WRITE, ADDR, WDATA, SIZE, BURST, HRESP, SEL, TRANS, HRDATA);
  endfunction
  
  // ==================== VIRTUAL COPY FUNCTION ====================
  virtual function void copy(ahb_packet p);
    this.HGRANT  = p.HGRANT;
    this.HREADY  = p.HREADY;
    this.BUSREQ  = p.BUSREQ;
    this.ADDREQ  = p.ADDREQ;
    this.WRITE   = p.WRITE;
    this.ADDR    = p.ADDR;
    this.WDATA   = p.WDATA;
    this.SIZE    = p.SIZE;
    this.BURST   = p.BURST;
    this.HRESP   = p.HRESP;
    this.SEL     = p.SEL;
    this.TRANS   = p.TRANS;
    this.HRDATA  = p.HRDATA;
  endfunction

endclass

// ============================================================================
// TEST CASE - 1: CHILD CLASS (Simple Read Transaction)
// ============================================================================
class pkt_1 extends ahb_packet;
  
  constraint signals_in {
    HGRANT == 1;
    HREADY == 1;
    // HRESP == 1;  // Commented out to allow randomization
    BUSREQ == 0;
    ADDREQ == 0;
    WRITE  == 0;
    BURST inside {[0:7]};
    
    SIZE[2] == 0;
    SIZE[1] == 1;
    SIZE inside {[0:7]};
    
  }
  
  virtual function void copy(ahb_packet p);
    this.HGRANT  = p.HGRANT;
    this.HREADY  = p.HREADY;
    this.BUSREQ  = p.BUSREQ;
    this.ADDREQ  = p.ADDREQ;
    this.WRITE   = p.WRITE;
    this.ADDR    = p.ADDR;
    this.WDATA   = p.WDATA;
    this.SIZE    = p.SIZE;
    this.BURST   = p.BURST;
    this.HRESP   = p.HRESP;
    this.SEL     = p.SEL;
    this.TRANS   = p.TRANS;
    this.HRDATA  = p.HRDATA;
    this.transfer = p.transfer;
  endfunction

endclass

// ============================================================================
// TEST CASE - 2: CHILD CLASS (Write Transaction)
// ============================================================================
class pkt_2 extends ahb_packet;
  
  constraint const_a {
    HRESP inside {0};
    HREADY inside {1};
    HTRANS inside {2'b01};  // NONSEQ
    ADDREQ == 1'b0;
    HWDATA == 32'h00000000;
    HWRITE inside {1};
  }
  
  virtual function void copy(ahb_packet p);
    this.HGRANT  = p.HGRANT;
    this.HREADY  = p.HREADY;
    this.BUSREQ  = p.BUSREQ;
    this.ADDREQ  = p.ADDREQ;
    this.WRITE   = p.WRITE;
    this.ADDR    = p.ADDR;
    this.WDATA   = p.WDATA;
    this.SIZE    = p.SIZE;
    this.BURST   = p.BURST;
    this.HRESP   = p.HRESP;
    this.SEL     = p.SEL;
    this.TRANS   = p.TRANS;
    this.HRDATA  = p.HRDATA;
    this.transfer = p.transfer;
  endfunction

endclass

// ============================================================================
// TEST CASE - 3: CHILD CLASS (Burst Transfer)
// ============================================================================
class pkt_3 extends ahb_packet;
  
  // Constraints for addr, wdata, hrdata, hresp
  constraint addr_range {
    ADDR inside {[0:((2**32)-1)]};
    WDATA inside {[0:((2**32)-1)]};
    HRDATA inside {[0:((2**32)-1)]};
    HRESP inside {[0:1]};
    unique {ADDR};
    unique {WDATA};
    unique {HRDATA};
  }
  
  // Constraints for trans
  constraint trans_type {
    transfer dist {0:=/20, 1:=/2, 2:=/7, 3:=/2};
  }
  
  // Transfer constraints
  constraint trans_constraint {
    if (transfer == 0) TRANS == 2'b00;  // IDLE
    if (transfer == 1) TRANS == 2'b01;  // BUSY
    if (transfer == 2) TRANS == 2'b10;  // NON-SEQ
    if (transfer == 3) TRANS == 2'b11;  // SEQ
  }
  
  // Constraints for grant, ready, busreq, addreq, write, burst, size
  constraint signals_in {
    HGRANT == 0;
    // HLOCK == 0;
    HREADY == 1;
    BUSREQ == 0;
    ADDREQ == 0;
    WRITE  == 1;
    BURST inside {[0:7]};
    SIZE  dist {0:=/1, 1:=/1, 2:=/1};
    if (SIZE == 0) SIZE == SIZE;
    if (TRANS == 2'b10 || TRANS == 2'b11) 
      ADDR inside {[0:2**5]};
  }
  
  virtual function void copy(ahb_packet p);
    this.ADDR    = p.ADDR;
    this.WDATA   = p.WDATA;
    this.SIZE    = p.SIZE;
    this.BURST   = p.BURST;
    this.HRESP   = p.HRESP;
    this.SEL     = p.SEL;
    this.TRANS   = p.TRANS;
    this.HRDATA  = p.HRDATA;
    this.HGRANT  = p.HGRANT;
    this.HREADY  = p.HREADY;
    this.BUSREQ  = p.BUSREQ;
    this.ADDREQ  = p.ADDREQ;
    this.WRITE   = p.WRITE;
    this.transfer = p.transfer;
  endfunction

endclass

// ============================================================================
// TEST CASE - 4: CHILD CLASS (Error Response)
// ============================================================================
class pkt_4 extends ahb_packet;
  
  constraint test_4 {
    HRESP inside {0};
    HREADY inside {1};
    HTRANS inside {2'b11};  // SEQ - non seq
    ADDREQ == 1'b0;
    HWRITE inside {1};
  }
  
  virtual function void copy(ahb_packet p);
    this.ADDR    = p.ADDR;
    this.WDATA   = p.WDATA;
    this.SIZE    = p.SIZE;
    this.BURST   = p.BURST;
    this.HRESP   = p.HRESP;
    this.SEL     = p.SEL;
    this.TRANS   = p.TRANS;
    this.HRDATA  = p.HRDATA;
    this.HGRANT  = p.HGRANT;
    this.HREADY  = p.HREADY;
    this.BUSREQ  = p.BUSREQ;
    this.ADDREQ  = p.ADDREQ;
    this.WRITE   = p.WRITE;
    this.transfer = p.transfer;
  endfunction

endclass
