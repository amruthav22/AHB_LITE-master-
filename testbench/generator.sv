// ============================================================================
// AHB Generator Class - Clean Implementation
// ============================================================================

class ahb_generator;
  
  ahb_packet pack, ref_pack;
  
  mailbox #(ahb_packet) mbx_gen2drv;
  
  // Constructor
  function new(mailbox #(ahb_packet) mbx_gen2drv);
    this.mbx_gen2drv = mbx_gen2drv;
    pack = new;
  endfunction
  
  // Main task to generate packets
  virtual task start();
    int count;
    $display("@%0t [GENERATOR] Run started\n", $time);
    
    repeat(256) begin
      pack.randomize();
      ref_pack = new;
      ref_pack.copy(pack);
      mbx_gen2drv.put(ref_pack);
      count = count + 1;
      $display("@%0t [GENERATOR] Sent packet %0d to driver \n", $time, count);
    end
    
    $display("@%0t [GENERATOR] Run Finished\n", $time);
  endtask

endclass
