vsim -gui processor.ram(mixed_ram)
add wave -position insertpoint  \
sim:/ram/address \
sim:/ram/clk \
sim:/ram/datain \
sim:/ram/dataout \
sim:/ram/n \
sim:/ram/ram \
sim:/ram/we
mem load -i C:/Users/User/shiny-processor/ram.mem /ram/ram
mem load -skip 0 -filltype inc -filldata 0 -fillradix symbolic /ram/ram
force -freeze sim:/ram/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/ram/address 0000000001 0
run
force -freeze sim:/ram/we 0 0
run
force -freeze sim:/ram/datain 11111111111111111111111111111111 0
force -freeze sim:/ram/we 1 0
run
run
run
run