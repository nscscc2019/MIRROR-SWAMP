`timescale 1ns / 1ps
module icache
(
    ////basic
    input         clk,
    input         resetn,
    //input         en,
    //input [31:0]  wen,
    //input         resetn, 
    //input [31:0]  addr,
    //input [31:0]  wdata,
    //output[31:0]  rdata,

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
    input          inst_req    ,
    input          inst_wr     ,
    input   [1 :0] inst_size   ,
    input   [31:0] inst_addr   ,
    input   [31:0] inst_wdata  ,
    output  [31:0] inst_rdata  ,
    output         inst_addr_ok,
    output         inst_data_ok

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

wire    [31:0] inst_addr_input;
assign  inst_addr_input = (work_state == 2'b00) ? inst_addr : inst_addr_reg;

wire [31:0]   idle_rdata_0;
wire [31:0]   idle_rdata_1;

icache_tag tag_0(clk,rst,1'b1,{4{tag_0_en}},{1'b1,inst_addr_input[31:12]},idle_rdata_0,inst_addr_input,hit_0,valid_0);
icache_tag tag_1(clk,rst,1'b1,{4{tag_1_en}},{1'b1,inst_addr_input[31:12]},idle_rdata_1,inst_addr_input,hit_1,valid_1);

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
		else if(work_state == 2'b00)
		begin
			succeed_ack <= succeed_0 | succeed_1;
		end
	end


////data access
wire    [19:0] tag;
wire    [6:0]  index;
wire    [4:0]  offset;

assign  tag     = (work_state == 2'b00) ? inst_addr[31:12] : inst_addr_reg[31:12];
assign  index   = (work_state == 2'b00) ? inst_addr[11:5] : inst_addr_reg[11:5];
assign  offset  = (work_state == 2'b00) ? inst_addr[4:0] :  inst_addr_reg[4:0];

wire 	[31:0] ram_wen;
//assign ram_wen = 32'hffff;
//assign   ram_wen = {4{}};

wire	[31:0] ram_wdata;

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

icache_data way_0_data_0(clk,rst,1'b1,{4{ram_en_way_0_bank_0}},ram_wdata,inst_addr_input,way_0_rdata_0);
icache_data way_0_data_1(clk,rst,1'b1,{4{ram_en_way_0_bank_1}},ram_wdata,inst_addr_input,way_0_rdata_1);
icache_data way_0_data_2(clk,rst,1'b1,{4{ram_en_way_0_bank_2}},ram_wdata,inst_addr_input,way_0_rdata_2);
icache_data way_0_data_3(clk,rst,1'b1,{4{ram_en_way_0_bank_3}},ram_wdata,inst_addr_input,way_0_rdata_3);
icache_data way_0_data_4(clk,rst,1'b1,{4{ram_en_way_0_bank_4}},ram_wdata,inst_addr_input,way_0_rdata_4);
icache_data way_0_data_5(clk,rst,1'b1,{4{ram_en_way_0_bank_5}},ram_wdata,inst_addr_input,way_0_rdata_5);
icache_data way_0_data_6(clk,rst,1'b1,{4{ram_en_way_0_bank_6}},ram_wdata,inst_addr_input,way_0_rdata_6);
icache_data way_0_data_7(clk,rst,1'b1,{4{ram_en_way_0_bank_7}},ram_wdata,inst_addr_input,way_0_rdata_7);

icache_data way_1_data_0(clk,rst,1'b1,{4{ram_en_way_1_bank_0}},ram_wdata,inst_addr_input,way_1_rdata_0);
icache_data way_1_data_1(clk,rst,1'b1,{4{ram_en_way_1_bank_1}},ram_wdata,inst_addr_input,way_1_rdata_1);
icache_data way_1_data_2(clk,rst,1'b1,{4{ram_en_way_1_bank_2}},ram_wdata,inst_addr_input,way_1_rdata_2);
icache_data way_1_data_3(clk,rst,1'b1,{4{ram_en_way_1_bank_3}},ram_wdata,inst_addr_input,way_1_rdata_3);
icache_data way_1_data_4(clk,rst,1'b1,{4{ram_en_way_1_bank_4}},ram_wdata,inst_addr_input,way_1_rdata_4);
icache_data way_1_data_5(clk,rst,1'b1,{4{ram_en_way_1_bank_5}},ram_wdata,inst_addr_input,way_1_rdata_5);
icache_data way_1_data_6(clk,rst,1'b1,{4{ram_en_way_1_bank_6}},ram_wdata,inst_addr_input,way_1_rdata_6);
icache_data way_1_data_7(clk,rst,1'b1,{4{ram_en_way_1_bank_7}},ram_wdata,inst_addr_input,way_1_rdata_7);

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


////replace
//info store
reg          inst_req_reg    ;
reg          inst_wr_reg     ;
reg   [1 :0] inst_size_reg   ;
reg   [31:0] inst_addr_reg   ;
reg   [31:0] inst_wdata_reg  ;

always @(posedge clk)
	begin
		if(rst)
		begin
			inst_req_reg <= 1'b0;
		end
		else if(work_state == 2'b00)
		begin
			inst_req_reg <= inst_req;
		end
//        else if((work_state == 2'b01) && axi_inst_addr_ok) // if axi ack addr, stop requiring //TBD
        else if((work_state == 2'b01)) // if axi ack addr, stop requiring //TBD
		begin
			inst_req_reg <= 1'b0;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			inst_wr_reg <= 1'b0;
		end
		else if(work_state == 2'b00)
		begin
			inst_wr_reg <= inst_wr;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			inst_size_reg <= 2'b0;
		end
		else if(work_state == 2'b00)
		begin
			inst_size_reg <= inst_size;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			inst_addr_reg <= 32'b0;
		end
		else if(work_state == 2'b00)
		begin
			inst_addr_reg <= inst_addr;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			inst_wdata_reg <= 32'b0;
		end
		else if(work_state == 2'b00)
		begin
			inst_wdata_reg <= inst_wdata;
		end
	end

//replace
wire replace_mode;
assign replace_mode = (work_state == 2'b11) ? 1'b1 : 1'b0;

wire way_choose = lru[index];

/*data bank*/
assign ram_wdata = rdata;

reg	[2:0] target_bank;
always @(posedge clk)
	begin
		if(rst)
		begin
			target_bank <= 3'd0;
		end
		else if((work_state == 2'b11) && rlast)
		begin
			target_bank <= 3'd0;
		end
		else if((work_state == 2'b11) && rvalid)
		begin
			target_bank <= target_bank + 3'd1;
		end		
	end

assign ram_en_way_0_bank_0 = replace_mode ? (way_choose ? 1'b0 : ((target_bank == 3'd0) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_1 = replace_mode ? (way_choose ? 1'b0 : ((target_bank == 3'd1) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_2 = replace_mode ? (way_choose ? 1'b0 : ((target_bank == 3'd2) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_3 = replace_mode ? (way_choose ? 1'b0 : ((target_bank == 3'd3) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_4 = replace_mode ? (way_choose ? 1'b0 : ((target_bank == 3'd4) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_5 = replace_mode ? (way_choose ? 1'b0 : ((target_bank == 3'd5) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_6 = replace_mode ? (way_choose ? 1'b0 : ((target_bank == 3'd6) && rvalid)) : 1'b0;
assign ram_en_way_0_bank_7 = replace_mode ? (way_choose ? 1'b0 : ((target_bank == 3'd7) && rvalid)) : 1'b0;

assign ram_en_way_1_bank_0 = replace_mode ? (way_choose ? ((target_bank == 3'd0) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_0 = replace_mode ? (way_choose ? ((target_bank == 3'd1) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_0 = replace_mode ? (way_choose ? ((target_bank == 3'd2) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_0 = replace_mode ? (way_choose ? ((target_bank == 3'd3) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_0 = replace_mode ? (way_choose ? ((target_bank == 3'd4) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_0 = replace_mode ? (way_choose ? ((target_bank == 3'd5) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_0 = replace_mode ? (way_choose ? ((target_bank == 3'd6) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_0 = replace_mode ? (way_choose ? ((target_bank == 3'd7) && rvalid) : 1'b0) : 1'b0;

/*tag*/
assign tag_0_en = replace_mode ? (way_choose ? 1'b0 : 1'b1) : 1'b0;
assign tag_1_en = replace_mode ? (way_choose ? 1'b1 : 1'b0) : 1'b0;

////workstate
//state
reg [1:0] work_state;   //00: hit  /01: seek to replace and require  /11: wait for axi
always @(posedge clk)
	begin
		if(rst)
		begin
			work_state <= 2'b00;
		end
		else if((work_state == 2'b00) && inst_req && (! succeed)) // miss or invalid, enter state 01
		begin
			work_state <= 2'b01;
		end
        else if((work_state == 2'b01) && arready) // after axi ack addr, enter state 11
        begin
            work_state <= 2'b11;
        end
		else if((work_state == 2'b11) && rlast) // after axi rlast(trans end), enter state 10
        begin
            work_state <= 2'b10;
        end
		else if(work_state == 2'b10)// state 10 is used for: wait for ram to store data
		begin
			work_state <= 2'b00;
		end
        else
        begin
            work_state <= work_state; 
        end
	end


//sram control
assign inst_addr_ok = (~work_state[0]) & inst_req;   ////////////////
assign inst_data_ok = succeed_ack || ((work_state == 2'b10) ? 1'b1 : 1'b0);   // state 10 after rlast, 
assign inst_rdata = cache_rdata;  // state 10 ensure that right state is ready

//axi control
assign arid		= 4'd0;
assign araddr   = inst_addr_reg;
assign arlen    = 8'd7;
assign arsize   = 3'd2; //////??????????
assign arburst  = 2'b01;
assign arlock   = 2'b0;
assign arcache  = 4'b0;
assign arprot   = 3'b0;
assign arvalid  = (work_state == 2'b01) ? 1'b1 : 1'b0;

assign rready 	= (work_state == 2'b11) ? 1'b1 : 1'b0;

//do not care
assign awid     = 3'b1; ////////?????????
assign awlen    = 8'b0;
assign awburst  = 2'b0;
assign awlock   = 2'b0;
assign awcache  = 4'b0;
assign awprot   = 3'b0;

assign wid      = 4'b1;
assign wlast    = 1'b1;

assign bid      = 4'b0;/////????????
assign bresp    = 2'b0;


////LRU
reg [127:0] lru;
always @(posedge clk)
	begin
		if(rst)
		begin
			lru <= 128'b0;
		end
		else if((work_state == 2'b00) && inst_req && succeed) // require and hit, so update lru
		begin
			lru[index] <= hit_1;
		end
		else if(work_state == 2'b10)	// require and miss, after replace, update lru
		begin
			lru[index] <= hit_1;
		end
        else
        begin
            lru <= lru;
        end
	end


endmodule