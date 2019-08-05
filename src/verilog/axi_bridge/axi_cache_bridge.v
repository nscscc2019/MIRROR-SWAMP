// module axi_cache_bridge
// By H.Q. Wang in 2019
// This module serves as a 4x1 crossbar between idcache, iduncache fsm and cpu interface.
// It should work just as (or may be faster than) Xilinx's AXI Crossbar IP 

// In this project, we allocate axi_id as:
// 0, 1 dcache write, read
// 2, 3 icache write, read
// 5, 6 uncached data write, read
// 7    uncached inst read

// By defualt, the signials in slave part should be like this:
// {dcache, icache, uncached_data, uncached_inst}

// In this module, we assume that ai requests will not exceed the limit of the buffer. (4)

module axi_cache_bridge (

    input aclk, // i, 1                 
    input aresetn, // i, 1                 

    input [15:0] s_axi_arid,       //( {dcache_arid, icache_arid, uncached_data_arid,uncached_inst_arid}        ),
    input [127:0] s_axi_araddr,     //( {dcache_araddr, icache_araddr, uncached_data_araddr,uncached_inst_araddr}      ),
    input [31:0] s_axi_arlen,      //( {dcache_arlen[3:0], icache_arlen[3:0], uncached_data_arlen[3:0], uncached_inst_arlen[3:0]}  ),
    input [11:0] s_axi_arsize,     //( {dcache_arsize, icache_arsize, 3'b010,3'b010}      ),
    input [7:0] s_axi_arburst,    //( {dcache_arburst, icache_arburst, uncached_data_arburst,uncached_inst_arburst}     ),
    input [7:0] s_axi_arlock,     //( {dcache_arlock, icache_arlock, uncached_data_arlock,uncached_inst_arlock}      ),
    input [15:0] s_axi_arcache,    //( {dcache_arcache, icache_arcache, uncached_data_arcache,uncached_inst_arcache}     ),
    input [11:0] s_axi_arprot,     //( {dcache_arprot, icache_arprot, uncached_data_arprot,uncached_inst_arprot}      ),
    input [15:0] s_axi_arqos,      //( {4'd0,4'd0,4'd0,4'd0}          ),
    input [3:0] s_axi_arvalid,    //( {dcache_arvalid, icache_arvalid, uncached_data_arvalid, uncached_inst_arvalid}     ),
    output [3:0] s_axi_arready,    //( {dcache_arready, icache_arready, uncached_data_arready, uncached_inst_arready}     ),
    output [15:0] s_axi_rid,        //( {dcache_rid, icache_rid, uncached_data_rid, uncached_inst_rid}         ),
    output [127:0] s_axi_rdata,      //( {dcache_rdata, icache_rdata, uncached_data_rdata, uncached_inst_rdata}       ),
    output [7:0] s_axi_rresp,      //( {dcache_rresp, icache_rresp, uncached_data_rresp, uncached_inst_rresp}       ),
    output [3:0] s_axi_rlast,      //( {dcache_rlast, icache_rlast, uncached_data_rlast, uncached_inst_rlast}       ),
    output [3:0] s_axi_rvalid,     //( {dcache_rvalid, icache_rvalid, uncached_data_rvalid, uncached_inst_rvalid}      ),
    input [3:0] s_axi_rready,     //( {dcache_rready, icache_rready, uncached_data_rready, uncached_inst_rready}      ),
    input [15:0] s_axi_awid,       //( {dcache_awid, icache_awid, uncached_data_awid, uncached_inst_awid}        ),
    input [127:0] s_axi_awaddr,     //( {dcache_awaddr, icache_awaddr, uncached_data_awaddr, 32'b0}      ),
    input [27:0] s_axi_awlen,      //( {dcache_awlen[3:0], icache_awlen[3:0], uncached_data_awlen[3:0], uncached_inst_awlen[3:0]}  ),
    input [11:0] s_axi_awsize,     //( {dcache_awsize, icache_awsize, uncached_data_awsize, uncached_inst_awsize}      ),
    input [7:0] s_axi_awburst,    //( {dcache_awburst, icache_awburst, uncached_data_awburst, uncached_inst_awburst}     ),
    input [7:0] s_axi_awlock,     //( {dcache_awlock, icache_awlock, uncached_data_awlock, uncached_inst_awlock}      ),
    input [15:0] s_axi_awcache,    //( {dcache_awcache, icache_awcache, uncached_data_awcache, uncached_inst_awcache}     ),
    input [11:0] s_axi_awprot,     //( {dcache_awprot, icache_awprot, uncached_data_awprot, uncached_inst_awprot}      ),
    input [15:0] s_axi_awqos,      //( {4'd0,4'd0,4'd0,4'd0}          ),
    input [3:0] s_axi_awvalid,    //( {dcache_awvalid, icache_awvalid, uncached_data_awvalid, uncached_inst_awvalid}     ),
    output [3:0] s_axi_awready,    //( {dcache_awready, icache_awready, uncached_data_awready, uncached_inst_awready}     ),
    input [15:0] s_axi_wid,        //( {dcache_wid, icache_wid, uncached_data_wid, uncached_inst_wid}         ),
    input [127:0] s_axi_wdata,      //( {dcache_wdata, icache_wdata, uncached_data_wdata, uncached_inst_wdata}       ),
    input [15:0] s_axi_wstrb,      //( {dcache_wstrb, icache_wstrb, uncached_data_wstrb, uncached_inst_wstrb}       ),
    input [3:0] s_axi_wlast,      //( {dcache_wlast, icache_wlast, uncached_data_wlast, uncached_inst_wlast}       ),
    input [3:0] s_axi_wvalid,     //( {dcache_wvalid, icache_wvalid, uncached_data_wvalid, uncached_inst_wvalid}      ),
    output [3:0] s_axi_wready,     //( {dcache_wready, icache_wready, uncached_data_wready, uncached_inst_wready}      ),
    output [15:0] s_axi_bid,        //( {dcache_bid, icache_bid, uncached_data_bid, uncached_inst_bid}         ),
    output [7:0] s_axi_bresp,      //( {dcache_bresp, icache_bresp, uncached_data_bresp, uncached_inst_bresp}       ),
    output [3:0] s_axi_bvalid,     //( {dcache_bvalid, icache_bvalid, uncached_data_bvalid, uncached_inst_bvalid}      ),
    input [3:0] s_axi_bready,     //( {dcache_bready, icache_bready, uncached_data_bready, uncached_inst_bready}      ),

    output  [3 :0] m_axi_arid,        //(arid      ),
    output  [31:0] m_axi_araddr,      //(araddr_before    ),
    output  [7 :0] m_axi_arlen,       //(arlen_before     ),
    output  [2 :0] m_axi_arsize,      //(arsize    ),
    output  [1 :0] m_axi_arburst,     //(arburst   ),
    output  [1 :0] m_axi_arlock,      //(arlock    ),
    output  [3 :0] m_axi_arcache,     //(arcache   ),
    output  [2 :0] m_axi_arprot,      //(arprot    ),
    output  [3:0]  m_axi_arqos,       //(xxx 4'b0?         ),
    output         m_axi_arvalid,     //(arvalid   ),
    input          m_axi_arready,     //(arready   ),
    input  [3 :0]  m_axi_rid,         //(rid       ),
    input  [31:0]  m_axi_rdata,       //(rdata     ),
    input  [1 :0]  m_axi_rresp,       //(rresp     ),
    input          m_axi_rlast,       //(rlast     ),
    input          m_axi_rvalid,      //(rvalid    ),
    output         m_axi_rready,      //(rready    ),
    output  [3 :0] m_axi_awid,        //(awid      ),
    output  [31:0] m_axi_awaddr,      //(awaddr_before    ),
    output  [7 :0] m_axi_awlen,       //(awlen     ),
    output  [2 :0] m_axi_awsize,      //(awsize    ),
    output  [1 :0] m_axi_awburst,     //(awburst   ),
    output  [1 :0] m_axi_awlock,      //(awlock    ),
    output  [3 :0] m_axi_awcache,     //(awcache   ),
    output  [2 :0] m_axi_awprot,      //(awprot    ),
    output  [3:0]  m_axi_awqos,       //(xxx          ),
    output         m_axi_awvalid,     //(awvalid   ),
    input          m_axi_awready,     //(awready   ),
    output  [3 :0] m_axi_wid,         //(wid       ),
    output  [31:0] m_axi_wdata,       //(wdata     ),
    output  [3 :0] m_axi_wstrb,       //(wstrb     ),
    output         m_axi_wlast,       //(wlast     ),
    output         m_axi_wvalid,      //(wvalid    ),
    input          m_axi_wready,      //(wready    ),
    input   [3 :0] m_axi_bid,         //(bid       ),
    input   [1 :0] m_axi_bresp,       //(bresp     ),
    input          m_axi_bvalid,      //(bvalid    ),
    output         m_axi_bready      //(bready    )

);

