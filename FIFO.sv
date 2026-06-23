////////////////////////////////////////////////////////////////////////////////
// Author    : Kareem Waseem
// Course    : Digital Verification using SV & UVM
// Description: FIFO RTL Design with Assertions & Cover Properties
////////////////////////////////////////////////////////////////////////////////

module FIFO(FIFO_if.DUT fifoif);

// =====================================================
// PARAMETERS & LOCAL CONSTANTS
// =====================================================
parameter FIFO_WIDTH = 16;          // Data bus width
parameter FIFO_DEPTH = 8;           // FIFO depth
localparam max_fifo_addr = $clog2(FIFO_DEPTH); // Address width for pointers

// =====================================================
// INTERNAL SIGNALS
// =====================================================
logic [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];   // FIFO storage memory
logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;      // Write & read pointers
logic [max_fifo_addr:0]   count;               // FIFO element counter

// =====================================================
// WRITE LOGIC
// =====================================================
always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
	if (!fifoif.rst_n) begin
		wr_ptr <= 0;
		fifoif.wr_ack <= 0;
		fifoif.overflow <= 0;
	end
	else if (fifoif.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= fifoif.data_in; // Write data to memory
		fifoif.wr_ack <= 1;             // Acknowledge write
		wr_ptr <= wr_ptr + 1;           // Increment write pointer
	end
	else begin
		fifoif.wr_ack <= 0; 
		if (fifoif.full && fifoif.wr_en)
			fifoif.overflow <= 1;       // Overflow if write attempted on full FIFO
		else
			fifoif.overflow <= 0;
	end
end

// =====================================================
// READ LOGIC
// =====================================================
always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
	if (!fifoif.rst_n) begin
		rd_ptr <= 0;
		fifoif.wr_ack <= 0;
		fifoif.underflow <= 0;
	end
	else if (fifoif.rd_en && count != 0) begin
		fifoif.data_out <= mem[rd_ptr]; // Read data from memory
		rd_ptr <= rd_ptr + 1;           // Increment read pointer
	end
	else begin
		if (fifoif.empty && fifoif.rd_en)
			fifoif.underflow <= 1;       // Underflow if read attempted on empty FIFO
		else
			fifoif.underflow <= 0;
	end
end

// =====================================================
// COUNTER UPDATE LOGIC
// =====================================================
always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
	if (!fifoif.rst_n) begin
		count <= 0;
	end
	else begin
		// Write only
		if ({fifoif.wr_en, fifoif.rd_en} == 2'b10 && !fifoif.full)
			count <= count + 1;
		// Read only
		else if ({fifoif.wr_en, fifoif.rd_en} == 2'b01 && !fifoif.empty)
			count <= count - 1;
		// Simultaneous write & read when FIFO empty (increase count)
		else if ({fifoif.wr_en, fifoif.rd_en} == 2'b11 && fifoif.empty)
			count <= count + 1;
		// Simultaneous write & read when FIFO full (decrease count)
		else if ({fifoif.wr_en, fifoif.rd_en} == 2'b11 && fifoif.full)
			count <= count - 1;
	end
end

// =====================================================
// STATUS FLAGS
// =====================================================
assign fifoif.full        = (count == FIFO_DEPTH);
assign fifoif.empty       = (count == 0);
assign fifoif.almostfull  = (count == FIFO_DEPTH-1);
assign fifoif.almostempty = (count == 1);

// =====================================================
// ASSERTION PROPERTIES
// =====================================================

// 1. Reset behavior
property Reset_Behavior;
	@(posedge fifoif.clk) !fifoif.rst_n |-> (!wr_ptr && !rd_ptr && !count);
endproperty

// 2. Write acknowledge
property Write_Acknowledge;
	@(posedge fifoif.clk) disable iff(!fifoif.rst_n)
		(fifoif.wr_en && !fifoif.full) |=> fifoif.wr_ack;
endproperty

// 3. Overflow detection
property Overflow_Detection;
	@(posedge fifoif.clk) disable iff(!fifoif.rst_n)
		(fifoif.full && fifoif.wr_en) |=> fifoif.overflow;
endproperty

// 4. Underflow detection
property Underflow_Detection;
	@(posedge fifoif.clk) disable iff(!fifoif.rst_n)
		(fifoif.empty && fifoif.rd_en) |=> fifoif.underflow;
endproperty

// 5. Empty flag correctness
property Empty_Flag;
	@(posedge fifoif.clk) disable iff(!fifoif.rst_n)
		(count == 0) |-> fifoif.empty;
endproperty

// 6. Full flag correctness
property Full_Flag;
	@(posedge fifoif.clk) disable iff(!fifoif.rst_n)
		(count == FIFO_DEPTH) |-> fifoif.full;
endproperty

// 7. Almost full correctness
property Almost_Full;
	@(posedge fifoif.clk) disable iff(!fifoif.rst_n)
		(count == FIFO_DEPTH-1) |-> fifoif.almostfull;
endproperty

// 8. Almost empty correctness
property Almost_empty;
	@(posedge fifoif.clk) disable iff(!fifoif.rst_n)
		(count == 1) |-> fifoif.almostempty;
endproperty

// 9. Pointer wraparound for write pointer
property Pointer_Wraparound_write;
	@(posedge fifoif.clk) disable iff (!fifoif.rst_n)
		((wr_ptr == FIFO_DEPTH-1) && fifoif.wr_en && !fifoif.full) |=> !wr_ptr[->1];
endproperty

// 10. Pointer wraparound for read pointer
property Pointer_Wraparound_read;
	@(posedge fifoif.clk) disable iff (!fifoif.rst_n)
		((rd_ptr == FIFO_DEPTH-1) && fifoif.rd_en && !fifoif.empty) |=> !rd_ptr[->1];
endproperty

// 11. Pointer & count threshold
property Pointer_threshold;
	@(posedge fifoif.clk) disable iff(!fifoif.rst_n)
		##5 (count <= FIFO_DEPTH) && (wr_ptr <= FIFO_DEPTH) && (rd_ptr <= FIFO_DEPTH);
endproperty

// =====================================================
// ASSERT & COVER INSTANTIATION
// =====================================================
assert property(Reset_Behavior);
assert property(Write_Acknowledge);
assert property(Overflow_Detection);
assert property(Underflow_Detection);
assert property(Empty_Flag);
assert property(Full_Flag);
assert property(Almost_Full);
assert property(Almost_empty);
assert property(Pointer_Wraparound_write);
assert property(Pointer_Wraparound_read);
assert property(Pointer_threshold);

cover property(Reset_Behavior);
cover property(Write_Acknowledge);
cover property(Overflow_Detection);
cover property(Underflow_Detection);
cover property(Empty_Flag);
cover property(Full_Flag);
cover property(Almost_Full);
cover property(Almost_empty);
cover property(Pointer_Wraparound_write);
cover property(Pointer_Wraparound_read);
cover property(Pointer_threshold);

// =====================================================
// EXTRA ASSERTIONS (active only in simulation)
// =====================================================
`ifdef SIM

// Full flag check
always @(posedge fifoif.clk) begin
	if (!fifoif.rst_n) disable full_flag_check;
	else full_flag_check: assert (fifoif.full == (count == FIFO_DEPTH))
		else $error("full flag mismatch: full=%0b, count=%0d", fifoif.full, count);
end

// Empty flag check
always @(posedge fifoif.clk) begin
	if (!fifoif.rst_n) disable empty_flag_check;
	else empty_flag_check: assert (fifoif.empty == (count == 0))
		else $error("empty flag mismatch: empty=%0b, count=%0d", fifoif.empty, count);
end

// Almost full check
always @(posedge fifoif.clk) begin
	if (!fifoif.rst_n) disable almostfull_flag_check;
	else almostfull_flag_check: assert (fifoif.almostfull == (count == FIFO_DEPTH-1))
		else $error("almostfull flag mismatch: almostfull=%0b, count=%0d", fifoif.almostfull, count);
end

// Almost empty check
always @(posedge fifoif.clk) begin
	if (!fifoif.rst_n) disable almostempty_flag_check;
	else almostempty_flag_check: assert (fifoif.almostempty == (count == 1))
		else $error("almostempty flag mismatch: almostempty=%0b, count=%0d", fifoif.almostempty, count);
end

// Underflow check
always @(posedge fifoif.clk) begin
	if (!fifoif.rst_n) disable underflow_flag_check;
	else underflow_flag_check: assert (fifoif.underflow == (fifoif.empty && fifoif.rd_en))
		else $error("underflow flag mismatch: underflow=%0b, empty=%0b, rd_en=%0b", fifoif.underflow, fifoif.empty, fifoif.rd_en);
end

// Count should never exceed FIFO depth
always @(posedge fifoif.clk) begin
	if (!fifoif.rst_n) disable count_range_check;
	else count_range_check: assert (count <= FIFO_DEPTH)
		else $error("count exceeded FIFO_DEPTH: count=%0d", count);
end

// Count should never go negative
always @(posedge fifoif.clk) begin
	if (!fifoif.rst_n) disable count_nonneg_check;
	else count_nonneg_check: assert (count >= 0)
		else $error("count negative: count=%0d", count);
end

`endif

endmodule
