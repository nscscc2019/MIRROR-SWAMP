module decoder_5_32(in,out);
    
input [4:0] in;
output [31:0] out; 

wire [4:0] in;
wire [31:0 ]out;

wire [3:0] high_d;
wire [7:0] low_d;

assign high_d[3] = ( in[4]) & ( in[3]);
assign high_d[2] = ( in[4]) & (~in[3]);
assign high_d[1] = (~in[4]) & ( in[3]);
assign high_d[0] = (~in[4]) & (~in[3]);

assign low_d[7] = ( in[2]) & ( in[1]) & ( in[0]);
assign low_d[6] = ( in[2]) & ( in[1]) & (~in[0]);
assign low_d[5] = ( in[2]) & (~in[1]) & ( in[0]);
assign low_d[4] = ( in[2]) & (~in[1]) & (~in[0]);
assign low_d[3] = (~in[2]) & ( in[1]) & ( in[0]);
assign low_d[2] = (~in[2]) & ( in[1]) & (~in[0]);
assign low_d[1] = (~in[2]) & (~in[1]) & ( in[0]);
assign low_d[0] = (~in[2]) & (~in[1]) & (~in[0]);

assign out[31] = high_d[3] & low_d[7];
assign out[30] = high_d[3] & low_d[6];
assign out[29] = high_d[3] & low_d[5];
assign out[28] = high_d[3] & low_d[4];
assign out[27] = high_d[3] & low_d[3];
assign out[26] = high_d[3] & low_d[2];
assign out[25] = high_d[3] & low_d[1];
assign out[24] = high_d[3] & low_d[0];    
assign out[23] = high_d[2] & low_d[7];
assign out[22] = high_d[2] & low_d[6];
assign out[21] = high_d[2] & low_d[5];
assign out[20] = high_d[2] & low_d[4];
assign out[19] = high_d[2] & low_d[3];
assign out[18] = high_d[2] & low_d[2];
assign out[17] = high_d[2] & low_d[1];
assign out[16] = high_d[2] & low_d[0];    
assign out[15] = high_d[1] & low_d[7];
assign out[14] = high_d[1] & low_d[6];
assign out[13] = high_d[1] & low_d[5];
assign out[12] = high_d[1] & low_d[4];
assign out[11] = high_d[1] & low_d[3];
assign out[10] = high_d[1] & low_d[2];
assign out[ 9] = high_d[1] & low_d[1];
assign out[ 8] = high_d[1] & low_d[0];    
assign out[ 7] = high_d[0] & low_d[7];
assign out[ 6] = high_d[0] & low_d[6];
assign out[ 5] = high_d[0] & low_d[5];
assign out[ 4] = high_d[0] & low_d[4];
assign out[ 3] = high_d[0] & low_d[3];
assign out[ 2] = high_d[0] & low_d[2];
assign out[ 1] = high_d[0] & low_d[1];
assign out[ 0] = high_d[0] & low_d[0];    

endmodule //decoder_5_32




module decoder_6_64(in,out);

input  [ 5:0] in;
output [63:0] out; 

wire [5:0]  in;
wire [63:0] out;
wire [7:0]  high_d;
wire [7:0]  low_d;

assign high_d[7] = ( in[5]) & ( in[4]) & ( in[3]);
assign high_d[6] = ( in[5]) & ( in[4]) & (~in[3]);
assign high_d[5] = ( in[5]) & (~in[4]) & ( in[3]);
assign high_d[4] = ( in[5]) & (~in[4]) & (~in[3]);
assign high_d[3] = (~in[5]) & ( in[4]) & ( in[3]);
assign high_d[2] = (~in[5]) & ( in[4]) & (~in[3]);
assign high_d[1] = (~in[5]) & (~in[4]) & ( in[3]);
assign high_d[0] = (~in[5]) & (~in[4]) & (~in[3]);