// write/read channels are seprated.

// -----------------------------------------
// priority
// -----------------------------------------

wire ar3 = s_axi_arready[3] & s_axi_arvalid[3]; 
wire ar2 = s_axi_arready[2] & s_axi_arvalid[2] & (!ar3); 
wire ar1 = s_axi_arready[1] & s_axi_arvalid[1] & (!ar3) & (!ar2); 
wire ar0 = s_axi_arready[0] & s_axi_arvalid[0] & (!ar3) & (!ar2) & (!ar1); 
wire [1:0] ar_pick =
    ar3 ? 2'd3:
    ar2 ? 2'd2:
    ar1 ? 2'd1:
    ar0 ? 2'd0;

// wire r3 = m_axi_rready[3] & m_axi_rvalid[3]; 
// wire r2 = m_axi_rready[2] & m_axi_rvalid[2] & (!r3); 
// wire r1 = m_axi_rready[1] & m_axi_rvalid[1] & (!r3) & (!r2); 
// wire r0 = m_axi_rready[0] & m_axi_rvalid[0] & (!r3) & (!r2) & (!r1); 

wire aw3 = s_axi_arready[3] & s_axi_arvalid[3]; 
wire aw2 = s_axi_arready[2] & s_axi_arvalid[2] & (!aw3); 
wire aw1 = s_axi_arready[1] & s_axi_arvalid[1] & (!aw3) & (!aw2); 
wire aw0 = s_axi_arready[0] & s_axi_arvalid[0] & (!aw3) & (!aw2) & (!aw1); 
wire [1:0] aw_pick =
    aw3 ? 2'd3:
    aw2 ? 2'd2:
    aw1 ? 2'd1:
    2'd0;

