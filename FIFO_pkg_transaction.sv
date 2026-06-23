package transaction_pkg;
import shared_pkg::*;
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
class FIFO_transaction;
rand bit [FIFO_WIDTH-1:0] data_in;
rand bit rst_n, wr_en, rd_en;
bit [FIFO_WIDTH-1:0] data_out;
bit wr_ack, overflow;
bit full, empty, almostfull, almostempty, underflow;
int RD_EN_ON_DIST, WR_EN_ON_DIST;

//constructor
function new(int RD_EN_ON_DIST=30, int WR_EN_ON_DIST=70);
    this.RD_EN_ON_DIST = RD_EN_ON_DIST;
    this.WR_EN_ON_DIST = WR_EN_ON_DIST;
endfunction : new

//constraints
constraint c_rst_n {rst_n dist {0:=5,1:=95}; }
constraint c_wr_en {wr_en dist {0:=100-WR_EN_ON_DIST,1:=WR_EN_ON_DIST}; }
constraint c_rd_en {rd_en dist {0:=100-RD_EN_ON_DIST,1:=RD_EN_ON_DIST};}

endclass : FIFO_transaction
endpackage :transaction_pkg
