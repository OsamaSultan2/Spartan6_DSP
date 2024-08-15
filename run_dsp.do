vlib work
vlog flipflop.v DSP.v DSP_tb.v
vsim -voptargs=+acc work.DSP_tb
add wave *
run -all