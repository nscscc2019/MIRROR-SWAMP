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
    input           dcache_data_data_ok
);

    assign dcache_data_req = cpu_data_req;
    assign dcache_data_wr = cpu_data_wr;
    assign dcache_data_size = cpu_data_size;
    assign dcache_data_addr = cpu_data_addr;
    assign dcache_data_wdata = cpu_data_wdata;
    assign dcache_data_wstrb = cpu_data_wstrb;
    assign cpu_data_rdata = dcache_data_rdata;
    assign cpu_data_addr_ok = dcache_data_addr_ok;
    assign cpu_data_data_ok = dcache_data_data_ok;

// wire rst;
// assign rst=!resetn; 

// reg [7:0]   s_valid        ;
// reg [2:0]   s_index   [0:7];
// reg [31:0]  s_addr    [0:7];
// reg [31:0]  s_data    [0:7];
// reg [3:0]   s_wstrb   [0:7];

// reg [2:0]   A;
// reg [2:0]   B;

// wire [2:0] symbol_A;
// wire [2:0] symbol_B;
// assign symbol_A = A + 3'd1;
// assign symbol_B = B + 3'd1;

// wire full;
// wire empty;
// assign full     = (symbol_B == A) ? 1'b1 : 1'b0;
// assign empty    = (A == B) ? 1'b1 : 1'b0;

// wire [7:0]valid_out;
// assign valid_out[0] = (A == s_index[0]) ? 1'b0 : s_valid[0];
// assign valid_out[1] = (A == s_index[1]) ? 1'b0 : s_valid[1];
// assign valid_out[2] = (A == s_index[2]) ? 1'b0 : s_valid[2];
// assign valid_out[3] = (A == s_index[3]) ? 1'b0 : s_valid[3];
// assign valid_out[4] = (A == s_index[4]) ? 1'b0 : s_valid[4];
// assign valid_out[5] = (A == s_index[5]) ? 1'b0 : s_valid[5];
// assign valid_out[6] = (A == s_index[6]) ? 1'b0 : s_valid[6];
// assign valid_out[7] = (A == s_index[7]) ? 1'b0 : s_valid[7];


// //schedulor
// reg cpu_data_req_history;
// wire [7:0] load_hit;
// wire [7:0] load_hit_trivial;
// wire [7:0] store_hit;
// wire load_succeed;
// wire load_fail;
// wire store_succeed;
// wire load_miss;
// wire store_no_merge;

// assign load_hit[0] =    (s_addr[0] == cpu_data_addr) && s_valid[0] && (s_wstrb[0] == 4'b1111);
// assign load_hit[1] =    (s_addr[1] == cpu_data_addr) && s_valid[1] && (s_wstrb[1] == 4'b1111); 
// assign load_hit[2] =    (s_addr[2] == cpu_data_addr) && s_valid[2] && (s_wstrb[2] == 4'b1111);
// assign load_hit[3] =    (s_addr[3] == cpu_data_addr) && s_valid[3] && (s_wstrb[3] == 4'b1111); 
// assign load_hit[4] =    (s_addr[4] == cpu_data_addr) && s_valid[4] && (s_wstrb[4] == 4'b1111);
// assign load_hit[5] =    (s_addr[5] == cpu_data_addr) && s_valid[5] && (s_wstrb[5] == 4'b1111); 
// assign load_hit[6] =    (s_addr[6] == cpu_data_addr) && s_valid[6] && (s_wstrb[6] == 4'b1111);
// assign load_hit[7] =    (s_addr[7] == cpu_data_addr) && s_valid[7] && (s_wstrb[7] == 4'b1111);

