// Code your design here
module FIFO (
  input clk ,rst,wr,rd ,
  input [7:0] din ,
  output reg [7:0] dout ,
  output full, empty );
  
  reg [7:0] mem [15:0] ;
  
  reg [3:0] wptr=4'b0 , rptr=4'b0 ;
  reg [4:0] cnt = 0 ;
  
  always@(posedge clk) begin 
    if(rst) begin
      wptr<=0 ;
      rptr<=0;
      cnt<=0;
    end
    else if(wr && !full) begin
      mem[wptr]<=din ;
      wptr=wptr+1 ;
      cnt<=cnt+1 ;
    end
    
    else if(rd && !empty) begin
      dout<=mem[rptr] ;
      rptr<=rptr+1 ;
      cnt<=cnt-1;
    end
  end
  
  assign empty =(cnt==0)?1:0 ;
  assign full = (cnt==16)?1:0 ;
endmodule
  
interface fifo_if ;
  logic clock ,rd,wr ;
  logic full ,empty ;
  logic [7:0] data_in ;
  logic [7:0] data_out ;
  logic rst ;
  
endinterface 
