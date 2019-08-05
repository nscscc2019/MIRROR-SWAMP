`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/30 22:51:44
// Design Name: 
// Module Name: tlb_sim
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


module icache_fetch_sim();

    wire [31:0]addr;
    wire [31:0]addr_ok;
    wire [31:0]inst;
    wire [31:0]inst_ok;

    task fetch_inst(
        input [31:0]    w_entrylo1
    );
    begin
        idx = w_idx;
        mask = w_mask;
        entryhi = w_entryhi;
        entrylo0 = w_entrylo0;
        entrylo1 = w_entrylo1;
        wen = 1;
        #10;
        wen = 0;
    end
    endtask

    task lookup_tlb(
        input [31:0]    w_vaddr,
        input           w_store
    );
    begin
        vaddr = w_vaddr;
        store = w_store;
        #10;
    end
    endtask

    always #5 clk = ~clk;

    integer i;
    initial begin
        clk = 0;
        #10;
        // initialize TLB
        for (i=0; i<32; i=i+1) write_tlb(i, 12'd0, 32'd0, 32'd0, 32'd0);
        #20;
        write_tlb(0, 12'h0, 32'h00002000, (32'h1111 << 6) | 6'b011010, (32'h2222 << 6) | 6'b011010);
        write_tlb(1, 12'h0, 32'h00004000, (32'h3333 << 6) | 6'b011110, (32'h4444 << 6) | 6'b011110);
        //write_tlb(2, 12'hf, 32'h00020000, (32'h5550 << 6) | 6'b011010, (32'h6660 << 6) | 6'b011010);
        //write_tlb(3, 12'hf, 32'h00040000, (32'h7770 << 6) | 6'b011110, (32'h8880 << 6) | 6'b011110);
        // lookup TLB
        entryhi = 32'h00; #20;
        lookup_tlb(32'hf0000000, 1'b0);
        lookup_tlb(32'hf0000000, 1'b1);
        lookup_tlb(32'h00002000, 1'b0);
        lookup_tlb(32'h00002000, 1'b1);
        lookup_tlb(32'h00003000, 1'b0);
        lookup_tlb(32'h00003000, 1'b1);
        lookup_tlb(32'h00004000, 1'b0);
        lookup_tlb(32'h00004000, 1'b1);
        lookup_tlb(32'h00005000, 1'b0);
        lookup_tlb(32'h00005000, 1'b1);
        //lookup_tlb(32'h00020000, 1'b0);
        //lookup_tlb(32'h00020000, 1'b1);
        //lookup_tlb(32'h00021000, 1'b0);
        //lookup_tlb(32'h00021000, 1'b1);
        //lookup_tlb(32'h00030000, 1'b0);
        //lookup_tlb(32'h00030000, 1'b1);
        //lookup_tlb(32'h00031000, 1'b0);
        //lookup_tlb(32'h00031000, 1'b1);
        //lookup_tlb(32'h00040000, 1'b0);
        //lookup_tlb(32'h00040000, 1'b1);
        //lookup_tlb(32'h00050000, 1'b0);
        //lookup_tlb(32'h00050000, 1'b1);
        entryhi = 32'h01; #20;
        lookup_tlb(32'h00002000, 1'b0);
        lookup_tlb(32'h00002000, 1'b1);
        entryhi = 32'h00; #20;
        $finish;
    end

endmodule
