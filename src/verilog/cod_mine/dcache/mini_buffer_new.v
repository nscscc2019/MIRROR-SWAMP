`timescale 1ns / 1ps
module mini_buffer
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
    input           dcache_data_data_ok
);

//   assign         dcache_data_req    = cpu_data_req;
//   assign         dcache_data_wr     = cpu_data_wr ;
//   assign         dcache_data_size   = cpu_data_size;
//   assign         dcache_data_addr   = cpu_data_addr;
//   assign         dcache_data_wdata  = cpu_data_wdata;
//   assign         dcache_data_wstrb  = cpu_data_wstrb;
//   assign         cpu_data_rdata     = dcache_data_rdata;
//   assign         cpu_data_addr_ok   = dcache_data_addr_ok;
//   assign         cpu_data_data_ok   = dcache_data_data_ok;

wire rst;
assign rst=!resetn; 

reg [7:0]   s_valid        ;
reg [2:0]   s_index   [0:7];
reg [31:0]  s_addr    [0:7];
reg [31:0]  s_data    [0:7];
reg [3:0]   s_wstrb   [0:7];

reg [2:0]   A;
reg [2:0]   B;

wire [2:0] symbol_A;
wire [2:0] symbol_B;
assign symbol_A = A + 3'd1;
assign symbol_B = B + 3'd1;

wire full;
wire empty;
assign full     = (symbol_B == A) ? 1'b1 : 1'b0;
assign empty    = (A == B) ? 1'b1 : 1'b0;

//schedulor
reg cpu_data_req_history;

always @(posedge clk)
	begin
		if(rst)
		begin
			cpu_data_req_history <= 1'b0;
		end
        else if(cpu_data_addr_ok)
        begin
            cpu_data_req_history <= cpu_data_req;
        end
        else if(cpu_data_data_ok)
        begin
            cpu_data_req_history <= 1'b0;
        end
	end

//workstate

wire        buffer_data_ok_r;
wire        buffer_addr_ok_r;
wire [31:0] buffer_addr_r;
wire [31:0] buffer_rdata_r;
wire [31:0] buffer_wdata_r;
wire [3:0]  buffer_wstrb_r;
wire        buffer_req_r;
wire        buffer_wr_r;

wire        buffer_data_ok_l;
wire        buffer_addr_ok_l;
wire [31:0] buffer_addr_l;
wire [31:0] buffer_rdata_l;
wire [31:0] buffer_wdata_l;
wire [3:0]  buffer_wstrb_l;
wire        buffer_req_l;
wire        buffer_wr_l;


reg [3:0] buffer_workstate;
reg [3:0] axi_workstate;
always @(posedge clk)
	begin
		if(rst)
		begin
			buffer_workstate <= 4'd0;        
		end
        else if(buffer_workstate == 4'd0)
        begin
            buffer_workstate <= 4'd1;
        end
        else if(buffer_workstate == 4'd1)
        begin
            if(buffer_addr_ok_r && !buffer_data_ok_r)
            begin
                buffer_workstate <= 4'd2;
            end
        end
        else if(buffer_workstate == 4'd2)
        begin
            if(buffer_data_ok_r && !buffer_addr_ok_r)
            begin
                buffer_workstate <= 4'd1;
            end
        end
    end

wire        axi_data_ok;
wire        axi_addr_ok;
wire [31:0] axi_addr;
wire [31:0] axi_rdata;
wire [31:0] axi_wdata;
wire [3:0]  axi_wstrb;
wire [1:0]  axi_size;
wire        axi_req;
wire        axi_wr;

always @(posedge clk)
	begin
		if(rst)
		begin
			axi_workstate <= 4'd0;        
		end
        else if(axi_workstate == 4'd0)
        begin
            axi_workstate <= 4'd1;
        end
        else if(axi_workstate == 4'd1)
        begin
            if(axi_addr_ok && !axi_data_ok)
            begin
                axi_workstate <= 4'd2;
            end
        end
        else if(axi_workstate == 4'd2)
        begin
            if(axi_data_ok && !axi_addr_ok)
            begin
                axi_workstate <= 4'd1;
            end
        end
    end

wire        buffer_push;
assign      buffer_push = (!full) && cpu_data_wr && cpu_data_req;

reg buffer_data_ok_out;
always @(posedge clk)
	begin
		if(rst)
		begin
			buffer_data_ok_out <= 1'b0;
		end
        else if(buffer_push)
        begin
            buffer_data_ok_out <= 1'b1;
        end
        else if(cpu_data_data_ok && (axi_workstate != 4'd2))
        begin
            buffer_data_ok_out <= 1'b0;
        end
	end

assign buffer_addr_ok_l = buffer_push;
assign buffer_data_ok_l = buffer_data_ok_out;

assign buffer_addr_r    = s_addr[A];
assign buffer_wr_r      = 1'b1;
assign buffer_req_r     = ((buffer_workstate == 4'd1) || buffer_data_ok_r) && !empty;
assign buffer_wstrb_r   = s_wstrb[A];
assign buffer_wdata_r   = s_data[A];
assign buffer_addr_ok_r = buffer_req_r && dcache_data_addr_ok; 
assign buffer_data_ok_r = (buffer_workstate == 4'd2) && (axi_workstate != 4'd2) && dcache_data_data_ok;

wire axi_work;
assign axi_work     = empty;
assign axi_data_ok  = (axi_workstate == 4'd2) && dcache_data_data_ok;
assign axi_addr_ok  = axi_req && dcache_data_addr_ok;
assign axi_addr     = cpu_data_addr;
assign axi_rdata    = dcache_data_rdata;
assign axi_wdata    = cpu_data_wdata;
assign axi_wstrb    = cpu_data_wstrb;
assign axi_req      = cpu_data_req;
assign axi_size     = cpu_data_size;
assign axi_wr       = cpu_data_wr;

assign dcache_data_req      = (axi_work) ? axi_req      : buffer_req_r;
assign dcache_data_wr       = (axi_work) ? axi_wr       : buffer_wr_r;
assign dcache_data_size     = (axi_work) ? axi_size     : 3'd2;
assign dcache_data_addr     = (axi_work) ? axi_addr     : buffer_addr_r;
assign dcache_data_wdata    = (axi_work) ? axi_wdata    : buffer_wdata_r;
assign dcache_data_wstrb    = (axi_work) ? axi_wstrb    : buffer_wstrb_r;

assign cpu_data_rdata       = axi_rdata;
assign cpu_data_addr_ok     = axi_addr_ok || buffer_addr_ok_l;
assign cpu_data_data_ok     = ((axi_workstate == 4'd2)) ? axi_data_ok : buffer_data_ok_l;

always @(posedge clk)
	begin
		if(rst)
		begin
			s_index[0] <= 3'd0;
            s_index[1] <= 3'd1;
            s_index[2] <= 3'd2;
            s_index[3] <= 3'd3;
            s_index[4] <= 3'd4;
            s_index[5] <= 3'd5; 
            s_index[6] <= 3'd6;
            s_index[7] <= 3'd7;
		end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			A <= 3'd0;
		end
        else if((buffer_workstate == 4'd2) && buffer_data_ok_r && !empty)
        begin
            A <= A + 3'd1;
        end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			B <= 3'd0;
		end
        else if(buffer_addr_ok_l && buffer_push)
        begin
            B <= B + 3'd1;
        end
	end

always @(posedge clk)
	begin
        if(buffer_addr_ok_l && buffer_push)
        begin
            s_addr[B] <= cpu_data_addr;
        end
	end

always @(posedge clk)
	begin
        if(buffer_push && buffer_addr_ok_l)
        begin
            s_wstrb[B] <= cpu_data_wstrb;
        end
	end

always @(posedge clk)
	begin
        if(buffer_push && buffer_addr_ok_l)
        begin
            s_data[B] <= cpu_data_wdata;
        end
	end

reg push_history;
always @(posedge clk)
	begin
        if(rst)
        begin
            push_history <= 1'b0;
        end
        else if(buffer_push && buffer_addr_ok_l)
        begin
            push_history <= 1'b1;
        end
        else
        begin
            push_history <= 1'b0;
        end
	end

reg [31:0] counter_full;
always @(posedge clk)
	begin
        if(rst)
        begin
            counter_full <= 32'b0;
        end
        else if(push_history && full)
        begin
            counter_full <= counter_full + 32'd1;
        end
	end

endmodule
