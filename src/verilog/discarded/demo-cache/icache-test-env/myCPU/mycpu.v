`timescale 10ns / 1ns
module mycpu(
    input  [ 5:0]     hw_int       ,
    input             clk          ,
    input             resetn       ,

    //------inst sram-like-------
    (*mark_debug = "true"*)output        inst_req         ,
    (*mark_debug = "true"*)output        inst_wr          ,
    (*mark_debug = "true"*)output [1 :0] inst_size        ,
    (*mark_debug = "true"*)output [31:0] inst_addr        ,
    (*mark_debug = "true"*)output [31:0] inst_wdata       ,
    (*mark_debug = "true"*)input  [31:0] inst_rdata       ,
    (*mark_debug = "true"*)input         inst_addr_ok     ,
    (*mark_debug = "true"*)input         inst_data_ok     ,

    //------data sram-like-------
    (*mark_debug = "true"*)output        data_req         ,
    (*mark_debug = "true"*)output        data_wr          ,
    (*mark_debug = "true"*)output [1 :0] data_size        ,
    (*mark_debug = "true"*)output [31:0] data_addr        ,
    (*mark_debug = "true"*)output [31:0] data_wdata       ,
    (*mark_debug = "true"*)input  [31:0] data_rdata       ,
    (*mark_debug = "true"*)input         data_addr_ok     ,
    (*mark_debug = "true"*)input         data_data_ok     ,

    //trace debug interface
    output [31:0] debug_wb_pc      ,
    output [ 3:0] debug_wb_rf_wen  ,
    output [ 4:0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
);

reg reset;
always @(posedge clk) reset <= ~resetn;

//----------| pre-IF stage |------------
wire [31:0] seq_pc;
wire [31:0] nextpc;
wire        to_fs_valid;
//#Exception
wire        ex_inst_ADEL;

//----------|fs_| IF stage |------------
wire        fs_allowin;
wire        fs_ready_go;
wire        fs_to_ds_valid;
reg         fs_valid;
reg         fs_inst_data_ok;
reg  [31:0] fs_inst;
(*mark_debug = "true"*)reg  [31:0] fs_pc;
wire [31:0] inst;
//#Exception
reg         fs_inst_ADEL;

//----------|ds_| ID stage |------------
wire        ds_allowin;
wire        ds_ready_go;
wire        ds_to_es_valid;
reg         ds_valid;
reg  [31:0] ds_pc;
reg  [31:0] ds_inst;
wire [ 5:0] op;
wire [ 4:0] rs;
wire [ 4:0] rt;
wire [ 4:0] rd;
wire [ 4:0] sa;
wire [ 5:0] func;
wire [15:0] imm;
wire [25:0] jidx;
wire [ 2:0] sel;
wire [63:0] op_d;
wire [31:0] rs_d;
wire [31:0] rt_d;
wire [31:0] rd_d;
wire [31:0] sa_d;
wire [63:0] func_d;
wire        inst_ADDU;
wire        inst_SUBU;
wire        inst_SLT;
wire        inst_SLTU;
wire        inst_AND;
wire        inst_OR;
wire        inst_XOR;
wire        inst_NOR;
wire        inst_SLL;
wire        inst_SRL;
wire        inst_SRA;
wire        inst_ADDIU;
wire        inst_LUI;
wire        inst_LW;
wire        inst_SW;
wire        inst_BEQ;
wire        inst_BNE;
wire        inst_JAL;
wire        inst_JR;
wire        inst_ADD;
wire        inst_ADDI;
wire        inst_SUB;
wire        inst_SLTI;
wire        inst_SLTIU;
wire        inst_ANDI;
wire        inst_ORI;
wire        inst_XORI;
wire        inst_SLLV;
wire        inst_SRAV;
wire        inst_SRLV;
wire        inst_DIV;
wire        inst_DIVU;
wire        inst_MULT;
wire        inst_MULTU;
wire        inst_MFHI;
wire        inst_MFLO;
wire        inst_MTHI;
wire        inst_MTLO;
wire        inst_J;
wire        inst_BGEZ;
wire        inst_BGTZ;
wire        inst_BLEZ;
wire        inst_BLTZ;
wire        inst_BLTZAL;
wire        inst_BGEZAL;
wire        inst_JALR;
wire        inst_LB;
wire        inst_LBU;
wire        inst_LH;
wire        inst_LHU;
wire        inst_LWL;
wire        inst_LWR;
wire        inst_SB;
wire        inst_SH;
wire        inst_SWL;
wire        inst_SWR;
wire        inst_MTC0;
wire        inst_MFC0;
wire        inst_ERET;
wire        inst_SYSCALL;
wire        inst_BREAK;
wire [11:0] alu_op;
wire        src1_is_sa;
wire        src1_is_pc;
wire        src2_is_imm;
wire        src2_is_uimm;
wire        src2_is_8;
wire        res_from_mem;
wire        dst_is_r31;
wire        dst_is_rt;
wire        gr_we;
wire        not_read_rs;
wire        not_read_rt;
wire        inst_BRANCH;
wire [ 4:0] dest;
wire [ 6:0] load_mask;
wire [ 4:0] save_mask;
wire [ 4:0] rf_raddr1;
wire [31:0] rf_rdata1;
wire [ 4:0] rf_raddr2;
wire [31:0] rf_rdata2;
wire [31:0] rs_value;
wire [31:0] rt_value;
wire        rs_eq_rt;
wire        rs_zero;
wire        rs_gez;
wire        rs_gtz;
wire        rs_lez;
wire        rs_ltz;
wire        br_taken;
wire [31:0] br_target;
wire [ 3:0] mul_div;
//#Stall
wire        rs_from_es;
wire        rs_from_ms;
wire        rs_from_ws;
wire        rt_from_es;
wire        rt_from_ms;
wire        rt_from_ws;
wire        rs_stall;
wire        rt_stall;
wire        stall;
//#Exception
reg         ds_ex_tag;
reg         ds_inst_ADEL;
wire        ds_exception;
wire [ 4:0] excode;
wire        ex_INT;
wire        ex_RI;


//----------|es_| EXE stage |------------
wire        es_allowin;
wire        es_ready_go;
wire        es_to_ms_valid;
reg         es_valid;
reg  [31:0] es_pc;
reg  [31:0] es_rs_value;
reg  [31:0] es_rt_value;
reg  [15:0] es_imm;
reg  [11:0] es_alu_op;
reg         es_src1_is_sa;
reg         es_src1_is_pc;
reg         es_src2_is_imm;
reg         es_src2_is_uimm;
reg         es_src2_is_8;
reg         es_res_from_mem;
reg         es_gr_we;
reg  [ 3:0] es_mul_div;
reg         es_inst_MFHI;
reg         es_inst_MFLO;
reg         es_inst_MTHI;
reg         es_inst_MTLO;
reg         es_inst_MTC0;
reg         es_inst_MFC0;
reg         es_inst_ERET;
reg         es_inst_BRANCH;
reg  [ 4:0] es_dest;
reg  [ 6:0] es_load_mask;
reg  [ 4:0] es_save_mask;
wire [ 4:0] mem_we;
wire [31:0] mem_wdata;
wire [63:0] mul_result;
wire        div_done;
wire [63:0] div_result;
wire [31:0] alu_src1;
wire [31:0] alu_src2;
wire [31:0] alu_result;
//#Exception
wire        es_exception;
reg  [ 7:0] es_cp0_addr;
reg  [ 4:0] es_excode;
reg         es_ex_tag;
reg         es_ex_occur;
reg         es_inst_ADEL;
reg         es_ov_add;
reg         es_ov_sub;
wire        ex_data_ADEL;
(*mark_debug = "true"*)wire        ex_data_ADES;
wire        ex_OV;
//#Cp0
wire        cp0_ren;
wire        cp0_wen;
wire [ 7:0] cp0_addr;
wire [ 7:0] cp0_raddr;
wire [ 7:0] cp0_waddr;
wire [31:0] cp0_wr_value;
wire [31:0] cp0_rd_value;

//----------|ms_| MEM stage |------------
wire        ms_allowin;
wire        ms_ready_go;
wire        ms_to_ws_valid;
reg         ms_valid;
reg  [31:0] ms_pc;
reg  [ 4:0] ms_dest;
reg  [ 6:0] ms_load_mask;
reg  [ 4:0] ms_save_mask;
reg         ms_res_from_mem;
reg         ms_gr_we;
reg  [31:0] ms_final_result;
reg  [ 3:0] ms_mul_div;
reg  [63:0] ms_div_result;
reg         ms_inst_MTHI;
reg         ms_inst_MTLO;
reg  [31:0] ms_data_addr;
reg         ms_data_data_ok;
reg  [31:0] ms_data;
reg  [31:0] ms_rt_value;
reg         ms_inst_BRANCH;
wire [31:0] mem_result;
wire [31:0] mask_result;
wire [31:0] final_result;
//#Exception
reg         ms_ex_tag;

//----------|ws_| WB stage |------------
wire        ws_allowin;
wire        ws_ready_go;
reg         ws_valid;
reg  [31:0] ws_pc;
reg         ws_gr_we;
reg  [ 4:0] ws_dest;
reg  [31:0] ws_final_result;
wire        rf_we;
wire [ 4:0] rf_waddr;
wire [31:0] rf_wdata;
reg  [31:0] HI;
reg  [31:0] LO;
wire [31:0] next_HI;
wire [31:0] next_LO;
//#Exception
reg         ws_ex_tag;

//----------| CP0 Registers |------------

wire        exception_commit;
wire        set_ex_tag;
wire [ 5:0] exe_excode;

// BadVAddr     reg: 8, sel: 0
reg  [31:0] cr_badvaddr;
wire [31:0] badvaddr_value;
assign badvaddr_value = cr_badvaddr;

// Count        reg: 9, sel: 0
reg  [31:0] cr_count;
wire [31:0] count_value;
assign count_value = cr_count;

// Compare      reg: 11, sel: 0
reg  [31:0] cr_compare;
wire [31:0] compare_value;
assign compare_value = cr_compare;

// Status       reg: 12, sel: 0
wire        cr_status_BEV;
reg         cr_status_IM7;
reg         cr_status_IM6;
reg         cr_status_IM5;
reg         cr_status_IM4;
reg         cr_status_IM3;
reg         cr_status_IM2;
reg         cr_status_IM1;
reg         cr_status_IM0;
reg         cr_status_EXL;
reg         cr_status_IE;
assign cr_status_BEV = 1'b1;
wire [31:0] status_value;
assign status_value = {
    9'b0,
    cr_status_BEV,
    6'b0, 
    cr_status_IM7,
    cr_status_IM6,
    cr_status_IM5,
    cr_status_IM4,
    cr_status_IM3,
    cr_status_IM2,
    cr_status_IM1,
    cr_status_IM0,
    6'b0,
    cr_status_EXL,
    cr_status_IE
};

// Cause        reg: 13, sel: 0
reg         cr_cause_BD;
reg         cr_cause_TI;
reg         cr_cause_IP7;
reg         cr_cause_IP6;
reg         cr_cause_IP5;
reg         cr_cause_IP4;
reg         cr_cause_IP3;
reg         cr_cause_IP2;
reg         cr_cause_IP1;
reg         cr_cause_IP0;
reg  [4:0]  cr_cause_ExcCode;
wire [31:0] cause_value;
assign cause_value = {
    cr_cause_BD,
    cr_cause_TI,
    14'b0,
    cr_cause_IP7,
    cr_cause_IP6,
    cr_cause_IP5,
    cr_cause_IP4,
    cr_cause_IP3,
    cr_cause_IP2,
    cr_cause_IP1,
    cr_cause_IP0,
    1'b0,
    cr_cause_ExcCode,
    2'b00
};

// EPC          reg: 14, sel: 0
reg  [31:0] cr_epc;
wire [31:0] epc_value;
assign epc_value = cr_epc;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//----------| pre-IF stage |------------
//Start fetching instructions after resetting
assign to_fs_valid  = ~reset;
//*seq_pc* Next program counter if execute sequentially
assign seq_pc = fs_pc + 3'h4;
//When EXE stage is not valid (e.g. ID stalling), CPU should not jump in or out the exception handler section
//TODO By [Tag 01], maybe nextpc = br_taken ? br_target : seq_pc  is enough
assign nextpc = es_valid ?
                (exception_commit ? 32'hbfc00380 : es_inst_ERET ? epc_value : br_taken ? br_target : seq_pc) : 
                (br_taken ? br_target : seq_pc);
//Exception in IF stage: Address not aligned when loading instruction
assign ex_inst_ADEL = nextpc[1] | nextpc[0];

//----------|fs_| IF stage |------------
reg [1:0] fs_state;
reg [1:0] fs_next_state;
reg       nextpc_ex;
reg       nextpc_eret;
//Wait for loading Instruction data
assign fs_ready_go    = fs_state == 2'b00;
assign fs_allowin     = !fs_valid || fs_ready_go && ds_allowin;
assign fs_to_ds_valid = fs_valid && fs_ready_go;
always @(posedge clk) begin
    if (reset) begin
        fs_valid <= 1'b0;
        fs_inst_ADEL <= 1'b0;
        fs_inst_data_ok <= 1'b1;
        nextpc_ex <= 1'b0;
        nextpc_eret <= 1'b0;
    end
    else if (fs_allowin) begin
        fs_valid <= to_fs_valid;
    end

    fs_inst_data_ok <= inst_data_ok;
    if(inst_data_ok)
        fs_inst <= inst;
    if(exception_commit)
        nextpc_ex <= 1'b1;
    if(es_inst_ERET)
        nextpc_eret <= 1'b1;
    if (reset) begin
//trick: to make nextpc be 0xbfc00000 during reset
        fs_pc <= 32'hbfbffffc;
    end
    else if (to_fs_valid && fs_allowin) begin
//[Tag 01] begin
        if(nextpc_ex) begin
            fs_pc <= 32'hbfc00380;
            nextpc_ex <= 1'b0;
            //Important! need to set ADEL exception when not sequentially assigning fs_pc
            fs_inst_ADEL <= 1'b0;
        end
        else if(nextpc_eret) begin
            fs_pc <= epc_value;
            nextpc_eret <= 1'b0;
            //Important! need to set ADEL exception when not sequentially assigning fs_pc
            fs_inst_ADEL <= epc_value[1] | epc_value[0];
        end
        else
            fs_pc <= nextpc;
            fs_inst_ADEL <= ex_inst_ADEL;
//[Tag 01] end
    end
end

always @(posedge clk) begin
    if (reset)
        fs_state <= 2'b00;
    else
        fs_state <= fs_next_state;
end

//IF stage FSM ctrl: 00(ready) =(ds_allowin)=> 01 =(addr_sent)=> 10 =(inst_ready)=> 00
always @(*) begin
    if(fs_state == 2'b00 & ds_allowin)
        fs_next_state <= 2'b01;
    else if(fs_state == 2'b01 & inst_addr_ok)
        fs_next_state <= 2'b10;
    else if(fs_state == 2'b10 & fs_inst_data_ok)
        fs_next_state <= 2'b00;
    else
        fs_next_state <= fs_state;
end

//inst sram-lick output
assign inst_req   = fs_valid & (fs_state == 2'b01);
assign inst_wr    = 1'b0;
assign inst_size  = 2'b10;
assign inst_addr  = inst_req ? fs_pc : 32'hxxxxxxxx;
assign inst_wdata = 32'b0;
assign inst       = inst_rdata;

//----------|ds_| ID stage |------------
reg ds_ex_reg;
assign ds_ready_go    = !stall;
assign ds_allowin     = !ds_valid || ds_ready_go && es_allowin;
assign ds_to_es_valid = ds_valid && ds_ready_go;
always @(posedge clk) begin
    if (reset) begin
        ds_valid <= 1'b0;
        ds_inst  <= 32'b0;
        ds_ex_tag <= 1'b0;
        ds_ex_reg <= 1'b0;
        ds_inst_ADEL <= 1'b0;
    end
    else if (ds_allowin) begin
        ds_valid <= fs_to_ds_valid;
    end

    if (fs_to_ds_valid && ds_allowin) begin
//*es_inst_ERET* will triger *set_ex_tag*, which will flush the pipeline.
//But due to delay slot design, the inst in ID stage should not be flushed.
        if((ds_ex_reg || set_ex_tag) & !es_inst_ERET) begin
            ds_ex_tag <= 1'b1;
            ds_ex_reg <= 1'b0;
        end
        else begin
            ds_ex_tag <= 1'b0;
        end
        ds_inst_ADEL <= fs_pc[1] | fs_pc[0] /*fs_inst_ADEL*/;
        ds_pc   <= fs_pc;
        ds_inst <= fs_inst;
    end
//Use *ds_ex_reg* to remember the exception when ID stage is stalled
//[TAG 02]
    else if(set_ex_tag & !es_inst_ERET)
        ds_ex_reg <= 1'b1;
end

assign op   = ds_inst[31:26];
assign rs   = ds_inst[25:21];
assign rt   = ds_inst[20:16];
assign rd   = ds_inst[15:11];
assign sa   = ds_inst[10: 6];
assign func = ds_inst[ 5: 0];
assign imm  = ds_inst[15: 0];
assign jidx = ds_inst[25: 0];
assign sel  = ds_inst[ 2: 0]; 

//decoder from tools.v, binary to one-hot
decoder_6_64 u_dec0(.in(op  ), .out(op_d  ));
decoder_6_64 u_dec1(.in(func), .out(func_d));
decoder_5_32 u_dec2(.in(rs  ), .out(rs_d  ));
decoder_5_32 u_dec3(.in(rt  ), .out(rt_d  ));
decoder_5_32 u_dec4(.in(rd  ), .out(rd_d  ));
decoder_5_32 u_dec5(.in(sa  ), .out(sa_d  ));

assign inst_ADDU   = op_d[6'h00] & func_d[6'h21] & sa_d[5'h00];
assign inst_SUBU   = op_d[6'h00] & func_d[6'h23] & sa_d[5'h00];
assign inst_SLT    = op_d[6'h00] & func_d[6'h2a] & sa_d[5'h00];
assign inst_SLTU   = op_d[6'h00] & func_d[6'h2b] & sa_d[5'h00];
assign inst_AND    = op_d[6'h00] & func_d[6'h24] & sa_d[5'h00];
assign inst_OR     = op_d[6'h00] & func_d[6'h25] & sa_d[5'h00];
assign inst_XOR    = op_d[6'h00] & func_d[6'h26] & sa_d[5'h00];
assign inst_NOR    = op_d[6'h00] & func_d[6'h27] & sa_d[5'h00];
assign inst_SLL    = op_d[6'h00] & func_d[6'h00] & rs_d[5'h00];
assign inst_SRL    = op_d[6'h00] & func_d[6'h02] & rs_d[5'h00];
assign inst_SRA    = op_d[6'h00] & func_d[6'h03] & rs_d[5'h00];
assign inst_ADDIU  = op_d[6'h09];
assign inst_LUI    = op_d[6'h0f] & rs_d[5'h00];
assign inst_LW     = op_d[6'h23];
assign inst_SW     = op_d[6'h2b];
assign inst_BEQ    = op_d[6'h04];
assign inst_BNE    = op_d[6'h05];
assign inst_JAL    = op_d[6'h03];
assign inst_JR     = op_d[6'h00] & func_d[6'h08] & rt_d[5'h00] & rd_d[5'h00] & sa_d[5'h00];
assign inst_ADD    = op_d[6'h00] & func_d[6'h20] & sa_d[5'h00];
assign inst_ADDI   = op_d[6'h08];
assign inst_SUB    = op_d[6'h00] & func_d[6'h22] & sa_d[5'h00];
assign inst_SLTI   = op_d[6'h0a];
assign inst_SLTIU  = op_d[6'h0b];
assign inst_ANDI   = op_d[6'h0c];
assign inst_ORI    = op_d[6'h0d];
assign inst_XORI   = op_d[6'h0e];
assign inst_SLLV   = op_d[6'h00] & func_d[6'h04] & sa_d[5'h00];
assign inst_SRAV   = op_d[6'h00] & func_d[6'h07] & sa_d[5'h00];
assign inst_SRLV   = op_d[6'h00] & func_d[6'h06] & sa_d[5'h00];
assign inst_DIV    = op_d[6'h00] & func_d[6'h1a] & sa_d[5'h00] & rd_d[5'h00];
assign inst_DIVU   = op_d[6'h00] & func_d[6'h1b] & sa_d[5'h00] & rd_d[5'h00];
assign inst_MULT   = op_d[6'h00] & func_d[6'h18] & sa_d[5'h00] & rd_d[5'h00];
assign inst_MULTU  = op_d[6'h00] & func_d[6'h19] & sa_d[5'h00] & rd_d[5'h00];
assign inst_MFHI   = op_d[6'h00] & func_d[6'h10] & sa_d[5'h00] & rs_d[5'h00] & rt_d[5'h00];
assign inst_MFLO   = op_d[6'h00] & func_d[6'h12] & sa_d[5'h00] & rs_d[5'h00] & rt_d[5'h00];
assign inst_MTHI   = op_d[6'h00] & func_d[6'h11] & sa_d[5'h00] & rt_d[5'h00] & rd_d[5'h00];
assign inst_MTLO   = op_d[6'h00] & func_d[6'h13] & sa_d[5'h00] & rt_d[5'h00] & rd_d[5'h00];
assign inst_J      = op_d[6'h02];
assign inst_BGEZ   = op_d[6'h01] & rt_d[5'h01];
assign inst_BGTZ   = op_d[6'h07] & rt_d[5'h00];
assign inst_BLEZ   = op_d[6'h06] & rt_d[5'h00];
assign inst_BLTZ   = op_d[6'h01] & rt_d[5'h00];
assign inst_BLTZAL = op_d[6'h01] & rt_d[5'h10];
assign inst_BGEZAL = op_d[6'h01] & rt_d[5'h11];
assign inst_JALR   = op_d[6'h00] & func_d[6'h09] & sa_d[5'h00] & rt_d[5'h00];
assign inst_LB     = op_d[6'h20];
assign inst_LBU    = op_d[6'h24];
assign inst_LH     = op_d[6'h21];
assign inst_LHU    = op_d[6'h25];
assign inst_LWL    = op_d[6'h22];
assign inst_LWR    = op_d[6'h26];
assign inst_SB     = op_d[6'h28];
assign inst_SH     = op_d[6'h29];
assign inst_SWL    = op_d[6'h2a];
assign inst_SWR    = op_d[6'h2e];
assign inst_ERET   = op_d[6'h10] & func_d[6'h18]&rs_d[5'h10]&rt_d[5'h00]&rd_d[5'h00]&sa_d[5'h00];
assign inst_MFC0   = op_d[6'h10] & (func[5:3]==3'b0) & rs_d[5'h00] & sa_d[5'h00];
assign inst_MTC0   = op_d[6'h10] & (func[5:3]==3'b0) & rs_d[5'h04] & sa_d[5'h00];
assign inst_BREAK  = op_d[6'h00] & func_d[6'h0d];
assign inst_SYSCALL= op_d[6'h00] & func_d[6'h0c];

//ALU - add
assign alu_op[ 0] = inst_ADD  | inst_ADDU | inst_ADDI | inst_ADDIU | inst_LW | inst_LB | inst_LBU | inst_LH | inst_LHU | inst_LWL | inst_LWR
                  | inst_SW | inst_SB | inst_SH | inst_SWL | inst_SWR | inst_JAL | inst_BLTZAL | inst_BGEZAL | inst_JALR;
//ALU - sub
assign alu_op[ 1] = inst_SUB  | inst_SUBU | inst_BEQ  | inst_BNE ;
//ALU - slt
assign alu_op[ 2] = inst_SLT  | inst_SLTI;
//ALU - sltu
assign alu_op[ 3] = inst_SLTU | inst_SLTIU;
//ALU - and
assign alu_op[ 4] = inst_AND  | inst_ANDI;
//ALU - nor
assign alu_op[ 5] = inst_NOR;
//ALU - or
assign alu_op[ 6] = inst_OR   | inst_ORI  | inst_MTHI | inst_MTLO;
//ALU - xor
assign alu_op[ 7] = inst_XOR  | inst_XORI;
//ALU - sll
assign alu_op[ 8] = inst_SLL  | inst_SLLV;
//ALU - srl
assign alu_op[ 9] = inst_SRL  | inst_SRLV;
//ALU - sra
assign alu_op[10] = inst_SRA  | inst_SRAV;
//ALU - lui
assign alu_op[11] = inst_LUI;

//ALU source number 1
assign src1_is_sa   = inst_SLL | inst_SRL  | inst_SRA;
assign src1_is_pc   = inst_JAL | inst_JALR | inst_BLTZAL | inst_BGEZAL;
//ALU source number 2
assign src2_is_imm  = inst_LUI | inst_LW   | inst_SW   | inst_ADDI | inst_ADDIU | inst_SLTI | inst_SLTIU | inst_LB | inst_LBU | inst_LH | inst_LHU | inst_LWL | inst_LWR | inst_SB | inst_SH | inst_SW | inst_SWR | inst_SWL;
assign src2_is_uimm = inst_ORI | inst_ANDI | inst_XORI;
assign src2_is_8    = inst_JAL | inst_JALR | inst_BLTZAL | inst_BGEZAL;
//regfile final data source is from memory
assign res_from_mem = inst_LW  | inst_LB   | inst_LBU  | inst_LH   | inst_LHU  | inst_LWL  | inst_LWR;
//regfile dest location is No.31
assign dst_is_r31   = inst_JAL | inst_BLTZAL | inst_BGEZAL;
//regfile dest location is Inst rt section
assign dst_is_rt    = inst_LUI | inst_LW  | inst_ADDIU | inst_ORI | inst_ANDI | inst_XORI | inst_ADDI | inst_SLTI | inst_SLTIU | inst_LB | inst_LBU | inst_LH | inst_LHU | inst_LWL | inst_LWR | inst_MFC0;
//Need to write regfile
assign gr_we        = ~inst_SW & ~inst_BEQ & ~inst_BNE & ~inst_JR & ~inst_DIV & ~inst_DIVU & ~inst_MULT & ~inst_MULTU & ~inst_MTHI & ~inst_MTLO & ~inst_J & ~inst_BGEZ &
                      ~inst_BGTZ & ~inst_BLEZ & ~inst_BLTZ & ~inst_SB & ~inst_SH & ~inst_SWL & ~inst_SWR & ~inst_MTC0 & ~inst_ERET & ~inst_SYSCALL & ~inst_BREAK;
//Do not need the data from regfile rs port
assign not_read_rs  = inst_JAL | inst_J   | inst_MFC0  | inst_MTC0 | inst_ERET | inst_BREAK | inst_SYSCALL;
//Do not need the data from regfile rt port
assign not_read_rt  = inst_LUI | inst_ADDIU | inst_LW | inst_JAL | inst_ADDI | inst_SLTI | inst_SLTIU | inst_ANDI | inst_ORI | inst_XORI
                      | inst_J | inst_BGEZ | inst_BLTZAL | inst_BGEZAL | inst_LB | inst_LBU |inst_LH | inst_LHU | inst_LWL | inst_LWR  | inst_MFC0 | inst_ERET | inst_BREAK | inst_SYSCALL;
//A control set to pass multiply/divide Inst decoding result to next stage
assign mul_div      = {inst_MULT, inst_MULTU, inst_DIV, inst_DIVU};
assign dest         = dst_is_r31 ? 5'd31 :
                      dst_is_rt  ? rt    :
                                   rd;
//A control set to pass loading Inst decoding result to next stage
assign load_mask    = {inst_LW, inst_LH, inst_LHU, inst_LB, inst_LBU, inst_LWL, inst_LWR};
//A control set to pass saving Inst decoding result to next stage
assign save_mask    = {inst_SW, inst_SH, inst_SB, inst_SWL, inst_SWR};
//Branch Inst
assign inst_BRANCH  = inst_BEQ | inst_BNE | inst_BGEZ | inst_BGEZAL | inst_BLTZ | inst_BLTZAL | inst_BGTZ | inst_BLEZ| inst_JAL | inst_JALR | inst_JR | inst_J;
//Data conflit between rs data and EXE stage
assign rs_from_es = (!not_read_rs) && (rs != 5'b0) && (rs == es_dest) && es_gr_we && (!inst_BRANCH) && (!es_res_from_mem) && (!es_inst_MFHI) && (!es_inst_MFLO) &&(!es_inst_MFC0) && (!es_ex_tag) && es_ready_go;
//Data conflit between rs data and MEM stage
assign rs_from_ms = (!not_read_rs) && (rs != 5'b0) && (rs == ms_dest) && ms_gr_we && (!inst_BRANCH) && (!ms_ex_tag) && ms_ready_go;
//Data conflit between rs data and WB stage
assign rs_from_ws = (!not_read_rs) && (rs != 5'b0) && (rs == ws_dest) && ws_gr_we && (!inst_BRANCH) && (!ws_ex_tag) && ws_ready_go;
//Data conflit between rt data and EXE stage
assign rt_from_es = (!not_read_rt) && (rt != 5'b0) && (rt == es_dest) && es_gr_we && (!inst_BRANCH) && (!es_res_from_mem) && (!es_inst_MFHI) && (!es_inst_MFLO) &&(!es_inst_MFC0) && (!es_ex_tag) && es_ready_go;
//Data conflit between rt data and MEM stage
assign rt_from_ms = (!not_read_rt) && (rt != 5'b0) && (rt == ms_dest) && ms_gr_we && (!inst_BRANCH) && (!ms_ex_tag) && ms_ready_go;
//Data conflit between rt data and WB stage
assign rt_from_ws = (!not_read_rt) && (rt != 5'b0) && (rt == ws_dest) && ws_gr_we && (!inst_BRANCH) && (!ws_ex_tag) && ws_ready_go;
//Need to stall due to rs conflit
assign rs_stall   = (not_read_rs || rs == 5'b0 || rs_from_es || rs_from_ms || rs_from_ws) ? 1'b0 : (rs == es_dest || rs == ms_dest || rs == ws_dest);
//Need to stall due to tt conflit
assign rt_stall   = (not_read_rt || rt == 5'b0 || rt_from_es || rt_from_ms || rt_from_ws) ? 1'b0 : (rt == es_dest || rt == ms_dest || rt == ws_dest);
//When setting exception tag, ID stage will be flushed and no need for stalling
assign stall      = (rs_stall || rt_stall) & !set_ex_tag;

//regfile.v connector
assign rf_raddr1    = rs;
assign rf_raddr2    = rt;
regfile u_regfile(
        .clk         (clk      ),
        .raddr1      (rf_raddr1),
        .rdata1      (rf_rdata1),
        .raddr2      (rf_raddr2),
        .rdata2      (rf_rdata2),
        .we          (rf_we    ),
        .waddr       (rf_waddr ),
        .wdata       (rf_wdata )
    );
//Forward value or read value from regfile
assign rs_value = rs_from_es ? alu_result :
                  rs_from_ms ? final_result :
                  rs_from_ws ? ws_final_result :
                               rf_rdata1;
assign rt_value = rt_from_es ? alu_result :
                  rt_from_ms ? final_result :
                  rt_from_ws ? ws_final_result :
                               rf_rdata2;

//Branch judging
assign rs_eq_rt = (rf_rdata1 == rf_rdata2);
assign rs_zero  = ~(|rf_rdata1);
assign rs_gez   =  rs_zero | !rf_rdata1[31];
assign rs_gtz   = !rs_zero & !rf_rdata1[31];
assign rs_lez   =  rs_zero |  rf_rdata1[31];
assign rs_ltz   = !rs_zero &  rf_rdata1[31];
assign br_taken = (    rs_eq_rt && inst_BEQ 
                   || !rs_eq_rt && inst_BNE
                   || rs_gez && (inst_BGEZ | inst_BGEZAL)
                   || rs_ltz && (inst_BLTZ | inst_BLTZAL)
                   || rs_gtz && inst_BGTZ
                   || rs_lez && inst_BLEZ
                   || inst_JAL
                   || inst_JALR
                   || inst_JR
                   || inst_J
                  ) /*&& ds_valid */&& !ds_ex_tag;
assign br_target = (inst_JAL  || inst_J)    ? ({fs_pc[31:28], jidx[25:0], 2'b0}) :
                   (inst_JR   || inst_JALR) ? rf_rdata1 :
                   /*BXXX*/                   fs_pc + {{14{imm[15]}}, imm[15:0], 2'b0};
//#Exception
assign ex_INT   = |(cause_value[15:8] & status_value[15:8]);
assign ex_RI    = !(inst_ADDU  | inst_SUBU  | inst_SLT   | inst_SLTU  | inst_AND   | inst_OR    |
                    inst_XOR   | inst_NOR   | inst_SLL   | inst_SRL   | inst_SRA   | inst_ADDIU |
                    inst_LUI   | inst_LW    | inst_SW    | inst_BEQ   | inst_BNE   | inst_JAL   |
                    inst_JR    | inst_ADD   | inst_ADDI  | inst_SUB   | inst_SLTI  | inst_SLTIU |
                    inst_ANDI  | inst_ORI   | inst_XORI  | inst_SLLV  | inst_SRAV  | inst_SRLV  |
                    inst_DIV   | inst_DIVU  | inst_MULT  | inst_MULTU | inst_MFHI  | inst_MFLO  |
                    inst_MTHI  | inst_MTLO  | inst_J     | inst_BGEZ  | inst_BGTZ  | inst_BLEZ  |
                    inst_BLTZ  | inst_BLTZAL| inst_BGEZAL| inst_JALR  | inst_LB    | inst_LBU   |
                    inst_LH    | inst_LHU   | inst_LWL   | inst_LWR   | inst_SB    | inst_SH    |
                    inst_SWL   | inst_SWR   | inst_ERET  | inst_MFC0  | inst_MTC0  | inst_BREAK |
                    inst_SYSCALL);
assign excode = ex_INT       ? 6'h00 :
                ex_RI        ? 6'h0a :
                inst_SYSCALL ? 6'h08 :
                inst_BREAK   ? 6'h09 :
                               6'h00 ;
assign ds_exception = inst_SYSCALL | inst_BREAK | ex_RI | ex_INT;

//----------|es_| EXE stage |------------
reg es_ex_reg;
//Need to wait for division
assign es_ready_go    = (es_mul_div[1:0] == 2'b0 | es_ex_tag) ? 1'b1 : div_done;
assign es_allowin     = !es_valid || es_ready_go && ms_allowin;
assign es_to_ms_valid = es_valid && es_ready_go || stall;
always @(posedge clk) begin
    if (reset) begin
        es_valid <= 1'b0;
        es_mul_div <= 4'b0;
        es_ex_tag <= 1'b0;
        es_ex_reg <= 1'b0;
        es_ex_occur <= 1'b0;
        es_inst_ADEL <= 1'b0;
    end
    else if (es_allowin) begin
        es_valid <= ds_to_es_valid;
    end
//Use *es_ex_reg* to remember the exception when EXE stage is stalled
//Need to notice that the location is different from [TAG 02] and [TAG 03]
    if(set_ex_tag & !(ds_to_es_valid && es_allowin))
        es_ex_reg <= 1'b1;
//Only set those three regs because they will cause the chaneg of memory or regfile
    if (stall & !es_valid) begin
        es_res_from_mem <= 1'b0;
        es_gr_we        <= 1'b0;
        es_dest         <= 5'b0;
    end
    else if (ds_to_es_valid && es_allowin) begin
        es_pc           <= ds_pc;
        es_rs_value     <= rs_value;
        es_rt_value     <= rt_value;
        es_imm          <= imm;
        es_alu_op       <= alu_op;
        es_src1_is_sa   <= src1_is_sa;
        es_src1_is_pc   <= src1_is_pc;
        es_src2_is_imm  <= src2_is_imm;
        es_src2_is_uimm <= src2_is_uimm;
        es_src2_is_8    <= src2_is_8;
        es_res_from_mem <= res_from_mem;
        es_gr_we        <= gr_we;
        es_dest         <= gr_we ? dest : 5'b0;
        es_load_mask    <= load_mask;
        es_save_mask    <= save_mask;
        es_mul_div      <= mul_div;
        es_inst_MFHI    <= inst_MFHI;
        es_inst_MFLO    <= inst_MFLO;
        es_inst_MTHI    <= inst_MTHI;
        es_inst_MTLO    <= inst_MTLO;
        es_inst_MTC0    <= inst_MTC0;
        es_inst_MFC0    <= inst_MFC0;
        es_inst_ERET    <= inst_ERET;
        es_inst_BRANCH  <= inst_BRANCH;
        es_excode       <= excode;
        es_ex_occur     <= ds_exception;
        es_inst_ADEL    <= ds_inst_ADEL;
        es_cp0_addr     <= {rd, sel};
        es_ov_add       <= inst_ADD | inst_ADDI;
        es_ov_sub       <= inst_SUB;
        if(es_ex_reg || set_ex_tag) begin
            es_ex_tag <= 1'b1;
            es_ex_reg <= 1'b0;
        end
        else begin
            es_ex_tag <= ds_ex_tag;
        end
    end
end

assign alu_src1     = es_src1_is_sa   ? {27'b0, es_imm[10:6]} :
                      es_src1_is_pc   ? es_pc[31:0] :
                                        es_rs_value;
assign alu_src2     = es_src2_is_imm  ? {{16{es_imm[15]}}, es_imm[15:0]} :
                      es_src2_is_uimm ? {16'b0, es_imm[15:0]} :
                      es_src2_is_8    ? 32'd8 :
                                        es_rt_value;
//alu.v connector
alu u_alu(
        .alu_control (es_alu_op ),
        .alu_src1    (alu_src1  ),
        .alu_src2    (alu_src2  ),
        .alu_result  (alu_result)
);
//multiplier.v connector
mul u_mul(
    .mul_clk      (clk),
    .resetn       (resetn),
    .mul_signed   (es_mul_div[3]),
    .x            (es_rs_value),
    .y            (es_rt_value),    
    .result       (mul_result)
);
//divider.v connector
div u_div(
    .div_clk    (clk),
    .resetn     (resetn),
    .div        ((es_mul_div[1] | es_mul_div[0]) & !es_ex_tag),
    .div_signed (es_mul_div[1]),
    .x          (es_rs_value),
    .y          (es_rt_value),
    .s          (div_result[63:32]),
    .r          (div_result[31: 0]),
    .complete   (div_done)
);

//#Exception
assign ex_OV  = (~alu_src1[31]&~alu_src2[31]& alu_result[31] | alu_src1[31]& alu_src2[31]&~alu_result[31] ) & es_ov_add |
                (~alu_src1[31]& alu_src2[31]& alu_result[31] | alu_src1[31]&~alu_src2[31]&~alu_result[31] ) & es_ov_sub ;
assign ex_data_ADES    = (es_save_mask[4] & (alu_result[1] | alu_result[0])) | (es_save_mask[3] & alu_result[0]);
assign ex_data_ADEL    = (es_load_mask[6] & (alu_result[1] | alu_result[0])) | ((es_load_mask[5] | es_load_mask[4]) & alu_result[0]);
assign es_exception    = ex_data_ADEL | ex_data_ADES | ex_OV | es_ex_occur | es_inst_ADEL;
assign exe_excode      = (es_excode==6'h00 & es_ex_occur) ? 6'h00 :
                                             es_inst_ADEL ? 6'h04 :
                                                    ex_OV ? 6'h0c :
                                             ex_data_ADEL ? 6'h04 :
                                             ex_data_ADES ? 6'h05 :
                                                        es_excode ;

//----------|ms_| MEM stage |------------
reg ms_ex_reg;
(*mark_debug = "true"*)reg [2:0] ms_state;
reg [2:0] ms_next_state;
assign ms_ready_go    = ms_state == 3'b000;
assign ms_allowin     = !ms_valid || ms_ready_go && ws_allowin;
assign ms_to_ws_valid = ms_valid && ms_ready_go;
always @(posedge clk) begin
    if (reset) begin
        ms_valid <= 1'b0;
        ms_ex_tag <= 1'b0;
        ms_ex_reg <= 1'b0;
        ms_data_data_ok <= 1'b1;
    end
    else if (ms_allowin) begin
        ms_valid <= es_to_ms_valid;
    end

    ms_data_data_ok <= data_data_ok;
    if(data_data_ok)
        ms_data <= data_rdata;

    if (es_to_ms_valid && ms_allowin) begin
        ms_pc           <= es_pc;
        ms_gr_we        <= es_gr_we;
        ms_dest         <= es_dest;
        ms_load_mask    <= es_load_mask;
        ms_save_mask    <= es_save_mask;
        ms_final_result <= es_inst_MFHI ? next_HI : es_inst_MFLO ? next_LO : es_inst_MFC0 ? cp0_rd_value : alu_result;
        ms_res_from_mem <= es_res_from_mem;
        ms_mul_div      <= es_mul_div;
        ms_div_result   <= div_result;
        ms_inst_MTHI    <= es_inst_MTHI;
        ms_inst_MTLO    <= es_inst_MTLO;
        ms_rt_value     <= es_rt_value;
        ms_inst_BRANCH  <= es_inst_BRANCH;
        if(ms_ex_reg || set_ex_tag) begin
            ms_ex_tag <= 1'b1;
            ms_ex_reg <= 1'b0;
        end
        else begin
            ms_ex_tag <= es_ex_tag;
        end
    end
//Use *ms_ex_reg* to remember the exception when MEM stage is stalled
//[TAG 03]
    else if(set_ex_tag)
        ms_ex_reg <= 1'b1;
end

//save_mask - {inst_SW, inst_SH, inst_SB, inst_SWL, inst_SWR}
//Re-assemble saving data
wire       write_twice;
wire [1 :0] w1_size;
wire [31:0] w1_addr;
wire [1 :0] w2_size;
wire [31:0] w2_addr;
assign write_twice = (ms_save_mask[1] & (ms_final_result[1:0]==2'b10)) | 
                     (ms_save_mask[0] & (ms_final_result[1:0]==2'b01));
assign w1_size = ms_save_mask[4] ?                                 2'b10 :
                 ms_save_mask[3] & (ms_final_result[1:0]==2'b00) ? 2'b01 :
                 ms_save_mask[3] & (ms_final_result[1:0]==2'b10) ? 2'b01 :
                 ms_save_mask[2] & (ms_final_result[1:0]==2'b00) ? 2'b00 :
                 ms_save_mask[2] & (ms_final_result[1:0]==2'b01) ? 2'b00 :
                 ms_save_mask[2] & (ms_final_result[1:0]==2'b10) ? 2'b00 :
                 ms_save_mask[2] & (ms_final_result[1:0]==2'b11) ? 2'b00 :
                 ms_save_mask[1] & (ms_final_result[1:0]==2'b00) ? 2'b00 :
                 ms_save_mask[1] & (ms_final_result[1:0]==2'b01) ? 2'b01 :
                 ms_save_mask[1] & (ms_final_result[1:0]==2'b10) ? 2'b01 :
                 ms_save_mask[1] & (ms_final_result[1:0]==2'b11) ? 2'b10 :
                 ms_save_mask[0] & (ms_final_result[1:0]==2'b00) ? 2'b10 :
                 ms_save_mask[0] & (ms_final_result[1:0]==2'b01) ? 2'b00 :
                 ms_save_mask[0] & (ms_final_result[1:0]==2'b10) ? 2'b01 :
                 ms_save_mask[0] & (ms_final_result[1:0]==2'b11) ? 2'b00 :
                                                                   2'b11;
assign w1_addr = ms_save_mask[1] ? {ms_final_result[31:2], 2'b00} : ms_final_result;
assign w2_size = ms_save_mask[1] & (ms_final_result[1:0]==2'b10) ? 2'b00 :
                 ms_save_mask[0] & (ms_final_result[1:0]==2'b01) ? 2'b01 :
                                                                 2'b11;
assign w2_addr = ms_save_mask[0] ? {ms_final_result[31:2], 2'b10} : ms_final_result;
assign mem_wdata = ms_save_mask[4] ?                                 ms_rt_value :
                   ms_save_mask[3] & (ms_final_result[1:0]==2'b00) ? {16'b0, ms_rt_value[15: 0]} :
                   ms_save_mask[3] & (ms_final_result[1:0]==2'b10) ? {ms_rt_value[15: 0], 16'b0} :
                   ms_save_mask[2] & (ms_final_result[1:0]==2'b00) ? {24'b0, ms_rt_value[ 7: 0]} :
                   ms_save_mask[2] & (ms_final_result[1:0]==2'b01) ? {16'b0, ms_rt_value[ 7: 0],  8'b0} :
                   ms_save_mask[2] & (ms_final_result[1:0]==2'b10) ? { 8'b0, ms_rt_value[ 7: 0], 16'b0} :
                   ms_save_mask[2] & (ms_final_result[1:0]==2'b11) ? {ms_rt_value[ 7: 0], 24'b0} :
                   ms_save_mask[1] & (ms_final_result[1:0]==2'b00) ? {24'b0, ms_rt_value[31:24]} :
                   ms_save_mask[1] & (ms_final_result[1:0]==2'b01) ? {16'b0, ms_rt_value[31:16]} :
                   ms_save_mask[1] & (ms_final_result[1:0]==2'b10) ? { 8'b0, ms_rt_value[31: 8]} :
                   ms_save_mask[1] & (ms_final_result[1:0]==2'b11) ? ms_rt_value :
                   ms_save_mask[0] & (ms_final_result[1:0]==2'b00) ? ms_rt_value :
                   ms_save_mask[0] & (ms_final_result[1:0]==2'b01) ? {ms_rt_value[23: 0],  8'b0} :
                   ms_save_mask[0] & (ms_final_result[1:0]==2'b10) ? {ms_rt_value[15: 0], 16'b0} :
                   ms_save_mask[0] & (ms_final_result[1:0]==2'b11) ? {ms_rt_value[ 7: 0], 24'b0} :
                                                                     32'b0;

//ms_load_mask - {inst_LW, inst_LH, inst_LHU, inst_LB, inst_LBU, inst_LWL, inst_LWR};
//Re-assemble loaded data
assign mem_result   = data_rdata;
assign mask_result  = ms_load_mask[6]                                 ? mem_result[31:0] :
                      ms_load_mask[5] & (ms_final_result[1:0]==2'b00) ? {{16{mem_result[15]}}, mem_result[15: 0]} :
                      ms_load_mask[5] & (ms_final_result[1:0]==2'b10) ? {{16{mem_result[31]}}, mem_result[31:16]} :
                      ms_load_mask[4] & (ms_final_result[1:0]==2'b00) ? {16'b0, mem_result[15:0]} :
                      ms_load_mask[4] & (ms_final_result[1:0]==2'b10) ? {16'b0, mem_result[31:16]} :
                      ms_load_mask[3] & (ms_final_result[1:0]==2'b00) ? {{24{mem_result[ 7]}}, mem_result[ 7: 0]} :
                      ms_load_mask[3] & (ms_final_result[1:0]==2'b01) ? {{24{mem_result[15]}}, mem_result[15: 8]} :
                      ms_load_mask[3] & (ms_final_result[1:0]==2'b10) ? {{24{mem_result[23]}}, mem_result[23:16]} :
                      ms_load_mask[3] & (ms_final_result[1:0]==2'b11) ? {{24{mem_result[31]}}, mem_result[31:24]} :
                      ms_load_mask[2] & (ms_final_result[1:0]==2'b00) ? {24'b0, mem_result[ 7: 0]} :
                      ms_load_mask[2] & (ms_final_result[1:0]==2'b01) ? {24'b0, mem_result[15: 8]} :
                      ms_load_mask[2] & (ms_final_result[1:0]==2'b10) ? {24'b0, mem_result[23:16]} :
                      ms_load_mask[2] & (ms_final_result[1:0]==2'b11) ? {24'b0, mem_result[31:24]} :
                      ms_load_mask[1] & (ms_final_result[1:0]==2'b00) ? {mem_result[ 7: 0], ms_rt_value[23: 0]}:
                      ms_load_mask[1] & (ms_final_result[1:0]==2'b01) ? {mem_result[15: 0], ms_rt_value[15: 0]}:
                      ms_load_mask[1] & (ms_final_result[1:0]==2'b10) ? {mem_result[23: 0], ms_rt_value[ 7: 0]}:
                      ms_load_mask[1] & (ms_final_result[1:0]==2'b11) ? {mem_result[31: 0]}:
                      ms_load_mask[0] & (ms_final_result[1:0]==2'b00) ? {mem_result[31: 0]}:
                      ms_load_mask[0] & (ms_final_result[1:0]==2'b01) ? {ms_rt_value[31:24], mem_result[31: 8]}:
                      ms_load_mask[0] & (ms_final_result[1:0]==2'b10) ? {ms_rt_value[31:16], mem_result[31:16]}:
                      ms_load_mask[0] & (ms_final_result[1:0]==2'b11) ? {ms_rt_value[31: 8], mem_result[31:24]}:
                                                                        32'b0;

wire inst_LOAD  = |es_load_mask;
wire inst_STORE = |es_save_mask;
assign data_req = ms_valid & (ms_state==3'b001 || ms_state==3'b011);
assign data_wr  = |ms_save_mask & data_req;
assign data_size = |ms_load_mask ? 2'b10 : ms_state==3'b011 ? w2_size : w1_size;
assign data_addr = |ms_load_mask ? ms_final_result : ms_state==3'b011 ? w2_addr : w1_addr;
assign data_wdata = mem_wdata;
assign final_result = ms_res_from_mem ? mask_result :
                                        ms_final_result;
//MEM stage FSM ctrl : dealing with data writting
//Warning : Do not attempt to change this part! I have failed over 20 times
always @(posedge clk) begin
    if (reset)
        ms_state <= 3'b000;
    else
        ms_state <= ms_next_state;
end

always @(*) begin
    if(ms_state == 3'b000 & es_to_ms_valid & ms_allowin & (inst_LOAD|inst_STORE) & !es_ex_tag & !(ex_data_ADEL | ex_data_ADES | ex_OV))
        ms_next_state <= 3'b001;
    else if(ms_state == 3'b001 & data_addr_ok)
        ms_next_state <= 3'b010;
    else if(ms_state == 3'b010 & data_data_ok & write_twice)
        ms_next_state <= 3'b011;
    else if(ms_state == 3'b010 & data_data_ok)
        ms_next_state <= 3'b000;
    else if(ms_state == 3'b011 & data_addr_ok)
        ms_next_state <= 3'b100;
    else if(ms_state == 3'b100 & data_data_ok)
        ms_next_state <= 3'b000;
    else
        ms_next_state <= ms_state;
end

//----------|ws_| WB stage |------------
assign ws_ready_go = 1'b1;
assign ws_allowin  = !ws_valid || ws_ready_go;
always @(posedge clk) begin
    if (reset) begin
        ws_valid <= 1'b0;
        ws_pc <= 32'b0;
        ws_ex_tag <= 1'b0;
    end
    else if (ws_allowin) begin
        ws_valid <= ms_to_ws_valid;
    end

    if (ms_to_ws_valid && ws_allowin) begin
        ws_ex_tag       <= ms_ex_tag;
        ws_pc           <= ms_pc;
        ws_gr_we        <= ms_gr_we;
        ws_dest         <= ms_dest;
        ws_final_result <= final_result;
        HI              <= next_HI;
        LO              <= next_LO;
    end
end

//Use this part to make rf_we only be triggered one time when stalled
reg [31:0] last_pc;
wire once = (last_pc != ws_pc);
always @(posedge clk) begin
    if (reset)
        last_pc <= 32'b0;
    else
        last_pc <= ws_pc;
end

assign next_HI = ms_ex_tag ? HI : ms_inst_MTHI ? ms_final_result : ms_mul_div[3:2] != 2'b0 ? mul_result[63:32] : ms_mul_div[1:0] != 2'b0 ? ms_div_result[31: 0] : HI;
assign next_LO = ms_ex_tag ? LO : ms_inst_MTLO ? ms_final_result : ms_mul_div[3:2] != 2'b0 ? mul_result[31: 0] : ms_mul_div[1:0] != 2'b0 ? ms_div_result[63:32] : LO;
assign rf_we    = ws_gr_we && ws_valid && !ws_ex_tag && once;
assign rf_waddr = ws_dest;
assign rf_wdata = ws_final_result;

assign debug_wb_pc       = ws_pc;
assign debug_wb_rf_wen   = {4{rf_we}};
assign debug_wb_rf_wnum  = ws_dest;
assign debug_wb_rf_wdata = ws_final_result;

//The following part is easy to understand
//----------------------------------------------------------
//-----------| CP0 Registers & Exception Commit |-----------
//TODO Change CP0.Status.EXL & IE, enable multi exception
wire        count_cmp_eq;
wire        timer_int;
wire [ 5:0] int_pending;

//Need to consider all those situations
assign set_ex_tag = !es_valid ? 1'b0 :
                    es_inst_ERET ? 1'b1 :
                    (status_value[1] | es_ex_tag) ? 1'b0 :
                    es_exception;
//if CP0.Status.EXL=1, can not raise exception
assign exception_commit = status_value[1] ? 1'b0 : es_exception;

assign count_cmp_eq     = cr_compare == cr_count;
assign timer_int        = cr_cause_TI;
assign int_pending[  5] = hw_int[5] | timer_int; 
assign int_pending[4:0] = hw_int[4:0];

// Cp0 Operation
assign cp0_ren      = es_inst_MFC0;
assign cp0_wen      = es_inst_MTC0 & !es_ex_tag;
assign cp0_addr     = es_cp0_addr;
assign cp0_raddr    = es_inst_MFC0 ? cp0_addr : 8'h0;
assign cp0_waddr    = es_inst_MTC0 ? cp0_addr : 8'h0;
assign cp0_wr_value = es_rt_value;

assign cp0_rd_value = 
    {32{cp0_raddr=={5'd8 , 3'd0}}} & badvaddr_value |
    {32{cp0_raddr=={5'd12, 3'd0}}} & status_value   |
    {32{cp0_raddr=={5'd13, 3'd0}}} & cause_value    |
    {32{cp0_raddr=={5'd14, 3'd0}}} & epc_value      |
    {32{cp0_raddr=={5'd9 , 3'd0}}} & count_value    |
    {32{cp0_raddr=={5'd11, 3'd0}}} & compare_value  ;

reg count_add_en;
always @(posedge clk)
    count_add_en <= reset ? 1'b0 : ~count_add_en;

// BadVAddr     reg: 8, sel: 0
always @(posedge clk)
begin
    if (exception_commit && (exe_excode==6'h04 || exe_excode==6'h05) && (!es_ex_tag || es_inst_ERET))
        cr_badvaddr <= (ex_data_ADES | ex_data_ADEL) ? alu_result : es_pc;
end

// Count        reg: 9, sel: 0
always @(posedge clk)
begin
    if (reset)
        cr_count <= 32'h0;
    else if (cp0_wen && cp0_waddr=={5'd9, 3'd0})
        cr_count <= cp0_wr_value[31:0];
    else if (count_add_en)
        cr_count <= cr_count + 1'b1;
end

// Compare      reg: 11, sel: 0
always @(posedge clk)
begin
    if (reset)
        cr_compare <= 32'h0;
    else if (cp0_wen && cp0_waddr=={5'd11, 3'd0})
        cr_compare <= cp0_wr_value[31:0];
end

// Status       reg: 12, sel: 0
always @(posedge clk)
begin
    if (reset)
    begin
        cr_status_IM7   <= 1'b0;
        cr_status_IM6   <= 1'b0;
        cr_status_IM5   <= 1'b0;
        cr_status_IM4   <= 1'b0;
        cr_status_IM3   <= 1'b0;
        cr_status_IM2   <= 1'b0;
        cr_status_IM1   <= 1'b0;
        cr_status_IM0   <= 1'b0;
        cr_status_EXL   <= 1'b0;
        cr_status_IE    <= 1'b0;
    end
    else begin
        if (exception_commit)
            cr_status_EXL <= 1'b1;
        else if (es_inst_ERET)
        begin
            cr_status_EXL <= 1'b0;
        end
        else if (cp0_wen && cp0_waddr=={5'd12, 3'd0})
        begin
            cr_status_EXL <= cp0_wr_value[  1];
        end

        if (cp0_wen && cp0_waddr=={5'd12, 3'd0})
        begin
            cr_status_IM7 <= cp0_wr_value[ 15];
            cr_status_IM6 <= cp0_wr_value[ 14];
            cr_status_IM5 <= cp0_wr_value[ 13];
            cr_status_IM4 <= cp0_wr_value[ 12];
            cr_status_IM3 <= cp0_wr_value[ 11];
            cr_status_IM2 <= cp0_wr_value[ 10];
            cr_status_IM1 <= cp0_wr_value[  9];
            cr_status_IM0 <= cp0_wr_value[  8];
            cr_status_IE  <= cp0_wr_value[  0];
        end
    end
end

// Cause        reg: 13, sel: 0
always @(posedge clk)
begin
    if (reset)
    begin
        cr_cause_TI <= 1'b0;
    end
    else if (cp0_wen && cp0_waddr=={5'd11, 3'd0})
    begin
        cr_cause_TI <= 1'b0;
    end
    else if (count_cmp_eq)
    begin
        cr_cause_TI <= 1'b1;
    end
end

always @(posedge clk)
begin
    if (reset)
    begin
        cr_cause_BD     <= 1'b0;
        cr_cause_IP7    <= 1'b0;
        cr_cause_IP6    <= 1'b0;
        cr_cause_IP5    <= 1'b0;
        cr_cause_IP4    <= 1'b0;
        cr_cause_IP3    <= 1'b0;
        cr_cause_IP2    <= 1'b0;
        cr_cause_IP1    <= 1'b0;
        cr_cause_IP0    <= 1'b0;
        cr_cause_ExcCode<= 5'h1f;
    end
    else begin
        if (exception_commit)
        begin
            cr_cause_ExcCode <= exe_excode[4:0];
      
            if (!cr_status_EXL)
                cr_cause_BD <= es_inst_ADEL ? 1'b0 : ms_inst_BRANCH;
        end

        if (cp0_wen && cp0_waddr=={5'd13, 3'd0})
        begin
            cr_cause_IP1  <= cp0_wr_value[ 9];
            cr_cause_IP0  <= cp0_wr_value[ 8];
        end

        cr_cause_IP7    <= int_pending[5];
        cr_cause_IP6    <= int_pending[4];
        cr_cause_IP5    <= int_pending[3];
        cr_cause_IP4    <= int_pending[2];
        cr_cause_IP3    <= int_pending[1];
        cr_cause_IP2    <= int_pending[0];
    end
end

// EPC          reg: 14, sel: 0
wire [31:0] epc;
always @(posedge clk)
begin
    if (exception_commit && !cr_status_EXL)
        cr_epc          <= epc;
    else if (cp0_wen && cp0_waddr=={5'd14, 3'd0})
        cr_epc          <= cp0_wr_value[31:0];
end

wire [29:0] pc_w_m4 = es_pc[31:2] - 1'b1;
assign epc          = (ms_inst_BRANCH & !es_inst_ADEL) ? {pc_w_m4, es_pc[1:0]} : es_pc;
//-----------| CP0 Registers & Exception Commit |-----------
//----------------------------------------------------------

endmodule
