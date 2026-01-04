class ahb_omonitor;
  
  virtual ahb_interface.OMON omon_vif;
  mailbox #(ahb_packet) mbx_mon2scb;
  covergroup mon_cg;
  
  function new(mailbox #(ahb_packet) mbx_mon2scb, 
               virtual ahb_interface.OMON omon_vif);
    this.mbx_mon2scb = mbx_mon2scb;
    this.omon_vif = omon_vif;
    mon_cg = new();
  endfunction
  
  // Coverage group for monitoring outputs
  covergroup mon_cg;
    cp_HBUSREQ: coverpoint omon_vif.omon_cb.HBUSREQ {
      bins b_HBUSREQ[] = {0, 1};
    }
    cp_HLOCK: coverpoint omon_vif.omon_cb.HLOCK {
      bins b_HLOCK[] = {0, 1};
    }
    cp_HWRITE: coverpoint omon_vif.omon_cb.HWRITE_out {
      bins b_HWRITE[] = {0, 1};
    }
    cp_HBURST: coverpoint omon_vif.omon_cb.HBURST_out {
      bins b_HBURST[] = {[0:7]};
    }
    cp_HTRANS: coverpoint omon_vif.omon_cb.HTRANS_out {
      bins b_HTRANS[] = {[0:3]};
    }
    cp_HADDR: coverpoint omon_vif.omon_cb.HADDR {
      bins b_HADDR_low = {[0:32'hFFFF]};
      bins b_HADDR_mid = {[32'h10000:32'hFFFFFF]};
      bins b_HADDR_high = {[32'h1000000:32'hFFFFFFFF]};
    }
    cp_HSIZE: coverpoint omon_vif.omon_cb.HSIZE_out {
      bins b_HSIZE[] = {[0:7]};
    }
    cp_HSEL: coverpoint omon_vif.omon_cb.HSEL_out {
      bins b_HSEL[] = {[0:3]};
    }
  endgroup
  
  task start();
    $display("@%0t [OMON] RUN STARTED", $time);
    repeat(256) begin
      ahb_packet omon_pkt = new();
      
      // Sample output signals
      @(omon_vif.omon_cb);
      omon_pkt.HBUSREQ = omon_vif.omon_cb.HBUSREQ;
      omon_pkt.HLOCK   = omon_vif.omon_cb.HLOCK;
      omon_pkt.HWRITE  = omon_vif.omon_cb.HWRITE_out;
      omon_pkt.HTRANS  = omon_vif.omon_cb.HTRANS_out;
      omon_pkt.HADDR   = omon_vif.omon_cb.HADDR;
      omon_pkt.HWDATA  = omon_vif.omon_cb.HWDATA_out;
      omon_pkt.HSIZE   = omon_vif.omon_cb.HSIZE_out;
      omon_pkt.HBURST  = omon_vif.omon_cb.HBURST_out;
      omon_pkt.HSEL    = omon_vif.omon_cb.HSEL_out;
      
      // Display monitored packet
      $display("@%0t [MON OUT] generated HBUSREQ=%0d | HLOCK=%0d | HWRITE=%0d | HTRANS=%0d | HSEL=%0d | HADDR=0x%0h | HWDATA=0x%0h | HSIZE=%0d | HBURST=%0d",
               $time, omon_pkt.HBUSREQ, omon_pkt.HLOCK, omon_pkt.HWRITE, omon_pkt.HTRANS, 
               omon_pkt.HSEL, omon_pkt.HADDR, omon_pkt.HWDATA, omon_pkt.HSIZE, omon_pkt.HBURST);
      
      // Send to scoreboard
      mbx_mon2scb.put(omon_pkt);
      
      // Sample coverage
      mon_cg.sample();
      $display(mon_cg.get_coverage());
    end
    $display("@%0t [MON] RUN FINISHED", $time);
  endtask
  
endclass