// assign load_hit_trivial[0] =    (s_addr[0] == cpu_data_addr) && s_valid[0];
// assign load_hit_trivial[1] =    (s_addr[1] == cpu_data_addr) && s_valid[1]; 
// assign load_hit_trivial[2] =    (s_addr[2] == cpu_data_addr) && s_valid[2];
// assign load_hit_trivial[3] =    (s_addr[3] == cpu_data_addr) && s_valid[3]; 
// assign load_hit_trivial[4] =    (s_addr[4] == cpu_data_addr) && s_valid[4];
// assign load_hit_trivial[5] =    (s_addr[5] == cpu_data_addr) && s_valid[5]; 
// assign load_hit_trivial[6] =    (s_addr[6] == cpu_data_addr) && s_valid[6];
// assign load_hit_trivial[7] =    (s_addr[7] == cpu_data_addr) && s_valid[7];

// assign store_hit[0] =    (s_addr[0] == cpu_data_addr) && valid_out[0];
// assign store_hit[1] =    (s_addr[1] == cpu_data_addr) && valid_out[1]; 
// assign store_hit[2] =    (s_addr[2] == cpu_data_addr) && valid_out[2];
// assign store_hit[3] =    (s_addr[3] == cpu_data_addr) && valid_out[3]; 
// assign store_hit[4] =    (s_addr[4] == cpu_data_addr) && valid_out[4];
// assign store_hit[5] =    (s_addr[5] == cpu_data_addr) && valid_out[5]; 
// assign store_hit[6] =    (s_addr[6] == cpu_data_addr) && valid_out[6];
// assign store_hit[7] =    (s_addr[7] == cpu_data_addr) && valid_out[7];

// assign load_succeed     = !cpu_data_wr && cpu_data_req && (load_hit != 8'd0);
// assign load_miss        = !cpu_data_wr && cpu_data_req && (load_hit == 8'd0);
// assign store_succeed    =  cpu_data_wr && cpu_data_req && (store_hit != 8'd0);
// assign store_no_merge   =  cpu_data_wr && cpu_data_req && (store_hit == 8'd0);
// assign load_fail        =  ((load_hit ^ load_hit_trivial) == 8'b0) ? 1'b0 : 1'b1;


// reg [7:0]load_hit_history;
// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			load_hit_history <= 8'd0;
// 		end
//         else 
//         begin
//             load_hit_history <= load_hit;
//         end
// 	end


// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			cpu_data_req_history <= 1'b0;
// 		end
//         else if(cpu_data_addr_ok)
//         begin
//             cpu_data_req_history <= cpu_data_req;
//         end
//         else if(cpu_data_data_ok)
//         begin
//             cpu_data_req_history <= 1'b0;
//         end
// 	end

// wire [7:0] hit_history = load_hit_history;//??????? FIXIT

// //workstate
 

// wire        buffer_data_ok_r;
// wire        buffer_addr_ok_r;
// wire [31:0] buffer_addr_r;
// wire [31:0] buffer_rdata_r;
// wire [31:0] buffer_wdata_r;
// wire [3:0]  buffer_wstrb_r;
// wire        buffer_req_r;
// wire        buffer_wr_r;

// wire        buffer_data_ok_l;
// wire        buffer_addr_ok_l;
// wire [31:0] buffer_addr_l;
// wire [31:0] buffer_rdata_l;
// wire [31:0] buffer_wdata_l;
// wire [3:0]  buffer_wstrb_l;
// wire        buffer_req_l;
// wire        buffer_wr_l;


// reg [3:0] buffer_workstate;
// reg [3:0] axi_workstate;
// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			buffer_workstate <= 4'd0;        
// 		end
//         else if(buffer_workstate == 4'd0)
//         begin
//             buffer_workstate <= 4'd1;
//         end
//         else if(buffer_workstate == 4'd1)
//         begin
//             if(buffer_addr_ok_r && !buffer_data_ok_r)
//             begin
//                 buffer_workstate <= 4'd2;
//             end
//         end
//         else if(buffer_workstate == 4'd2)
//         begin
//             if(buffer_data_ok_r && !buffer_addr_ok_r)
//             begin
//                 buffer_workstate <= 4'd1;
//             end
//         end
//     end

