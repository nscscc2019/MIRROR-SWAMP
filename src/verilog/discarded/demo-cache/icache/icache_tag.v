`timescale 1ns / 1ps
module icache_tag
(
    input         clk,
    input         rst,
    input    [3:0] wen,
    input         en,
    input   [20:0] wdata,
    output  [20:0] rdata,

    input   [31:0] addr,        //input desired address to check whether hit
    output         hit,         //whether hit?
    output         valid
);

assign hit = (rdata[19:0] == addr[31:12]) ? 1'b1 : 1'b0;
assign valid = rdata[20];


icache_tag_ram icache_tag_ram_u
(
    .clka  (clk            ),   
//    .rsta   (rst        ),
    .ena   (en        ),
    .wea   (wen       ),   //3:0 //TBD
    .addra (addr[11:5]),   //17:0
    .dina  (wdata     ),   //31:0
    .douta (rdata     )    //31:0
);


endmodule