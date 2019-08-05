module mycpu_top(
    input clk,
    input resetn,   //low active
    input  [6 :0]   int,

    output          inst_sram_en,
    output [3 :0]   inst_sram_wen,
    output [31:0]   inst_sram_addr,
    output [31:0]   inst_sram_wdata,
    input  [31:0]   inst_sram_rdata,
    
    output          data_sram_en,
    output [3 :0]   data_sram_wen,
    output [31:0]   data_sram_addr,
    output [31:0]   data_sram_wdata,
    input  [31:0]   data_sram_rdata,

    //debug interface
    output  [31:0]   debug_wb_pc,
    output  [3 :0]   debug_wb_rf_wen,
    output  [4 :0]   debug_wb_rf_wnum,
    output  [31:0]   debug_wb_rf_wdata
);

    wire cpu_inst_req;
    wire [31:0] cpu_inst_addr;
    wire [31:0] cpu_inst_rdata;
    wire cpu_inst_addr_ok;
    wire cpu_inst_data_ok;
    wire cpu_data_req;
    wire cpu_data_wr;
    wire [3:0] cpu_data_wstrb;
    wire [31:0] cpu_data_addr;
    wire [2 :0] cpu_data_size;
    wire [31:0] cpu_data_wdata;
    wire [31:0] cpu_data_rdata;
    wire cpu_data_addr_ok;
    wire cpu_data_data_ok;
    
    wire cache_req;

    mips_cpu cpu(
        .clk(clk),
        .resetn(resetn),
        .int(int),
        .inst_req(cpu_inst_req),
        .inst_addr(cpu_inst_addr),
        .inst_rdata(cpu_inst_rdata),
        .inst_addr_ok(cpu_inst_addr_ok),
        .inst_data_ok(cpu_inst_data_ok),
        .data_req(cpu_data_req),
        .data_wr(cpu_data_wr),
        .data_wstrb(cpu_data_wstrb),
        .data_addr(cpu_data_addr),
        .data_size(cpu_data_size),
        .data_wdata(cpu_data_wdata),
        .data_rdata(cpu_data_rdata),
        .data_addr_ok(cpu_data_addr_ok),
        .data_data_ok(cpu_data_data_ok),
        .cache_req(cache_req),
        .cache_op(),
        .cache_tag(),
        .cache_op_ok(cache_req),
        .debug_wb_pc(debug_wb_pc),
        .debug_wb_rf_wen(debug_wb_rf_wen),
        .debug_wb_rf_wnum(debug_wb_rf_wnum),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );

    assign inst_sram_en     = cpu_inst_req;
    assign inst_sram_wen    = 4'h0;
    assign inst_sram_addr   = cpu_inst_addr;
    assign inst_sram_wdata  = 32'd0;
    
    assign data_sram_en     = cpu_data_req;
    assign data_sram_wen    = {4{cpu_data_wr}} & cpu_data_wstrb;
    assign data_sram_addr   = cpu_data_addr;
    assign data_sram_wdata  = cpu_data_wdata;
    
    reg inst_data_ok_r, data_data_ok_r;
    always @(posedge clk) inst_data_ok_r <= cpu_inst_req;
    always @(posedge clk) data_data_ok_r <= cpu_data_req;
    
    assign cpu_inst_rdata   = inst_sram_rdata;
    assign cpu_inst_addr_ok = cpu_inst_req;
    assign cpu_inst_data_ok = inst_data_ok_r;
    
    assign cpu_data_rdata   = data_sram_rdata;
    assign cpu_data_addr_ok = cpu_data_req;
    assign cpu_data_data_ok = data_data_ok_r;

endmodule