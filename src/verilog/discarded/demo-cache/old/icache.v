// nscscc2019_ucas_llcw
// icache.v
// wanghuaqiang16@mails.ucas.ac.cn
// liuyunzhe16@mails.ucas.ac.cn

// Cache命中应该是流水的，也就是连续命中时应当可以不间断的返回数据。 
// 对一次访问，Cache 命中时的延迟，CPU 内部应该完全消化掉。也就是当取指和访存全部命中时，不考 虑数据相关，CPU内部流水线应该完全流水起来，对于单发射 CPU，此时 IPC为 1。 有以下几点细节可以考虑实现： 
// Cache Miss时，使用关键字优先返回。这个需要 AXI的 Burst传输类型为 Wrap访问。 
// 考虑 Store buffer的实现，Store无论 Miss还是 Hit，都可以不阻塞后续访存指令。 

module cache
#(
    parameter integer I_ADDR_WIDTH = 32, //addr width is 32
    parameter integer I_BLOCK_SIZE = 5,  //2^5=32B per cache block
    parameter integer I_CACHE_SIZE = 13  //2^12=8KB cache size
    // parameter I_GROUP_SIZE = 1   //2^1=2-way
)
(
    input clk,
    input resetn,

    //icache
    input [I_ADDR_WIDTH-1:0]i_raddr,
    input [I_ADDR_WIDTH-1:0]i_waddr,
    input i_en, //icache enable
    input [3:0]i_wen, //byte write enable
    input [31:0]i_wdata,
    output [31:0]i_rdata,
    output i_valid,

    //dcache
    //TODO

    //memory interface
    //axi-interface
    //sram-like-interface

    //config and inst
    output reg [31:0]config0,
    output reg [31:0]config1,
    input [2:0]config_in,// will only influence the KO part of CP0 reg config
    input [31:0]inst_in // deal with cache insts
);

    //icache
    // |  TAG  |  INDEX  |  OFFSET  |
    // |  20   |    7    |    5     |
    parameter I_OFFSET_W = I_BLOCK_SIZE;                            //5
    parameter I_INDEX_W  = I_CACHE_SIZE-I_BLOCK_SIZE-I_GROUP_SIZE;      //7
    parameter I_TAG_W    = I_ADDR_WIDTH-I_INDEX_W-I_OFFSET_W;           //20
    // parameter I_CACHE_TAG_W = 4;

    //TODO: modify this to use vivado IP.
    reg [I_TAG_W-1:0]i_tag1[I_INDEX_W-1:0];
    reg [I_TAG_W-1:0]i_tag2[I_INDEX_W-1:0];
    reg [I_BLOCK_SIZE-1+3:0]i_data1[I_INDEX_W-1:0];
    reg [I_BLOCK_SIZE-1+3:0]i_data2[I_INDEX_W-1:0];

    reg i_LRU[I_INDEX_W-1:0];
    reg i_V1[I_INDEX_W-1:0];
    reg i_V2[I_INDEX_W-1:0];
    reg i_D1[I_INDEX_W-1:0];
    reg i_D2[I_INDEX_W-1:0];

    //TODO: modify this to use vivado IP.
    //-------------------------------------------------------
    // reg [I_TAG_W-1:0]i_tag1_reg[I_INDEX_W-1:0];
    // reg [I_TAG_W-1:0]i_tag2_reg[I_INDEX_W-1:0];
    // reg [I_BLOCK_SIZE-1+3:0]i_data1_reg[I_INDEX_W-1:0];
    // reg [I_BLOCK_SIZE-1+3:0]i_data2_reg[I_INDEX_W-1:0];

    // genvar i;
    // generate
    // for (i=0; i<(1<<(I_INDEX_W-1)); i=i+1) begin
    //         assign i_tag1[i] = i_tag1_reg[i];
    //         assign i_tag2[i] = i_tag2_reg[i];
    //         assign i_data1[i] = i_data1_reg[i];
    //         assign i_data2[i] = i_data2_reg[i];
    //     end
    // endgenerate
    //-------------------------------------------------------

