

class ahb_test;

  // ================= VIRTUAL INTERFACES =================
  virtual ahb_interface.DRV  drv_vif;
  virtual ahb_interface.IMON imon_vif;
  virtual ahb_interface.OMON omon_vif;

  // ================= ENVIRONMENT =================
  ahb_environment env;

  // ================= CONSTRUCTOR =================
  function new( virtual ahb_interface.DRV  drv_vif,
                virtual ahb_interface.IMON imon_vif,
                virtual ahb_interface.OMON omon_vif );
    this.drv_vif  = drv_vif;
    this.imon_vif = imon_vif;
    this.omon_vif = omon_vif;
  endfunction

  // ================= RUN =================
  virtual task run();
    $display("@%0t [TEST] BASE TEST STARTED", $time);

    env = new(drv_vif, imon_vif, omon_vif);
    env.build();
    env.start();

    #2000;

    $display("@%0t [TEST] BASE TEST COMPLETED", $time);
  endtask

endclass


// ====================================================================
// TEST CASE 1
// ====================================================================
class test_one extends ahb_test;

  pkt_1 pkt1;

  function new( virtual ahb_interface.DRV  drv_vif,
                virtual ahb_interface.IMON imon_vif,
                virtual ahb_interface.OMON omon_vif );
    super.new(drv_vif, imon_vif, omon_vif);
  endfunction

  virtual task run();
    $display("@%0t [TEST1] STARTED", $time);

    env = new(drv_vif, imon_vif, omon_vif);
    env.build();

    pkt1 = new();
    env.gen.pack = pkt1;

    env.start();
    #2000;

    $display("@%0t [TEST1] COMPLETED", $time);
  endtask

endclass


// ====================================================================
// TEST CASE 2
// ====================================================================
class test_two extends ahb_test;

  pkt_2 pkt2;

  function new( virtual ahb_interface.DRV  drv_vif,
                virtual ahb_interface.IMON imon_vif,
                virtual ahb_interface.OMON omon_vif );
    super.new(drv_vif, imon_vif, omon_vif);
  endfunction

  virtual task run();
    $display("@%0t [TEST2] STARTED", $time);

    env = new(drv_vif, imon_vif, omon_vif);
    env.build();

    pkt2 = new();
    env.gen.pack = pkt2;

    env.start();
    #2000;

    $display("@%0t [TEST2] COMPLETED", $time);
  endtask

endclass


// ====================================================================
// TEST CASE 3
// ====================================================================
class test_three extends ahb_test;

  pkt_3 pkt3;

  function new( virtual ahb_interface.DRV  drv_vif,
                virtual ahb_interface.IMON imon_vif,
                virtual ahb_interface.OMON omon_vif );
    super.new(drv_vif, imon_vif, omon_vif);
  endfunction

  virtual task run();
    $display("@%0t [TEST3] STARTED", $time);

    env = new(drv_vif, imon_vif, omon_vif);
    env.build();

    pkt3 = new();
    env.gen.pack = pkt3;

    env.start();
    #2000;

    $display("@%0t [TEST3] COMPLETED", $time);
  endtask

endclass


// ====================================================================
// TEST CASE 4
// ====================================================================
class test_four extends ahb_test;

  pkt_4 pkt4;

  function new( virtual ahb_interface.DRV  drv_vif,
                virtual ahb_interface.IMON imon_vif,
                virtual ahb_interface.OMON omon_vif );
    super.new(drv_vif, imon_vif, omon_vif);
  endfunction

  virtual task run();
    $display("@%0t [TEST4] STARTED", $time);

    env = new(drv_vif, imon_vif, omon_vif);
    env.build();

    pkt4 = new();
    env.gen.pack = pkt4;

    env.start();
    #2000;

    $display("@%0t [TEST4] COMPLETED", $time);
  endtask

endclass
