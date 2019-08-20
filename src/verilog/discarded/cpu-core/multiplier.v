`timescale 1ns / 1ps
module mul(
    input  wire        mul_clk,
    input  wire        resetn,
    input  wire        mul_signed,
    
    input  wire [31:0] x,
    input  wire [31:0] y,    
    output wire [63:0] result
);

    wire [65  : 0] dx;
    wire [33  : 0] dy;
    wire [63  : 0] dC;
    wire [63  : 0] dS;
    wire           dCo;
    reg  [63  : 0] C;
    reg  [63  : 0] S;
    reg            cin;
    wire [1121: 0] tmp;
    wire [1121:66] sum;
    wire [1121: 0] tr;
    wire [16  : 0] c;
    wire [989 : 0] mc;
    wire [66  : 0] tc;
    wire [65  : 0] ts;

    assign result = C + S + cin;
    assign dx     = {{34{mul_signed & x[31]}}, x};
    assign dy     = {{ 2{mul_signed & y[31]}}, y};
    assign tc[0]  = c[15];
    assign dCo    = c[16];
    assign dC     = tc[63:0];
    assign dS     = ts[63:0];

    always @(posedge mul_clk) begin
        if (!resetn) begin
            C   <= 64'b0;
            S   <= 64'b0;
            cin <= 1'b0;
        end
        else begin
            C   <= dC;
            S   <= dS;
            cin <= dCo;
        end
    end

    booth_mul booth(
        .x (dx            ),
        .y ({dy[1:0],1'b0}),
        .p (tmp[65:0]     ),
        .c (c[0]          )
    );
    generate genvar i;
        for (i = 1; i < 17; i = i + 1) begin
            booth_mul booth(
                .x (dx                  ),
                .y (dy[i*2+1    : i*2-1]),
                .p (sum[66*i+65 : 66*i ]),
                .c (c[i]                )
            );
            assign tmp[66*i+65 : 66*i] = {sum[64*i+65 : 66*i], {i*2{c[i]}}};
        end
    endgenerate

    generate genvar m, n;
        for (m = 0; m < 66; m = m + 1) begin
        for (n = 0; n < 17; n = n + 1) begin
            assign tr[m*17+n] = tmp [n*66+m];
        end
        end
    endgenerate

    wallace_tree tree(
        .x  (tr[16:0]),
        .ci (c [14:0]),
        .co (mc[14:0]),
        .C  (tc[1]   ),
        .S  (ts[0]   )
    );
    generate genvar j;
        for (j = 1; j < 66; j = j + 1) begin
            wallace_tree tree(
                .x  (tr[17*j+16 : 17*j   ]),
                .ci (mc[15*j-1  : 15*j-15]),
                .co (mc[15*j+14 : 15*j   ]),
                .C  (tc[j+1]              ),
                .S  (ts[j]                )
            );
        end
    endgenerate
endmodule
//---------------------------------------------------------------------------------------------
module booth_mul(
    input  wire [65:0] x,
    input  wire [ 2:0] y,
    output wire [65:0] p,
    output wire        c
);
    wire [65:0] nx;   // negative x
    wire [65:0] dx;   // double x
    wire [65:0] ndx;  // negative double x
    wire        m_1x; // minus  x
    wire        p_1x; // plus   x
    wire        m_2x; // minus 2x
    wire        p_2x; // plus  2x
    assign nx   = ~x;
    assign dx   = {x[64:0], 1'b0};
    assign ndx  = ~dx;
    assign m_1x = ( y[2] &  y[1] & ~y[0]) | ( y[2] & ~y[1] &  y[0]);
    assign p_1x = (~y[2] &  y[1] & ~y[0]) | (~y[2] & ~y[1] &  y[0]);
    assign m_2x =   y[2] & ~y[1] & ~y[0];
    assign p_2x =  ~y[2] &  y[1] &  y[0];
    assign {c,p} = ({67{m_1x}} & {1'b1, nx }) |
                   ({67{p_1x}} & {1'b0, x  }) |
                   ({67{m_2x}} & {1'b1, ndx}) |
                   ({67{p_2x}} & {1'b0, dx }) ;
endmodule
//---------------------------------------------------------------------------------------------
module full_adder(
    input  wire A,
    input  wire B,
    input  wire Ci,
    output wire Co,
    output wire S
);
    assign S  = A ^ B ^ Ci;
    assign Co = A & B | A & Ci | B & Ci;
endmodule
//---------------------------------------------------------------------------------------------
module wallace_tree(
    input  wire [16:0] x,
    input  wire [14:0] ci,
    output wire [14:0] co,
    output wire        C,
    output wire        S
);
    wire [14:0] s;
    full_adder adder00(x [ 0], x [ 1], x [ 2], co[ 0], s[ 0]);
    full_adder adder01(x [ 3], x [ 4], x [ 5], co[ 1], s[ 1]);
    full_adder adder02(x [ 6], x [ 7], x [ 8], co[ 2], s[ 2]);
    full_adder adder03(x [ 9], x [10], x [11], co[ 3], s[ 3]);
    full_adder adder04(x [12], x [13], x [14], co[ 4], s[ 4]);
    full_adder adder05(x [15], x [16], 1'b0  , co[ 5], s[ 5]);
    full_adder adder06(s [ 0], s [ 1], s [ 2], co[ 6], s[ 6]);
    full_adder adder07(s [ 3], s [ 4], s [ 5], co[ 7], s[ 7]);
    full_adder adder08(ci[ 0], ci[ 1], ci[ 2], co[ 8], s[ 8]);
    full_adder adder09(ci[ 3], ci[ 4], ci[ 5], co[ 9], s[ 9]);
    full_adder adder10(s [ 6], s [ 7], s [ 8], co[10], s[10]);
    full_adder adder11(s [ 9], ci[ 6], ci[ 7], co[11], s[11]);
    full_adder adder12(s [10], s [11], ci[ 8], co[12], s[12]);
    full_adder adder13(ci[ 9], ci[10], ci[11], co[13], s[13]);
    full_adder adder14(s [12], s [13], ci[12], co[14], s[14]);
    full_adder adder15(s [14], ci[13], ci[14], C     , S    );
endmodule