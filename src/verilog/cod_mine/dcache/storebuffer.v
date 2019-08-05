`timescale 1ns / 1ps
module store_buffer
(
    input          clk,
    input          resetn,

    input          cpu_data_cache  ,
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

wire [7:0]valid_out;
assign valid_out[0] = (A == s_index[0]) ? 1'b0 : s_valid[0];
assign valid_out[1] = (A == s_index[1]) ? 1'b0 : s_valid[1];
assign valid_out[2] = (A == s_index[2]) ? 1'b0 : s_valid[2];
assign valid_out[3] = (A == s_index[3]) ? 1'b0 : s_valid[3];
assign valid_out[4] = (A == s_index[4]) ? 1'b0 : s_valid[4];
assign valid_out[5] = (A == s_index[5]) ? 1'b0 : s_valid[5];
assign valid_out[6] = (A == s_index[6]) ? 1'b0 : s_valid[6];
assign valid_out[7] = (A == s_index[7]) ? 1'b0 : s_valid[7];


//schedulor
wire [7:0] load_hit;
wire [7:0] store_hit;
wire load_succeed;
wire store_succeed;
wire req_but_miss;
wire store_no_merge;

assign load_hit[0] =    (s_addr[0] == cpu_data_addr) && valid_out[0] && (s_wstrb[0] == 4'b1111);
assign load_hit[1] =    (s_addr[1] == cpu_data_addr) && valid_out[1] && (s_wstrb[1] == 4'b1111); 
assign load_hit[2] =    (s_addr[2] == cpu_data_addr) && valid_out[2] && (s_wstrb[2] == 4'b1111);
assign load_hit[3] =    (s_addr[3] == cpu_data_addr) && valid_out[3] && (s_wstrb[3] == 4'b1111); 
assign load_hit[4] =    (s_addr[4] == cpu_data_addr) && valid_out[4] && (s_wstrb[4] == 4'b1111);
assign load_hit[5] =    (s_addr[5] == cpu_data_addr) && valid_out[5] && (s_wstrb[5] == 4'b1111); 
assign load_hit[6] =    (s_addr[6] == cpu_data_addr) && valid_out[6] && (s_wstrb[6] == 4'b1111);
assign load_hit[7] =    (s_addr[7] == cpu_data_addr) && valid_out[7] && (s_wstrb[7] == 4'b1111);

assign store_hit[0] =    (s_addr[0] == cpu_data_addr) && valid_out[0];
assign store_hit[1] =    (s_addr[1] == cpu_data_addr) && valid_out[1]; 
assign store_hit[2] =    (s_addr[2] == cpu_data_addr) && valid_out[2];
assign store_hit[3] =    (s_addr[3] == cpu_data_addr) && valid_out[3]; 
assign store_hit[4] =    (s_addr[4] == cpu_data_addr) && valid_out[4];
assign store_hit[5] =    (s_addr[5] == cpu_data_addr) && valid_out[5]; 
assign store_hit[6] =    (s_addr[6] == cpu_data_addr) && valid_out[6];
assign store_hit[7] =    (s_addr[7] == cpu_data_addr) && valid_out[7];

assign load_succeed     = !cpu_data_wr && cpu_data_cache && cpu_data_req && (load_hit != 8'd0);
assign req_but_miss     = !cpu_data_wr && cpu_data_cache && cpu_data_req && (load_hit == 8'd0);
assign store_succeed    =  cpu_data_wr && cpu_data_cache && cpu_data_req && (store_hit != 8'd0);
assign store_no_merge   =  cpu_data_wr && cpu_data_cache && cpu_data_req && (store_hit == 8'd0);


reg [7:0]load_hit_history;
always @(posedge clk)
	begin
		if(rst)
		begin
			load_hit_history <= 8'd0;
		end
        else 
        begin
            load_hit_history <= load_hit;
        end
	end

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

assign cpu_data_data_ok = cpu_data_req_history && (hit_history != 8'd0);



wire  uncache_req;
assign uncache_req = cpu_data_req & !cpu_data_cache; 

wire  load_miss;
assign load_miss = req_but_miss & !cpu_data_wr;


//workstate
reg [3:0] workstate;
always @(posedge clk)
	begin
		if(rst)
		begin
			workstate <= 4'd0;         //0: idle ,free
		end
        else if(workstate == 4'd0)
        begin
            workstate <= 4'd1;         //1: axi locked by uncache sw or lw
        end
        else if(workstate == 4'd2)
        begin
            if(dcache_data_addr_ok)
            begin
                workstate <= 4'd3;    //3: buffer wait for dcache finish
            end
        end
        else if(workstate == 4'd3)
        begin
            if(dcache_data_data_ok && (load_miss || uncache_req))
            begin
                workstate <= 4'd1;
            end
            else if(dcache_data_data_ok && empty)
            begin
                workstate <= 4'd1;
            end
            else if(dcache_data_data_ok && !empty)
            begin
                workstate <= 4'd2;   //2: buffer req and wait for dcache ack
            end
        end
        else if(workstate == 4'd1)
        begin
            if(cpu_data_addr_ok )
            begin
                workstate <= 4'd6;  // 6: cpu wait for outer finish
            end
            else if(!dcache_data_req && !empty)
            begin
                workstate <= 4'd2;
            end
        end
        else if(workstate == 4'd6)
        begin
            if(dcache_data_data_ok && (load_miss || uncache_req))
            begin
                workstate <= 4'd1;
            end
            else if(dcache_data_data_ok && !empty)
            begin
                workstate <= 4'd2;
            end
            else if(dcache_data_data_ok)
            begin
                workstate <= 4'd1;
            end
        end
	end

reg         buffer_data_ok;
wire        buffer_addr_ok;
wire [31:0] buffer_addr;
wire [31:0] buffer_rdata;
wire [31:0] buffer_wdata;
wire [3:0]  buffer_wstrb;
wire        buffer_req;
wire        buffer_wr;

wire        buffer_push;
assign      buffer_push = (!full) && cpu_data_wr && cpu_data_cache && cpu_data_req;

always @(posedge clk)
	begin
		if(rst)
		begin
			buffer_data_ok <= 1'b0;
		end
        else if(buffer_addr_ok)
        begin
            buffer_data_ok <= 1'b1;
        end
        else
        begin
            buffer_data_ok <= 1'b0;
        end
	end

assign buffer_wr      = 1'b1;
assign buffer_req     = (workstate == 4'd2) ? s_valid[A] : 1'b0;
assign buffer_wstrb   = s_wstrb[A];
assign buffer_wdata   = s_data[A];
assign buffer_rdata   = ({32{load_hit_history[0]}} & s_data[0]) |
                        ({32{load_hit_history[1]}} & s_data[1]) |
                        ({32{load_hit_history[2]}} & s_data[2]) |
                        ({32{load_hit_history[3]}} & s_data[3]) |
                        ({32{load_hit_history[4]}} & s_data[4]) |
                        ({32{load_hit_history[5]}} & s_data[5]) |
                        ({32{load_hit_history[6]}} & s_data[6]) |
                        ({32{load_hit_history[7]}} & s_data[7]) ;
assign buffer_addr    = s_addr[A];
assign buffer_addr_ok = cpu_data_wr ? (store_succeed || buffer_push): load_succeed;

assign dcache_data_req      = (workstate == 4'd1) ? cpu_data_req : buffer_req;
assign dcache_data_wr       = (workstate == 4'd1) ? cpu_data_wr : buffer_wr;
assign dcache_data_size     = (workstate == 4'd1) ? cpu_data_size : 3'd2;
assign dcache_data_addr     = (workstate == 4'd1) ? cpu_data_addr : buffer_addr;
assign dcache_data_wdata    = (workstate == 4'd1) ? cpu_data_wdata : buffer_wdata;
assign dcache_data_wstrb    = (workstate == 4'd1) ? cpu_data_wstrb : buffer_wstrb;

assign cpu_data_rdata       = ((workstate == 4'd6)) ? dcache_data_rdata : buffer_rdata;
assign cpu_data_addr_ok     = ((workstate == 4'd1) || (workstate ==4'd6)) ? dcache_data_addr_ok : buffer_addr_ok;
assign cpu_data_data_ok     = ((workstate == 4'd6)) ? dcache_data_data_ok : buffer_data_ok;

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
			s_valid <= 8'd0;
		end
        else if((workstate == 4'd2) || ((workstate == 4'd3))
        begin
            s_valid[B] = buffer_push;
            if((workstate == 4'd3) && dcache_data_data_ok)
            begin
                s_valid[A] = 1'b0;
            end
        end
        else if(((workstate == 4'd1))
        begin
            s_valid[B] = buffer_push;
        end
	end

always @(posedge clk)
	begin
		if(rst)
		begin
			A <= 3'd7;
		end
        else if((workstate == 4'd3) && dcache_data_data_ok && !empty)
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
        else if(((workstate == 4'd2) || (workstate == 4'd3) || (workstate == 4'd1)) && dcache_data_addr_ok && !full)
        begin
            B <= B + 3'd1;
        end
	end

always @(posedge clk)
	begin
        if(buffer_push)
        begin
            s_addr[B] <= cpu_data_addr;
        end
	end

always @(posedge clk)
	begin
        if(buffer_push)
        begin
            s_wstrb[B] <= cpu_data_wstrb;
        end
        else if(store_succeed)
        begin
            s_wstrb[B] <= (s_wstrb[B] | cpu_data_wstrb);
        end
	end

wire [31:0] s_data_input;
wire [31:0] temp_wstrb;
wire [31:0] temp_wstrb_inverse;
assign temp_wstrb = {{4{cpu_data_wstrb[3]}},{4{cpu_data_wstrb[2]}},{4{cpu_data_wstrb[1]}},{4{cpu_data_wstrb[0]}}};
assign temp_wstrb_inverse = ~temp_wstrb;
assign s_data_input = (temp_wstrb & cpu_data_wdata) | (temp_wstrb_inverse & s_data[B]);

always @(posedge clk)
	begin
        if(buffer_push)
        begin
            s_data[B] <= cpu_data_wdata;
        end
        else if(store_succeed)
        begin
            s_data[B] <= s_data_input;
        end
	end


endmodule