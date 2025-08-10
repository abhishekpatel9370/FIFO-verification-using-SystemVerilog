// Code your testbench here
// or browse Examples
class transaction ;
  rand bit oper ; 
  bit rd, wr ;
  bit [7:0] data_in ;
  bit full , empty ;
  bit [7:0] data_out ;
  constraint oper_ctr {oper dist {1:/ 50 , 0:/50 };}
endclass

class generator ;
  transaction tr  ;
  mailbox #(transaction) mbx  ;
  int count =0,i=0 ;
  
  event next , done ;
  
  function new (mailbox #(transaction) mbx) ;
    this.mbx=mbx ;
    tr=new();
  endfunction 
  
  task run() ;
    repeat(count) begin 
      assert(tr.randomize)  
        else 
          $error("randomization failed");
      		i++ ;
      mbx.put(tr) ;
      $display("[GEN] : Oper : %0d iteration : %0d",tr.oper , i);
      @(next);
    end
    -> done ;
  endtask 
  
endclass 

// Driver class 
class driver ; 
  virtual fifo_if fif ;
  mailbox #(transaction) mbx ;
  transaction datac ;
 
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction 
  
  // reset the DUT
  task reset() ;
    fif.rst<=1'b1 ;
    fif.rd <=1'b0 ;
    fif.wr<=1'b0 ;
    fif.data_in<=0;
    repeat(5)@(posedge fif.clock);
      fif.rst<=1'b0 ;
      $display("[DRV] :DUT RESET DONE");
      $display("---------------------") ;
      endtask
      
    // write data to FIFO 
    
      task write() ;
        @(posedge fif.clock);
        fif.rst<=1'b0 ;
        fif.rd<=1'b0 ;
        fif.wr<=1'b1 ;
        fif.data_in<=$urandom_range(1, 200);
        @(posedge fif.clock) ;
        fif.wr<=1'b0 ;
        $display("[DRV] : DATA WRITE data=%0d",fif.data_in);
        @(posedge fif.clock);
      endtask 
      
      // Read data from FIFO
      task read() ;
        @(posedge fif.clock);
        fif.rst<=1'b0 ;
        fif.rd<=1'b1 ;
        fif.wr<=1'b0 ;
        @(posedge fif.clock);
        fif.rd<=1'b0 ;
        $display("[DRV]:DATA READ");
        @(posedge fif.clock) ;
      endtask 
      
      // applying random stimulus to dut 
      task run() ;
        forever begin
          mbx.get(datac);
          if(datac.oper==1'b1)
          write() ;
          else 
            read();
        end
          endtask 
          
          endclass 
          
  /////////////////////        ///////
   class monitor ;
     virtual fifo_if fif ;
     mailbox #(transaction) mbx ;
     transaction tr ;
     
     function new(mailbox #(transaction) mbx);
       this.mbx=mbx ;
      
     endfunction 
     
     task run() ;
       tr=new();
       forever begin
       repeat(2) @(posedge fif.clock ) ;
       tr.wr=fif.wr ;
       tr.rd=fif.rd ;
       tr.data_in=fif.data_in ;
       tr.full = fif.full ;
       tr.empty=fif.empty ;
       @(posedge fif.clock);
       tr.data_out=fif.data_out ;
       
       mbx.put(tr);
       $display("[MON] :Wr:%0d din:%0d dout:%0d full=%0d empty:%0d",tr.wr,tr.rd,tr.data_in,tr.data_out,tr.full,tr.empty);
       end
     endtask 
     
   endclass 
          
  ////////////////////////////////////
       class scoreboard ;
         mailbox #(transaction) mbx ;
         transaction tr ;
         event next ;
         bit [7:0] din[$] ;
         bit [7:0] temp ;
         int err= 0 ;
         
         function new(mailbox #(transaction) mbx );
           this.mbx=mbx ;
         endfunction
         
         task run() ;
           forever begin
           mbx.get(tr) ;
           $display("[SOC] ::Wr:%0d din:%0d dout:%0d full=%0d empty:%0d",tr.wr,tr.rd,tr.data_in,tr.data_out,tr.full,tr.empty);
           if(tr.wr ==1'b1) begin
             if(tr.full ==1'b0) begin 
               din.push_front(tr.data_in);
               $display("[SOC] DATA STORED IN QUEUE %0d",tr.data_in);
             end
             else begin
 	$display("[SOC] : FIFO is full ") ;
           end
             $display("-------------------");
           end
           
           if(tr.rd==1'b1)begin
             if(tr.empty==1'b0)begin
             temp =din.pop_back();
             
               if(tr.data_out==temp) begin 
                 $display("[SOC]:DATA MATCHED");end
             else begin 
               $display("[SOC]:DATA MISMATCHED");
               err++ ;
             end 
           end
           else begin
             $display("FIFO IS EMPTY") ;
           end
           
           $display("---------------------");
           end
           -> next ;
           end
         endtask 
       endclass
          
          ///////////////////////////////
  class environment ;
            generator gen ;
            driver drv ;
            monitor mon ;
            scoreboard sco ;
            mailbox #(transaction) gdmbx ;
            mailbox #(transaction) msmbx ; 
            event nextgs ;
            virtual fifo_if fif ;
            
    function new(virtual fifo_if fif);
      gdmbx=new() ;
      gen=new(gdmbx) ;
      drv=new(gdmbx) ;
      msmbx=new() ;
      mon=new(msmbx);
      sco=new(msmbx);
      this.fif=fif;
      drv.fif=this.fif;
      mon.fif=this.fif;
      gen.next=this.nextgs ;
      sco.next=this.nextgs;
    endfunction 
    
    task pre_test();
      drv.reset();
    endtask 
    
    task test() ;
      fork 
        gen.run() ;
        drv.run() ;
        mon.run() ;
        sco.run();
      join_any 
    endtask 
    
    task post_test() ;
      wait(gen.done.triggered);
      $display("----------------");
      $display("error count =%0d",sco.err);
      $display("----------------");
      $finish();
    endtask 
    
    task run() ;
      pre_test();
      test() ;
      post_test() ;
    endtask 
    
  endclass 
     
          /////////////////////////////////////

    module tb ;
      fifo_if fif();
      FIFO dut(.clk(fif.clock),.wr(fif.wr),.rd(fif.rd),.din(fif.data_in), .dout(fif.data_out),.empty(fif.empty),.full(fif.full));
      
      initial begin 
        fif.clock = 0;
      end
      
      always #10 fif.clock=~fif.clock ;
      
      environment env ;
      initial begin 
        env=new(fif) ;
        env.gen.count=30 ;
        env.run() ;
      end
      
      initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #2500 $finish; 
      end
      endmodule 
            
            
             
          
                 
        
        
    
      
