`timescale 1ns / 1ps
module icache_tag
(
    input         clk,
    input         rst,
    input         en,
    input    [3:0] wen,
    input   [20:0] wdata,
    output  [20:0] rdata,

    input   [31:0] addr,        //input desired address to check whether hit
    output         hit,         //whether hit?
    output         valid
);

reg [31:0] addr_reg;
always @(posedge clk)
	begin
		if(rst)
		begin
			addr_reg <= 32'b0;
		end
		else
		begin
			addr_reg <= addr;
		end
	end

assign hit = (rdata[19:0] == addr_reg[31:12]) ? 1'b1 : 1'b0;
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