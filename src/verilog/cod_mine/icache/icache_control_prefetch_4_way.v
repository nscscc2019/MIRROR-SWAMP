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
wire    hit_2;
wire    hit_3;
wire    valid_0;
wire    valid_1;
wire    valid_2;
wire    valid_3;
wire 	tag_0_en;
wire    tag_1_en;
wire 	tag_2_en;
wire    tag_3_en;

wire    [31:0] inst_addr_input;
assign  inst_addr_input = (work_state == 4'b0000) ? inst_addr : (((work_state == 4'b0111) || (work_state == 4'b0010)) ? (inst_addr_reg + 32'h00000020) : inst_addr_reg);

wire [20:0]   idle_rdata_0;
wire [20:0]   idle_rdata_1;
wire [20:0]   idle_rdata_2;
wire [20:0]   idle_rdata_3;

wire cache_work_0;
wire cache_work_1;
wire cache_work_2;
wire cache_work_3;

icache_tag tag_0(clk,rst,1'b1,{4{tag_0_en}},{1'b1,inst_addr_input[31:12]},idle_rdata_0,inst_addr_input,hit_0,valid_0,cache_work_0);
icache_tag tag_1(clk,rst,1'b1,{4{tag_1_en}},{1'b1,inst_addr_input[31:12]},idle_rdata_1,inst_addr_input,hit_1,valid_1,cache_work_1);
icache_tag tag_2(clk,rst,1'b1,{4{tag_2_en}},{1'b1,inst_addr_input[31:12]},idle_rdata_2,inst_addr_input,hit_2,valid_2,cache_work_2);
icache_tag tag_3(clk,rst,1'b1,{4{tag_3_en}},{1'b1,inst_addr_input[31:12]},idle_rdata_3,inst_addr_input,hit_3,valid_3,cache_work_3);

wire    hit;
assign  hit = hit_0 | hit_1 | hit_2 | hit_3;

//valid
wire    succeed_0;
wire    succeed_1;
wire    succeed_2;
wire    succeed_3;
wire    succeed;
reg     succeed_ack;

assign succeed_0    = hit_0 & valid_0; //if hit and  if valid
assign succeed_1    = hit_1 & valid_1;
assign succeed_2    = hit_2 & valid_2; 
assign succeed_3    = hit_3 & valid_3;
assign succeed      = succeed_0 | succeed_1 | succeed_2 | succeed_3 ;
always @(posedge clk)
	begin
		if(rst)
		begin
			succeed_ack <= 1'b0;
		end
		else if((work_state == 4'b0000) || (work_state == 4'b0010))
		begin
			succeed_ack <= succeed;
		end
	end


////data access
wire    [19:0] tag;
wire    [6:0]  index;
wire    [4:0]  offset;

assign  tag     = inst_addr_reg[31:12];
assign  index   = inst_addr_reg[11:5];
assign  offset  = inst_addr_reg[4:0];

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

wire 	ram_en_way_2_bank_0;
wire 	ram_en_way_2_bank_1;
wire 	ram_en_way_2_bank_2;
wire 	ram_en_way_2_bank_3;
wire 	ram_en_way_2_bank_4;
wire 	ram_en_way_2_bank_5;
wire 	ram_en_way_2_bank_6;
wire 	ram_en_way_2_bank_7;

wire 	ram_en_way_3_bank_0;
wire 	ram_en_way_3_bank_1;
wire 	ram_en_way_3_bank_2;
wire 	ram_en_way_3_bank_3;
wire 	ram_en_way_3_bank_4;
wire 	ram_en_way_3_bank_5;
wire 	ram_en_way_3_bank_6;
wire 	ram_en_way_3_bank_7;

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

wire    [31:0] way_2_rdata_0;
wire    [31:0] way_2_rdata_1;
wire    [31:0] way_2_rdata_2;
wire    [31:0] way_2_rdata_3;
wire    [31:0] way_2_rdata_4;
wire    [31:0] way_2_rdata_5;
wire    [31:0] way_2_rdata_6;
wire    [31:0] way_2_rdata_7;

