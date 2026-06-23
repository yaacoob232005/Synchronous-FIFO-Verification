vlib work
vlog -f src_files.list  +cover -covercells
vsim -voptargs=+acc work.FIFO_top -cover
add wave /FIFO_top/fifoif/*
coverage save FIFO_top.ucdb -onexit
run -all