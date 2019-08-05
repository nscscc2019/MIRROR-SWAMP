`include "common.vh"

module decoder #(
    parameter integer bits = 4
)
(
    input [bits-1:0] in,
    output [(1<<bits)-1:0] out
);

  generate
    genvar i;
    for (i=0; i<(1<<bits); i=i+1) begin
      assign out[i] = in == i;
    end
  endgenerate

endmodule

module decode_stage(
    input                       clk,
    input                       resetn,
    
    // memory access interface
    input   [31:0]              inst_rdata,
    input                       inst_data_ok,

    // regfile interface
    output  [4 :0]              rf_raddr1,
    output  [4 :0]              rf_raddr2,
    input   [31:0]              rf_rdata1,
    input   [31:0]              rf_rdata2,

    // data forwarding
    input   [4 :0]              ex_fwd_addr,    // 0 if instruction does not write
    input   [31:0]              ex_fwd_data,
    input                       ex_fwd_ok,      // whether data is generated after ex stage
    input   [4 :0]              wb_fwd_addr,    // 0 if instruction does not write
    input   [31:0]              wb_fwd_data,
    input                       wb_fwd_ok,      // whether data is generated after wb stage

    output                      done_o,
    input                       valid_i,
    input   [31:0]              pc_i,
    input                       cancelled_i,
    input                       ready_i,
    output reg                  valid_o,
    output reg [31:0]           pc_o,
    output reg [31:0]           inst_o,
    output reg [`I_MAX-1:0]     ctrl_o,
    output reg [31:0]           rdata1_o,
    output reg [31:0]           rdata2_o,
    output reg [31:0]           eaddr_o,
    output reg [4 :0]           waddr_o,
    
    // exception interface
    input                       exc_i,
    input                       exc_miss_i,
    input   [4:0]               exccode_i,
    output reg                  exc_o,
    output reg                  exc_miss_o,
    output reg [4:0]            exccode_o,
    output reg                  bd_o,
    input                       cancel_i,
    output                      cancel_o,
    
    output reg [31:0]           perfcnt_fetch_waitack
);

    wire valid;
    reg done;
    
    reg [31:0] inst_save;
    always @(posedge clk) if (inst_data_ok) inst_save <= inst_rdata;
    
    reg inst_saved;
    always @(posedge clk) begin
        if (!resetn) inst_saved <= 1'b0;
        else if (done_o && ready_i) inst_saved <= 1'b0;
        else if (inst_data_ok) inst_saved <= 1'b1;
    end
    
    wire [31:0] inst = inst_saved ? inst_save : inst_rdata;
    wire inst_ok = inst_data_ok || inst_saved;
    
    reg cancel_save;
    always @(posedge clk) begin
        if (!resetn) cancel_save <= 1'b0;
        else if (done_o && ready_i) cancel_save <= 1'b0;
        else if (cancel_i && valid_i) cancel_save <= 1'b1;
    end
    
    assign valid = valid_i && !cancelled_i && inst_ok && !done && !cancel_save;
    
    wire [`I_MAX-1:0] ctrl_sig;

    wire [63:0] op_d, func_d;
    wire [31:0] rs_d, rt_d, rd_d, sa_d;
    
    decoder #(.bits(6))
    dec_op (.in(inst[31:26]), .out(op_d)), dec_func (.in(inst[5:0]), .out(func_d));
    
    decoder #(.bits(5))
    dec_rs (.in(inst[25:21]), .out(rs_d)), dec_rt (.in(inst[20:16]), .out(rt_d)),
    dec_rd (.in(inst[15:11]), .out(rd_d)), dec_sa (.in(inst[10:6]), .out(sa_d));
    
    wire op_sll       = op_d[0] && rs_d[0] && func_d[0];
    wire op_srl       = op_d[0] && rs_d[0] && func_d[2];
    wire op_sra       = op_d[0] && rs_d[0] && func_d[3];
    wire op_sllv      = op_d[0] && sa_d[0] && func_d[4];
    wire op_srlv      = op_d[0] && sa_d[0] && func_d[6];
    wire op_srav      = op_d[0] && sa_d[0] && func_d[7];
    wire op_jr        = op_d[0] && rt_d[0] && rd_d[0] && sa_d[0] && func_d[8];
    wire op_jalr      = op_d[0] && rt_d[0] && sa_d[0] && func_d[9];
    wire op_syscall   = op_d[0] && func_d[12];
    wire op_break     = op_d[0] && func_d[13];
    wire op_mfhi      = op_d[0] && rs_d[0] && rt_d[0] && sa_d[0] && func_d[16];
    wire op_mthi      = op_d[0] && rt_d[0] && rd_d[0] && sa_d[0] && func_d[17];
    wire op_mflo      = op_d[0] && rs_d[0] && rt_d[0] && sa_d[0] && func_d[18];
    wire op_mtlo      = op_d[0] && rt_d[0] && rd_d[0] && sa_d[0] && func_d[19];
    wire op_mult      = op_d[0] && rd_d[0] && sa_d[0] && func_d[24];
    wire op_multu     = op_d[0] && rd_d[0] && sa_d[0] && func_d[25];
    wire op_div       = op_d[0] && rd_d[0] && sa_d[0] && func_d[26];
    wire op_divu      = op_d[0] && rd_d[0] && sa_d[0] && func_d[27];
    wire op_add       = op_d[0] && sa_d[0] && func_d[32];
    wire op_addu      = op_d[0] && sa_d[0] && func_d[33];
    wire op_sub       = op_d[0] && sa_d[0] && func_d[34];
    wire op_subu      = op_d[0] && sa_d[0] && func_d[35];
    wire op_and       = op_d[0] && sa_d[0] && func_d[36];
    wire op_or        = op_d[0] && sa_d[0] && func_d[37];
    wire op_xor       = op_d[0] && sa_d[0] && func_d[38];
    wire op_nor       = op_d[0] && sa_d[0] && func_d[39];
    wire op_slt       = op_d[0] && sa_d[0] && func_d[42];
    wire op_sltu      = op_d[0] && sa_d[0] && func_d[43];
    wire op_bltz      = op_d[1] && rt_d[0];
    wire op_bgez      = op_d[1] && rt_d[1];
    wire op_bltzal    = op_d[1] && rt_d[16];
    wire op_bgezal    = op_d[1] && rt_d[17];
    wire op_j         = op_d[2];
    wire op_jal       = op_d[3];
    wire op_beq       = op_d[4];
    wire op_bne       = op_d[5];
    wire op_blez      = op_d[6] && rt_d[0];
    wire op_bgtz      = op_d[7] && rt_d[0];
    wire op_addi      = op_d[8];
    wire op_addiu     = op_d[9];
    wire op_slti      = op_d[10];
    wire op_sltiu     = op_d[11];
    wire op_andi      = op_d[12];
    wire op_ori       = op_d[13];
    wire op_xori      = op_d[14];
    wire op_lui       = op_d[15];
    wire op_tlbr      = op_d[16] && rs_d[16] && rt_d[0] && rd_d[0] && sa_d[0] && func_d[1];
    wire op_tlbwi     = op_d[16] && rs_d[16] && rt_d[0] && rd_d[0] && sa_d[0] && func_d[2];
    wire op_tlbwr     = op_d[16] && rs_d[16] && rt_d[0] && rd_d[0] && sa_d[0] && func_d[6];
    wire op_tlbp      = op_d[16] && rs_d[16] && rt_d[0] && rd_d[0] && sa_d[0] && func_d[8];
    wire op_eret      = op_d[16] && rs_d[16] && rt_d[0] && rd_d[0] && sa_d[0] && func_d[24];
    wire op_mfc0      = op_d[16] && rs_d[0] && sa_d[0] && inst[5:3] == 3'b000;
    wire op_mtc0      = op_d[16] && rs_d[4] && sa_d[0] && inst[5:3] == 3'b000;
    wire op_lb        = op_d[32];
    wire op_lh        = op_d[33];
    wire op_lwl       = op_d[34];
    wire op_lw        = op_d[35];
    wire op_lbu       = op_d[36];
    wire op_lhu       = op_d[37];
    wire op_lwr       = op_d[38];
    wire op_sb        = op_d[40];
    wire op_sh        = op_d[41];
    wire op_swl       = op_d[42];
    wire op_sw        = op_d[43];
    wire op_swr       = op_d[46];

    wire reserved     = !(op_sll||op_srl||op_sra||op_sllv||op_srlv||op_srav||op_jr||op_jalr||op_syscall||op_break||
                          op_mfhi||op_mthi||op_mflo||op_mtlo||op_mult||op_multu||op_div||op_divu||
                          op_add||op_addu||op_sub||op_subu||op_and||op_or||op_xor||op_nor||op_slt||op_sltu||
                          op_bltz||op_bgez||op_bltzal||op_bgezal||op_j||op_jal||op_beq||op_bne||op_blez||op_bgtz||
                          op_addi||op_addiu||op_slti||op_sltiu||op_andi||op_ori||op_xori||op_lui||
                          op_tlbr||op_tlbwi||op_tlbwr||op_tlbp||op_eret||op_mfc0||op_mtc0||
                          op_lb||op_lh||op_lwl||op_lw||op_lbu||op_lhu||op_lwr||op_sb||op_sh||op_swl||op_sw||op_swr);

    // write data to [rt] generated in ex stage
    wire inst_rt_wex              = op_addi||op_addiu||op_slti||op_sltiu||op_andi||op_ori||op_xori||op_lui||op_mfc0;
    // write data to [rt] generated in wb stage
    wire inst_rt_wwb              = ctrl_sig[`I_MEM_R];
    // write data to [rd] generated in ex stage
    wire inst_rd_wex              = op_sll||op_srl||op_sra||op_sllv||op_srlv||op_srav||op_jr||op_jalr||op_mfhi||op_mflo||
                                   op_add||op_addu||op_sub||op_subu||op_and||op_or||op_xor||op_nor||op_slt||op_sltu;
    // write data to [31] generated in ex stage
    wire inst_r31_wex             = op_bltzal||op_bgezal||op_jal;

    // alu operation
    assign ctrl_sig[`I_ALU_ADD]   = op_add||op_addu||op_addi||op_addiu;
    assign ctrl_sig[`I_ALU_SUB]   = op_sub||op_subu||op_beq||op_bne;
    assign ctrl_sig[`I_ALU_AND]   = op_and||op_andi;
    assign ctrl_sig[`I_ALU_OR]    = op_or||op_ori;
    assign ctrl_sig[`I_ALU_XOR]   = op_xor||op_xori;
    assign ctrl_sig[`I_ALU_NOR]   = op_nor;
    assign ctrl_sig[`I_ALU_SLT]   = op_slt||op_slti;
    assign ctrl_sig[`I_ALU_SLTU]  = op_sltu||op_sltiu;
    assign ctrl_sig[`I_ALU_SLL]   = op_sll||op_sllv;
    assign ctrl_sig[`I_ALU_SRL]   = op_srl||op_srlv;
    assign ctrl_sig[`I_ALU_SRA]   = op_sra||op_srav;
    
    assign ctrl_sig[`I_RESERVED]  = reserved;
    
    assign ctrl_sig[`I_SYSCALL]   = op_syscall;
    assign ctrl_sig[`I_BREAK]     = op_break;
    assign ctrl_sig[`I_MFHI]      = op_mfhi;
    assign ctrl_sig[`I_MTHI]      = op_mthi;
    assign ctrl_sig[`I_MFLO]      = op_mflo;
    assign ctrl_sig[`I_MTLO]      = op_mtlo;
    assign ctrl_sig[`I_LUI]       = op_lui;
    assign ctrl_sig[`I_TLBR]      = op_tlbr;
    assign ctrl_sig[`I_TLBWI]     = op_tlbwi;
    assign ctrl_sig[`I_TLBWR]     = op_tlbwr;
    assign ctrl_sig[`I_TLBP]      = op_tlbp;
    assign ctrl_sig[`I_ERET]      = op_eret;
    assign ctrl_sig[`I_MFC0]      = op_mfc0;
    assign ctrl_sig[`I_MTC0]      = op_mtc0;
    assign ctrl_sig[`I_LB]        = op_lb;
    assign ctrl_sig[`I_LH]        = op_lh;
    assign ctrl_sig[`I_LWL]       = op_lwl;
    assign ctrl_sig[`I_LW]        = op_lw;
    assign ctrl_sig[`I_LBU]       = op_lbu;
    assign ctrl_sig[`I_LHU]       = op_lhu;
    assign ctrl_sig[`I_LWR]       = op_lwr;
    assign ctrl_sig[`I_SB]        = op_sb;
    assign ctrl_sig[`I_SH]        = op_sh;
    assign ctrl_sig[`I_SWL]       = op_swl;
    assign ctrl_sig[`I_SW]        = op_sw;
    assign ctrl_sig[`I_SWR]       = op_swr;
    
    // load instruction
    assign ctrl_sig[`I_MEM_R]     = op_lb||op_lh||op_lwl||op_lw||op_lbu||op_lhu||op_lwr;
    // store instruction
    assign ctrl_sig[`I_MEM_W]     = op_sb||op_sh||op_swl||op_sw||op_swr;

    // read [rs]
    assign ctrl_sig[`I_RS_R]      = op_sllv||op_srlv||op_srav||op_jr||op_jalr||op_mthi||op_mtlo||op_mult||op_multu||op_div||op_divu||
                                   op_add||op_addu||op_sub||op_subu||op_and||op_or||op_xor||op_nor||op_slt||op_sltu||
                                   op_bltz||op_bgez||op_bltzal||op_bgezal||op_beq||op_bne||op_blez||op_bgtz||
                                   op_addi||op_addiu||op_slti||op_sltiu||op_andi||op_ori||op_xori||
                                   ctrl_sig[`I_MEM_R]||ctrl_sig[`I_MEM_W];
    // read [rt]
    assign ctrl_sig[`I_RT_R]      = op_sll||op_srl||op_sra||op_sllv||op_srlv||op_srav||op_mult||op_multu||op_div||op_divu||
                                   op_add||op_addu||op_sub||op_subu||op_and||op_or||op_xor||op_nor||op_slt||op_sltu||
                                   op_beq||op_bne||op_mtc0||op_lwl||op_lwr||ctrl_sig[`I_MEM_W];
    // write data generated in ex stage
    assign ctrl_sig[`I_WEX]       = inst_rt_wex||inst_rd_wex||inst_r31_wex;
    // write data generated in wb stage
    assign ctrl_sig[`I_WWB]       = inst_rt_wwb;
    // imm is sign-extended
    assign ctrl_sig[`I_IMM_SX]    = !(op_andi||op_ori||op_xori);
    // alu operand a is sa
    assign ctrl_sig[`I_ALU_A_SA]  = op_sll||op_srl||op_sra;
    // alu operand b is imm
    assign ctrl_sig[`I_ALU_B_IMM] = op_addi||op_addiu||op_slti||op_sltiu||op_andi||op_ori||op_xori||ctrl_sig[`I_MEM_R]||ctrl_sig[`I_MEM_W];
    assign ctrl_sig[`I_LINK]      = op_jal||op_jalr||op_bgezal||op_bltzal;
    assign ctrl_sig[`I_DO_MUL]    = op_mult||op_multu;
    assign ctrl_sig[`I_DO_DIV]    = op_div||op_divu;
    assign ctrl_sig[`I_MD_SIGN]   = op_mult||op_div;
    assign ctrl_sig[`I_EXC_OF]    = op_add || op_sub || op_addi;
    
    assign ctrl_sig[`I_BNE]         = op_bne;
    assign ctrl_sig[`I_BEQ]         = op_beq;
    assign ctrl_sig[`I_BGEZ]        = op_bgez || op_bgezal;
    assign ctrl_sig[`I_BLEZ]        = op_blez;
    assign ctrl_sig[`I_BGTZ]        = op_bgtz;
    assign ctrl_sig[`I_BLTZ]        = op_bltz || op_bltzal;
    assign ctrl_sig[`I_J]           = op_j || op_jal;
    assign ctrl_sig[`I_JR]          = op_jr || op_jalr;
    
    assign rf_raddr1 = `GET_RS(inst);
    assign rf_raddr2 = `GET_RT(inst);

    // data forwarding
    // `I_RS_R & `I_RT_R check is omitted for enhanced timing
    // this may introduce false data hazards but no forwarding errors
    wire fwd_ex_raddr1_hit  = rf_raddr1 != 5'd0 && rf_raddr1 == ex_fwd_addr;
    wire fwd_ex_raddr2_hit  = rf_raddr2 != 5'd0 && rf_raddr2 == ex_fwd_addr;
    wire fwd_wb_raddr1_hit  = rf_raddr1 != 5'd0 && rf_raddr1 == wb_fwd_addr;
    wire fwd_wb_raddr2_hit  = rf_raddr2 != 5'd0 && rf_raddr2 == wb_fwd_addr;
    
    wire [31:0] fwd_rdata1  = fwd_ex_raddr1_hit && ex_fwd_ok ? ex_fwd_data
                            : fwd_wb_raddr1_hit && wb_fwd_ok ? wb_fwd_data
                            : rf_rdata1;
    wire [31:0] fwd_rdata2  = fwd_ex_raddr2_hit && ex_fwd_ok ? ex_fwd_data
                            : fwd_wb_raddr2_hit && wb_fwd_ok ? wb_fwd_data
                            : rf_rdata2;

    wire br_inst = op_bne||op_beq||op_bgez||op_bgezal||op_blez||op_bgtz||op_bltz||op_bltzal||op_j||op_jr||op_jal||op_jalr;
    
    wire fwd_stall  = fwd_ex_raddr1_hit && !ex_fwd_ok
                   || fwd_ex_raddr2_hit && !ex_fwd_ok
                   || fwd_wb_raddr1_hit && !wb_fwd_ok
                   || fwd_wb_raddr2_hit && !wb_fwd_ok;

    always @(posedge clk) begin
        if (!resetn) done <= 1'b0;
        else if (ready_i) done <= 1'b0;
        else if (valid && done_o) done <= 1'b1;
    end

    // branch delay slot
    reg prev_branch; // if previous instruction is branch/jump
    always @(posedge clk) begin
        if (!resetn) prev_branch <= 1'b0;
        else if (valid_i && done_o && ready_i) prev_branch <= br_inst && !(valid_i && exc_i) && !cancelled_i && !cancel_i && !cancel_save;
    end
    
    assign cancel_o = 1'b0; ///////////////
    
    assign done_o = inst_ok && (!fwd_stall || cancelled_i) || exc_i;
    
    wire [15:0] imm = `GET_IMM(inst);

    always @(posedge clk) begin
        if (!resetn) begin
            valid_o     <= 1'b0;
            pc_o        <= 32'd0;
            inst_o      <= 32'd0;
            ctrl_o      <= `I_MAX'd0;
            rdata1_o    <= 32'd0;
            rdata2_o    <= 32'd0;
            eaddr_o     <= 32'd0;
            waddr_o     <= 5'd0;
            exc_o       <= 1'b0;
            exc_miss_o  <= 1'b0;
            exccode_o   <= 5'd0;
            bd_o        <= 1'b0;
        end
        else if (ready_i) begin
            valid_o     <= valid_i && done_o && !cancelled_i && !cancel_i && !cancel_save;
            pc_o        <= pc_i;
            inst_o      <= inst;
            ctrl_o      <= ctrl_sig;
            rdata1_o    <= fwd_rdata1;
            rdata2_o    <= fwd_rdata2;
            eaddr_o     <= fwd_rdata1 + {{16{imm[15]}}, imm};
            waddr_o     <= {5{inst_rt_wex||inst_rt_wwb}}    & `GET_RT(inst)
                         | {5{inst_rd_wex}}                 & `GET_RD(inst)
                         | {5{inst_r31_wex}}                & 5'd31;
            exc_o       <= exc_i;
            exc_miss_o  <= exc_miss_i;
            exccode_o   <= exccode_i;
            bd_o        <= prev_branch;
        end
    end
    
    // performance counters
    always @(posedge clk) begin
        if (!resetn) perfcnt_fetch_waitack <= 32'd0;
        else if (valid_i && !exc_i && !inst_ok) perfcnt_fetch_waitack <= perfcnt_fetch_waitack + 32'd1;
    end

endmodule