// Coprocessor 0 Registers

`define CP0_INDEX           8'b00000_000 // 0 , 0
`define CP0_RANDOM          8'b00001_000 // 1 , 0
`define CP0_ENTRYLO0        8'b00010_000 // 2 , 0
`define CP0_ENTRYLO1        8'b00011_000 // 3 , 0
`define CP0_CONTEXT         8'b00100_000 // 4 , 0
`define CP0_PAGEMASK        8'b00101_000 // 5 , 0
`define CP0_WIRED           8'b00110_000 // 6 , 0
`define CP0_BADVADDR        8'b01000_000 // 8 , 0
`define CP0_COUNT           8'b01001_000 // 9 , 0
`define CP0_ENTRYHI         8'b01010_000 // 10, 0
`define CP0_COMPARE         8'b01011_000 // 11, 0
`define CP0_STATUS          8'b01100_000 // 12, 0
`define CP0_CAUSE           8'b01101_000 // 13, 0
`define CP0_EPC             8'b01110_000 // 14, 0
`define CP0_PRID            8'b01111_000 // 15, 0
`define CP0_EBASE           8'b01111_001 // 15, 1
`define CP0_CONFIG          8'b10000_000 // 16, 0
`define CP0_CONFIG1         8'b10000_001 // 16, 1
`define CP0_TAGLO           8'b11100_000 // 28, 0

// TLB parameters
`define TLB_IDXBITS         5
`define TLB_ENTRIES         (1<<`TLB_IDXBITS)

// Coprocessor 0 Register Bits
// Index (0, 0)
`define INDEX_P             31
`define INDEX_INDEX         `TLB_IDXBITS-1:0

// Random (1, 0)
`define RANDOM_RANDOM       `TLB_IDXBITS-1:0

// EntryLo0, EntryLo1 (2 and 3, 0)
`define ENTRYLO_PFN         25:6
`define ENTRYLO_C           5:3
`define ENTRYLO_D           2
`define ENTRYLO_V           1
`define ENTRYLO_G           0

// Context (4, 0)
`define CONTEXT_PTEBASE     31:23
`define CONTEXT_BADVPN2     22:4

// PageMask (5, 0)
// Note: length of mask field is set to 12
`define PAGEMASK_MASK       24:13

// Wired (6, 0)
`define WIRED_WIRED         `TLB_IDXBITS-1:0

// EntryHi (10, 0)
`define ENTRYHI_VPN2        31:13
`define ENTRYHI_ASID        7:0

// Status (12, 0)
`define STATUS_CU0          28
`define STATUS_BEV          22
`define STATUS_IM           15:8
`define STATUS_UM           4
`define STATUS_EXL          1
`define STATUS_IE           0

// Cause (13, 0)
`define CAUSE_BD            31
`define CAUSE_TI            30
`define CAUSE_CE            29:28
`define CAUSE_IV            23
`define CAUSE_IP            15:8
`define CAUSE_IP7_2         15:10
`define CAUSE_IP1_0         9:8
`define CAUSE_EXCCODE       6:2

// EBase (15, 1)
`define EBASE_BASE          29:12

// Config (16, 0)
`define CONFIG_K0           2:0

// Exception vectors

`define VEC_RESET           32'hbfc0_0000
`define VEC_REFILL          32'h8000_0000
`define VEC_REFILL_EXL      32'h8000_0180
`define VEC_REFILL_BEV      32'hbfc0_0200
`define VEC_REFILL_BEV_EXL  32'hbfc0_0380
`define VEC_CACHEERR        32'ha000_0100
`define VEC_CACHEERR_BEV    32'dbfc0_0300
`define VEC_INTR            32'h8000_0180
`define VEC_INTR_IV         32'h8000_0200
`define VEC_INTR_BEV        32'hbfc0_0380
`define VEC_INTR_BEV_IV     32'hbfc0_0400
`define VEC_OTHER           32'h8000_0180
`define VEC_OTHER_BEV       32'hbfc0_0380

// EXCCODE

`define EXC_INT         5'h00
`define EXC_MOD         5'h01
`define EXC_TLBL        5'h02
`define EXC_TLBS        5'h03
`define EXC_ADEL        5'h04
`define EXC_ADES        5'h05
`define EXC_IBE         5'h06
`define EXC_DBE         5'h07
`define EXC_SYS         5'h08
`define EXC_BP          5'h09
`define EXC_RI          5'h0a
`define EXC_CPU         5'h0b
`define EXC_OV          5'h0c
`define EXC_TR          5'h0d

`define EXC_WATCH       5'h17

`define EXC_CACHEERR    5'h1e

// instruction encoding

`define GET_RS(x)       x[25:21]
`define GET_RT(x)       x[20:16]
`define GET_RD(x)       x[15:11]
`define GET_SA(x)       x[10:6]
`define GET_IMM(x)      x[15:0]
`define GET_INDEX(x) x[25:0]

// Control signal indexes

`define I_ALU_ADD   0
`define I_ALU_SUB   1
`define I_ALU_AND   2
`define I_ALU_OR    3
`define I_ALU_XOR   4
`define I_ALU_NOR   5
`define I_ALU_SLT   6
`define I_ALU_SLTU  7
`define I_ALU_SLL   8
`define I_ALU_SRL   9
`define I_ALU_SRA   10

`define I_RESERVED  11

`define I_SYSCALL   12
`define I_BREAK     13
`define I_MFHI      14
`define I_MTHI      15
`define I_MFLO      16
`define I_MTLO      17
`define I_LUI       18
`define I_TLBR      19
`define I_TLBWI     20
`define I_TLBWR     21
`define I_TLBP      22
`define I_ERET      23
`define I_MFC0      24
`define I_MTC0      25
`define I_LB        26
`define I_LH        27
`define I_LWL       28
`define I_LW        29
`define I_LBU       30
`define I_LHU       31
`define I_LWR       32
`define I_SB        33
`define I_SH        34
`define I_SWL       35
`define I_SW        36
`define I_SWR       37

`define I_MEM_R     38
`define I_MEM_W     39
`define I_RS_R      40
`define I_RT_R      41
`define I_WEX       42
`define I_WWB       43
`define I_IMM_SX    44
`define I_ALU_A_SA  45
`define I_ALU_B_IMM 46
`define I_LINK      47
`define I_DO_MUL    48
`define I_DO_DIV    49
`define I_MD_SIGN   50
`define I_EXC_OF    51

`define I_BNE       52
`define I_BEQ       53
`define I_BGEZ      54
`define I_BLEZ      55
`define I_BGTZ      56
`define I_BLTZ      57
`define I_J         58
`define I_JR        59

`define I_MAX       60
