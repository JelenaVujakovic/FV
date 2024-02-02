clear -all
analyze -sv09 hanoi.sv
elaborate -top hanoi
clock clk
reset rst
prove -all \
	-orchestration off \
	-engine_mode Tri \
	-per_property_time_limit_factor 0 \
	-per_property_time_limit 12