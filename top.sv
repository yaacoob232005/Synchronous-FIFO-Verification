module FIFO_top();
bit clk;
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
FIFO_if fifoif(clk);
FIFO DUT(fifoif);
FIFO_tb tb(fifoif);
FIFO_monitor monitor(fifoif);
endmodule : FIFO_top