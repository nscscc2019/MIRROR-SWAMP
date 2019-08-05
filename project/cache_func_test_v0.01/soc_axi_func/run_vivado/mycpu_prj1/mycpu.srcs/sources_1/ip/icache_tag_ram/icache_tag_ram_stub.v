// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon Jul  8 20:27:11 2019
// Host        : AW-MECH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/workpath/nscscc2019_ucas_llcw/project/cache_func_test_v0.01/soc_axi_func/run_vivado/mycpu_prj1/mycpu.srcs/sources_1/ip/icache_tag_ram/icache_tag_ram_stub.v
// Design      : icache_tag_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module icache_tag_ram(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[6:0],dina[20:0],douta[20:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [6:0]addra;
  input [20:0]dina;
  output [20:0]douta;
endmodule
