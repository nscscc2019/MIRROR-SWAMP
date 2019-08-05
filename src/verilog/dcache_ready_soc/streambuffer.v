`timescale 1ns / 1ps
module streambuffer_control
(
    input          clk,
    input          rst,
    input   [31:0] target_addr,
    input          target_req,
    output         target_addr_ok,
    output         target_data_ok,
    output reg [31:0] target_data_bank_0,
    output reg [31:0] target_data_bank_1,
    output reg [31:0] target_data_bank_2,
    output reg [31:0] target_data_bank_3,
    output reg [31:0] target_data_bank_4,
    output reg [31:0] target_data_bank_5,
    output reg [31:0] target_data_bank_6,
    output reg [31:0] target_data_bank_7,
    output         hit,
    input          take,
   
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

);

//depth_choose
wire    hit_0;
wire    hit_1;

assign  hit_0    = (depth_0_tag == target_addr[31:12]) ? 1'b1 : 1'b0;
assign  hit_1    = (depth_1_tag == target_addr[31:12]) ? 1'b1 : 1'b0;
assign  hit      = hit_0 || hit_1;

reg  [2:0]  bank_choose;   

// assign  target_data_bank_0 = hit_0 ? depth_0_bank_0 : depth_1_bank_0;
// assign  target_data_bank_1 = hit_0 ? depth_0_bank_1 : depth_1_bank_1;
// assign  target_data_bank_2 = hit_0 ? depth_0_bank_2 : depth_1_bank_2;
// assign  target_data_bank_3 = hit_0 ? depth_0_bank_3 : depth_1_bank_3;
// assign  target_data_bank_4 = hit_0 ? depth_0_bank_4 : depth_1_bank_4;
// assign  target_data_bank_5 = hit_0 ? depth_0_bank_5 : depth_1_bank_5;
// assign  target_data_bank_6 = hit_0 ? depth_0_bank_6 : depth_1_bank_6;
// assign  target_data_bank_7 = hit_0 ? depth_0_bank_7 : depth_1_bank_7;

assign  output_bank_0_input = depth_choose ? depth_1_bank_0 : depth_0_bank_0;
assign  output_bank_1_input = depth_choose ? depth_1_bank_1 : depth_0_bank_1;
assign  output_bank_2_input = depth_choose ? depth_1_bank_2 : depth_0_bank_2;
assign  output_bank_3_input = depth_choose ? depth_1_bank_3 : depth_0_bank_3;
assign  output_bank_4_input = depth_choose ? depth_1_bank_4 : depth_0_bank_4;
assign  output_bank_5_input = depth_choose ? depth_1_bank_5 : depth_0_bank_5;
assign  output_bank_6_input = depth_choose ? depth_1_bank_6 : depth_0_bank_6;
assign  output_bank_7_input = depth_choose ? depth_1_bank_7 : depth_0_bank_7;

always @(posedge clk)
	begin
		if(rst)
		begin
			target_data_bank_0 <= 1'b0;
		end
		else if(work_state == 4'd0)
		begin
			target_data_bank_0 <= output_bank_0_input;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			target_data_bank_1 <= 1'b0;
		end
		else if(work_state == 4'd0)
		begin
			target_data_bank_1 <= output_bank_1_input;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			target_data_bank_2 <= 1'b0;
		end
		else if(work_state == 4'd0)
		begin
			target_data_bank_2 <= output_bank_2_input;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			target_data_bank_3 <= 1'b0;
		end
		else if(work_state == 4'd0)
		begin
			target_data_bank_3 <= output_bank_3_input;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			target_data_bank_4 <= 1'b0;
		end
		else if(work_state == 4'd0)
		begin
			target_data_bank_4 <= output_bank_4_input;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			target_data_bank_5 <= 1'b0;
		end
		else if(work_state == 4'd0)
		begin
			target_data_bank_5 <= output_bank_5_input;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			target_data_bank_6 <= 1'b0;
		end
		else if(work_state == 4'd0)
		begin
			target_data_bank_6 <= output_bank_6_input;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			target_data_bank_7 <= 1'b0;
		end
		else if(work_state == 4'd0)
		begin
			target_data_bank_7 <= output_bank_7_input;
		end
	end
// assign  data_depth_0 =  ({32{(bank_choose == 3'd0)}} & depth_0_bank_0) |
//                         ({32{(bank_choose == 3'd1)}} & depth_0_bank_1) |
//                         ({32{(bank_choose == 3'd2)}} & depth_0_bank_2) |
//                         ({32{(bank_choose == 3'd3)}} & depth_0_bank_3) |
//                         ({32{(bank_choose == 3'd4)}} & depth_0_bank_4) |
//                         ({32{(bank_choose == 3'd5)}} & depth_0_bank_5) |
//                         ({32{(bank_choose == 3'd6)}} & depth_0_bank_6) |
//                         ({32{(bank_choose == 3'd7)}} & depth_0_bank_7) ;
// assign  data_depth_1 =  ({32{(bank_choose == 3'd0)}} & depth_1_bank_0) |
//                         ({32{(bank_choose == 3'd1)}} & depth_1_bank_1) |
//                         ({32{(bank_choose == 3'd2)}} & depth_1_bank_2) |
//                         ({32{(bank_choose == 3'd3)}} & depth_1_bank_3) |
//                         ({32{(bank_choose == 3'd4)}} & depth_1_bank_4) |
//                         ({32{(bank_choose == 3'd5)}} & depth_1_bank_5) |
//                         ({32{(bank_choose == 3'd6)}} & depth_1_bank_6) |
//                         ({32{(bank_choose == 3'd7)}} & depth_1_bank_7) ;


reg depth_choose;
always @(posedge clk)
	begin
		if(rst)
		begin
			depth_choose <= 1'b0;
		end
		else if(work_state == )
		begin
			depth_choose <= !depth_choose;
		end
	end

reg [3:0] work_state;
always @(posedge clk)
	begin
		if(rst)
		begin
			work_state <= 4'd15;
		end
		else if(work_state == 4'd15)
		begin
			work_state <= 4'd0;
		end
        else if((work_state == 4'd0) && take)
        begin
            work_state == 4'd1;
        end
	end

reg [19:0] depth_0_tag;
reg [19:0] depth_1_tag;

reg [31:0] depth_0_bank_0;
reg [31:0] depth_0_bank_1;
reg [31:0] depth_0_bank_2;
reg [31:0] depth_0_bank_3;
reg [31:0] depth_0_bank_4;
reg [31:0] depth_0_bank_5;
reg [31:0] depth_0_bank_6;
reg [31:0] depth_0_bank_7;

reg [31:0] depth_1_bank_0;
reg [31:0] depth_1_bank_1;
reg [31:0] depth_1_bank_2;
reg [31:0] depth_1_bank_3;
reg [31:0] depth_1_bank_4;
reg [31:0] depth_1_bank_5;
reg [31:0] depth_1_bank_6;
reg [31:0] depth_1_bank_7;

//axi control
assign arid		= 4'd3;
assign araddr   = {target_addr,5'b0};
assign arlen    = 8'd7;
assign arsize   = 3'd2; //////??????????
assign arburst  = 2'b01;
assign arlock   = 2'b0;
assign arcache  = 4'b0;
assign arprot   = 3'b0;
assign arvalid  = (work_state == 3'b001) ? 1'b1 : 1'b0;

assign rready 	= (work_state == 3'b011) ? 1'b1 : 1'b0;

//do not care
assign awid     = 4'd3; ////////?????????
assign awlen    = 8'b0;
assign awburst  = 2'b0;
assign awlock   = 2'b0;
assign awcache  = 4'b0;
assign awprot   = 3'b0;
assign awaddr   = 32'b0;
assign awvalid  = 1'b0;
assign bvalid   = 1'b0;
assign wdata    = 32'b0;
assign wvalid   = 1'b0;

assign wid      = 4'd3;
assign wlast    = 1'b1;

assign bid      = 4'd3;/////????????
assign bresp    = 2'b0;

endmodule