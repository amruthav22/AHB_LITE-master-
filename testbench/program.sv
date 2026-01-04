

program ahb_program(ahb_interface vif);
  
  ahb_test test;
  test_one test1;
  test_two test2;
  test_three test3;
  test_four test4;
  
  initial begin
    $display("@%0t [Prg] simulation started", $time);
    
    // Instantiate and run base test
    test = new(vif.DRV, vif.IMON, vif.OMON);
    test.run();
    
    // Instantiate and run test cases
    test1 = new(vif.DRV, vif.IMON, vif.OMON);
    test1.run();
    
    test2 = new(vif.DRV, vif.IMON, vif.OMON);
    test2.run();
    
    test3 = new(vif.DRV, vif.IMON, vif.OMON);
    test3.run();
    
    test4 = new(vif.DRV, vif.IMON, vif.OMON);
    test4.run();
    
    $display("@%0t [Prg] simulation finished", $time);
    $finish;
  end
  
endprogram
