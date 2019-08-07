// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Aug  6 21:12:04 2019
// Host        : AW-MECH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/workpath/nscscc2019_ucas_llcw_final/project/Final_Submission/performance/soc_axi_perf/rtl/myCPU/cache/icache_data_ram/icache_data_ram2_stub.v
// Design      : icache_data_ram2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_12,Vivado 2018.3" *)
module icache_data_ram2(a, d, clk, we, spo)
/* synthesis syn_black_box black_box_pad_pin="a[6:0],d[31:0],clk,we,spo[31:0]" */;
  input [6:0]a;
  input [31:0]d;
  input clk;
  input we;
  output [31:0]spo;
endmodule
