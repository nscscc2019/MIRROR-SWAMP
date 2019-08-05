// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Mon Mar 20 10:31:38 2017
// Host        : PC-201602280044 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               F:/archlab_nand_20170317/archlab_build/archlab_build.srcs/sources_1/ip/sram_128x22/sram_128x22_stub.v
// Design      : sram_128x22
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_2,Vivado 2015.2" *)
module sram_128x22(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[6:0],dina[21:0],douta[21:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [6:0]addra;
  input [21:0]dina;
  output [21:0]douta;
endmodule
