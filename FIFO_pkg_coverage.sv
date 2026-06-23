package coverage_pkg;
  import transaction_pkg::*;
  class FIFO_coverage;
    FIFO_transaction F_cvg_txn;
//covergroups
    covergroup FIFO_cvg_grp();
      write_enable_cp : coverpoint F_cvg_txn.wr_en{
        bins one_wr_en={1};
        bins zero_wr_en={0};
      }
      read_enable_cp : coverpoint F_cvg_txn.rd_en{
        bins one_rd_en={1};
        bins zero_rd_en={0};
      }
      full_cp : coverpoint F_cvg_txn.full{
        bins one_full={1};
        bins zero_full={0};
      }
      empty_cp: coverpoint F_cvg_txn.empty{
        bins one_empty={1};
        bins zero_empty={0};
      }
      almost_full_cp : coverpoint F_cvg_txn.almostfull{
        bins one_almostfull={1};
        bins zero_almostfull={0};
      }
      almost_empty_cp: coverpoint F_cvg_txn.almostempty{
        bins one_almostempty={1};
        bins zero_almostempty={0};
      }
      overflow_cp: coverpoint F_cvg_txn.overflow{
        bins one_overflow={1};
        bins zero_overflow={0};
      }
      underflow_cp: coverpoint F_cvg_txn.underflow{
        bins one_underflow={1};
        bins zero_underflow={0};
      }
      wr_ack_cp: coverpoint F_cvg_txn.wr_ack{
        bins one_wr_ack={1};
        bins zero_wr_ack={0};
      }
// Crosses
      
      wr_rd_full_cross       : cross write_enable_cp, read_enable_cp, full_cp{
        ignore_bins full_0=binsof(write_enable_cp.zero_wr_en)&&binsof(read_enable_cp.one_rd_en)&&binsof(full_cp.one_full);
        ignore_bins full_1=binsof(write_enable_cp.one_wr_en)&&binsof(read_enable_cp.one_rd_en)&&binsof(full_cp.one_full);
      }
      wr_rd_empty_cross      : cross write_enable_cp, read_enable_cp, empty_cp;
      wr_rd_almost_full_cross: cross write_enable_cp, read_enable_cp, almost_full_cp;
      wr_rd_almost_empty_cross: cross write_enable_cp, read_enable_cp, almost_empty_cp;
      wr_rd_overflow_cross   : cross write_enable_cp, read_enable_cp, overflow_cp{
        ignore_bins ov_0=binsof(write_enable_cp.zero_wr_en)&&binsof(read_enable_cp.one_rd_en)&&binsof(overflow_cp.one_overflow);
        ignore_bins ov_1=binsof(write_enable_cp.zero_wr_en)&&binsof(read_enable_cp.zero_rd_en)&&binsof(overflow_cp.one_overflow);
      }
      wr_rd_underflow_cross  : cross write_enable_cp, read_enable_cp, underflow_cp{
        ignore_bins under_0=binsof(write_enable_cp.one_wr_en)&&binsof(read_enable_cp.zero_rd_en)&&binsof(underflow_cp.one_underflow);
        ignore_bins under_1=binsof(write_enable_cp.zero_wr_en)&&binsof(read_enable_cp.zero_rd_en)&&binsof(underflow_cp.one_underflow);
      }
      wr_rd_wrack_cross      : cross write_enable_cp, read_enable_cp, wr_ack_cp{
        ignore_bins wrack_0=binsof(write_enable_cp.zero_wr_en)&&binsof(read_enable_cp.zero_rd_en)&&binsof(wr_ack_cp.one_wr_ack);
        ignore_bins wrack_1=binsof(write_enable_cp.zero_wr_en)&&binsof(read_enable_cp.one_rd_en)&&binsof(wr_ack_cp.one_wr_ack);
      }
    endgroup : FIFO_cvg_grp

// constructor
    function new();
      F_cvg_txn = new();
      FIFO_cvg_grp= new();
    endfunction

    function void sample_data(FIFO_transaction F_txn);
      F_cvg_txn = F_txn;
      FIFO_cvg_grp.sample();
    endfunction
  endclass : FIFO_coverage
endpackage : coverage_pkg