wire    [31:0] way_3_rdata_0;
wire    [31:0] way_3_rdata_1;
wire    [31:0] way_3_rdata_2;
wire    [31:0] way_3_rdata_3;
wire    [31:0] way_3_rdata_4;
wire    [31:0] way_3_rdata_5;
wire    [31:0] way_3_rdata_6;
wire    [31:0] way_3_rdata_7;

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

icache_data way_2_data_0(clk,rst,1'b1,{4{ram_en_way_2_bank_0}},ram_wdata,inst_addr_input,way_2_rdata_0);
icache_data way_2_data_1(clk,rst,1'b1,{4{ram_en_way_2_bank_1}},ram_wdata,inst_addr_input,way_2_rdata_1);
icache_data way_2_data_2(clk,rst,1'b1,{4{ram_en_way_2_bank_2}},ram_wdata,inst_addr_input,way_2_rdata_2);
icache_data way_2_data_3(clk,rst,1'b1,{4{ram_en_way_2_bank_3}},ram_wdata,inst_addr_input,way_2_rdata_3);
icache_data way_2_data_4(clk,rst,1'b1,{4{ram_en_way_2_bank_4}},ram_wdata,inst_addr_input,way_2_rdata_4);
icache_data way_2_data_5(clk,rst,1'b1,{4{ram_en_way_2_bank_5}},ram_wdata,inst_addr_input,way_2_rdata_5);
icache_data way_2_data_6(clk,rst,1'b1,{4{ram_en_way_2_bank_6}},ram_wdata,inst_addr_input,way_2_rdata_6);
icache_data way_2_data_7(clk,rst,1'b1,{4{ram_en_way_2_bank_7}},ram_wdata,inst_addr_input,way_2_rdata_7);

icache_data way_3_data_0(clk,rst,1'b1,{4{ram_en_way_3_bank_0}},ram_wdata,inst_addr_input,way_3_rdata_0);
icache_data way_3_data_1(clk,rst,1'b1,{4{ram_en_way_3_bank_1}},ram_wdata,inst_addr_input,way_3_rdata_1);
icache_data way_3_data_2(clk,rst,1'b1,{4{ram_en_way_3_bank_2}},ram_wdata,inst_addr_input,way_3_rdata_2);
icache_data way_3_data_3(clk,rst,1'b1,{4{ram_en_way_3_bank_3}},ram_wdata,inst_addr_input,way_3_rdata_3);
icache_data way_3_data_4(clk,rst,1'b1,{4{ram_en_way_3_bank_4}},ram_wdata,inst_addr_input,way_3_rdata_4);
icache_data way_3_data_5(clk,rst,1'b1,{4{ram_en_way_3_bank_5}},ram_wdata,inst_addr_input,way_3_rdata_5);
icache_data way_3_data_6(clk,rst,1'b1,{4{ram_en_way_3_bank_6}},ram_wdata,inst_addr_input,way_3_rdata_6);
icache_data way_3_data_7(clk,rst,1'b1,{4{ram_en_way_3_bank_7}},ram_wdata,inst_addr_input,way_3_rdata_7);


assign rdata_0 = ({32{hit_0}} & way_0_rdata_0) | 
				 ({32{hit_1}} & way_1_rdata_0) |
				 ({32{hit_2}} & way_2_rdata_0) | 
				 ({32{hit_3}} & way_3_rdata_0) ;
assign rdata_1 = ({32{hit_0}} & way_0_rdata_1) | 
				 ({32{hit_1}} & way_1_rdata_1) |
				 ({32{hit_2}} & way_2_rdata_1) | 
				 ({32{hit_3}} & way_3_rdata_1) ;
assign rdata_2 = ({32{hit_0}} & way_0_rdata_2) | 
				 ({32{hit_1}} & way_1_rdata_2) |
				 ({32{hit_2}} & way_2_rdata_2) | 
				 ({32{hit_3}} & way_3_rdata_2) ;
assign rdata_3 = ({32{hit_0}} & way_0_rdata_3) | 
				 ({32{hit_1}} & way_1_rdata_3) |
				 ({32{hit_2}} & way_2_rdata_3) | 
				 ({32{hit_3}} & way_3_rdata_3) ;
assign rdata_4 = ({32{hit_0}} & way_0_rdata_4) | 
				 ({32{hit_1}} & way_1_rdata_4) |
				 ({32{hit_2}} & way_2_rdata_4) | 
				 ({32{hit_3}} & way_3_rdata_4) ;
assign rdata_5 = ({32{hit_0}} & way_0_rdata_5) | 
				 ({32{hit_1}} & way_1_rdata_5) |
				 ({32{hit_2}} & way_2_rdata_5) | 
				 ({32{hit_3}} & way_3_rdata_5) ;
assign rdata_6 = ({32{hit_0}} & way_0_rdata_6) | 
				 ({32{hit_1}} & way_1_rdata_6) |
				 ({32{hit_2}} & way_2_rdata_6) | 
				 ({32{hit_3}} & way_3_rdata_6) ;
assign rdata_7 = ({32{hit_0}} & way_0_rdata_7) | 
				 ({32{hit_1}} & way_1_rdata_7) |
				 ({32{hit_2}} & way_2_rdata_7) | 
				 ({32{hit_3}} & way_3_rdata_7) ;

wire    [31:0] cache_rdata;
assign cache_rdata =  	(({32{offset[4:2] == 3'd0}}) & rdata_0) |
						(({32{offset[4:2] == 3'd1}}) & rdata_1) |
						(({32{offset[4:2] == 3'd2}}) & rdata_2) |
						(({32{offset[4:2] == 3'd3}}) & rdata_3) |
						(({32{offset[4:2] == 3'd4}}) & rdata_4) |
						(({32{offset[4:2] == 3'd5}}) & rdata_5) |
						(({32{offset[4:2] == 3'd6}}) & rdata_6) |
						(({32{offset[4:2] == 3'd7}}) & rdata_7);

wire [2:0] pick = offset[4:2]; //idle

////replace
//info store
reg          inst_req_reg    ;
reg          inst_wr_reg     ;
reg   [1 :0] inst_size_reg   ;
reg   [31:0] inst_addr_reg   ;
reg   [31:0] inst_rdata_reg  ;

always @(posedge clk)
	begin
		if(rst)
		begin
			inst_req_reg <= 1'b0;
		end
		else if((work_state == 4'b0000) && inst_addr_ok)
		begin
			inst_req_reg <= inst_req;
		end
//        else if((work_state == 3'b001) && axi_inst_addr_ok) // if axi ack addr, stop requiring //TBD
        else if(inst_data_ok) // if axi ack addr, stop requiring //TBD
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
		else if(work_state == 4'b0000)
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
		else if(work_state == 4'b0000)
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
		else if((work_state == 4'b0000) & inst_addr_ok)
		begin
			inst_addr_reg <= inst_addr;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			inst_rdata_reg <= 32'b0;
		end
		else if(((work_state == 4'b0000) && ((!addr_data_equal) || inst_data_ok || (succeed && !index_change_reg))) || (work_state == 4'b0010))
		begin
			inst_rdata_reg <= cache_rdata;
		end
	end

//replace
wire replace_mode;
assign replace_mode = ((work_state == 4'b0011) || (work_state == 4'b0111)) ? 1'b1 : 1'b0;

wire [1:0] way_choose = {lru_3_1[index],lru_3_0[index]};

/*data bank*/
assign ram_wdata = rdata;

reg	[2:0] target_bank;
always @(posedge clk)
	begin
		if(rst)
		begin
			target_bank <= 3'd0;
		end
		// else if(((work_state == 3'b011) || (work_state == 3'b111)) && (rlast && (rid == 4'd3)))
		// begin
		// 	target_bank <= 3'd0;
		// end
		else if(((work_state == 4'b0011) || (work_state == 4'b0111)) && (rvalid && (rid == 4'd3)))
		begin
			target_bank <= target_bank + 3'd1;
		end		
	end

assign ram_en_way_0_bank_0 = replace_mode ? ((way_choose == 2'b00) ? ((target_bank == 3'd0) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_0_bank_1 = replace_mode ? ((way_choose == 2'b00) ? ((target_bank == 3'd1) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_0_bank_2 = replace_mode ? ((way_choose == 2'b00) ? ((target_bank == 3'd2) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_0_bank_3 = replace_mode ? ((way_choose == 2'b00) ? ((target_bank == 3'd3) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_0_bank_4 = replace_mode ? ((way_choose == 2'b00) ? ((target_bank == 3'd4) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_0_bank_5 = replace_mode ? ((way_choose == 2'b00) ? ((target_bank == 3'd5) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_0_bank_6 = replace_mode ? ((way_choose == 2'b00) ? ((target_bank == 3'd6) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_0_bank_7 = replace_mode ? ((way_choose == 2'b00) ? ((target_bank == 3'd7) && rvalid) : 1'b0) : 1'b0;

assign ram_en_way_1_bank_0 = replace_mode ? ((way_choose == 2'b01) ? ((target_bank == 3'd0) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_1 = replace_mode ? ((way_choose == 2'b01) ? ((target_bank == 3'd1) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_2 = replace_mode ? ((way_choose == 2'b01) ? ((target_bank == 3'd2) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_3 = replace_mode ? ((way_choose == 2'b01) ? ((target_bank == 3'd3) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_4 = replace_mode ? ((way_choose == 2'b01) ? ((target_bank == 3'd4) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_5 = replace_mode ? ((way_choose == 2'b01) ? ((target_bank == 3'd5) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_6 = replace_mode ? ((way_choose == 2'b01) ? ((target_bank == 3'd6) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_1_bank_7 = replace_mode ? ((way_choose == 2'b01) ? ((target_bank == 3'd7) && rvalid) : 1'b0) : 1'b0;

assign ram_en_way_2_bank_0 = replace_mode ? ((way_choose == 2'b10) ? ((target_bank == 3'd0) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_2_bank_1 = replace_mode ? ((way_choose == 2'b10) ? ((target_bank == 3'd1) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_2_bank_2 = replace_mode ? ((way_choose == 2'b10) ? ((target_bank == 3'd2) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_2_bank_3 = replace_mode ? ((way_choose == 2'b10) ? ((target_bank == 3'd3) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_2_bank_4 = replace_mode ? ((way_choose == 2'b10) ? ((target_bank == 3'd4) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_2_bank_5 = replace_mode ? ((way_choose == 2'b10) ? ((target_bank == 3'd5) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_2_bank_6 = replace_mode ? ((way_choose == 2'b10) ? ((target_bank == 3'd6) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_2_bank_7 = replace_mode ? ((way_choose == 2'b10) ? ((target_bank == 3'd7) && rvalid) : 1'b0) : 1'b0;

assign ram_en_way_3_bank_0 = replace_mode ? ((way_choose == 2'b11) ? ((target_bank == 3'd0) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_3_bank_1 = replace_mode ? ((way_choose == 2'b11) ? ((target_bank == 3'd1) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_3_bank_2 = replace_mode ? ((way_choose == 2'b11) ? ((target_bank == 3'd2) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_3_bank_3 = replace_mode ? ((way_choose == 2'b11) ? ((target_bank == 3'd3) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_3_bank_4 = replace_mode ? ((way_choose == 2'b11) ? ((target_bank == 3'd4) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_3_bank_5 = replace_mode ? ((way_choose == 2'b11) ? ((target_bank == 3'd5) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_3_bank_6 = replace_mode ? ((way_choose == 2'b11) ? ((target_bank == 3'd6) && rvalid) : 1'b0) : 1'b0;
assign ram_en_way_3_bank_7 = replace_mode ? ((way_choose == 2'b11) ? ((target_bank == 3'd7) && rvalid) : 1'b0) : 1'b0;

/*tag*/
assign tag_0_en = replace_mode ? ((way_choose == 2'b00) ? 1'b1 : 1'b0) : 1'b0;
assign tag_1_en = replace_mode ? ((way_choose == 2'b01) ? 1'b1 : 1'b0) : 1'b0;
assign tag_2_en = replace_mode ? ((way_choose == 2'b10) ? 1'b1 : 1'b0) : 1'b0;
assign tag_3_en = replace_mode ? ((way_choose == 2'b11) ? 1'b1 : 1'b0) : 1'b0;

////workstate
//state
reg [3:0] work_state;   //00: hit  /01: seek to replace and require  /11: wait for axi
wire req_but_miss;
assign req_but_miss = inst_req_reg && (! succeed);

reg prefetch;
always @(posedge clk)
	begin
		if(rst)
		begin
			prefetch <= 1'b0;
		end
		else if(work_state == 4'b0110)
		begin
			prefetch <= 1'd1;
		end
		else if((work_state == 4'b0011) && rvalid && (target_bank == 3'd7) && (rid == 4'd3))
        begin
            prefetch <= 1'd0;
        end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			work_state <= 4'b0100;
		end
		else if((work_state == 4'b0100) && cache_work_0)
		begin
			work_state <= 4'b0000;
		end
		else if(work_state == 4'b0101)
		begin
			work_state <= 4'b0000;
		end
		else if(work_state == 4'b0010)
		begin
			work_state <= 4'b0111;
		end
		else if((work_state == 4'b0000) && req_but_miss && (offset[4] == 1'b1)) // miss or invalid, prefetch
		begin
			work_state <= 4'b0110;
		end
		else if((work_state == 4'b0000) && req_but_miss) // miss or invalid, enter state 001
		begin
			work_state <= 4'b0001;
		end
		else if((work_state == 4'b0000) && index_change) 
		begin
			work_state <= 4'b0101;
		end
        else if((work_state == 4'b0001) && arready && (arid == 4'd3)) // after axi ack addr, enter state 011
        begin
            work_state <= 4'b0011;
        end
		else if((work_state == 4'b0110) && arready && (arid == 4'd3)) // 
        begin
            work_state <= 4'b0011;
        end
		else if((work_state == 4'b0011) && rlast && (rid == 4'd3) && !prefetch) // after axi rlast(trans end), enter state 010
        begin
            work_state <= 4'b0000;
        end
		else if((work_state == 4'b0011) && rvalid && (target_bank == 3'd7) && (rid == 4'd3) && prefetch) // after axi rlast(trans end), enter state 010
        begin
            work_state <= 4'b0010;
        end
		else if((work_state == 4'b0111) && rlast && (rid == 4'd3)) // after axi rlast(trans end), enter state 010
        begin
            work_state <= 4'b0101;
        end
		// else if(work_state == 3'b010)// state 10 is used for: wait for ram to store data
		// begin
		// 	work_state <= 3'b000;
		// end
        else
        begin
            work_state <= work_state; 
        end
	end

reg inst_addr_ok_history;
always @(posedge clk)
	begin
		if(rst)
		begin
			inst_addr_ok_history <= 1'b0;
		end
        else 
        begin
           	inst_addr_ok_history <= inst_addr_ok;
        end
	end


reg addr_data_equal;
always @(posedge clk)
	begin
		if(rst)
		begin
			addr_data_equal <= 1'b0;
		end
        else if(inst_addr_ok && !inst_data_ok)
        begin
            addr_data_equal <= 1'b1; 
        end
		else if(inst_data_ok && !inst_addr_ok)
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

reg index_change_reg;
always @(posedge clk)
	begin
		if(rst)
		begin
			index_change_reg <= 1'd0;
		end
		else
		begin
            index_change_reg <= index_change;
        end
	end


//sram control
assign inst_addr_ok = inst_req & (work_state == 4'b0000) & (addr_data_equal ? inst_data_ok : 1'b1);   ////////////////
assign inst_data_ok = inst_req_reg && succeed /*&& succeed_ack*/ && (work_state == 4'b0000);// || ((work_state == 3'b010) ? 1'b1 : 1'b0);   // state 10 after rlast, 
assign inst_rdata   = cache_rdata;  // state 10 ensure that right state is ready

//axi control
assign arid		= 4'd3;
assign araddr   = {inst_addr_reg[31:5],5'b0};
assign arlen    = (work_state == 4'b0110) ? 8'd15 : 8'd7;
assign arsize   = 3'd2; 
assign arburst  = 2'b01;
assign arlock   = 2'b0;
assign arcache  = 4'b0;
assign arprot   = 3'b0;
assign arvalid  = ((work_state == 4'b0001) || (work_state == 4'b0110)) ? 1'b1 : 1'b0;

assign rready 	= ((work_state == 4'b0011) || (work_state == 4'b0111)) ? 1'b1 : 1'b0;

//do not care
assign awid     = 4'd2;
assign awlen    = 8'b0;
assign awburst  = 2'b0;
assign awlock   = 2'b0;
assign awcache  = 4'b0;
assign awprot   = 3'b0;
assign awaddr   = 32'b0;
assign awvalid  = 1'b0;
assign awsize   = 3'd2;

assign wdata    = 32'b0;
assign wvalid   = 1'b0;
assign wid      = 4'd2;
assign wlast    = 1'b0;

assign bresp    = 2'b0;
assign bready   = 1'b0;

////LRU
reg [127:0] lru;
reg [127:0] lru_0_0;
reg [127:0] lru_0_1;
reg [127:0] lru_1_0;
reg [127:0] lru_1_1;
reg [127:0] lru_2_0;
reg [127:0] lru_2_1;
reg [127:0] lru_3_0;
reg [127:0] lru_3_1;
wire lru_0_0_input;
wire lru_0_1_input;
wire lru_1_0_input;
wire lru_1_1_input;
wire lru_2_0_input;
wire lru_2_1_input;
wire lru_3_0_input;
wire lru_3_1_input;
assign lru_0_0_input = hit_1 || hit_3;
assign lru_0_1_input = hit_2 || hit_3;
assign lru_1_0_input = hit_1 || hit_3;
assign lru_1_1_input = hit_2 || hit_3;


always @(posedge clk)
	begin
		if(rst)
		begin
			lru_0_0 <= 128'h0;
			lru_0_1 <= 128'h0;
			lru_1_0 <= 128'hffffffffffffffffffffffffffffffff;
			lru_1_1 <= 128'h0;
			lru_2_0 <= 128'h0;
			lru_2_1 <= 128'hffffffffffffffffffffffffffffffff;
			lru_3_0 <= 128'hffffffffffffffffffffffffffffffff;
			lru_3_1 <= 128'hffffffffffffffffffffffffffffffff;
		end
		else if((work_state == 3'b000) && inst_req_reg && succeed ) // require and hit, so update lru
		begin
			if((lru_3_0[index] == lru_0_0_input) && (lru_3_1[index] == lru_0_1_input))
			begin
				lru_0_0[index] <= lru_0_0_input;
				lru_0_1[index] <= lru_0_1_input;
				lru_1_0[index] <= lru_0_0[index];
				lru_1_1[index] <= lru_0_1[index];
				lru_2_0[index] <= lru_1_0[index];
				lru_2_1[index] <= lru_1_1[index];
				lru_3_0[index] <= lru_2_0[index];
				lru_3_1[index] <= lru_2_1[index];
			end
			else if((lru_2_0[index] == lru_0_0_input) && (lru_2_1[index] == lru_0_1_input))
			begin
				lru_0_0[index] <= lru_0_0_input;
				lru_0_1[index] <= lru_0_1_input;
				lru_1_0[index] <= lru_0_0[index];
				lru_1_1[index] <= lru_0_1[index];
				lru_2_0[index] <= lru_1_0[index];
				lru_2_1[index] <= lru_1_1[index];
			end
			else if((lru_1_0[index] == lru_0_0_input) && (lru_1_1[index] == lru_0_1_input))
			begin
				lru_0_0[index] <= lru_0_0_input;
				lru_0_1[index] <= lru_0_1_input;
				lru_1_0[index] <= lru_0_0[index];
				lru_1_1[index] <= lru_0_1[index];
			end
			else 
			begin
				lru_0_0[index] <= lru_0_0_input;
				lru_0_1[index] <= lru_0_1_input;
			end
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
		else if(inst_addr_ok) // 
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
		else if(inst_addr_ok && (req_counter_0 == 32'hffffffff)) 
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
		else if(inst_addr_ok && (req_counter_1 == 32'hffffffff)) 
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