class ahb_scoreboard;
  
  mailbox #(ahb_packet) mbx_ref2scb;
  mailbox #(ahb_packet) mbx_mon2scb;
  
  int match;
  int mismatch;
  
  function new(mailbox #(ahb_packet) mbx_ref2scb, 
               mailbox #(ahb_packet) mbx_mon2scb);
    this.mbx_ref2scb = mbx_ref2scb;
    this.mbx_mon2scb = mbx_mon2scb;
    match = 0;
    mismatch = 0;
  endfunction
  
  task start();
    $display("@%0t [SCB] STARTED", $time);
    forever begin
      ahb_packet ref2scb_pkt;
      ahb_packet mon2scb_pkt;
      
      // Get packets from reference model and monitor
      mbx_ref2scb.get(ref2scb_pkt);
      mbx_mon2scb.get(mon2scb_pkt);
      
      // Display received data
     $display("@%0t [SCB REF] HBUSREQ=%b | HLOCK=%b | HWRITE=%b | HTRANS=%b | HSEL=%b | HADDR=0x%h | HWDATA=0x%h | HSIZE=%d | HBURST=%d",
         $time, ref2scb_pkt.HBUSREQ_IN, ref2scb_pkt.HLOCK_IN, ref2scb_pkt.HWRITE_IN,
         ref2scb_pkt.HTRANS_IN, ref2scb_pkt.HSEL_IN, ref2scb_pkt.HADDR_IN,
         ref2scb_pkt.HWDATA_IN, ref2scb_pkt.HSIZE_IN, ref2scb_pkt.HBURST_IN);

$display("@%0t [SCB MON] HBUSREQ=%b | HLOCK=%b | HWRITE=%b | HTRANS=%b | HSEL=%b | HADDR=0x%h | HWDATA=0x%h | HSIZE=%d | HBURST=%d",
         $time, mon2scb_pkt.HBUSREQ, mon2scb_pkt.HLOCK, mon2scb_pkt.HWRITE,
         mon2scb_pkt.HTRANS, mon2scb_pkt.HSEL, mon2scb_pkt.HADDR,
         mon2scb_pkt.HWDATA, mon2scb_pkt.HSIZE, mon2scb_pkt.HBURST);
      
      // Compare
      compare_report(ref2scb_pkt, mon2scb_pkt);
    end
  endtask
  
  task compare_report(ahb_packet ref_pkt, ahb_packet mon_pkt);
  bit pass = 1;

  // Compare HBUSREQ
  if (ref_pkt.HBUSREQ_IN !== mon_pkt.HBUSREQ) begin
    $display("@%0t [SCB] MISMATCH: HBUSREQ - Expected=%b, Got=%b",
             $time, ref_pkt.HBUSREQ_IN, mon_pkt.HBUSREQ);
    pass = 0;
  end

  // Compare HLOCK
  if (ref_pkt.HLOCK_IN !== mon_pkt.HLOCK) begin
    $display("@%0t [SCB] MISMATCH: HLOCK - Expected=%b, Got=%b",
             $time, ref_pkt.HLOCK_IN, mon_pkt.HLOCK);
    pass = 0;
  end

  // Compare HWRITE
  if (ref_pkt.HWRITE_IN !== mon_pkt.HWRITE) begin
    $display("@%0t [SCB] MISMATCH: HWRITE - Expected=%b, Got=%b",
             $time, ref_pkt.HWRITE_IN, mon_pkt.HWRITE);
    pass = 0;
  end

  // Compare HADDR
  if (ref_pkt.HADDR_IN !== mon_pkt.HADDR) begin
    $display("@%0t [SCB] MISMATCH: HADDR - Expected=0x%h, Got=0x%h",
             $time, ref_pkt.HADDR_IN, mon_pkt.HADDR);
    pass = 0;
  end

  // Compare HWDATA (only meaningful for writes)
  if (ref_pkt.HWRITE_IN == 1) begin  // Only check data on write transfers
    if (ref_pkt.HWDATA_IN !== mon_pkt.HWDATA) begin
      $display("@%0t [SCB] MISMATCH: HWDATA - Expected=0x%h, Got=0x%h",
               $time, ref_pkt.HWDATA_IN, mon_pkt.HWDATA);
      pass = 0;
    end
  end

  // Compare HSIZE
  if (ref_pkt.HSIZE_IN !== mon_pkt.HSIZE) begin
    $display("@%0t [SCB] MISMATCH: HSIZE - Expected=%d, Got=%d",
             $time, ref_pkt.HSIZE_IN, mon_pkt.HSIZE);
    pass = 0;
  end

  // Compare HBURST
  if (ref_pkt.HBURST_IN !== mon_pkt.HBURST) begin
    $display("@%0t [SCB] MISMATCH: HBURST - Expected=%d, Got=%d",
             $time, ref_pkt.HBURST_IN, mon_pkt.HBURST);
    pass = 0;
  end

  // Compare HTRANS
  if (ref_pkt.HTRANS_IN !== mon_pkt.HTRANS) begin
    $display("@%0t [SCB] MISMATCH: HTRANS - Expected=%b, Got=%b",
             $time, ref_pkt.HTRANS_IN, mon_pkt.HTRANS);
    pass = 0;
  end

  // Compare HSEL
  if (ref_pkt.HSEL_IN !== mon_pkt.HSEL) begin
    $display("@%0t [SCB] MISMATCH: HSEL - Expected=%b, Got=%b",
             $time, ref_pkt.HSEL_IN, mon_pkt.HSEL);
    pass = 0;
  end

  // Final result
  if (pass) begin
    $display("@%0t [SCB] PACKET MATCH - PASS", $time);
    match++;
  end else begin
    $display("@%0t [SCB] PACKET MATCH - FAIL", $time);
    mismatch++;
  end

  $display("@%0t [SCB] SCOREBOARD: MATCH=%0d | MISMATCH=%0d\n", $time, match, mismatch);
endtask
  
endclass
