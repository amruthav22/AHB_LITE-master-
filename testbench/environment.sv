

class ahb_environment;

  // ================= VIRTUAL INTERFACES =================
  virtual ahb_interface.DRV  drv_vif;
  virtual ahb_interface.IMON imon_vif;
  virtual ahb_interface.OMON omon_vif;

  // ================= MAILBOXES =================
  mailbox #(ahb_packet) mbx_gen2drv;
  mailbox #(ahb_packet) mbx_drv2ref;
  mailbox #(ahb_packet) mbx_ref2scb;
  mailbox #(ahb_packet) mbx_mon2scb;

  // ================= COMPONENTS =================
  ahb_generator  gen;
  ahb_driver     drv;
  ahb_imonitor   imon;
  ahb_omonitor   omon;
  ahb_scoreboard scb;

  // ================= CONSTRUCTOR =================
  function new( virtual ahb_interface.DRV  drv_vif,
                virtual ahb_interface.IMON imon_vif,
                virtual ahb_interface.OMON omon_vif );

    this.drv_vif  = drv_vif;
    this.imon_vif = imon_vif;
    this.omon_vif = omon_vif;

  endfunction

  // ================= BUILD PHASE =================
  task build();
    $display("@%0t [ENV:build] Build started", $time);

    mbx_gen2drv = new();
    mbx_drv2ref = new();
    mbx_ref2scb = new();
    mbx_mon2scb = new();

    gen  = new(mbx_gen2drv);
    drv  = new(mbx_gen2drv, mbx_drv2ref, drv_vif);
    imon = new(mbx_drv2ref, mbx_ref2scb, imon_vif);
    omon = new(mbx_mon2scb, omon_vif);
    scb  = new(mbx_ref2scb, mbx_mon2scb);

    $display("@%0t [ENV:build] Build completed", $time);
  endtask

  // ================= RUN PHASE =================
  task start();
    $display("@%0t [ENV:run] Simulation started", $time);

    fork
      gen.start();
      drv.start();
      imon.start();
      omon.start();
      scb.start();
    join_none

  endtask

endclass
