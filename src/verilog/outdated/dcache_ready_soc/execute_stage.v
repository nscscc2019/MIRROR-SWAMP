`include "common.vh"

module execute_stage(
    input                       clk,
    input                       resetn,

    // memory access interface
    output                      data_req,
    output                      data_cache,
    output                      data_wr,
    output  [3 :0]              data_wstrb,
    output  [31:0]              data_addr,
    output  [2 :0]              data_size,
    output  [31:0]              data_wdata,
    input                       data_addr_ok,
    
    // branch/jump signals
    output                      branch,
    input                       branch_ready,
    output  [31:0]              target_pc,
    
    // tlb
    output  [31:0]              tlb_vaddr,
    input   [31:0]              tlb_paddr,
    input                       tlb_miss,
    input                       tlb_invalid,
    input                       tlb_dirty,
    input   [2 :0]              tlb_cattr,
    
    input   [2: 0]              config_k0,
    
    // interrupt
    input                       int_sig,
    
    // data forwarding
    output  [4 :0]              fwd_addr,
    output  [31:0]              fwd_data,
    output                      fwd_ok,      // whether data is generated after ex stage
    
    // mtc0/mfc0
    output                      cp0_w,
    output  [31:0]              cp0_wdata,
    input   [31:0]              cp0_rdata,
    output  [7 :0]              cp0_addr,
    
    // tlb read/write
    output                      tlbr,
    output                      tlbwi,
    output                      tlbwr,
    output                      tlbp,

    output                      done_o,
    input                       valid_i,
    input   [31:0]              pc_i,
    input   [31:0]              inst_i,
    input   [`I_MAX-1:0]        ctrl_i,
    input   [31:0]              rdata1_i,
    input   [31:0]              rdata2_i,
    input   [31:0]              eaddr_i,
    input   [4 :0]              waddr_i,
    input                       ready_i,
    output reg                  valid_o,
    output reg [31:0]           pc_o,
    output reg [31:0]           inst_o,
    output reg [`I_MAX-1:0]     ctrl_o,
    output reg [31:0]           result_o,
    output reg [31:0]           eaddr_o,
    output reg [31:0]           rdata2_o,
    output reg [4 :0]           waddr_o,
    
    // exception interface
    input                       exc_i,
    input                       exc_miss_i,
    input   [4 :0]              exccode_i,
    input                       bd_i,
    output                      commit,
    output                      commit_miss,
    output  [4 :0]              commit_code,
    output                      commit_bd,
    output  [31:0]              commit_epc,
    output  [31:0]              commit_bvaddr,
    output                      commit_eret,
    
    output reg [31:0]           perfcnt_load_waitreq,
    output reg [31:0]           perfcnt_store_waitreq
);

    wire valid;
    reg done;

    assign valid = valid_i && !done && !exc_i;

    // imm extension
    wire [15:0] imm = `GET_IMM(inst_i);
    wire [31:0] imm_sx = {{16{imm[15]}}, imm};
    wire [31:0] imm_zx = {16'd0, imm};
    wire [31:0] imm_32 = ctrl_i[`I_IMM_SX] ? imm_sx : imm_zx;
    
    // ALU operation
    wire [10:0] alu_op = ctrl_i[10:0];
    
    // ALU module
    wire [31:0] alu_a, alu_b, alu_res_wire;
    wire alu_of;
    alu alu_instance(
        .A          (alu_a),
        .B          (alu_b),
        .ALUop      (alu_op),
        .CarryOut   (),
        .Overflow   (alu_of),
        .Zero       (),
        .Result     (alu_res_wire)
    );

    // select operand sources
    assign alu_a = ctrl_i[`I_ALU_A_SA] ? {27'd0, `GET_SA(inst_i)} : rdata1_i;
    assign alu_b = ctrl_i[`I_ALU_B_IMM] ? imm_32 : rdata2_i;

    // multiplication
    // the multiplier is divided into 3 stages
    wire [63:0] mul_res;
    reg [1:0] mul_flag;
    always @(posedge clk) begin
        if (!resetn) mul_flag <= 2'b00;
        else if (ctrl_i[`I_DO_DIV] && valid) mul_flag <= 2'b00;
        else mul_flag <= {mul_flag[0], ctrl_i[`I_DO_MUL] && valid};
    end
    
    mul u_mul(
        .mul_clk(clk),
        .resetn(resetn),
        .mul_signed(ctrl_i[`I_MD_SIGN]),
        .x(rdata1_i),
        .y(rdata2_i),
        .result(mul_res)
    );
    
    // division
    wire [31:0] div_s, div_r;
    wire div_complete;
    div u_div(
        .div_clk(clk),
        .resetn(resetn),
        .div(ctrl_i[`I_DO_DIV] && valid),
        .div_signed(ctrl_i[`I_MD_SIGN]),
        .x(rdata1_i),
        .y(rdata2_i),
        .s(div_s),
        .r(div_r),
        .complete(div_complete),
        .cancel(ctrl_i[`I_DO_MUL] && valid)
    );
    
    wire alu_of_exc = ctrl_i[`I_EXC_OF] && alu_of;
    
    reg muldiv; // mul or div in progreses
    always @(posedge clk) begin
        if (!resetn) muldiv <= 1'b0;
        else if (mul_flag[1] || div_complete) muldiv <= 1'b0;
        else if ((ctrl_i[`I_DO_MUL] || ctrl_i[`I_DO_DIV]) && valid) muldiv <= 1'b1;
    end
    
    // HI/LO registers
    reg [31:0] hi, lo;
    always @(posedge clk) begin
        if (mul_flag[1]) begin
            hi <= mul_res[63:32];
            lo <= mul_res[31:0];
        end
        else if (div_complete) begin
            hi <= div_r;
            lo <= div_s;
        end
        else begin
            if (valid && ctrl_i[`I_MTHI]) hi <= rdata1_i;
            if (valid && ctrl_i[`I_MTLO]) lo <= rdata1_i;
        end
    end
    
    // branch test
    wire branch_taken   = (ctrl_i[`I_BNE] && (rdata1_i != rdata2_i))
                       || (ctrl_i[`I_BEQ] && (rdata1_i == rdata2_i))
                       || (ctrl_i[`I_BGEZ] && !rdata1_i[31])
                       || (ctrl_i[`I_BLEZ] && (rdata1_i[31] || rdata1_i == 32'd0))
                       || (ctrl_i[`I_BGTZ] && !(rdata1_i[31] || rdata1_i == 32'd0))
                       || (ctrl_i[`I_BLTZ] && rdata1_i[31]);

    assign branch       = valid && branch_ready && (ctrl_i[`I_J]||ctrl_i[`I_JR]||branch_taken); // && done_o

    wire [31:0] seq_pc = pc_i + 32'd4;
    wire [31:0] pc_branch = seq_pc + {{14{imm[15]}}, imm, 2'd0};
    wire [31:0] pc_jump = {seq_pc[31:28], `GET_INDEX(inst_i), 2'd0};

    assign target_pc    = {32{!(ctrl_i[`I_J]||ctrl_i[`I_JR])}} & pc_branch
                        | {32{ctrl_i[`I_JR]}} & rdata1_i
                        | {32{ctrl_i[`I_J]}} & pc_jump;
    
    // mtc0/mfc0
    assign cp0_w = valid && ctrl_i[`I_MTC0];
    assign cp0_wdata = rdata2_i;
    assign cp0_addr = {`GET_RD(inst_i), inst_i[2:0]};
    
    // tlb instructions
    assign tlbr = valid && ctrl_i[`I_TLBR];
    assign tlbwi = valid && ctrl_i[`I_TLBWI];
    assign tlbwr = valid && ctrl_i[`I_TLBWR];
    assign tlbp = valid && ctrl_i[`I_TLBP];

    ///// memory access request /////
    
    // tlb query fsm (0=check/bypass, 1=query, 2=request)
    reg [1:0] qstate, qstate_next;
    
    // tlb query cache
    reg tlbc_valid; // indicates query cache validity
    reg [19:0] tlbc_vaddr_hi, tlbc_paddr_hi;
    reg tlbc_miss, tlbc_invalid, tlbc_dirty;
    reg [2:0] tlbc_cattr;
    
    //wire [31:0] eff_addr = rdata1_i + imm_sx;
    wire [31:0] ea_aligned = eaddr_i & 32'hfffffffc;
    wire [1:0] mem_byte_offset = eaddr_i[1:0];
    wire [1:0] mem_byte_offsetn = ~mem_byte_offset;
    
    wire mem_adel   = ctrl_i[`I_LW] && eaddr_i[1:0] != 2'd0
                   || (ctrl_i[`I_LH] || ctrl_i[`I_LHU]) && eaddr_i[0] != 1'd0;
    wire mem_ades   = ctrl_i[`I_SW] && eaddr_i[1:0] != 2'd0
                   || ctrl_i[`I_SH] && eaddr_i[0] != 1'd0;
    
    wire mem_read = ctrl_i[`I_MEM_R] && !mem_adel;
    wire mem_write = ctrl_i[`I_MEM_W] && !mem_ades;
    
    
    wire kseg01 = ea_aligned[31:30] == 2'b10;
    wire kseg0 = ea_aligned[31:29] == 3'b100;
    wire tlbc_hit = tlbc_valid && tlbc_vaddr_hi == ea_aligned[31:12];
    
    wire tlbc_ok = qstate == 2'd0 && tlbc_hit
                || qstate == 2'd2;
    
    wire tlbl = ctrl_i[`I_MEM_R] && tlbc_ok && (tlbc_miss || tlbc_invalid);
    wire tlbs = ctrl_i[`I_MEM_W] && tlbc_ok && (tlbc_miss || tlbc_invalid);
    wire tlbm = ctrl_i[`I_MEM_W] && tlbc_ok && !tlbc_miss && !tlbc_invalid && !tlbc_dirty;
    
    wire mem_exc = qstate == 2'd0 && (mem_adel || mem_ades) || tlbl || tlbs || tlbm;
    
    always @(posedge clk) begin
        if (!resetn) qstate <= 2'd0;
        else qstate <= qstate_next;
    end
    
    always @(*) begin
        case (qstate)
        2'd0:       qstate_next = (kseg01 || tlbc_hit || !valid_i || !mem_read && !mem_write) ? 2'd0 : 2'd1;
        2'd1:       qstate_next = 2'd2;
        2'd2:       qstate_next = mem_exc || data_addr_ok ? 2'd0 : 2'd2;
        default:    qstate_next = 2'd0;
        endcase
    end
    
    // ea is saved for tlb lookup
    reg [31:0] ea_aligned_save;
    always @(posedge clk) if (qstate_next == 2'd1) ea_aligned_save <= ea_aligned;
    
    assign tlb_vaddr = ea_aligned_save;
    
    always @(posedge clk) begin
        if (!resetn) tlbc_valid <= 1'b0;
        else if (tlbwi || tlbwr) tlbc_valid <= 1'b0;
        else if (qstate == 2'd1) tlbc_valid <= 1'b1;
    end
    
    always @(posedge clk) begin
        if (qstate == 2'd1) begin
            tlbc_vaddr_hi <= ea_aligned_save[31:12];
            tlbc_paddr_hi <= tlb_paddr[31:12];
            tlbc_miss <= tlb_miss;
            tlbc_invalid <= tlb_invalid;
            tlbc_dirty <= tlb_dirty;
            tlbc_cattr <= tlb_cattr;
        end
    end
    
    wire req_state = qstate == 2'd0 && (kseg01 || tlbc_hit)
                  || qstate == 2'd2;
    
    assign data_req = valid && (mem_read || mem_write) && !mem_exc && req_state;
    assign data_cache = qstate == 2'd0 ? (kseg0 && config_k0[0]) : tlbc_cattr[0];
    assign data_wr = mem_write;
    
    // mem write mask
    assign data_wstrb =
        {4{ctrl_i[`I_SW]}} & 4'b1111 |
        {4{ctrl_i[`I_SH]}} & (4'b0011 << mem_byte_offset) |
        {4{ctrl_i[`I_SB]}} & (4'b0001 << mem_byte_offset) |
        {4{ctrl_i[`I_SWL]}} & (4'b1111 >> mem_byte_offsetn) |
        {4{ctrl_i[`I_SWR]}} & (4'b1111 << mem_byte_offset);
    
    // mem write data
    assign data_wdata =
        {32{ctrl_i[`I_SW]}} & rdata2_i |
        {32{ctrl_i[`I_SH]}} & {rdata2_i[15:0], rdata2_i[15:0]} |
        {32{ctrl_i[`I_SB]}} & {rdata2_i[7:0], rdata2_i[7:0], rdata2_i[7:0], rdata2_i[7:0]} |
        {32{ctrl_i[`I_SWL]}} & (rdata2_i >> (8 * mem_byte_offsetn)) |
        {32{ctrl_i[`I_SWR]}} & (rdata2_i << (8 * mem_byte_offset));
    
    assign data_addr = qstate == 2'd0 ? (tlbc_hit ? {tlbc_paddr_hi, ea_aligned[11:0]} : {3'd0, ea_aligned[28:0]})
                     : {tlbc_paddr_hi, ea_aligned_save[11:0]};
    
    assign data_size =
        {3{ctrl_i[`I_SW]||ctrl_i[`I_SWL]||ctrl_i[`I_SWR]||ctrl_i[`I_LW]||ctrl_i[`I_LWL]||ctrl_i[`I_LWR]}} & 3'd2 |
        {3{ctrl_i[`I_SH]||ctrl_i[`I_LH]||ctrl_i[`I_LHU]}} & 3'd1 |
        {3{ctrl_i[`I_SB]||ctrl_i[`I_LB]||ctrl_i[`I_LBU]}} & 3'd0;

    always @(posedge clk) begin
        if (!resetn) done <= 1'b0;
        else if (ready_i) done <= 1'b0;
        else if (valid_i && done_o) done <= 1'b1;
    end

    // exceptions
    wire exc = int_sig || ctrl_i[`I_RESERVED]
            || ctrl_i[`I_SYSCALL] || ctrl_i[`I_BREAK] || ctrl_i[`I_ERET]
            || alu_of_exc || mem_adel || mem_ades
            || valid_i && (tlbl || tlbs || tlbm);

    wire [4:0] exccode = {5{int_sig}} & `EXC_INT
                       | {5{ctrl_i[`I_RESERVED]}} & `EXC_RI
                       | {5{ctrl_i[`I_SYSCALL]}} & `EXC_SYS
                       | {5{ctrl_i[`I_BREAK]}} & `EXC_BP
                       | {5{alu_of_exc}} & `EXC_OV
                       | {5{mem_adel}} & `EXC_ADEL
                       | {5{mem_ades}} & `EXC_ADES
                       | {5{tlbl}} & `EXC_TLBL
                       | {5{tlbs}} & `EXC_TLBS
                       | {5{tlbm}} & `EXC_MOD;
    assign commit = valid && exc || valid_i && exc_i;
    assign commit_miss = valid && (mem_read || mem_write) && (qstate == 2'd0 && tlbc_hit || qstate == 2'd2) && tlbc_miss
                      || valid_i && exc_i && exc_miss_i;
    assign commit_code = valid && exc ? exccode : exccode_i;
    assign commit_bd = bd_i;
    assign commit_epc = bd_i ? pc_i - 32'd4 : pc_i;
    assign commit_bvaddr = exc_i ? pc_i : eaddr_i;
    assign commit_eret = ctrl_i[`I_ERET];
    
    wire done_nonmem = ((ctrl_i[`I_MFHI]||ctrl_i[`I_MFLO]||ctrl_i[`I_MTHI]||ctrl_i[`I_MTLO]) && !muldiv
                    ||  (ctrl_i[`I_J]||ctrl_i[`I_JR]||branch_taken) && branch_ready
                    || !(ctrl_i[`I_MFHI]||ctrl_i[`I_MFLO]||ctrl_i[`I_MTHI]||ctrl_i[`I_MTLO]||
                         ctrl_i[`I_MEM_R]||ctrl_i[`I_MEM_W]||(ctrl_i[`I_J]||ctrl_i[`I_JR]||branch_taken)));
    assign done_o   = done_nonmem
                   || (ctrl_i[`I_MEM_R]||ctrl_i[`I_MEM_W]) && (data_addr_ok)
                   || exc_i || exc;
    
    assign fwd_addr = {5{valid_i}} & waddr_i;
    assign fwd_data = {32{ctrl_i[`I_MFHI]}} & hi
                    | {32{ctrl_i[`I_MFLO]}} & lo
                    | {32{ctrl_i[`I_LUI]}} & {imm, 16'd0}
                    | {32{ctrl_i[`I_LINK]}} & (pc_i + 32'd8)
                    | {32{ctrl_i[`I_MFC0]}} & cp0_rdata
                    | {32{!(ctrl_i[`I_MFHI]||ctrl_i[`I_MFLO]||ctrl_i[`I_LUI]||ctrl_i[`I_LINK]||ctrl_i[`I_MFC0])}} & alu_res_wire;

    assign fwd_ok   = valid && done_nonmem && ready_i && ctrl_i[`I_WEX];

    always @(posedge clk) begin
        if (!resetn) begin
            valid_o     <= 1'b0;
            pc_o        <= 32'd0;
            inst_o      <= 32'd0;
            ctrl_o      <= `I_MAX'd0;
            waddr_o     <= 5'd0;
            result_o    <= 32'd0;
            eaddr_o     <= 32'd0;
            rdata2_o    <= 32'd0;
        end
        else if (ready_i) begin
            valid_o     <= valid_i && done_o && !exc_i && !exc;
            pc_o        <= pc_i;
            inst_o      <= inst_i;
            ctrl_o      <= ctrl_i;
            waddr_o     <= waddr_i;
            result_o    <= fwd_data;
            eaddr_o     <= eaddr_i;
            rdata2_o    <= rdata2_i;
        end
    end
    
    // performance counters
    always @(posedge clk) begin
        // stalled cycles for load req
        if (!resetn) perfcnt_load_waitreq <= 32'd0;
        else if (valid && data_req && !done_o && ctrl_i[`I_MEM_R]) perfcnt_load_waitreq <= perfcnt_load_waitreq + 32'd1;
        // stalled cycles for store req
        if (!resetn) perfcnt_store_waitreq <= 32'd0;
        else if (valid && data_req && !done_o && ctrl_i[`I_MEM_W]) perfcnt_store_waitreq <= perfcnt_store_waitreq + 32'd1;
    end

endmodule