// wire w3 = m_axi_arready[3] & m_axi_arvalid[3]; 
// wire w2 = m_axi_arready[2] & m_axi_arvalid[2] & (!w3); 
// wire w1 = m_axi_arready[1] & m_axi_arvalid[1] & (!w3) & (!w2); 
// wire w0 = m_axi_arready[0] & m_axi_arvalid[0] & (!w3) & (!w2) & (!w1); 

// -----------------------------------------
// read channel
// -----------------------------------------

assign m_axi_arid = s_axi_arid[ar_pick];
assign m_axi_araddr = 
    ar3 ? s_axi_araddr[127-:32]:
    ar2 ? s_axi_araddr[95-:32]:
    ar1 ? s_axi_araddr[63-:32]:
    ar0 ? s_axi_araddr[31-:32];
assign m_axi_arlen = 
    ar3 ? s_axi_araddr[7-:2]:
    ar2 ? s_axi_araddr[5-:2]:
    ar1 ? s_axi_araddr[3-:2]:
    ar0 ? s_axi_araddr[1-:2];
assign m_axi_arsize =
    ar3 ? s_axi_arsize[11-:3]:
    ar2 ? s_axi_arsize[8-:3]:
    ar1 ? s_axi_arsize[5-:3]:
    ar0 ? s_axi_arsize[2-:3];
assign m_axi_arburst =
    ar3 ? s_axi_arburst[7-:2]:
    ar2 ? s_axi_arburst[5-:2]:
    ar1 ? s_axi_arburst[3-:2]:
    ar0 ? s_axi_arburst[1-:2];
assign m_axi_arlock =
    ar3 ? s_axi_arlock[7-:2]:
    ar2 ? s_axi_arlock[5-:2]:
    ar1 ? s_axi_arlock[3-:2]:
    ar0 ? s_axi_arlock[1-:2];
assign m_axi_arcache = 
    ar3 ? s_axi_araddr[7-:2]:
    ar2 ? s_axi_araddr[5-:2]:
    ar1 ? s_axi_araddr[3-:2]:
    ar0 ? s_axi_araddr[1-:2];
