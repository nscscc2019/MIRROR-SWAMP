// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module dcache_data_ram(clka, ena, wea, addra, dina, douta);
  input clka;
  input ena;
  input [3:0]wea;
  input [6:0]addra;
  input [31:0]dina;
  output [31:0]douta;
endmodule
