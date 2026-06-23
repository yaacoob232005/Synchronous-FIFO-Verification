import shared_pkg::*;
import transaction_pkg::*;
import coverage_pkg::*;
import scoreboard_pkg::*;
module FIFO_monitor(FIFO_if.monitor fifoif);
FIFO_transaction trans;
FIFO_coverage cov;
FIFO_scoreboard sb;
initial begin 
    trans=new();
    cov=new();
    sb=new();
    forever begin 
        wait(fifoif.etrigger.triggered);
        @(negedge fifoif.clk);
        trans.data_in= fifoif.data_in;
        trans.rst_n=fifoif.rst_n;
       trans.wr_en= fifoif.wr_en;
        trans.rd_en=fifoif.rd_en;
        trans.data_out=fifoif.data_out;
       trans.wr_ack= fifoif.wr_ack;
        trans.overflow=fifoif.overflow;
        trans.underflow=fifoif.underflow;
        trans.full=fifoif.full;
        trans.empty=fifoif.empty;
        trans.almostfull=fifoif.almostfull;
        trans.almostempty=fifoif.almostempty;
        fork
        begin
             cov.sample_data(trans); 
        end
        begin 
           sb.check_data(trans);
        end
    join
    
    if(test_finished)begin 
        $display("errors=%d,correct=%d",error_count,correct_count);
        $stop;
    end
    end
    
end  
endmodule : FIFO_monitor