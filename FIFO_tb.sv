import shared_pkg::*;
import transaction_pkg::*;

module FIFO_tb(FIFO_if.TB fifoif);
 FIFO_transaction trans_test;
 initial begin
    error_count=0;
    correct_count=0;
    test_finished=0;
    trans_test=new();
    repeat(10000)begin 
        assert(trans_test.randomize());
        fifoif.data_in=trans_test.data_in;
        fifoif.rst_n=trans_test.rst_n;
        fifoif.wr_en=trans_test.wr_en;
        fifoif.rd_en=trans_test.rd_en;
         @(negedge fifoif.clk);
        ->fifoif.etrigger;
       end
    test_finished=1;
 end
endmodule