//Simple Icache

    //Init

    genvar p;
    generate
    for (p=0; p<(1<<(I_INDEX_W-1)); p=p+1) begin
        always@(posedge clk)begin
            if(!resetn)begin
                i_V1[p]<=1'b0;
                i_V2[p]<=1'b0;
                i_LRU[p]<=1'b0;
            end
        end
    end
    endgenerate

    //------------------------------------------------------------
    //CACHEIN LEVEL
    //------------------------------------------------------------

    // Look up：判断是否在 Cache中，并读出 Data供命中时返回读数据。 
    // 发送地址请求
    // Tag比较

    wire in_addr_tag=i_raddr[31:I_ADDR_WIDTH-I_BLOCK_SIZE-I_CACHE_SIZE-3];
    wire in_addr_index=i_raddr[I_ADDR_WIDTH-I_BLOCK_SIZE-I_CACHE_SIZE-3:I_BLOCK_SIZE-1];
    wire in_addr_offset=i_raddr[I_BLOCK_SIZE-1:0];

    assign wire hit1 = (in_addr_tag==i_tag1[in_addr_index]);
    assign wire hit2 = (in_addr_tag==i_tag2[in_addr_index]);

    i_V1[in_addr_index];
    i_V2[in_addr_index];

    //about LRU
    //LRU[in_addr_index] == 0 means way1 is recently used, else, way2 is reacently used. 
    
    assign wire not_valid=(!i_V1[in_addr_index])&(!i_V2[in_addr_index]);
    assign wire need_refill1=
        (hit1 & (!i_V1[in_addr_index])) | //if way1 hit but not valid
        (not_valid & (i_LRU[in_addr_index]==1'b1)); //if way2 hit
    assign wire need_refill2=
        (hit2 & (!i_V2[in_addr_index])) |
        (not_valid & (i_LRU[in_addr_index]==1'b0));
    
    // if hit1 v -> read
    // if hit2 v -> read
    // if hit1 !v -> refill
    // if hit2 !v -> refill
    // if !hit1, !hit2 -> pick one and refill

    assign wire return1 = hit1 & i_V1[in_addr_index];
    assign wire return2 = hit2 & i_V2[in_addr_index];
    assign wire cache_hit = return1|return2;
    reg cache_hit_reg;
    reg return1_reg;
    reg return2_reg;
    reg need_refill1_reg;
    reg need_refill2_reg;
    reg hit1_reg;
    reg hit2_reg;
    reg addr_reg;


    // Hit Update：命中 Cache时，更新信息。 
    // 发送地址请求
    // 获取数据

    
    //cachein pipeline control logic
    wire cachein_valid       = i_en; //enable i cache TODO
    wire cachein_ready_go    = i_en; //enable i cache TODO
    wire cachein_allowin     = i_en;
    wire cachein_to_cacheout_valid = cachein_valid && cachein_ready_go;
    // assign cachein_allowin     = !fs_valid || fs_ready_go && ds_allowin;
    always @(posedge clk) begin
        if (reset) begin
            cacheout_valid <= 1'b0;
        end
        else if (cachein_allowin & cachein_ready_go) begin
            cacheout_valid <= cachein_valid;
            cache_hit_reg<=cache_hit&cachein_valid;//TODO ?
            return1_reg<=return1&cachein_valid;
            return2_reg<=return2&cachein_valid;
            need_refill1_reg<=need_refill1&cachein_valid;
            need_refill2_reg<=need_refill2&cachein_valid;
            hit1_reg<=hit1&cachein_valid;
            hit2_reg<=hit2&cachein_valid;
            cacheout_i_raddr<=i_raddr&{32{cachein_valid}};
        end
    end

    //mod LRU
    // hit1 -> i_LRU[in_addr_index]=1'0;
    // need_refill1 -> i_LRU[in_addr_index]=1'0; //TODO : 文档上将hit和refill的LRU update时间做了区分, 为何?
    // hit2 -> i_LRU[in_addr_index]=1'1;
    // need_refill2 -> i_LRU[in_addr_index]=1'1;


    // Select：选出被替换的 Cache行。 
            // 由“Miss 处理单元”进行维护
    // Replace：将某一 Cache行读出来，后续会替换出去。 
    // Refill：将新取回的 Cache行填入 Replace后剩余的空行中。 
        // 通常在“Refill”之后，被替换出来的 Cache行如果是脏的，会对外进行写回
    
    // Uncached的访问不可以经过 Cache缓存
    // Uncached 的 Load 不能使用之前的 Store 前递过来的数据，所有 Uncached Load 必须从目标设备获取数据； 
    // Uncached的访问需要确保顺序性，比如 Uncached Load不要越过其之前的 Uncached Store先执行

    //------------------------------------------------------------
    //CACHEOUT LEVEL
    //------------------------------------------------------------
    //cacheout pipeline control logic
    reg cacheout_valid;
    wire cacheout_ready_go    = i_valid;
    wire cacheout_allowin     = !cacheout_valid || cacheout_ready_go;
    // wire cacheout_allowin     = !cacheout_valid || cacheout_ready_go && ds_allowin;

    wire out_addr_tag=cacheout_i_raddr[31:I_ADDR_WIDTH-I_BLOCK_SIZE-I_CACHE_SIZE-3];
    wire out_addr_index=cacheout_i_raddr[I_ADDR_WIDTH-I_BLOCK_SIZE-I_CACHE_SIZE-3:I_BLOCK_SIZE-1];
    wire out_addr_offset=cacheout_i_raddr[I_BLOCK_SIZE-1:0];

    //cacheout state machine
    reg [2:0]cacheout_state_reg;
    reg [I_BLOCK_SIZE-1:0]update_counter;
    wire [2:0]cacheout_next_state;
    `define cacheout_state_return 3'b000
    `define cacheout_state_update 3'b000
    `define cacheout_state_send_addr 3'b010
    `define cacheout_state_load_data 3'b100

    always@(posedge clk)begin
        if(!resetn)begin
            cacheout_state_reg<=`cacheout_state_return;
            update_counter <= 32'b0;
            start_flag<=1'b0;
            finish_flag<=1'b0;
        end else begin
            cacheout_state_reg<=cacheout_next_state;
        end
    end

    //cache update logic: sram version
    reg start_flag;
    reg finish_flag;

    always@(posedge clk)begin
        if(cacheout_state_reg==`cacheout_state_update)begin
            //counter update
            if(sram_valid)begin
                update_counter<=update_counter+3'b100;//+4
                
            end
        end
    end

    assign sram_en = cacheout_state_reg==`cacheout_state_update;
    assign sram_addr = {cacheout_i_raddr[31:I_BLOCK_SIZE], update_counter[I_BLOCK_SIZE-1:0]};


    assign cacheout_next_state=((cacheout_state_reg==`cacheout_state_update)&(counter==32'b0))?
                                    (cache_hit_reg?`cacheout_state_return:`cacheout_state_update):
                                    ();

    assign i_rdata = hit1_reg?i_data1[in_addr_index]:i_data2[in_addr_index];
    assign i_valid = cacheout_valid&(cacheout_state_reg==`cacheout_state_return);

endmodule


//Complex Icache
    // genvar i;
    // generate
    //     for (i=0; i<(1<<(I_CACHE_SIZE-I_BLOCK_SIZE)); i=i+1) begin
    //         assign tag_ram[i]=tag_ram_reg[i];
    //         assign data_ram[i]=data_ram_reg[i];
    //     end
    // endgenerate
