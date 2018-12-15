vsim -gui processor.reg_file(structural)
mem load -i C:/Users/User/shiny-processor/ram.mem /reg_file/ram/ram
add wave -position insertpoint  \
sim:/reg_file/address \
sim:/reg_file/clk \
sim:/reg_file/mem_clk \
sim:/reg_file/data_1 \
sim:/reg_file/data_2 \
sim:/reg_file/decoded_dst_sel \
sim:/reg_file/decoded_src_sel \
sim:/reg_file/dst_en \
sim:/reg_file/dst_sel \
sim:/reg_file/mar_data_out \
sim:/reg_file/mdr_data_in \
sim:/reg_file/mdr_data_out \
sim:/reg_file/mdr_force_in \
sim:/reg_file/n \
sim:/reg_file/num_reg \
sim:/reg_file/src_en \
sim:/reg_file/src_sel \
sim:/reg_file/write_en
force -freeze sim:/reg_file/data_1 0000AAAA 0
force -freeze sim:/reg_file/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/reg_file/mem_clk 0 0, 1 {50 ps} -r 100
run
run
force -freeze sim:/reg_file/mdr_force_in 1 0
run
run
force -freeze sim:/reg_file/dst_en 1 0
force -freeze sim:/reg_file/dst_sel 000001 0
run
run
force -freeze sim:/reg_file/mar_data_out 00000151 0
run
run
force -freeze sim:/reg_file/mar_data_out 00000100 0
run
run
run
force -freeze sim:/reg_file/mar_data_out 00000111 0
run
run
run

