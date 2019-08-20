`timescale 1ns / 1ps
module store_buffer
(
    input          clk,
    input          resetn,

    input          cpu_data_req    ,
    input          cpu_data_wr     ,
    input   [1 :0] cpu_data_size   ,
    input   [31:0] cpu_data_addr   ,
    input   [31:0] cpu_data_wdata  ,
	input   [3 :0] cpu_data_wstrb  ,
    output  [31:0] cpu_data_rdata  ,
    output         cpu_data_addr_ok,
    output         cpu_data_data_ok,

    output          dcache_data_req    ,
    output          dcache_data_wr     ,
    output   [1 :0] dcache_data_size   ,
    output   [31:0] dcache_data_addr   ,
    output   [31:0] dcache_data_wdata  ,
	output   [3 :0] dcache_data_wstrb  ,
    input    [31:0] dcache_data_rdata  ,
    input           dcache_data_addr_ok,
    input           dcache_data_data_ok,
);

wire rst;
assign rst = !resetn;

assign dcache_data_req      = valid ? 1'b0 : cpu_data_req;
assign dcache_data_wr       = cpu_data_wr;
assign dcache_data_wstrb    = cpu_data_wstrb;
assign dcache_data_size     = cpu_data_size;
assign dcache_data_wdata    = cpu_data_wdata;
assign dcache_data_addr     = cpu_data_addr;


assign cpu_data_rdata       = dcache_data_rdata;
assign cpu_data_addr_ok     = dcache_data_addr_ok;
assign cpu_data_data_ok     = (valid && !valid_history) ? 1'b1 : (dcache_data_data_ok & !valid);

reg         valid;
reg         valid_history;
reg[31:0]   tag;
reg[31:0]   content;

always @(posedge clk)
	begin
		if(rst)
		begin
			valid <= 1'b0;
		end
		else if(dcache_data_addr_ok && cpu_data_wr) 
		begin
			valid <= 1'b1;
		end
        else if(dcache_data_data_ok) 
		begin
			valid <= 1'b0;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			valid_history <= 1'b0;
		end
        else
		begin
			valid_history <= valid;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			tag <= 32'b0;
		end
		else if(dcache_data_addr_ok && cpu_data_wr) 
		begin
			tag <= cpu_data_addr;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			content <= 32'b0;
		end
		else if(dcache_data_addr_ok && cpu_data_wr) 
		begin
			content <= cpu_data_wdata;
		end
	end

endmodule