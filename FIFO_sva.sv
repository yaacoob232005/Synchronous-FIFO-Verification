module FIFO_sva #(parameter FIFO_DEPTH=8, FIFO_WIDTH=16, parameter max_fifo_addr=$clog2(FIFO_DEPTH))
(
    FIFO_if.DUT fifoif,
    input logic [max_fifo_addr:0] count,
    input logic [max_fifo_addr-1:0] wr_ptr,
    input logic [max_fifo_addr-1:0] rd_ptr
);


//1
property Reset_Behavior;
@(posedge fifoif.clk) !fifoif.rst_n |-> (!wr_ptr && !rd_ptr && !count)
endproperty
assert property(Reset_Behavior);
cover property(Reset_Behavior);
//2
property Write_Acknowledge;
@(posedge fifoif.clk) disable iff(!fifoif.rst_n) (fifoif.wr_en && !fifoif.full) |-> fifoif.wr_ack;
endproperty
assert property(Write_Acknowledge);
cover property(Write_Acknowledge);
//3
property Overflow_Detection;
@(posedge fifoif.clk) disable iff(!fifoif.rst_n) (fifoif.full && fifoif.wr_en) |-> fifoif.overflow;
endproperty
assert property(Overflow_Detection);
cover property(Overflow_Detection);
//4
property Underflow_Detection;
@(posedge fifoif.clk) disable iff(!fifoif.rst_n) (fifoif.empty && fifoif.rd_en) |-> fifoif.underflow;
endproperty
assert property(Underflow_Detection);
cover property(Underflow_Detection);
//5
property Empty_Flag;
@(posedge fifoif.clk) disable iff(!fifoif.rst_n) (count == 0) |-> fifoif.empty;
endproperty
assert property(Empty_Flag);
cover property(Empty_Flag);
//6
property Full_Flag;
@(posedge fifoif.clk) disable iff(!fifoif.rst_n) (count==FIFO_DEPTH) |-> fifoif.full;
endproperty
assert property(Full_Flag);
cover property(Full_Flag);
//7
property Almost_Full;
@(posedge fifoif.clk) disable iff(!fifoif.rst_n) (count==FIFO_DEPTH-1) |-> fifoif.almostfull;
endproperty
assert property (Almost_Full);
cover property(Almost_Full);
//8
property Almost_empty;
@(posedge fifoif.clk) disable iff(!fifoif.rst_n) (count==1) |-> fifoif.almostempty;
endproperty
assert property(Almost_empty);
cover property(Almost_empty);
//9
property Pointer_Wraparound_write;
@(posedge fifoif.clk)
disable iff (!fifoif.rst_n)
((wr_ptr == FIFO_DEPTH-1) && fifoif.wr_en && !fifoif.full) |-> !wr_ptr[->1];
endproperty
assert property(Pointer_Wraparound_write);
cover property(Pointer_Wraparound_write);
//10
property Pointer_Wraparound_read;
@(posedge fifoif.clk)
disable iff (!fifoif.rst_n)
((rd_ptr == FIFO_DEPTH-1) && fifoif.rd_en && !fifoif.empty) |=> !rd_ptr [->1] ;
endproperty
assert property(Pointer_Wraparound_read);
cover property(Pointer_Wraparound_read);
//11
property Pointer_threshold;
@(posedge fifoif.clk) disable iff(!fifoif.rst_n) 
(count <= FIFO_DEPTH) && (wr_ptr < FIFO_DEPTH)&& (rd_ptr < FIFO_DEPTH);
endproperty
assert property(Pointer_threshold);
cover property(Pointer_threshold);
endmodule : FIFO_sva