// wire        axi_data_ok;
// wire        axi_addr_ok;
// wire [31:0] axi_addr;
// wire [31:0] axi_rdata;
// wire [31:0] axi_wdata;
// wire [3:0]  axi_wstrb;
// wire [1:0]  axi_size;
// wire        axi_req;
// wire        axi_wr;

// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			axi_workstate <= 4'd0;        
// 		end
//         else if(axi_workstate == 4'd0)
//         begin
//             axi_workstate <= 4'd1;
//         end
//         else if(axi_workstate == 4'd1)
//         begin
//             if(axi_addr_ok && !axi_data_ok)
//             begin
//                 axi_workstate <= 4'd2;
//             end
//         end
//         else if(axi_workstate == 4'd2)
//         begin
//             if(axi_data_ok && !axi_addr_ok)
//             begin
//                 axi_workstate <= 4'd1;
//             end
//         end
//     end

// wire        buffer_push;
// assign      buffer_push = (!full) && cpu_data_wr && cpu_data_req;

// reg buffer_data_ok_out;
// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			buffer_data_ok_out <= 1'b0;
// 		end
//         else if((store_succeed || buffer_push) || (load_succeed && !load_fail))
//         begin
//             buffer_data_ok_out <= 1'b1;
//         end
//         else if(cpu_data_data_ok && (axi_workstate != 4'd2))
//         begin
//             buffer_data_ok_out <= 1'b0;
//         end
// 	end

// assign buffer_addr_ok_l = (store_succeed || buffer_push) || (load_succeed && !load_fail);
// assign buffer_data_ok_l = buffer_data_ok_out;
// assign buffer_rdata_l   =({32{load_hit_history[0]}} & s_data[0]) |
//                          ({32{load_hit_history[1]}} & s_data[1]) |
//                          ({32{load_hit_history[2]}} & s_data[2]) |
//                          ({32{load_hit_history[3]}} & s_data[3]) |
//                          ({32{load_hit_history[4]}} & s_data[4]) |
//                          ({32{load_hit_history[5]}} & s_data[5]) |
//                          ({32{load_hit_history[6]}} & s_data[6]) |
//                          ({32{load_hit_history[7]}} & s_data[7]) ;

// assign buffer_addr_r    = s_addr[A];
// assign buffer_wr_r      = 1'b1;
// assign buffer_req_r     = ((buffer_workstate == 4'd1) || buffer_data_ok_r) && (!load_miss || load_fail) && s_valid[A];
// assign buffer_wstrb_r   = s_wstrb[A];
// assign buffer_wdata_r   = s_data[A];
// assign buffer_addr_ok_r = buffer_req_r && dcache_data_addr_ok; 
// assign buffer_data_ok_r = (buffer_workstate == 4'd2) && (axi_workstate != 4'd2) && dcache_data_data_ok;

// wire axi_work;
// assign axi_work     = load_miss && !load_fail;
// assign axi_data_ok  = (axi_workstate == 4'd2) && dcache_data_data_ok;
// assign axi_addr_ok  = axi_req && dcache_data_addr_ok;
// assign axi_addr     = cpu_data_addr;
// assign axi_rdata    = dcache_data_rdata;
// assign axi_wdata    = cpu_data_wdata;
// assign axi_wstrb    = cpu_data_wstrb;
// assign axi_req      = ((axi_workstate == 4'd1) || axi_data_ok) && load_miss && !load_fail;
// assign axi_size     = cpu_data_size;
// assign axi_wr       = cpu_data_wr;

// assign dcache_data_req      = (axi_work) ? axi_req      : buffer_req_r;
// assign dcache_data_wr       = (axi_work) ? axi_wr       : buffer_wr_r;
// assign dcache_data_size     = (axi_work) ? axi_size     : 3'd2;
// assign dcache_data_addr     = (axi_work) ? axi_addr     : buffer_addr_r;
// assign dcache_data_wdata    = (axi_work) ? axi_wdata    : buffer_wdata_r;
// assign dcache_data_wstrb    = (axi_work) ? axi_wstrb    : buffer_wstrb_r;

