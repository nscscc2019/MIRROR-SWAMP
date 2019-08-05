`timescale 1ns / 1ps
module icache_data
(
    input          clk,
    input          rst,
    input          en,
    input          wen,
    input   [31:0] wdata,
    input   [31:0] addr,
    output  [31:0] rdata
);

icache_data_ram icache_data_ram_u
(
    .clka  (clk            ),   
//    .rsta   (rst        ),
    .ena   (en        ),
    .wea   (wen       ),   //3:0 //TBD
    .addra (addr[11:5]),   //17:0
    .dina  (wdata     ),   //31:0
    .douta (rdata     )    //31:0
);

//reg [31:0] data[127:0];
//reg [31:0]data_out;

//always@(posedge clk)
//begin
//    if(wen)
//    begin
//        data[addr[11:5]] <= wdata;
//    end
//end

//always@(posedge clk)
//begin
//    if(rst)
//    begin
//        data_out <= 32'd0;
//    end
//    else
//    begin
//        data_out <= data[addr[11:5]];
//    end
//end

//assign rdata = data_out;


endmodule