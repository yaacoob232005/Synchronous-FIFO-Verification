package scoreboard_pkg;
import transaction_pkg::*;
import shared_pkg::*;
bit [FIFO_WIDTH-1:0] data_out_ref;
bit [FIFO_WIDTH-1:0] mem_ref[FIFO_DEPTH-1:0];
bit [2:0] write_ptr_ref, read_ptr_ref;
int count;
bit full_ref, empty_ref, almostfull_ref, almostempty_ref;
bit wr_ack_ref, overflow_ref, underflow_ref;

class FIFO_scoreboard;
task reference_model(FIFO_transaction F_scr_txn2 );
    // Simple reference model logic for FIFO
    if (F_scr_txn2.rst_n == 0) begin
        full_ref = 0;
        empty_ref = 1;
        wr_ack_ref = 0;
        overflow_ref = 0;
        underflow_ref = 0;
        write_ptr_ref = 0;
        read_ptr_ref = 0;
        count = 0;
    end else begin
        if (F_scr_txn2.wr_en && !full_ref && count < FIFO_DEPTH) begin
            // Simulate write operation
            wr_ack_ref = 1;
            empty_ref = 0;
            mem_ref[write_ptr_ref]=  F_scr_txn2.data_in; // Store data in reference memory
            write_ptr_ref = write_ptr_ref + 1;
            count++;
            if (count==FIFO_DEPTH-1) begin
                almostfull_ref = 1;
            end
            if (count==FIFO_DEPTH) begin
                full_ref = 1;
            end
        end else begin
            wr_ack_ref = 0;
            if (F_scr_txn2.wr_en && full_ref) begin
                overflow_ref = 1; // Overflow condition
            end else begin
                overflow_ref = 0;
            end
        end

        if (F_scr_txn2.rd_en && count !=0) begin
            // Simulate read operation
            data_out_ref =mem_ref[read_ptr_ref]; // Read data from reference memory;
            read_ptr_ref = read_ptr_ref + 1;
            count--;
            if (count==1) begin
                almostempty_ref = 1;
            end
            if (count==0) begin
                empty_ref = 1;
            end
        end else begin
            if (F_scr_txn2.rd_en && empty_ref) begin
                underflow_ref = 1; // Underflow condition
            end else begin
                underflow_ref = 0;
            end
        end
        if(F_scr_txn2.rd_en && F_scr_txn2.wr_en && !full_ref)begin
            wr_ack_ref = 1;
            empty_ref = 0;
            mem_ref[write_ptr_ref]=  F_scr_txn2.data_in; // Store data in reference memory
            write_ptr_ref = write_ptr_ref + 1;
            count++;
end else if(F_scr_txn2.rd_en && F_scr_txn2.wr_en && !empty_ref) begin
            data_out_ref =mem_ref[read_ptr_ref]; // Read data from reference memory;
            read_ptr_ref = read_ptr_ref + 1;
            count--;
end else if(F_scr_txn2.rd_en && F_scr_txn2.wr_en && empty_ref) begin
             wr_ack_ref = 1;
            empty_ref = 0;
            mem_ref[write_ptr_ref]=  F_scr_txn2.data_in; // Store data in reference memory
            write_ptr_ref = write_ptr_ref + 1;
            count++;
end else if(F_scr_txn2.rd_en && F_scr_txn2.wr_en && full_ref)begin
             data_out_ref =mem_ref[read_ptr_ref]; // Read data from reference memory;
            read_ptr_ref = read_ptr_ref + 1;
            count--;
end
    end 
endtask
task check_data(FIFO_transaction F_scr_txn);
        reference_model(F_scr_txn);
    if ((F_scr_txn.data_out !== data_out_ref) &&
            (F_scr_txn.full !== full_ref) &&
            (F_scr_txn.empty !== empty_ref) &&
            (F_scr_txn.almostfull !== almostfull_ref) &&
            (F_scr_txn.almostempty !== almostempty_ref) &&
            (F_scr_txn.wr_ack !== wr_ack_ref) &&
            (F_scr_txn.overflow !== overflow_ref) &&
            (F_scr_txn.underflow !== underflow_ref)) begin
            error_count++;
            $display("SCOREBOARD ERROR at time %0t: Expected: data_out=%0h, full=%0b, empty=%0b, almostfull=%0b, almostempty=%0b, wr_ack=%0b, overflow=%0b, underflow=%0b | Got: data_out=%0h, full=%0b, empty=%0b, almostfull=%0b, almostempty=%0b, wr_ack=%0b, overflow=%0b, underflow=%0b",
                $time, data_out_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, wr_ack_ref, overflow_ref, underflow_ref,
                F_scr_txn.data_out, F_scr_txn.full, F_scr_txn.empty, F_scr_txn.almostfull, F_scr_txn.almostempty, F_scr_txn.wr_ack, F_scr_txn.overflow, F_scr_txn.underflow);
        end else begin
            correct_count++;
        end
   endtask
endclass : FIFO_scoreboard

endpackage : scoreboard_pkg