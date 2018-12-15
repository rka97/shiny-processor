vsim -gui processor.ram_testbench
mmem load -i C:/Users/User/shiny-processor/ram.mem /ram_testbench/uut/ram
add wave -position insertpoint sim:/ram_testbench/*
run
run
run
run