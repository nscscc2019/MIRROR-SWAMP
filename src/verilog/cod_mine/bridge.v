`timescale 1ns / 1ps
module bridge
(
	//input	[5:0] int,
    input         aclk,
    input         aresetn, 

    //------inst sram-like-------
    input          inst_req    ,
    input          inst_wr     ,
    input   [1 :0] inst_size   ,
    input   [31:0] inst_addr   ,
    input   [31:0] inst_wdata  ,
    output  [31:0] inst_rdata  ,
    output         inst_addr_ok,
    output         inst_data_ok,
    
    //------data sram-like-------
    input            data_req    ,
    input            data_wr     ,
    input     [1 :0] data_size   ,
    input     [31:0] data_addr   ,
    input     [31:0] data_wdata  ,
    input     [3:0 ] data_wstrb  ,
    output    [31:0] data_rdata  ,
    output           data_addr_ok,
    output           data_data_ok,

	//------debug------
	//output [31:0] 	debug_wb_pc,
	//output [3:0] 	debug_wb_rf_wen,
	//output [4:0] 	debug_wb_rf_wnum,
	//output [31:0] 	debug_wb_rf_wdata,

    //ar
    output  [3 :0] arid   ,
    output  [31:0] araddr,
    output  [7 :0] arlen  ,
    output  [2 :0] arsize ,
    output  [1 :0] arburst,
    output  [1 :0] arlock ,
    output  [3 :0] arcache,
    output  [2 :0] arprot ,
    output  reg    arvalid,
    input          arready,
    //r
    input [3 :0] rid    ,
    input [31:0] rdata  ,
    input [1 :0] rresp ,
    input        rlast ,
    input        rvalid ,
    output  reg  rready ,
    //aw
    output  [3 :0] awid   ,
    output  [31:0] awaddr ,
    output  [7 :0] awlen  ,
    output  [2 :0] awsize ,
    output  [1 :0] awburst,
    output  [1 :0] awlock ,
    output  [3 :0] awcache,
    output  [2 :0] awprot ,
    output  reg    awvalid,
    input          awready,
    //w
    output  [3 :0] wid    ,
    output  [31:0] wdata  ,
    output  [3 :0] wstrb  ,
    output         wlast  ,
    output  reg    wvalid ,
    input          wready ,
    //b
    input [3 :0] bid    ,
    input [1 :0] bresp  ,
    input        bvalid ,
    output  reg  bready 
);

/*assign  debug_wb_pc = cpu_debug_wb_pc;
assign  debug_wb_rf_wen = cpu_debug_wb_rf_wen;
assign  debug_wb_rf_wnum = cpu_debug_wb_rf_wnum;
assign  debug_wb_rf_wdata = cpu_debug_wb_rf_wdata;
wire    cpu_debug_wb_pc;
wire    cpu_debug_wb_rf_wen;
wire    cpu_debug_wb_rf_wnum;
wire    cpu_debug_wb_rf_wdata;
mycpu mycpu(
    aresetn		,
	aclk		,
    //------inst sram-like-------
    inst_req    ,
    inst_wr     ,
    inst_size   ,
    inst_addr   ,
    inst_rdata  ,
	inst_wdata  ,
    inst_addr_ok,
    inst_data_ok,
    
    //------data sram-like-------
    data_req    ,
    data_wr     ,
    data_size   ,
    data_addr   ,
    data_wdata  ,
    data_wstrb  ,
    data_rdata  ,
    data_addr_ok,
    data_data_ok,
	cpu_debug_wb_pc,
    cpu_debug_wb_rf_wen,
    cpu_debug_wb_rf_wnum,
    cpu_debug_wb_rf_wdata
	);*/

    assign arlen    = 8'b0;
    assign arburst   = 2'b01;
    assign arlock   = 2'b0;
    assign arcache  = 4'b0;
    assign arprot   = 3'b0;

    assign rresp   = 2'b0;
    //assign rlast   = 1'b0;

    assign awid     = 3'b1;
    assign awlen    = 8'b0;
    assign awburst  = 2'b0;
    assign awlock   = 2'b0;
    assign awcache  = 4'b0;
    assign awprot   = 3'b0;

    assign wid      = 4'b1;
    assign wlast    = 1'b1;

    //assign bid      = 4'b0;/////????????
    assign bresp    = 2'b0;

    //rst
    assign rst = !aresetn;

    //////sram //////data
    //mode
    reg [1:0] data_mode;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            data_mode <= 1'b0;
        end
        else if(data_mode == 1'b1)
        begin
            if(bvalid == 1'b1)
            begin
                data_mode <= 1'b0;
            end
        end
        else if(mode_change)
        begin
            if(mode_read)
            begin
                data_mode <= 1'b0;
            end
            else
            begin
                data_mode <= 1'b1;
            end
        end
    end

    reg [31:0]data;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            data <= 32'b0;
        end
        else if(rvalid)
        begin
            data <= rdata;
        end
    end

    reg [2:0] data_work_state;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            data_work_state <= 3'b0;
        end
        /*else if(mode_change)
        begin
            data_work_state <= 3'b0;
        end*/
        else if(data_work_state == 3'b0)
        begin
            if(data_addr_ok == 1'b1)
            begin
                data_work_state <= 3'b1;
            end
        end
        else if(data_work_state == 3'b1)
        begin
            if(data_data_ok == 1'b1)
            begin
                data_work_state <= 3'd0;
            end
        end
    end

    wire    mode_change;
    assign  mode_change = data_req && (data_work_state == 3'b0);
    //reg [2:0] data_work_state_record;

    wire    mode_read;
    wire    mode_write;
    assign  mode_read   = data_req && ~data_wr;
    assign  mode_write  = data_req && data_wr;

    assign  data_addr_ok    = (data_work_state == 3'b0) && data_req;
    assign  data_data_ok = data_mode ? bvalid : ((source == 2'd1) && rvalid && rready);
    assign  data_rdata      = data;

    reg [31:0] data_addr_reg;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            data_addr_reg <= 32'b0;
        end
        else if(data_addr_ok)
        begin
            data_addr_reg <= data_addr;
        end
    end

    reg [31:0] data_wdata_reg;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            data_wdata_reg <= 32'b0;
        end
        else if(data_addr_ok)
        begin
            data_wdata_reg <= data_wdata;
        end
    end

    reg [3:0] data_wstrb_reg;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            data_wstrb_reg <= 4'b0;
        end
        else if(data_addr_ok)
        begin
            data_wstrb_reg <= data_wstrb;
        end
    end

    reg [1:0] data_size_reg;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            data_size_reg <= 2'b0;
        end
        else if(data_addr_ok)
        begin
            data_size_reg <= data_size;
        end
    end

    wire[3:0] task_wstrb;
    reg [3:0] task_wstrb_reg;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            task_wstrb_reg <= 4'b0;
        end
        else if(data_addr_ok)
        begin
            task_wstrb_reg <= task_wstrb;
        end
    end
    assign task_wstrb = ({4{(data_size == 2'b00) && (data_addr[1:0] == 2'b00)}} & 4'b0001) |
                        ({4{(data_size == 2'b00) && (data_addr[1:0] == 2'b01)}} & 4'b0010) |
                        ({4{(data_size == 2'b00) && (data_addr[1:0] == 2'b10)}} & 4'b0100) |
                        ({4{(data_size == 2'b00) && (data_addr[1:0] == 2'b11)}} & 4'b1000) |
                        ({4{(data_size == 2'b01) && (data_addr[1:0] == 2'b00)}} & 4'b0011) |
                        ({4{(data_size == 2'b01) && (data_addr[1:0] == 2'b10)}} & 4'b1100) |
                        ({4{(data_size == 2'b10) && (data_addr[1:0] == 2'b00)}} & 4'b1111);

    //////sram //////inst
    reg [2:0] inst_work_state;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            inst_work_state <= 3'b0;
        end
        else if(inst_work_state == 3'b0)
        begin
            if(inst_addr_ok == 1'b1)
            begin
                inst_work_state <= 3'b1;
            end
        end
        else if(inst_work_state == 3'b1)
        begin
            if(inst_data_ok == 1'b1)
            begin
                inst_work_state <= 3'd0;
            end
        end
    end

    assign  inst_addr_ok    = (inst_work_state == 3'b0) && inst_req;
    assign  inst_data_ok = rready && rvalid && (source == 2'b0);
    assign  inst_rdata      = data;

    reg [31:0] inst_addr_reg;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            inst_addr_reg <= 32'b0;
        end
        else if(inst_addr_ok)
        begin
            inst_addr_reg <= inst_addr;
        end
    end

    reg [1:0] inst_size_reg;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            inst_size_reg <= 2'b0;
        end
        else if(inst_addr_ok)
        begin
            inst_size_reg <= inst_size;
        end
    end

    ///////axi //////write
    wire write_allow;
    assign write_allow = 1'b1;

    reg [2:0] axi_write_state;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            axi_write_state <= 3'd0;
        end
        else if((axi_write_state == 3'd0) && ((data_work_state == 3'd1) || (data_addr_ok == 1'b1)) && data_mode)
        begin
            axi_write_state <= 3'd1;
        end
        else if((axi_write_state == 3'd1) && (awvalid == 1'b1) && (awready == 1'b1))
        begin
            axi_write_state <= 3'd2;
        end
        else if((axi_write_state == 3'd2) && (wvalid == 1'b1) && (wready == 1'b1))
        begin
            axi_write_state <= 3'd3;
        end
        else if((axi_write_state == 3'd3) && (bready == 1'b1) && (bvalid == 1'b1))
         begin
            axi_write_state <= 3'd0;
        end
    end

    assign awaddr   = data_addr_reg;
    assign awsize   =   (data_size_reg == 2'd0) ? 3'd1 :
                        (data_size_reg == 2'd1) ? 3'd2 :
                        3'd4;

    always @(posedge aclk)
    begin
        if(rst)
        begin
            awvalid <= 1'b0;
        end
        else if((axi_write_state == 3'd1) && (awvalid == 1'b0))
        begin
            awvalid <= 1'b1;
        end
        else if(awready == 1'b1)
        begin
            awvalid <= 1'b0;
        end
    end

    assign wdata    = data_wdata_reg;
    assign wstrb    = data_wstrb_reg;

    always @(posedge aclk)
    begin
        if(rst)
        begin
            wvalid <= 1'b0;
        end
        else if((axi_write_state == 3'd2) && (wvalid == 1'b0))
        begin
            wvalid <= 1'b1;
        end
        else if(wready == 1'b1)
        begin
            wvalid <= 1'b0;
        end
    end

    always @(posedge aclk)
    begin
        if(rst)
        begin
            bready <= 1'b0;
        end
        else if((axi_write_state == 3'd3) && (bready == 1'b0))
        begin
            bready <= 1'b1;
        end
        else if(bvalid == 1'b1)
        begin
            bready <= 1'b0;
        end
    end

    ///////axi //////read
    reg [1:0]source;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            source <= 2'd2;
        end
		else if((inst_work_state == 1'b1) && (source == 2'd2) && !inst_data_ok)
        begin
            source <= 2'd0;
        end
		else if((data_work_state == 1'b1) && (data_mode == 1'b0) && (source == 2'd2) && !data_data_ok)
        begin
            source <= 2'd1;
        end
        else if(source == 2'd0 && inst_data_ok)
        begin
            source <= 2'd2;
        end
        else if(source == 2'd1 && data_data_ok)
        begin
            source <= 2'd2;
        end
    end


    wire [2:0] state_input;
    assign state_input = arid ? (((data_work_state == 3'd1) || (data_addr_ok == 1'b1)) && (data_mode == 1'b0)) : ((inst_work_state == 3'd1) || (inst_addr_ok == 1'b1));

    reg [2:0] axi_read_state;
    always @(posedge aclk)
    begin
        if(rst)
        begin
            axi_read_state <= 3'd0;
        end
        else if((axi_read_state == 3'd0) && state_input)
        begin
            axi_read_state <= 3'd1;
        end
        else if((axi_read_state == 3'd1) && (arvalid == 1'b1) && (arready == 1'b1))
        begin
            axi_read_state <= 3'd2;
        end
        else if((axi_read_state == 3'd2) && (rvalid == 1'b1) && (rready == 1'b1))
         begin
            axi_read_state <= 3'd0;
        end
    end

    assign arid     = source[0];
    assign araddr  = arid ? data_addr_reg : inst_addr_reg;
    assign arsize   = arid ? data_size_reg : inst_size_reg;

    always @(posedge aclk)
    begin
        if(rst)
        begin
            arvalid <= 1'b0;
        end
        else if((axi_read_state == 3'd1) && (arvalid == 1'b0))
        begin
            arvalid <= 1'b1;
        end
        else if(arready == 1'b1)
        begin
            arvalid <= 1'b0;
        end
    end

    always @(posedge aclk)
    begin
        if(rst)
        begin
            rready <= 1'b0;
        end
        else if((axi_read_state == 3'd2) && (rready == 1'b0))
        begin
            rready <= 1'b1;
        end
        else if(rvalid == 1'b1)
        begin
            rready <= 1'b0;
        end
    end

endmodule