// assign cpu_data_rdata       = ((axi_workstate == 4'd2)) ? axi_rdata : buffer_rdata_l;
// assign cpu_data_addr_ok     = axi_addr_ok || buffer_addr_ok_l;
// assign cpu_data_data_ok     = ((axi_workstate == 4'd2)) ? axi_data_ok : buffer_data_ok_l;

// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			s_index[0] <= 3'd0;
//             s_index[1] <= 3'd1;
//             s_index[2] <= 3'd2;
//             s_index[3] <= 3'd3;
//             s_index[4] <= 3'd4;
//             s_index[5] <= 3'd5; 
//             s_index[6] <= 3'd6;
//             s_index[7] <= 3'd7;
// 		end
// 	end

// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			s_valid <= 8'd0;
// 		end
//         else if((buffer_push && !store_succeed) && buffer_data_ok_r )
//         begin
//             s_valid[B] <= buffer_push;
//             s_valid[A] <= 1'b0;
//         end
//         else if((buffer_push && !store_succeed) || buffer_data_ok_r)
//         begin
//             if((buffer_push && !store_succeed))
//             begin
//                 s_valid[B] <= buffer_push;
//             end
//             else if(buffer_data_ok_r)
//             begin
//                 s_valid[A] <= 1'b0;
//             end
//         end
// 	end

// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			A <= 3'd0;
// 		end
//         else if((buffer_workstate == 4'd2) && buffer_data_ok_r && !empty)
//         begin
//             A <= A + 3'd1;
//         end
// 	end

// always @(posedge clk)
// 	begin
// 		if(rst)
// 		begin
// 			B <= 3'd0;
// 		end
//         else if(buffer_addr_ok_l && buffer_push && !store_succeed)
//         begin
//             B <= B + 3'd1;
//         end
// 	end

// always @(posedge clk)
// 	begin
//         if(buffer_addr_ok_l && buffer_push)
//         begin
//             s_addr[B] <= cpu_data_addr;
//         end
// 	end

// wire[3:0] store_hit_input;
// assign store_hit_input =    ({3{(store_hit == 8'b00000001)}} & 3'd0) |
//                             ({3{(store_hit == 8'b00000010)}} & 3'd1) |
//                             ({3{(store_hit == 8'b00000100)}} & 3'd2) |
//                             ({3{(store_hit == 8'b00001000)}} & 3'd3) |
//                             ({3{(store_hit == 8'b00010000)}} & 3'd4) |
//                             ({3{(store_hit == 8'b00100000)}} & 3'd5) |
//                             ({3{(store_hit == 8'b01000000)}} & 3'd6) |
//                             ({3{(store_hit == 8'b10000000)}} & 3'd7) ;

// always @(posedge clk)
// 	begin
//         if(store_succeed && buffer_addr_ok_l)
//         begin
//             s_wstrb[store_hit_input] <= (s_wstrb[store_hit_input] | cpu_data_wstrb);
//         end
//         else if(buffer_push && buffer_addr_ok_l)
//         begin
//             s_wstrb[B] <= cpu_data_wstrb;
//         end
// 	end

// wire [31:0] s_data_rput;
// wire [31:0] temp_wstrb;
// wire [31:0] temp_wstrb_rverse;
// assign temp_wstrb = {{8{cpu_data_wstrb[3]}},{8{cpu_data_wstrb[2]}},{8{cpu_data_wstrb[1]}},{8{cpu_data_wstrb[0]}}};
// assign temp_wstrb_rverse = ~temp_wstrb;
// assign s_data_rput = (temp_wstrb & cpu_data_wdata) | (temp_wstrb_rverse & s_data[store_hit_input]);

// always @(posedge clk)
// 	begin
//         if(store_succeed && buffer_addr_ok_l)
//         begin
//             s_data[store_hit_input] <= s_data_rput;
//         end
//         else if(buffer_push && buffer_addr_ok_l)
//         begin
//             s_data[B] <= cpu_data_wdata;
//         end
// 	end
endmodule