assign m_axi_arprot = 
    ar3 ? s_axi_arprot[11-:3]:
    ar2 ? s_axi_arprot[8-:3]:
    ar1 ? s_axi_arprot[5-:3]:
    ar0 ? s_axi_arprot[2-:3];
assign m_axi_arqos = 4'b0;
assign m_axi_arvalid = |(s_axi_arvalid);

assign s_axi_arready = {
    ar3 & m_axi_arready,
    ar2 & m_axi_arready,
    ar1 & m_axi_arready,
    ar0 & m_axi_arready
};

// r: rdata

reg [1:0] read_index_head;
reg [1:0] read_index_tail;

reg [31:0] read_queue_data [1:0];
reg [3:0] read_queue_id [1:0];
reg read_queue_last [1:0];
reg read_queue_resp [1:0];

// queue control logic
wire read_queue_in = (m_axi_rvalid & m_axi_rready);//succeed in shaking hands 
wire read_queue_out = |(s_axi_rvalid & s_axi_rready);
wire read_direct_out = read_index_head == read_index_tail; 

// en/dequeue logic
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        read_index_head <= 2'b0;
    end 
    else 
    begin
        read_index_head <= read_queue_in ? read_index_head+2'b1 : read_index_head;
    end
end

always@(posedge aclk)
begin
    if(!aresetn)
    begin
        read_index_tail <= 2'b0;
    end 
    else 
    begin
        read_index_tail <= read_queue_out ? read_index_tail+2'b1 : read_index_tail;
    end
end

always@(posedge aclk)
begin
    if(read_queue_in)
    begin
        read_queue_data[read_index_head] <= m_axi_rdata;
        read_queue_id[read_index_head] <= m_axi_rid;
        read_queue_last[read_index_head] <= m_axi_rlast;
        read_queue_resp[read_index_head] <= m_axi_rresp;
    end
end

