#Define Source Folders
SRC1="/home/smoreno/adaptive-filter/design"

#Compilation
xmvlog -64bit -sv "$SRC1/adaptive_filter.sv" "$SRC1/direct_fir.sv" "$SRC1/fadd.sv" "$SRC1/fixed_point_converter.sv" "$SRC1/fmult.sv" "$SRC1/lms.sv" "$SRC1/tapped_delay_line.sv" "$SRC1/transposed_fir.sv" 
