`timescale 10ns / 1ns
module div(
	input  wire        div_clk,
	input  wire        resetn,
	input  wire        div,
	input  wire        div_signed,
	input  wire [31:0] x,
	input  wire [31:0] y,
	output wire [31:0] s,
	output wire [31:0] r,
	output wire 	   complete
);

	reg           start;
	wire          x_sign;
	wire          y_sign;
	wire          s_sign;
	wire          r_sign;
	reg           s_sign_r;
	reg           r_sign_r;
	wire [  31:0] x_0;
	wire [  31:0] y_0;
	reg  [  63:0] x_div;
	reg  [  31:0] y_div;
	reg  [  31:0] count;
	wire [1055:0] divt;
	reg  [  31:0] s_r;
    reg  [2047:0] x_tmp;

	assign x_sign   = div_signed & x[31];
	assign y_sign   = div_signed & y[31];
	assign s_sign   = div_signed & (x[31] ^ y[31]);
	assign r_sign   = x_sign;
	assign s        = ({32{s_sign_r}}^s_r) + {30'd0,s_sign_r}; 
	assign r        = ({32{r_sign_r}}^x_tmp[2015:1984]) + r_sign_r;
	assign x_0      = (({32{x_sign}} ^ x) + x_sign);
	assign y_0      = (({32{y_sign}} ^ y) + y_sign);
	assign complete = count[31];

	always @(posedge div_clk)
	begin
		if(!resetn) begin
			start <= 1'b0;
		end
		else if(div) begin		
			x_div 	 <= {32'b0,x_0};
			y_div 	 <= y_0;
			s_sign_r <= s_sign;
			r_sign_r <= r_sign;
			start 	 <= ~(|count);
		end
		else begin
			start    <= 1'b0;
		end
	end
	
	assign divt[32:0]  = x_div[63:31] - {1'b0,y_div};
	generate genvar i;
        for (i = 1; i < 32; i = i + 1) begin
			assign divt[33*i+32:33*i]  = x_tmp[63*i-1:63*i-33] - {1'b0,y_div};
        end
    endgenerate

	always @(posedge div_clk)
	begin
		if(!resetn) begin
			count[0]               <= 1'b0;
		end
		else begin
			count[0]               <= start;
			s_r  [31]              <= !divt[32];
			x_tmp[63:31]           <= divt[32] ? x_div[63:31] : divt[32:0];
			x_tmp[30: 0]           <= x_div[30: 0];
		end
	end

    generate genvar j;
    for (j = 1; j < 31; j = j + 1) begin
	always @(posedge div_clk) begin
		if(!resetn) begin
			count[j]               <= 1'b0;
		end
		else begin
			count[j]               <= count[j-1];
			s_r  [31-j]            <= !divt[33*j+32];
			x_tmp[63*j+63:63*j+31] <= divt[33*j+32] ? x_tmp[63*j-1 : 63*j-33] : divt[33*j+32 : 33*j];
			x_tmp[63*j+30:64*j]	   <= x_tmp[63*j-34 : 64*j-64];
		end
	end
    end
    endgenerate

	always @(posedge div_clk)
	begin
		if(!resetn) begin
			count[31]              <= 1'b0;
		end
		else begin
            count[31]              <= count[30];
			s_r  [0]               <= !divt[1055];
			x_tmp[2016: 1984]      <= divt[1055] ? x_tmp[1952: 1920] : divt[1055:1023];
		end
	end
endmodule