// interface assign
assign m_axi_rready = 1'b1; //always ready, may cause problem
assign s_axi_rid = {4{read_direct_out ? m_axi_rid : read_queue_id[read_index_tail]}};
assign s_axi_rdata = {4{read_direct_out ? m_axi_rdata : read_queue_data[read_index_tail]}};
assign s_axi_rresp = {4{read_direct_out ? m_axi_rresp : read_queue_resp[read_index_tail]}};
assign s_axi_rlast = {4{read_direct_out ? m_axi_rlast : read_queue_last[read_index_tail]}};
case(read_direct_out ? m_axi_rid : read_queue_id[read_index_tail])
    // `4'b0: s_axi_rvalid = 4'b0000; 
    `4'b1: s_axi_rvalid = 4'b1000; 
    `4'b3: s_axi_rvalid = 4'b0100; 
    `4'b6: s_axi_rvalid = 4'b0010; 
    `4'b7: s_axi_rvalid = 4'b0001; 
    `default: s_axi_rvalid = 4'b0000;
endcase 
    

// -----------------------------------------
// write channel
// -----------------------------------------

assign m_axi_awid = s_axi_awid[aw_pick];
assign m_axi_awaddr = 
    aw3 ? s_axi_awaddr[127-:32]:
    aw2 ? s_axi_awaddr[95-:32]:
    aw1 ? s_axi_awaddr[63-:32]:
    s_axi_awaddr[31-:32];
assign m_axi_awlen = 
    aw3 ? s_axi_awaddr[7-:2]:
    aw2 ? s_axi_awaddr[5-:2]:
    aw1 ? s_axi_awaddr[3-:2]:
    s_axi_awaddr[1-:2];
assign m_axi_awsize =
    aw3 ? s_axi_awsize[11-:3]:
    aw2 ? s_axi_awsize[8-:3]:
    aw1 ? s_axi_awsize[5-:3]:
    s_axi_awsize[2-:3];
assign m_axi_awburst =
    aw3 ? s_axi_awburst[7-:2]:
    aw2 ? s_axi_awburst[5-:2]:
    aw1 ? s_axi_awburst[3-:2]:
    s_axi_awburst[1-:2];
assign m_axi_awlock =
    aw3 ? s_axi_awlock[7-:2]:
    aw2 ? s_axi_awlock[5-:2]:
    aw1 ? s_axi_awlock[3-:2]:
    s_axi_awlock[1-:2];
assign m_axi_awcache = 
    aw3 ? s_axi_awaddr[7-:2]:
    aw2 ? s_axi_awaddr[5-:2]:
    aw1 ? s_axi_awaddr[3-:2]:
    s_axi_awaddr[1-:2];
assign m_axi_awprot = 
    aw3 ? s_axi_awprot[11-:3]:
    aw2 ? s_axi_awprot[8-:3]:
    aw1 ? s_axi_awprot[5-:3]:
    s_axi_awprot[2-:3];
assign m_axi_awqos = 4'b0;
assign m_axi_awvalid = |(s_axi_awvalid);

assign s_axi_awready = {
    aw3 & m_axi_awready,
    aw2 & m_axi_awready,
    aw1 & m_axi_awready,
    aw0 & m_axi_awready
};

// w: wdata

reg [1:0] write_index_head;
reg [1:0] write_index_tail;

reg [31:0] write_queue_data [1:0];
reg [3:0] write_queue_id [1:0];
reg write_queue_last [1:0];

// queue control logic
wire write_queue_in = |(s_axi_wvalid & s_axi_wready);//succeed in shaking hands 
wire write_queue_out = (m_axi_wvalid & m_axi_wready);
wire write_direct_out = write_index_head == write_index_tail; 

wire [31:0] s_axi_wdata_picked = 
    aw3 ? s_axi_wdata[127-:32] :
    aw2 ? s_axi_wdata[95-:32] :
    aw1 ? s_axi_wdata[63-:32] :
    s_axi_wdata[31-:32];
wire [3:0] s_axi_wid_picked =
    aw3 ? s_axi_wid[15-:4] :
    aw2 ? s_axi_wid[11-:4] :
    aw1 ? s_axi_wid[7-:4] :
    s_axi_wid[3-:4];
wire s_axi_wlast_picked =
    aw3 ? s_axi_wlast[3] :
    aw2 ? s_axi_wlast[2] :
    aw1 ? s_axi_wlast[1] :
    s_axi_wlast[0];
wire [3:0] s_axi_wstrb_picked =
    aw3 ? s_axi_wstrb[15-:4] :
    aw2 ? s_axi_wstrb[11-:4] :
    aw1 ? s_axi_wstrb[7-:4] :
    s_axi_wstrb[3-:4];

// en/dequeue logic
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        write_index_head <= 2'b0;
    end 
    else 
    begin
        write_index_head <= write_queue_in ? write_index_head+2'b1 : write_index_head;
    end
end

always@(posedge aclk)
begin
    if(!aresetn)
    begin
        write_index_tail <= 2'b0;
    end 
    else 
    begin
        write_index_tail <= write_queue_out ? write_index_tail+2'b1 : write_index_tail;
    end
end

always@(posedge aclk)
begin
    if(write_queue_in)
    begin
        write_queue_data[write_index_head] <= s_axi_wdata_picked;
        write_queue_id[write_index_head] <= s_axi_wid_picked;
        write_queue_last[write_index_head] <= s_axi_wlast_picked;
        write_queue_strb[write_index_head] <= s_axi_wstrb_picked;
    end
end

// interface assign
wire write_queue_full = (write_index_head + 2'b1) == write_index_tail;
assign s_axi_wready = {4{write_queue_full}};

assign s_axi_bready = {//FIXIT ????
    (m_axi_awid==4'b0) & m_axi_bready,
    (m_axi_awid==4'b2) & m_axi_bready,
    (m_axi_awid==4'b5) & m_axi_bready,
    // (m_axi_awid==4'b) & m_axi_awready
    1'b0
};


assign m_axi_wid = write_direct_out ? s_axi_wid_picked : write_queue_id[write_index_tail];
assign m_axi_wdata = write_direct_out ? s_axi_wdata_picked : write_queue_id[write_index_tail];
assign m_axi_wstrb = write_direct_out ? s_axi_wstrb_picked : write_queue_strb[write_index_tail];
assign m_axi_wlast = write_direct_out ? s_axi_wlast_picked : write_queue_last[write_index_tail];

assign m_axi_wvalid = write_direct_out ? |(s_axi_vaild) : 1'b1; 
    
assign m_axi_bready = s_axi_bready; //TODO ?????


endmodule