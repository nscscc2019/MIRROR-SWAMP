`timescale 1ns / 1ps
module dcache
(
    ////basic
    input         clk,
    input         resetn,

    ////axi_control
    //ar
    output  [3 :0] arid   ,
    output  [31:0] araddr,
    output  [7 :0] arlen  ,
    output  [2 :0] arsize ,
    output  [1 :0] arburst,
    output  [1 :0] arlock ,
    output  [3 :0] arcache,
    output  [2 :0] arprot ,
    output         arvalid,
    input          arready,
    //r
    input [3 :0] rid    ,
    input [31:0] rdata  ,
    input [1 :0] rresp ,
    input        rlast ,
    input        rvalid ,
    output       rready ,
    //aw
    output  [3 :0] awid   ,
    output  [31:0] awaddr ,
    output  [7 :0] awlen  ,
    output  [2 :0] awsize ,
    output  [1 :0] awburst,
    output  [1 :0] awlock ,
    output  [3 :0] awcache,
    output  [2 :0] awprot ,
    output         awvalid,
    input          awready,
    //w
    output  [3 :0] wid    ,
    output  [31:0] wdata  ,
    output  [3 :0] wstrb  ,
    output         wlast  ,
    output         wvalid ,
    input          wready ,
    //b
    input [3 :0] bid    ,
    input [1 :0] bresp  ,
    input        bvalid ,
    output       bready ,

    ////cpu_control
    //------inst sram-like-------
    input          data_req    ,
    input          data_wr     ,
    input   [1 :0] data_size   ,
    input   [31:0] data_addr   ,
    input   [31:0] data_wdata  ,
	input   [3 :0] data_wstrb  ,
    output  [31:0] data_rdata  ,
    output         data_addr_ok,
    output         data_data_ok

);

wire rst;
assign rst = !resetn;

////hit and valid
//hit
wire    hit_0;
wire    hit_1;
wire    valid_0;
wire    valid_1;
wire 	tag_0_en;
wire    tag_1_en;
wire    [31:0] ram_wdata;

wire    [31:0] data_addr_input;
assign  data_addr_input = (work_state == 4'b0000) ? data_addr : data_addr_reg;

wire [20:0]   tag_rdata_0;
wire [20:0]   tag_rdata_1;
wire [20:0]   tag_rdata;

icache_tag tag_0(clk,rst,1'b1,{4{tag_0_en}},{1'b1,data_addr_input[31:12]},tag_rdata_0,data_addr_input,hit_0,valid_0);
icache_tag tag_1(clk,rst,1'b1,{4{tag_1_en}},{1'b1,data_addr_input[31:12]},tag_rdata_1,data_addr_input,hit_1,valid_1);

wire    hit;
assign  hit = hit_0 | hit_1;

//valid
wire    succeed_0;
wire    succeed_1;
wire    succeed;
reg     succeed_ack;

assign succeed_0    = hit_0 & valid_0; //if hit and  if valid
assign succeed_1    = hit_1 & valid_1;
assign succeed      = succeed_0 | succeed_1;
always @(posedge clk)
	begin
		if(rst)
		begin
			succeed_ack <= 1'b0;
		end
		else if((work_state == 4'b0000) || (work_state == 4'b0010))
		begin
			succeed_ack <= succeed_0 | succeed_1;
		end
	end


////data access
wire    [19:0] tag;
wire    [6:0]  index;
wire    [4:0]  offset;

reg   [3 :0] data_wstrb_reg; 
wire  [3 :0] data_wstrb_input;

assign  data_wstrb_input = (work_state == 4'b0011) ? 4'b1111 : data_wstrb_reg;

assign  tag     = data_addr_reg[31:12];
assign  index   = data_addr_reg[11:5];
assign  offset  = data_addr_reg[4:0];

wire 	[31:0] ram_wen;

wire	[31:0] ram_wdata_way_0_data_0;
wire	[31:0] ram_wdata_way_0_data_1;
wire	[31:0] ram_wdata_way_0_data_2;
wire	[31:0] ram_wdata_way_0_data_3;
wire	[31:0] ram_wdata_way_0_data_4;
wire	[31:0] ram_wdata_way_0_data_5;
wire	[31:0] ram_wdata_way_0_data_6;
wire	[31:0] ram_wdata_way_0_data_7;

wire	[31:0] ram_wdata_way_1_data_0;
wire	[31:0] ram_wdata_way_1_data_1;
wire	[31:0] ram_wdata_way_1_data_2;
wire	[31:0] ram_wdata_way_1_data_3;
wire	[31:0] ram_wdata_way_1_data_4;
wire	[31:0] ram_wdata_way_1_data_5;
wire	[31:0] ram_wdata_way_1_data_6;
wire	[31:0] ram_wdata_way_1_data_7;


wire 	ram_en_way_0_bank_0;
wire 	ram_en_way_0_bank_1;
wire 	ram_en_way_0_bank_2;
wire 	ram_en_way_0_bank_3;
wire 	ram_en_way_0_bank_4;
wire 	ram_en_way_0_bank_5;
wire 	ram_en_way_0_bank_6;
wire 	ram_en_way_0_bank_7;

wire 	ram_en_way_1_bank_0;
wire 	ram_en_way_1_bank_1;
wire 	ram_en_way_1_bank_2;
wire 	ram_en_way_1_bank_3;
wire 	ram_en_way_1_bank_4;
wire 	ram_en_way_1_bank_5;
wire 	ram_en_way_1_bank_6;
wire 	ram_en_way_1_bank_7;

wire 	ram_wen_way_0_bank_0;
wire 	ram_wen_way_0_bank_1;
wire 	ram_wen_way_0_bank_2;
wire 	ram_wen_way_0_bank_3;
wire 	ram_wen_way_0_bank_4;
wire 	ram_wen_way_0_bank_5;
wire 	ram_wen_way_0_bank_6;
wire 	ram_wen_way_0_bank_7;

wire 	ram_wen_way_1_bank_0;
wire 	ram_wen_way_1_bank_1;
wire 	ram_wen_way_1_bank_2;
wire 	ram_wen_way_1_bank_3;
wire 	ram_wen_way_1_bank_4;
wire 	ram_wen_way_1_bank_5;
wire 	ram_wen_way_1_bank_6;
wire 	ram_wen_way_1_bank_7;

wire 	ram_wen_way_0_bank_0_normal;
wire 	ram_wen_way_0_bank_1_normal;
wire 	ram_wen_way_0_bank_2_normal;
wire 	ram_wen_way_0_bank_3_normal;
wire 	ram_wen_way_0_bank_4_normal;
wire 	ram_wen_way_0_bank_5_normal;
wire 	ram_wen_way_0_bank_6_normal;
wire 	ram_wen_way_0_bank_7_normal;

wire 	ram_wen_way_1_bank_0_normal;
wire 	ram_wen_way_1_bank_1_normal;
wire 	ram_wen_way_1_bank_2_normal;
wire 	ram_wen_way_1_bank_3_normal;
wire 	ram_wen_way_1_bank_4_normal;
wire 	ram_wen_way_1_bank_5_normal;
wire 	ram_wen_way_1_bank_6_normal;
wire 	ram_wen_way_1_bank_7_normal;

wire 	ram_wen_way_0_bank_0_input;
wire 	ram_wen_way_0_bank_1_input;
wire 	ram_wen_way_0_bank_2_input;
wire 	ram_wen_way_0_bank_3_input;
wire 	ram_wen_way_0_bank_4_input;
wire 	ram_wen_way_0_bank_5_input;
wire 	ram_wen_way_0_bank_6_input;
wire 	ram_wen_way_0_bank_7_input;

wire 	ram_wen_way_1_bank_0_input;
wire 	ram_wen_way_1_bank_1_input;
wire 	ram_wen_way_1_bank_2_input;
wire 	ram_wen_way_1_bank_3_input;
wire 	ram_wen_way_1_bank_4_input;
wire 	ram_wen_way_1_bank_5_input;
wire 	ram_wen_way_1_bank_6_input;
wire 	ram_wen_way_1_bank_7_input;

wire 	ram_wstrb_way_0_bank_0;
wire 	ram_wstrb_way_0_bank_1;
wire 	ram_wstrb_way_0_bank_2;
wire 	ram_wstrb_way_0_bank_3;
wire 	ram_wstrb_way_0_bank_4;
wire 	ram_wstrb_way_0_bank_5;
wire 	ram_wstrb_way_0_bank_6;
wire 	ram_wstrb_way_0_bank_7;

wire 	ram_wstrb_way_1_bank_0;
wire 	ram_wstrb_way_1_bank_1;
wire 	ram_wstrb_way_1_bank_2;
wire 	ram_wstrb_way_1_bank_3;
wire 	ram_wstrb_way_1_bank_4;
wire 	ram_wstrb_way_1_bank_5;
wire 	ram_wstrb_way_1_bank_6;
wire 	ram_wstrb_way_1_bank_7;

wire    [31:0] rdata_0;
wire    [31:0] rdata_1;
wire    [31:0] rdata_2;
wire    [31:0] rdata_3;
wire    [31:0] rdata_4;
wire    [31:0] rdata_5;
wire    [31:0] rdata_6;
wire    [31:0] rdata_7;

wire    [31:0] way_0_rdata_0;
wire    [31:0] way_0_rdata_1;
wire    [31:0] way_0_rdata_2;
wire    [31:0] way_0_rdata_3;
wire    [31:0] way_0_rdata_4;
wire    [31:0] way_0_rdata_5;
wire    [31:0] way_0_rdata_6;
wire    [31:0] way_0_rdata_7;

wire    [31:0] way_1_rdata_0;
wire    [31:0] way_1_rdata_1;
wire    [31:0] way_1_rdata_2;
wire    [31:0] way_1_rdata_3;
wire    [31:0] way_1_rdata_4;
wire    [31:0] way_1_rdata_5;
wire    [31:0] way_1_rdata_6;
wire    [31:0] way_1_rdata_7;

// dcache_data way_0_data_0(clk,rst,1'b1,{4{ram_en_way_0_bank_0}},ram_wdata_way_0_data_0,data_addr_input,way_0_rdata_0);
// dcache_data way_0_data_1(clk,rst,1'b1,{4{ram_en_way_0_bank_1}},ram_wdata_way_0_data_1,data_addr_input,way_0_rdata_1);
// dcache_data way_0_data_2(clk,rst,1'b1,{4{ram_en_way_0_bank_2}},ram_wdata_way_0_data_2,data_addr_input,way_0_rdata_2);
// dcache_data way_0_data_3(clk,rst,1'b1,{4{ram_en_way_0_bank_3}},ram_wdata_way_0_data_3,data_addr_input,way_0_rdata_3);
// dcache_data way_0_data_4(clk,rst,1'b1,{4{ram_en_way_0_bank_4}},ram_wdata_way_0_data_4,data_addr_input,way_0_rdata_4);
// dcache_data way_0_data_5(clk,rst,1'b1,{4{ram_en_way_0_bank_5}},ram_wdata_way_0_data_5,data_addr_input,way_0_rdata_5);
// dcache_data way_0_data_6(clk,rst,1'b1,{4{ram_en_way_0_bank_6}},ram_wdata_way_0_data_6,data_addr_input,way_0_rdata_6);
// dcache_data way_0_data_7(clk,rst,1'b1,{4{ram_en_way_0_bank_7}},ram_wdata_way_0_data_7,data_addr_input,way_0_rdata_7);

// dcache_data way_1_data_0(clk,rst,1'b1,{4{ram_en_way_1_bank_0}},ram_wdata_way_1_data_0,data_addr_input,way_1_rdata_0);
// dcache_data way_1_data_1(clk,rst,1'b1,{4{ram_en_way_1_bank_1}},ram_wdata_way_1_data_1,data_addr_input,way_1_rdata_1);
// dcache_data way_1_data_2(clk,rst,1'b1,{4{ram_en_way_1_bank_2}},ram_wdata_way_1_data_2,data_addr_input,way_1_rdata_2);
// dcache_data way_1_data_3(clk,rst,1'b1,{4{ram_en_way_1_bank_3}},ram_wdata_way_1_data_3,data_addr_input,way_1_rdata_3);
// dcache_data way_1_data_4(clk,rst,1'b1,{4{ram_en_way_1_bank_4}},ram_wdata_way_1_data_4,data_addr_input,way_1_rdata_4);
// dcache_data way_1_data_5(clk,rst,1'b1,{4{ram_en_way_1_bank_5}},ram_wdata_way_1_data_5,data_addr_input,way_1_rdata_5);
// dcache_data way_1_data_6(clk,rst,1'b1,{4{ram_en_way_1_bank_6}},ram_wdata_way_1_data_6,data_addr_input,way_1_rdata_6);
// dcache_data way_1_data_7(clk,rst,1'b1,{4{ram_en_way_1_bank_7}},ram_wdata_way_1_data_7,data_addr_input,way_1_rdata_7);

icache_data way_0_data_0(clk,rst,1'b1,({4{ram_wen_way_0_bank_0_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_0_rdata_0);
icache_data way_0_data_1(clk,rst,1'b1,({4{ram_wen_way_0_bank_1_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_0_rdata_1);
icache_data way_0_data_2(clk,rst,1'b1,({4{ram_wen_way_0_bank_2_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_0_rdata_2);
icache_data way_0_data_3(clk,rst,1'b1,({4{ram_wen_way_0_bank_3_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_0_rdata_3);
icache_data way_0_data_4(clk,rst,1'b1,({4{ram_wen_way_0_bank_4_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_0_rdata_4);
icache_data way_0_data_5(clk,rst,1'b1,({4{ram_wen_way_0_bank_5_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_0_rdata_5);
icache_data way_0_data_6(clk,rst,1'b1,({4{ram_wen_way_0_bank_6_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_0_rdata_6);
icache_data way_0_data_7(clk,rst,1'b1,({4{ram_wen_way_0_bank_7_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_0_rdata_7);

icache_data way_1_data_0(clk,rst,1'b1,({4{ram_wen_way_1_bank_0_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_1_rdata_0);
icache_data way_1_data_1(clk,rst,1'b1,({4{ram_wen_way_1_bank_1_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_1_rdata_1);
icache_data way_1_data_2(clk,rst,1'b1,({4{ram_wen_way_1_bank_2_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_1_rdata_2);
icache_data way_1_data_3(clk,rst,1'b1,({4{ram_wen_way_1_bank_3_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_1_rdata_3);
icache_data way_1_data_4(clk,rst,1'b1,({4{ram_wen_way_1_bank_4_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_1_rdata_4);
icache_data way_1_data_5(clk,rst,1'b1,({4{ram_wen_way_1_bank_5_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_1_rdata_5);
icache_data way_1_data_6(clk,rst,1'b1,({4{ram_wen_way_1_bank_6_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_1_rdata_6);
icache_data way_1_data_7(clk,rst,1'b1,({4{ram_wen_way_1_bank_7_input}} & data_wstrb_input),ram_wdata,data_addr_input,way_1_rdata_7);

assign rdata_0 = hit_0 ? way_0_rdata_0 : way_1_rdata_0;
assign rdata_1 = hit_0 ? way_0_rdata_1 : way_1_rdata_1;
assign rdata_2 = hit_0 ? way_0_rdata_2 : way_1_rdata_2;
assign rdata_3 = hit_0 ? way_0_rdata_3 : way_1_rdata_3;
assign rdata_4 = hit_0 ? way_0_rdata_4 : way_1_rdata_4;
assign rdata_5 = hit_0 ? way_0_rdata_5 : way_1_rdata_5;
assign rdata_6 = hit_0 ? way_0_rdata_6 : way_1_rdata_6;
assign rdata_7 = hit_0 ? way_0_rdata_7 : way_1_rdata_7;

wire    [31:0] cache_rdata;
assign cache_rdata =  	(({32{offset[4:2] == 3'd0}}) & rdata_0) |
						(({32{offset[4:2] == 3'd1}}) & rdata_1) |
						(({32{offset[4:2] == 3'd2}}) & rdata_2) |
						(({32{offset[4:2] == 3'd3}}) & rdata_3) |
						(({32{offset[4:2] == 3'd4}}) & rdata_4) |
						(({32{offset[4:2] == 3'd5}}) & rdata_5) |
						(({32{offset[4:2] == 3'd6}}) & rdata_6) |
						(({32{offset[4:2] == 3'd7}}) & rdata_7);

wire [31:0] rdata_0_write_back;
wire [31:0] rdata_1_write_back;
wire [31:0] rdata_2_write_back;
wire [31:0] rdata_3_write_back;
wire [31:0] rdata_4_write_back;
wire [31:0] rdata_5_write_back;
wire [31:0] rdata_6_write_back;
wire [31:0] rdata_7_write_back;

assign rdata_0_write_back = way_choose ? way_1_rdata_0 : way_0_rdata_0;
assign rdata_1_write_back = way_choose ? way_1_rdata_1 : way_0_rdata_1;
assign rdata_2_write_back = way_choose ? way_1_rdata_2 : way_0_rdata_2;
assign rdata_3_write_back = way_choose ? way_1_rdata_3 : way_0_rdata_3;
assign rdata_4_write_back = way_choose ? way_1_rdata_4 : way_0_rdata_4;
assign rdata_5_write_back = way_choose ? way_1_rdata_5 : way_0_rdata_5;
assign rdata_6_write_back = way_choose ? way_1_rdata_6 : way_0_rdata_6;
assign rdata_7_write_back = way_choose ? way_1_rdata_7 : way_0_rdata_7;

wire    [31:0] cache_write_back;
assign cache_write_back =  	(({32{target_bank_write == 3'd0}}) & rdata_0_write_back) |
							(({32{target_bank_write == 3'd1}}) & rdata_1_write_back) |
							(({32{target_bank_write == 3'd2}}) & rdata_2_write_back) |
							(({32{target_bank_write == 3'd3}}) & rdata_3_write_back) |
							(({32{target_bank_write == 3'd4}}) & rdata_4_write_back) |
							(({32{target_bank_write == 3'd5}}) & rdata_5_write_back) |
							(({32{target_bank_write == 3'd6}}) & rdata_6_write_back) |
							(({32{target_bank_write == 3'd7}}) & rdata_7_write_back);

wire [2:0] pick = offset[4:2]; //idle

////replace
//info store
reg          data_req_reg    ;
reg          data_wr_reg     ;
reg   [1 :0] data_size_reg   ;
reg   [31:0] data_addr_reg   ;
reg   [31:0] data_wdata_reg  ;

always @(posedge clk)
	begin
		if(rst)
		begin
			data_req_reg <= 1'b0;
		end
		else if((work_state == 4'b0000) && data_addr_ok)
		begin
			data_req_reg <= data_req;
		end
        else if(data_data_ok) // if axi ack addr, stop requiring //TBD
		begin
			data_req_reg <= 1'b0;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			data_wr_reg <= 1'b0;
		end
		else if((work_state == 4'b0000) & data_addr_ok)
		begin
			data_wr_reg <= data_wr;
		end
		else if((work_state == 4'b0011) && rlast && (rid == 4'd1))
		begin
			data_wr_reg <= 1'b0;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			data_size_reg <= 2'b0;
		end
		else if(work_state == 4'b0000)
		begin
			data_size_reg <= data_size;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			data_wstrb_reg <= 4'b0;
		end
		else if((work_state == 4'b0000) & data_addr_ok)
		begin
			data_wstrb_reg <= data_wstrb;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			data_addr_reg <= 32'b0;
		end
		else if((work_state == 4'b0000) & data_addr_ok)
		begin
			data_addr_reg <= data_addr;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			data_wdata_reg <= 32'b0;
		end
		else if((work_state == 4'b0000) & data_addr_ok)
		begin
			data_wdata_reg <= data_wdata;
		end
	end

//replace
wire replace_mode_tag;
wire replace_mode_data;

assign replace_mode_tag  = (work_state == 4'b0011) ? 1'b1 : 1'b0;
assign replace_mode_data = (work_state == 4'b0000) ? data_wr : replace_mode_tag;

wire way_choose = !lru[index];

/*data bank*/
assign ram_wdata =  (work_state == 4'b0011) ? rdata : data_wdata_reg;

// assign ram_wdata_way_0_data_0 = ((data_wr_reg && (offset == 3'd0)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_0_data_1 = ((data_wr_reg && (offset == 3'd1)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_0_data_2 = ((data_wr_reg && (offset == 3'd2)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_0_data_3 = ((data_wr_reg && (offset == 3'd3)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_0_data_4 = ((data_wr_reg && (offset == 3'd4)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_0_data_5 = ((data_wr_reg && (offset == 3'd5)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_0_data_6 = ((data_wr_reg && (offset == 3'd6)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_0_data_7 = ((data_wr_reg && (offset == 3'd7)) || data_wr) ? wdata : rdata;

// assign ram_wdata_way_1_data_0 = ((data_wr_reg && (offset == 3'd0)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_1_data_1 = ((data_wr_reg && (offset == 3'd1)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_1_data_2 = ((data_wr_reg && (offset == 3'd2)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_1_data_3 = ((data_wr_reg && (offset == 3'd3)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_1_data_4 = ((data_wr_reg && (offset == 3'd4)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_1_data_5 = ((data_wr_reg && (offset == 3'd5)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_1_data_6 = ((data_wr_reg && (offset == 3'd6)) || data_wr) ? wdata : rdata;
// assign ram_wdata_way_1_data_7 = ((data_wr_reg && (offset == 3'd7)) || data_wr) ? wdata : rdata;

reg	[2:0] target_bank_read;
always @(posedge clk)
	begin
		if(rst)
		begin
			target_bank_read <= 3'd0;
		end
		else if((work_state == 4'b0011) && (rlast && (rid == 4'd3)))
		begin
			target_bank_read <= 3'd0;
		end
		else if((work_state == 4'b0011) && rvalid)
		begin
			target_bank_read <= target_bank_read + 3'd1;
		end		
	end

assign ram_en_way_0_bank_0 = replace_mode_data ? (way_choose ? 1'b0 : ((target_bank_read == 3'd0) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_1 = replace_mode_data ? (way_choose ? 1'b0 : ((target_bank_read == 3'd1) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_2 = replace_mode_data ? (way_choose ? 1'b0 : ((target_bank_read == 3'd2) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_3 = replace_mode_data ? (way_choose ? 1'b0 : ((target_bank_read == 3'd3) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_4 = replace_mode_data ? (way_choose ? 1'b0 : ((target_bank_read == 3'd4) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_5 = replace_mode_data ? (way_choose ? 1'b0 : ((target_bank_read == 3'd5) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_6 = replace_mode_data ? (way_choose ? 1'b0 : ((target_bank_read == 3'd6) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_7 = replace_mode_data ? (way_choose ? 1'b0 : ((target_bank_read == 3'd7) && rvalid)) : 1'b0;

assign ram_en_way_1_bank_0 = replace_mode_data ? (way_choose ? ((target_bank_read == 3'd0) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_1 = replace_mode_data ? (way_choose ? ((target_bank_read == 3'd1) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_2 = replace_mode_data ? (way_choose ? ((target_bank_read == 3'd2) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_3 = replace_mode_data ? (way_choose ? ((target_bank_read == 3'd3) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_4 = replace_mode_data ? (way_choose ? ((target_bank_read == 3'd4) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_5 = replace_mode_data ? (way_choose ? ((target_bank_read == 3'd5) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_6 = replace_mode_data ? (way_choose ? ((target_bank_read == 3'd6) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_7 = replace_mode_data ? (way_choose ? ((target_bank_read == 3'd7) && rvalid) : 1'b0) : 1'b0;

assign	ram_wen_way_0_bank_0 = ((work_state == 4'b0110)) ? (way_choose ? 1'b0 : ((offset[4:2] == 3'd0) ? 1'b1 : 1'b0)) : 1'b0;
assign	ram_wen_way_0_bank_1 = ((work_state == 4'b0110)) ? (way_choose ? 1'b0 : ((offset[4:2] == 3'd1) ? 1'b1 : 1'b0)) : 1'b0;
assign	ram_wen_way_0_bank_2 = ((work_state == 4'b0110)) ? (way_choose ? 1'b0 : ((offset[4:2] == 3'd2) ? 1'b1 : 1'b0)) : 1'b0;
assign	ram_wen_way_0_bank_3 = ((work_state == 4'b0110)) ? (way_choose ? 1'b0 : ((offset[4:2] == 3'd3) ? 1'b1 : 1'b0)) : 1'b0;
assign	ram_wen_way_0_bank_4 = ((work_state == 4'b0110)) ? (way_choose ? 1'b0 : ((offset[4:2] == 3'd4) ? 1'b1 : 1'b0)) : 1'b0;
assign	ram_wen_way_0_bank_5 = ((work_state == 4'b0110)) ? (way_choose ? 1'b0 : ((offset[4:2] == 3'd5) ? 1'b1 : 1'b0)) : 1'b0;
assign	ram_wen_way_0_bank_6 = ((work_state == 4'b0110)) ? (way_choose ? 1'b0 : ((offset[4:2] == 3'd6) ? 1'b1 : 1'b0)) : 1'b0;
assign	ram_wen_way_0_bank_7 = ((work_state == 4'b0110)) ? (way_choose ? 1'b0 : ((offset[4:2] == 3'd7) ? 1'b1 : 1'b0)) : 1'b0;

assign	ram_wen_way_1_bank_0 = ((work_state == 4'b0110)) ? (way_choose ? ((offset[4:2] == 3'd0) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_1 = ((work_state == 4'b0110)) ? (way_choose ? ((offset[4:2] == 3'd1) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_2 = ((work_state == 4'b0110)) ? (way_choose ? ((offset[4:2] == 3'd2) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_3 = ((work_state == 4'b0110)) ? (way_choose ? ((offset[4:2] == 3'd3) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_4 = ((work_state == 4'b0110)) ? (way_choose ? ((offset[4:2] == 3'd4) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_5 = ((work_state == 4'b0110)) ? (way_choose ? ((offset[4:2] == 3'd5) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_6 = ((work_state == 4'b0110)) ? (way_choose ? ((offset[4:2] == 3'd6) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_7 = ((work_state == 4'b0110)) ? (way_choose ? ((offset[4:2] == 3'd7) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;

assign	ram_wen_way_0_bank_0_normal = (work_state == 4'b0111) ? (succeed_0 ? ((offset[4:2] == 3'd0) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_0_bank_1_normal = (work_state == 4'b0111) ? (succeed_0 ? ((offset[4:2] == 3'd1) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_0_bank_2_normal = (work_state == 4'b0111) ? (succeed_0 ? ((offset[4:2] == 3'd2) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_0_bank_3_normal = (work_state == 4'b0111) ? (succeed_0 ? ((offset[4:2] == 3'd3) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_0_bank_4_normal = (work_state == 4'b0111) ? (succeed_0 ? ((offset[4:2] == 3'd4) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_0_bank_5_normal = (work_state == 4'b0111) ? (succeed_0 ? ((offset[4:2] == 3'd5) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_0_bank_6_normal = (work_state == 4'b0111) ? (succeed_0 ? ((offset[4:2] == 3'd6) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_0_bank_7_normal = (work_state == 4'b0111) ? (succeed_0 ? ((offset[4:2] == 3'd7) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;

assign	ram_wen_way_1_bank_0_normal = (work_state == 4'b0111) ? (succeed_1 ? ((offset[4:2] == 3'd0) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_1_normal = (work_state == 4'b0111) ? (succeed_1 ? ((offset[4:2] == 3'd1) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_2_normal = (work_state == 4'b0111) ? (succeed_1 ? ((offset[4:2] == 3'd2) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_3_normal = (work_state == 4'b0111) ? (succeed_1 ? ((offset[4:2] == 3'd3) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_4_normal = (work_state == 4'b0111) ? (succeed_1 ? ((offset[4:2] == 3'd4) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_5_normal = (work_state == 4'b0111) ? (succeed_1 ? ((offset[4:2] == 3'd5) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_6_normal = (work_state == 4'b0111) ? (succeed_1 ? ((offset[4:2] == 3'd6) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;
assign	ram_wen_way_1_bank_7_normal = (work_state == 4'b0111) ? (succeed_1 ? ((offset[4:2] == 3'd7) ? 1'b1 : 1'b0) : 1'b0) : 1'b0;

assign	ram_wen_way_0_bank_0_input = ram_en_way_0_bank_0 | ram_wen_way_0_bank_0 | ram_wen_way_0_bank_0_normal;
assign	ram_wen_way_0_bank_1_input = ram_en_way_0_bank_1 | ram_wen_way_0_bank_1 | ram_wen_way_0_bank_1_normal;
assign	ram_wen_way_0_bank_2_input = ram_en_way_0_bank_2 | ram_wen_way_0_bank_2 | ram_wen_way_0_bank_2_normal;
assign	ram_wen_way_0_bank_3_input = ram_en_way_0_bank_3 | ram_wen_way_0_bank_3 | ram_wen_way_0_bank_3_normal;
assign	ram_wen_way_0_bank_4_input = ram_en_way_0_bank_4 | ram_wen_way_0_bank_4 | ram_wen_way_0_bank_4_normal;
assign	ram_wen_way_0_bank_5_input = ram_en_way_0_bank_5 | ram_wen_way_0_bank_5 | ram_wen_way_0_bank_5_normal;
assign	ram_wen_way_0_bank_6_input = ram_en_way_0_bank_6 | ram_wen_way_0_bank_6 | ram_wen_way_0_bank_6_normal;
assign	ram_wen_way_0_bank_7_input = ram_en_way_0_bank_7 | ram_wen_way_0_bank_7 | ram_wen_way_0_bank_7_normal;

assign	ram_wen_way_1_bank_0_input = ram_en_way_1_bank_0 | ram_wen_way_1_bank_0 | ram_wen_way_1_bank_0_normal;
assign	ram_wen_way_1_bank_1_input = ram_en_way_1_bank_1 | ram_wen_way_1_bank_1 | ram_wen_way_1_bank_1_normal;
assign	ram_wen_way_1_bank_2_input = ram_en_way_1_bank_2 | ram_wen_way_1_bank_2 | ram_wen_way_1_bank_2_normal;
assign	ram_wen_way_1_bank_3_input = ram_en_way_1_bank_3 | ram_wen_way_1_bank_3 | ram_wen_way_1_bank_3_normal;
assign	ram_wen_way_1_bank_4_input = ram_en_way_1_bank_4 | ram_wen_way_1_bank_4 | ram_wen_way_1_bank_4_normal;
assign	ram_wen_way_1_bank_5_input = ram_en_way_1_bank_5 | ram_wen_way_1_bank_5 | ram_wen_way_1_bank_5_normal;
assign	ram_wen_way_1_bank_6_input = ram_en_way_1_bank_6 | ram_wen_way_1_bank_6 | ram_wen_way_1_bank_6_normal;
assign	ram_wen_way_1_bank_7_input = ram_en_way_1_bank_7 | ram_wen_way_1_bank_7 | ram_wen_way_1_bank_7_normal;

/*tag*/
assign tag_0_en = replace_mode_tag ? (way_choose ? 1'b0 : 1'b1) : 1'b0;
assign tag_1_en = replace_mode_tag ? (way_choose ? 1'b1 : 1'b0) : 1'b0;

////workstate
//state
reg [3:0] work_state;   //00: hit  /01: seek to replace and require  /11: wait for axi
wire req_but_miss;
wire write_back;

assign req_but_miss = data_req_reg && (!succeed);
assign write_back 	= ((way_choose == 1'b0) && (dirty_way_0[index] == 1'b1) && (valid_0 == 1'b1)) || ((way_choose == 1'b1) && (dirty_way_1[index] == 1'b1) && (valid_1 == 1'b1));
					  

always @(posedge clk)
	begin
		if(rst)
		begin
			work_state <= 4'b0100;
		end
		else if((work_state == 4'b0100) || (work_state == 4'b0101) || (work_state == 4'b0110))
		begin
			work_state <= 4'b0000;
		end
		else if((work_state == 4'b0010) && awready) // write back
		begin
			work_state <= 4'b1001; 
		end
		else if((work_state == 4'b0000) && data_addr_ok && data_wr) // write into cache
		begin
			work_state <= 4'b0111; 
		end
		else if((work_state == 4'b0111) && req_but_miss && write_back) // write back prepare
		begin
			work_state <= 4'b0010; 
		end
		else if((work_state == 4'b0111) && req_but_miss) // write into cache
		begin
			work_state <= 4'b0001; 
		end
		else if((work_state == 4'b0000) && req_but_miss && write_back) // write back prepare
		begin
			work_state <= 4'b0010;
		end
		else if((work_state == 4'b0111) && succeed) // write back
		begin
			work_state <= 4'b0000; 
		end
		else if((work_state == 4'b1001) && (target_bank_write == 3'd7) && wready) // write back finish
		begin
			work_state <= 4'b1000; 
		end
		else if((work_state == 4'b1000) && bvalid && (bid == 3'd0)) //after write back, fetch 
		begin
			work_state <= 4'b0001; 
		end
		else if((work_state == 4'b0000) && req_but_miss) // miss or invalid, enter state 001
		begin
			work_state <= 4'b0001;
		end
		else if((work_state == 4'b0000) && index_change) 
		begin
			work_state <= 4'b0101;
		end
        else if((work_state == 4'b0001) && arready) // after axi ack addr, enter state 011
        begin
            work_state <= 4'b0011;
        end
		else if((work_state == 4'b0011) && rlast && (rid == 4'd1) && data_wr_reg) // after axi rlast(trans end), enter state 010
        begin
            work_state <= 4'b0110;
        end
		else if((work_state == 4'b0011) && rlast && (rid == 4'd1)) // after axi rlast(trans end), enter state 010
        begin
            work_state <= 4'b0000;
        end
        else
        begin
            work_state <= work_state; 
        end
	end

reg addr_data_equal;
always @(posedge clk)
	begin
		if(rst)
		begin
			addr_data_equal <= 1'b0;
		end
        else if(data_addr_ok && !data_data_ok)
        begin
            addr_data_equal <= 1'b1; 
        end
		else if(data_data_ok && !data_addr_ok)
		begin
            addr_data_equal <= 1'b0; 
        end
	end

//index change
wire index_change;
reg [6:0] index_history;
always @(posedge clk)
	begin
		if(rst)
		begin
			index_history <= 7'd0;
		end
		else
		begin
            index_history <= index;
        end
	end

assign index_change = (index == index_history) ? 1'b0 : 1'b1;

//sram control
reg hit_0_history;
reg hit_1_history;
wire way_change;

always @(posedge clk)
	begin
		if(rst)
		begin
			hit_0_history <= 1'd0;
		end
		else
		begin
            hit_0_history <= succeed_0;
        end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			hit_1_history <= 1'd0;
		end
		else
		begin
            hit_1_history <= succeed_1;
        end
	end

assign 	way_change = (((hit_1_history == 1'b1) && (succeed_0 == 1'b1)) || ((hit_0_history == 1'b1) && (succeed_1 == 1'b1))) ? 1'b1 : 1'b0;

assign data_addr_ok = data_req & (work_state == 4'b0000) & (addr_data_equal ? data_data_ok : 1'b1);   ////////////////
assign data_data_ok = data_req_reg && succeed /*&& succeed_ack*/ && (work_state == 4'b0000);// || ((work_state == 3'b010) ? 1'b1 : 1'b0);   // state 10 after rlast, 
assign data_rdata   = cache_rdata;  // state 10 ensure that right state is ready

//axi control
assign arid		= 4'd1;
assign araddr   = {data_addr_reg[31:5],5'b0};
assign arlen    = 8'd7;
assign arsize   = 3'd2;
assign arburst  = 2'b01;
assign arlock   = 2'b0;
assign arcache  = 4'b0;
assign arprot   = 3'b0;
assign arvalid  = (work_state == 4'b0001) ? 1'b1 : 1'b0;

assign rready 	= (work_state == 4'b0011) ? 1'b1 : 1'b0;

reg	[2:0] target_bank_write;
always @(posedge clk)
	begin
		if(rst)
		begin
			target_bank_write <= 3'd0;
		end
		else if((work_state == 4'b1001) && (wready && (wid == 4'd0)))
		begin
			target_bank_write <= target_bank_write + 3'd1;
		end		
	end

assign tag_rdata = way_choose ? tag_rdata_1 : tag_rdata_0;

assign awid     = 4'd0;
assign awlen    = 8'd7;
assign awburst  = 2'b01;
assign awsize   = 3'd2;
assign awlock   = 2'b0;
assign awcache  = 4'b0;
assign awprot   = 3'b0;
assign awaddr   = {tag_rdata[19:0],index,5'b0};
assign awvalid  = (work_state == 4'b0010) ? 1'b1 : 1'b0;


assign wdata    = cache_write_back;
assign wvalid   = (work_state == 4'b1001) ? 1'b1 : 1'b0;
assign wid      = 4'd0;
assign wlast    = (target_bank_write == 3'd7) ? 1'b1 : 1'b0;
assign wstrb    = 4'b1111;

assign bresp    = 2'b0;
assign bready   = ((work_state == 4'b1001) || (work_state == 4'b1000)) ? 1'b1 : 1'b0;

////LRU
reg [127:0] lru;
always @(posedge clk)
	begin
		if(rst)
		begin
			lru <= 128'b0;
		end
		else if((work_state == 4'b0000) && data_req_reg && succeed) // require and hit, so update lru
		begin
			lru[index] <= hit_1;
		end
        else
        begin
            lru <= lru;
        end
	end


///dirty
reg [127:0] dirty_way_0;
reg [127:0] dirty_way_1;
wire dirty_way_0_input;
wire dirty_way_1_input;

assign dirty_way_0_input = hit_0 ? 1'b1 : !way_choose;
assign dirty_way_1_input = hit_1 ? 1'b1 : way_choose;

always @(posedge clk)
	begin
		if(rst)
		begin
			dirty_way_0 <= 128'b0;
		end
		else if((work_state == 4'b0000) && data_wr_reg) // 
		begin
			dirty_way_0[index] <= dirty_way_0_input;
		end
		else if(work_state == 4'b1000)
		begin
			dirty_way_0[index] <= 1'b0;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			dirty_way_1 <= 128'b0;
		end
		else if((work_state == 4'b0000) && data_wr_reg) // 
		begin
			dirty_way_1[index] <= dirty_way_1_input;
		end
		else if(work_state == 4'b1000)
		begin
			dirty_way_1[index] <= 1'b0;
		end
	end

// performance counter
reg [31:0] req_counter_0;
reg [31:0] req_counter_1;
reg [31:0] req_counter_2;
reg [31:0] miss_counter_0;
reg [31:0] miss_counter_1;

always @(posedge clk)
	begin
		if(rst)
		begin
			req_counter_0 <= 32'd0;
		end
		else if(data_addr_ok) // 
		begin
			req_counter_0 <= req_counter_0 + 32'd1;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			req_counter_1 <= 32'd0;
		end
		else if(data_addr_ok && (req_counter_0 == 32'hffffffff)) 
		begin
			req_counter_1 <= req_counter_1 + 32'd1;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			req_counter_2 <= 32'd0;
		end
		else if(data_addr_ok && (req_counter_1 == 32'hffffffff)) 
		begin
			req_counter_2 <= req_counter_2 + 32'd1;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			miss_counter_0 <= 32'd0;
		end
		else if(((work_state == 4'b0000) || (work_state == 4'b0111)) && req_but_miss) 
		begin
			miss_counter_0 <= miss_counter_0 + 32'd1;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			miss_counter_1 <= 32'd0;
		end
		else if(((work_state == 4'b0000) || (work_state == 4'b0111)) && req_but_miss && (miss_counter_0 == 32'hffffffff)) 
		begin
			miss_counter_1 <= miss_counter_1 + 32'd1;
		end
	end

endmodule