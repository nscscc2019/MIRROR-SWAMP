`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/01 17:57:41
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 001 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cpu_axi_interface(
    input clk,
    input resetn,
    
    //inst sram-like 
    input inst_req,
    input [31:0] inst_addr,
    output [31:0] inst_rdata,
    output inst_addr_ok,
    output inst_data_ok,
    
    //data sram-like 
    input data_req,
    input data_wr,
    input [3:0] data_wstrb,
    input [31:0] data_addr,
    input [2:0] data_size,
    input [31:0] data_wdata,
    output [31:0] data_rdata,
    output data_addr_ok,
    output data_data_ok,
    
    //axi
    //ar
    output [3:0] arid,
    output [31:0] araddr,
    output [7:0] arlen,
    output [2:0] arsize,
    output [1:0] arburst,
    output [1:0] arlock,
    output [3:0] arcache,
    output [2:0] arprot,
    output arvalid,
    input arready,
    //r              
    input [3:0] rid,
    input [31:0] rdata,
    input [1:0] rresp,
    input rlast,
    input rvalid,
    output rready,
    //aw           
    output [3:0] awid,
    output [31:0] awaddr,
    output [7:0] awlen,
    output [2:0] awsize,
    output [1:0] awburst,
    output [1:0] awlock,
    output [3:0] awcache,
    output [2:0] awprot,
    output awvalid,
    input awready,
    //w          
    output [3:0] wid,
    output [31:0] wdata,
    output [3:0] wstrb,
    output wlast,
    output wvalid,
    input wready,
    //b              
    input [3:0] bid,
    input [1:0] bresp,
    input bvalid,
    output bready
);

    // buffered requests
    localparam STAT_IDLE    = 2'd0; // idle
    localparam STAT_REQ     = 2'd1; // requesting axi
    localparam STAT_WD      = 2'd2; // transferring write data
    localparam STAT_WAIT    = 2'd3; // waiting for data from axi
    reg [1:0] buf_inst_rstat, buf_data_rstat, buf_data_wstat;
    reg [3:0] buf_data_wstrb;
    reg [2:0] buf_data_rsize, buf_data_wsize;
    reg [31:0] buf_inst_raddr, buf_data_raddr, buf_data_waddr;
    reg [31:0] buf_data_wdata;
    reg buf_data_rfirst; // indicates if read request is accepted first for data interface (valid only if buf_data_rstat != STAT_IDLE && buf_data_wstat != STAT_IDLE)

    reg [1:0] buf_inst_rstat_next, buf_data_rstat_next, buf_data_wstat_next;
    wire buf_inst_rreq, buf_data_rreq, buf_data_wreq;
    wire buf_inst_rreqok, buf_data_rreqok, buf_data_wreqok;
    wire buf_data_wdataok;
    wire buf_inst_rok, buf_data_rok, buf_data_wok;

    // FSM
    always @(posedge clk) begin
        if (!resetn) begin
            buf_inst_rstat <= STAT_IDLE;
            buf_data_rstat <= STAT_IDLE;
            buf_data_wstat <= STAT_IDLE;
        end
        else begin
            buf_inst_rstat <= buf_inst_rstat_next;
            buf_data_rstat <= buf_data_rstat_next;
            buf_data_wstat <= buf_data_wstat_next;
        end
    end

    always @(*) begin
        case (buf_inst_rstat)
            STAT_IDLE:  buf_inst_rstat_next = buf_inst_rreq ? STAT_REQ : STAT_IDLE;
            STAT_REQ:   buf_inst_rstat_next = buf_inst_rreqok ? STAT_WAIT : STAT_REQ;
            STAT_WAIT:  buf_inst_rstat_next = buf_inst_rok ? (buf_inst_rreq ? STAT_REQ : STAT_IDLE) : STAT_WAIT;
            default:    buf_inst_rstat_next = STAT_IDLE;
        endcase
        case (buf_data_rstat)
            STAT_IDLE:  buf_data_rstat_next = buf_data_rreq ? STAT_REQ : STAT_IDLE;
            STAT_REQ:   buf_data_rstat_next = buf_data_rreqok ? STAT_WAIT : STAT_REQ;
            STAT_WAIT:  buf_data_rstat_next = buf_data_rok ? (buf_data_rreq ? STAT_REQ : STAT_IDLE) : STAT_WAIT;
            default:    buf_data_rstat_next = STAT_IDLE;
        endcase
        case (buf_data_wstat)
            STAT_IDLE:  buf_data_wstat_next = buf_data_wreq ? STAT_REQ : STAT_IDLE;
            STAT_REQ:   buf_data_wstat_next = buf_data_wreqok ? STAT_WD : STAT_REQ;
            STAT_WD:    buf_data_wstat_next = buf_data_wdataok ? STAT_WAIT : STAT_WD;
            STAT_WAIT:  buf_data_wstat_next = buf_data_wok ? (buf_data_wreq ? STAT_REQ : STAT_IDLE) : STAT_WAIT;
            default:    buf_data_wstat_next = STAT_IDLE;
        endcase
    end

    // 1.buffering requests
    wire flag_inst_rbufok = buf_inst_rstat != STAT_REQ && buf_inst_rstat_next == STAT_REQ;
    wire flag_data_rbufok = buf_data_rstat != STAT_REQ && buf_data_rstat_next == STAT_REQ;
    wire flag_data_wbufok = buf_data_wstat != STAT_REQ && buf_data_wstat_next == STAT_REQ;
    assign buf_inst_rreq = inst_req;
    assign buf_data_rreq = data_req && !data_wr && buf_inst_rstat != STAT_REQ; // data request cannot be sent if inst is requesting
    assign buf_data_wreq = data_req && data_wr;
    always @(posedge clk) begin
        if (flag_inst_rbufok) begin
            buf_inst_raddr <= inst_addr;
        end
        if (flag_data_rbufok) begin
            buf_data_raddr <= data_addr;
            buf_data_rsize <= data_size;
        end
        if (flag_data_wbufok) begin
            buf_data_wstrb <= data_wstrb;
            buf_data_waddr <= data_addr;
            buf_data_wsize <= data_size;
            buf_data_wdata <= data_wdata;
        end
    end
    always @(posedge clk) begin
        if (flag_data_rbufok) buf_data_rfirst <= 1'b0;
        else if (flag_data_wbufok) buf_data_rfirst <= 1'b1;
    end
    assign inst_addr_ok = flag_inst_rbufok;
    assign data_addr_ok = flag_data_rbufok || flag_data_wbufok;

    // 2. requesting AXI
    wire flag_inst_rreqvalid = buf_inst_rstat == STAT_REQ && buf_data_rstat != STAT_REQ; // data read is prior to inst read
    wire flag_data_rreqvalid = (buf_data_raddr[31:2] != buf_data_waddr[31:2] || buf_data_wstat == STAT_IDLE) && buf_data_rstat == STAT_REQ; // data write must be completed before read from the same word
    wire flag_data_wreqvalid = buf_data_wstat == STAT_REQ;
    assign arid     = flag_data_rreqvalid ? 4'd1 : 4'd0;
    assign araddr   = flag_data_rreqvalid ? buf_data_raddr : buf_inst_raddr;
    assign arlen    = 8'd0;
    assign arsize   = flag_data_rreqvalid ? buf_data_rsize : 3'd2;
    assign arburst  = 2'd1;
    assign arlock   = 2'd0;
    assign arcache  = 4'd0;
    assign arprot   = 3'd0;
    assign arvalid  = flag_inst_rreqvalid || flag_data_rreqvalid;
    assign awid     = 4'd1;
    assign awaddr   = buf_data_waddr;
    assign awlen    = 8'd0;
    assign awsize   = buf_data_wsize;
    assign awburst  = 2'd1;
    assign awlock   = 2'd0;
    assign awcache  = 4'd0;
    assign awprot   = 3'd0;
    assign awvalid  = flag_data_wreqvalid;
    assign buf_inst_rreqok = arready && flag_inst_rreqvalid;
    assign buf_data_rreqok = arready && flag_data_rreqvalid;
    assign buf_data_wreqok = awready && flag_data_wreqvalid;

    // 3. transfering write data
    assign wid      = 4'd1;
    assign wdata    = buf_data_wdata;
    assign wstrb    = buf_data_wstrb;
    assign wlast    = 1'b1;
    assign wvalid   = buf_data_wstat == STAT_WD;
    assign buf_data_wdataok = wready && (buf_data_wstat == STAT_WD);

    // 4. receiving data from AXI
    wire flag_inst_rready = rid == 4'd0 && buf_inst_rstat == STAT_WAIT;
    wire flag_data_rready = rid == 4'd1 && buf_data_rstat == STAT_WAIT && (buf_data_rfirst || buf_data_wstat == STAT_IDLE); // read & write must be completed in order
    wire flag_data_wready = buf_data_wstat == STAT_WAIT && (!buf_data_rfirst || buf_data_rstat == STAT_IDLE); // read & write must be completed in order
    assign rready   = flag_inst_rready || flag_data_rready;
    assign bready   = flag_data_wready;
    assign inst_rdata = rdata;
    assign data_rdata = rdata;
    assign buf_inst_rok = rvalid && flag_inst_rready;
    assign buf_data_rok = rvalid && flag_data_rready;
    assign buf_data_wok = bvalid && flag_data_wready;
    assign inst_data_ok = buf_inst_rok;
    assign data_data_ok = buf_data_rok || buf_data_wok;

endmodule
