interface FIFO_if(clk);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
input clk;
logic [FIFO_WIDTH-1:0] data_in;
logic rst_n, wr_en, rd_en;
logic wr_ack, overflow, underflow;
logic [FIFO_WIDTH-1:0] data_out;
logic full, empty, almostfull, almostempty;
event etrigger;
modport DUT (
    input clk, rst_n, wr_en, rd_en, data_in,
    output full, empty, almostfull, almostempty,wr_ack,overflow, underflow, data_out);
modport monitor (
    input clk, rst_n, wr_en, rd_en, data_in, full, empty, almostfull,wr_ack,etrigger,overflow, almostempty, underflow, data_out);
modport TB (
    input clk, full, empty,wr_ack,overflow, almostfull, almostempty, underflow, data_out,
    output rst_n, wr_en, rd_en, data_in,etrigger);
endinterface