assign low_d[7] = ( in[2]) & ( in[1]) & ( in[0]);
assign low_d[6] = ( in[2]) & ( in[1]) & (~in[0]);
assign low_d[5] = ( in[2]) & (~in[1]) & ( in[0]);
assign low_d[4] = ( in[2]) & (~in[1]) & (~in[0]);
assign low_d[3] = (~in[2]) & ( in[1]) & ( in[0]);
assign low_d[2] = (~in[2]) & ( in[1]) & (~in[0]);
assign low_d[1] = (~in[2]) & (~in[1]) & ( in[0]);
assign low_d[0] = (~in[2]) & (~in[1]) & (~in[0]);

assign out[63] = high_d[7] & low_d[7];
assign out[62] = high_d[7] & low_d[6];
assign out[61] = high_d[7] & low_d[5];
assign out[60] = high_d[7] & low_d[4];
assign out[59] = high_d[7] & low_d[3];
assign out[58] = high_d[7] & low_d[2];
assign out[57] = high_d[7] & low_d[1];
assign out[56] = high_d[7] & low_d[0];    
assign out[55] = high_d[6] & low_d[7];
assign out[54] = high_d[6] & low_d[6];
assign out[53] = high_d[6] & low_d[5];
assign out[52] = high_d[6] & low_d[4];
assign out[51] = high_d[6] & low_d[3];
assign out[50] = high_d[6] & low_d[2];
assign out[49] = high_d[6] & low_d[1];
assign out[48] = high_d[6] & low_d[0];    
assign out[47] = high_d[5] & low_d[7];
assign out[46] = high_d[5] & low_d[6];
assign out[45] = high_d[5] & low_d[5];
assign out[44] = high_d[5] & low_d[4];
assign out[43] = high_d[5] & low_d[3];
assign out[42] = high_d[5] & low_d[2];
assign out[41] = high_d[5] & low_d[1];
assign out[40] = high_d[5] & low_d[0];    
assign out[39] = high_d[4] & low_d[7];
assign out[38] = high_d[4] & low_d[6];
assign out[37] = high_d[4] & low_d[5];
assign out[36] = high_d[4] & low_d[4];
assign out[35] = high_d[4] & low_d[3];
assign out[34] = high_d[4] & low_d[2];
assign out[33] = high_d[4] & low_d[1];
assign out[32] = high_d[4] & low_d[0];    
assign out[31] = high_d[3] & low_d[7];
assign out[30] = high_d[3] & low_d[6];
assign out[29] = high_d[3] & low_d[5];
assign out[28] = high_d[3] & low_d[4];
assign out[27] = high_d[3] & low_d[3];
assign out[26] = high_d[3] & low_d[2];
assign out[25] = high_d[3] & low_d[1];
assign out[24] = high_d[3] & low_d[0];    
assign out[23] = high_d[2] & low_d[7];
assign out[22] = high_d[2] & low_d[6];
assign out[21] = high_d[2] & low_d[5];
assign out[20] = high_d[2] & low_d[4];
assign out[19] = high_d[2] & low_d[3];
assign out[18] = high_d[2] & low_d[2];
assign out[17] = high_d[2] & low_d[1];
assign out[16] = high_d[2] & low_d[0];    
assign out[15] = high_d[1] & low_d[7];
assign out[14] = high_d[1] & low_d[6];
assign out[13] = high_d[1] & low_d[5];
assign out[12] = high_d[1] & low_d[4];
assign out[11] = high_d[1] & low_d[3];
assign out[10] = high_d[1] & low_d[2];
assign out[ 9] = high_d[1] & low_d[1];
assign out[ 8] = high_d[1] & low_d[0];    
assign out[ 7] = high_d[0] & low_d[7];
assign out[ 6] = high_d[0] & low_d[6];
assign out[ 5] = high_d[0] & low_d[5];
assign out[ 4] = high_d[0] & low_d[4];
assign out[ 3] = high_d[0] & low_d[3];
assign out[ 2] = high_d[0] & low_d[2];
assign out[ 1] = high_d[0] & low_d[1];
assign out[ 0] = high_d[0] & low_d[0];    

endmodule //decoder_6_64