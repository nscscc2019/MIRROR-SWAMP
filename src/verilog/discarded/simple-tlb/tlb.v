`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/30 21:40:33
// Design Name: 
// Module Name: tlb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tlb
#(
    parameter     ENTRIES = 32
)
(
    input           clk,

    // TLB entry write
    input           wen,
    input [5:0]     idx,
    input [11:0]    mask,
    input [31:0]    entryhi,    // bound to EntryHi
    input [31:0]    entrylo0,   // bound to EntryLo0
    input [31:0]    entrylo1,   // bound to EntryLo1

    // TLB lookup
    input [31:0]    vaddr,
    input           store,
    output [31:0]   paddr,
    output [2:0]    cache,
    output          miss,
    output          invalid,
    output          modify
);

    reg [11:0]  tlb_mask    [ENTRIES-1:0];
    reg [18:0]  tlb_vpn2    [ENTRIES-1:0];
    reg         tlb_g       [ENTRIES-1:0];
    reg [7:0]   tlb_asid    [ENTRIES-1:0];
    reg [23:0]  tlb_pfn0    [ENTRIES-1:0];
    reg [23:0]  tlb_pfn1    [ENTRIES-1:0];
    reg [2:0]   tlb_c0      [ENTRIES-1:0];
    reg [2:0]   tlb_c1      [ENTRIES-1:0];
    reg         tlb_d0      [ENTRIES-1:0];
    reg         tlb_d1      [ENTRIES-1:0];
    reg         tlb_v0      [ENTRIES-1:0];
    reg         tlb_v1      [ENTRIES-1:0];

    always @(posedge clk) begin
        if (wen) begin
            tlb_mask[idx]   <= mask;
            tlb_vpn2[idx]   <= entryhi[31:13];
            tlb_g[idx]      <= entrylo0[0] & entrylo1[0];
            tlb_asid[idx]   <= entryhi[7:0];
            {tlb_pfn0[idx], tlb_c0[idx], tlb_d0[idx], tlb_v0[idx]}  <= entrylo0[29:1];
            {tlb_pfn1[idx], tlb_c1[idx], tlb_d1[idx], tlb_v1[idx]}  <= entrylo1[29:1];
        end
    end

    wire [ENTRIES-1:0] match;
    wire [23:0] lookup_pfn  [ENTRIES:0];
    wire [2:0]  lookup_c    [ENTRIES:0];
    wire        lookup_d    [ENTRIES:0];
    wire        lookup_v    [ENTRIES:0];

    // NOTE: assume each lookup hits at most 1 TLB entry otherwise the result is undefined
    // TODO: support for variable page size
    assign lookup_pfn[0]    = 24'd0;
    assign lookup_c[0]      = 3'd0;
    assign lookup_d[0]      = 1'd0; 
    assign lookup_v[0]      = 1'd0; 
    genvar i;
    generate
        for (i=0; i<ENTRIES; i=i+1) begin
            assign match[i] = (vaddr[31:13] & ~tlb_mask[i]) == (tlb_vpn2[i] & ~tlb_mask[i])&& (tlb_g[i] || tlb_asid[i] == entryhi[7:0]);
            // all lookup results are OR'd together assuming match is at-most-one-hot
            assign lookup_pfn[i+1]  = lookup_pfn[i] | {24{match[i]}} & (vaddr[12] ? tlb_pfn1[i] : tlb_pfn0[i]);
            assign lookup_c[i+1]    = lookup_c[i]   | { 3{match[i]}} & (vaddr[12] ? tlb_c1[i]   : tlb_c0[i]);
            assign lookup_d[i+1]    = lookup_d[i]   | { 1{match[i]}} & (vaddr[12] ? tlb_d1[i]   : tlb_d0[i]);
            assign lookup_v[i+1]    = lookup_v[i]   | { 1{match[i]}} & (vaddr[12] ? tlb_v1[i]   : tlb_v0[i]);
        end
    endgenerate

    assign paddr    = {lookup_pfn[ENTRIES][19:0], vaddr[11:0]};
    assign cache    = lookup_c[ENTRIES];
    assign miss     = ~|match;
    assign invalid  = ~lookup_v[ENTRIES];
    assign modify   = store && ~lookup_d[ENTRIES];

endmodule
