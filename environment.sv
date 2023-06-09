//`include "transaction.sv"
//`include "generator.sv"
//`include "driver.sv"
//`include "monitor.sv"
//`include "scoreboard.sv"
class environment;
  
  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;
  
  mailbox gen2drv;
  mailbox mon2scb,drv2scr;

  
  event drv2gen;//to show generation of signals have stopped
  virtual fifo_intf vif_fifo;
  
  function new(virtual fifo_intf vif_fifo);
    this.vif_fifo = vif_fifo;
    gen2drv = new();
    mon2scb = new();
    drv2scr=new();
    gen = new(gen2drv,drv2gen);
    drv = new(vif_fifo,gen2drv,drv2scr);
    mon = new(vif_fifo,mon2scb);
    scb = new(drv2scr,mon2scb);
  endfunction
  
  task pre_test();
   drv.reset();
  endtask
  
  task test();
   fork
   gen.main();
   drv.drive();
   join
   //drv.driveRead();
   mon.main();
   scb.main();
  endtask
  
  task post_test();
  // wait(drv2gen.triggered);
   if (gen.repeat_count == drv.no_trans);
  // wait(gen.repeat_count == scb.no_trans);
  endtask
  
  task run();
   pre_test();
   test();
 // post_test();
   $finish;
  endtask
endclass
