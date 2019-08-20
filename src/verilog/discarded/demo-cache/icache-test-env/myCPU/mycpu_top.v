`timescale 10ns / 1ns
module mycpu_top(
    input  [5 :0] int,     //high active

    input         aclk,
    input         aresetn, //low active

    output [3 :0] arid             ,
    output [31:0] araddr           ,
    output [7 :0] arlen            ,
    output [2 :0] arsize           ,
    output [1 :0] arburst          ,
    output [1 :0] arlock           ,
    output [3 :0] arcache          ,
    output [2 :0] arprot           ,
    output        arvalid          ,
    input         arready          ,
            
    input  [3 :0] rid              ,
    input  [31:0] rdata            ,
    input  [1 :0] rresp            ,
    input         rlast            ,
    input         rvalid           ,
    output        rready           ,
               
    output [3 :0] awid             ,
    output [31:0] awaddr           ,
    output [7 :0] awlen            ,
    output [2 :0] awsize           ,
    output [1 :0] awburst          ,
    output [1 :0] awlock           ,
    output [3 :0] awcache          ,
    output [2 :0] awprot           ,
    output        awvalid          ,
    input         awready          ,
    
    output [3 :0] wid              ,
    output [31:0] wdata            ,
    output [3 :0] wstrb            ,
    output        wlast            ,
    output        wvalid           ,
    input         wready           ,
    
    input  [3 :0] bid              ,
    input  [1 :0] bresp            ,
    input         bvalid           ,
    output        bready           ,

    //debug interface
    output [31:0] debug_wb_pc      ,
    output [3 :0] debug_wb_rf_wen  ,
    output [4 :0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
);

wire        cpu_inst_req    ;
wire        cpu_inst_wr     ;
wire [1 :0] cpu_inst_size   ;
wire [31:0] cpu_inst_addr   ;
wire [31:0] cpu_inst_wdata  ;
wire [31:0] cpu_inst_rdata  ;
wire        cpu_inst_addr_ok;
wire        cpu_inst_data_ok;

wire        cpu_data_req    ;
wire        cpu_data_wr     ;
wire [1 :0] cpu_data_size   ;
wire [31:0] cpu_data_addr   ;
wire [31:0] cpu_data_wdata  ;
wire [31:0] cpu_data_rdata  ;
wire        cpu_data_addr_ok;
wire        cpu_data_data_ok;

mycpu u_cpu(
    .hw_int            (int              ),
    .clk               (aclk             ),
    .resetn            (aresetn          ),

    .inst_req          (cpu_inst_req     ),
    .inst_wr           (cpu_inst_wr      ),
    .inst_size         (cpu_inst_size    ),
    .inst_addr         (cpu_inst_addr    ),
    .inst_wdata        (cpu_inst_wdata   ),
    .inst_rdata        (cpu_inst_rdata   ),
    .inst_addr_ok      (cpu_inst_addr_ok ),
    .inst_data_ok      (cpu_inst_data_ok ),

    .data_req          (cpu_data_req     ),
    .data_wr           (cpu_data_wr      ),
    .data_size         (cpu_data_size    ),
    .data_addr         (cpu_data_addr    ),
    .data_wdata        (cpu_data_wdata   ),
    .data_rdata        (cpu_data_rdata   ),
    .data_addr_ok      (cpu_data_addr_ok ),
    .data_data_ok      (cpu_data_data_ok ),

    .debug_wb_pc       (debug_wb_pc      ),
    .debug_wb_rf_wen   (debug_wb_rf_wen  ),
    .debug_wb_rf_wnum  (debug_wb_rf_wnum ),
    .debug_wb_rf_wdata (debug_wb_rf_wdata)
);

wire [31:0] araddr_before, awaddr_before;

wire  [3 :0]oldbridge_arid   ;
wire  [31:0]oldbridge_araddr ;
wire  [7 :0]oldbridge_arlen  ;
wire  [2 :0]oldbridge_arsize ;
wire  [1 :0]oldbridge_arburst;
wire  [1 :0]oldbridge_arlock ;
wire  [3 :0]oldbridge_arcache;
wire  [2 :0]oldbridge_arprot ;
wire        oldbridge_arvalid;
wire        oldbridge_arready;
//r
wire [3 :0] oldbridge_rid    ;
wire [31:0] oldbridge_rdata  ;
wire [1 :0] oldbridge_rresp  ;
wire        oldbridge_rlast  ;
wire        oldbridge_rvalid ;
wire        oldbridge_rready ;
//aw
wire  [3 :0]oldbridge_awid   ;
wire  [31:0]oldbridge_awaddr ;
wire  [7 :0]oldbridge_awlen  ;
wire  [2 :0]oldbridge_awsize ;
wire  [1 :0]oldbridge_awburst;
wire  [1 :0]oldbridge_awlock ;
wire  [3 :0]oldbridge_awcache;
wire  [2 :0]oldbridge_awprot ;
wire         oldbridge_awvalid;
wire         oldbridge_awready;
//w
wire  [3 :0]oldbridge_wid    ;
wire  [31:0]oldbridge_wdata  ;
wire  [3 :0]oldbridge_wstrb  ;
wire         oldbridge_wlast  ;
wire         oldbridge_wvalid ;
wire         oldbridge_wready ;
//b
wire [3 :0]oldbridge_bid    ;
wire [1 :0]oldbridge_bresp  ;
wire        oldbridge_bvalid ;
wire        oldbridge_bready ;

wire idle_cpu_inst_wr = 1'b0;
wire [2:0]idle_cpu_inst_size = 3'b0;
wire [31:0]idle_cpu_inst_addr = 32'b0;
wire [31:0]idle_cpu_inst_rdata = 32'b0; 
wire [31:0]idle_cpu_inst_wdata = 32'b0;
wire idle_cpu_inst_addr_ok;
wire idle_cpu_inst_data_ok;

cpu_axi_interface u_cpu_axi_interface(
    .clk          (aclk             ),
    .resetn       (aresetn          ),

    //inst sram-like 
    .inst_req     (1'b0             ),
    .inst_wr      (idle_cpu_inst_wr      ),
    .inst_size    (idle_cpu_inst_size    ),
    .inst_addr    (idle_cpu_inst_addr    ),
    .inst_wdata   (idle_cpu_inst_wdata   ),
    .inst_rdata   (idle_cpu_inst_rdata   ),
    .inst_addr_ok (idle_cpu_inst_addr_ok ),
    .inst_data_ok (idle_cpu_inst_data_ok ),
    
    //data sram-like 
    .data_req     (cpu_data_req     ),
    .data_wr      (cpu_data_wr      ),
    .data_size    (cpu_data_size    ),
    .data_addr    (cpu_data_addr    ),
    .data_wdata   (cpu_data_wdata   ),
    .data_rdata   (cpu_data_rdata   ),
    .data_addr_ok (cpu_data_addr_ok ),
    .data_data_ok (cpu_data_data_ok ),

    //axi
    //ar
    .arid         (oldbridge_arid             ),
    .araddr       (oldbridge_araddr           ),
    .arlen        (oldbridge_arlen            ),
    .arsize       (oldbridge_arsize           ),
    .arburst      (oldbridge_arburst          ),
    .arlock       (oldbridge_arlock           ),
    .arcache      (oldbridge_arcache          ),
    .arprot       (oldbridge_arprot           ),
    .arvalid      (oldbridge_arvalid          ),
    .arready      (oldbridge_arready          ),
    //r              
    .rid          (oldbridge_rid              ),
    .rdata        (oldbridge_rdata            ),
    .rresp        (oldbridge_rresp            ),
    .rlast        (oldbridge_rlast            ),
    .rvalid       (oldbridge_rvalid           ),
    .rready       (oldbridge_rready           ),
    //aw               
    .awid         (oldbridge_awid             ),
    .awaddr       (oldbridge_awaddr           ),
    .awlen        (oldbridge_awlen            ),
    .awsize       (oldbridge_awsize           ),
    .awburst      (oldbridge_awburst          ),
    .awlock       (oldbridge_awlock           ),
    .awcache      (oldbridge_awcache          ),
    .awprot       (oldbridge_awprot           ),
    .awvalid      (oldbridge_awvalid          ),
    .awready      (oldbridge_awready          ),
    //w               
    .wid          (oldbridge_wid              ),
    .wdata        (oldbridge_wdata            ),
    .wstrb        (oldbridge_wstrb            ),
    .wlast        (oldbridge_wlast            ),
    .wvalid       (oldbridge_wvalid           ),
    .wready       (oldbridge_wready           ),
    //b              
    .bid          (oldbridge_bid              ),
    .bresp        (oldbridge_bresp            ),
    .bvalid       (oldbridge_bvalid           ),
    .bready       (oldbridge_bready           )
);

//
wire  [3 :0]icache_arid   ;
wire  [31:0]icache_araddr ;
wire  [7 :0]icache_arlen  ;
wire  [2 :0]icache_arsize ;
wire  [1 :0]icache_arburst;
wire  [1 :0]icache_arlock ;
wire  [3 :0]icache_arcache;
wire  [2 :0]icache_arprot ;
wire         icache_arvalid;
wire         icache_arready;
//r
wire [3 :0]icache_rid    ;
wire [31:0]icache_rdata  ;
wire [1 :0]icache_rresp  ;
wire        icache_rlast  ;
wire        icache_rvalid ;
wire        icache_rready ;
//aw
wire  [3 :0]icache_awid   ;
wire  [31:0]icache_awaddr ;
wire  [7 :0]icache_awlen  ;
wire  [2 :0]icache_awsize ;
wire  [1 :0]icache_awburst;
wire  [1 :0]icache_awlock ;
wire  [3 :0]icache_awcache;
wire  [2 :0]icache_awprot ;
wire         icache_awvalid;
wire         icache_awready;
//w
wire  [3 :0]icache_wid    ;
wire  [31:0]icache_wdata  ;
wire  [3 :0]icache_wstrb  ;
wire         icache_wlast  ;
wire         icache_wvalid ;
wire         icache_wready ;
//b
wire [3 :0]icache_bid    ;
wire [1 :0]icache_bresp  ;
wire        icache_bvalid ;
wire        icache_bready ;

icache u_icache
(
    ////basic
    .clk(aclk),   ////////????????????????
    .resetn(aresetn),   //////////?????????????????
    //input         en,
    //input [31:0]  wen,
    //input         resetn, 
    //input [31:0]  addr,
    //input [31:0]  wdata,
    //output[31:0]  rdata,

    ////axi_control
    //ar
    
    .arid         (icache_arid             ),
    .araddr       (icache_araddr           ),
    .arlen        (icache_arlen            ),
    .arsize       (icache_arsize           ),
    .arburst      (icache_arburst          ),
    .arlock       (icache_arlock           ),
    .arcache      (icache_arcache          ),
    .arprot       (icache_arprot           ),
    .arvalid      (icache_arvalid          ),
    .arready      (icache_arready          ),
    //r              
    .rid          (icache_rid              ),
    .rdata        (icache_rdata            ),
    .rresp        (icache_rresp            ),
    .rlast        (icache_rlast            ),
    .rvalid       (icache_rvalid           ),
    .rready       (icache_rready           ),
    //aw               
    .awid         (icache_awid             ),
    .awaddr       (icache_awaddr           ),
    .awlen        (icache_awlen            ),
    .awsize       (icache_awsize           ),
    .awburst      (icache_awburst          ),
    .awlock       (icache_awlock           ),
    .awcache      (icache_awcache          ),
    .awprot       (icache_awprot           ),
    .awvalid      (icache_awvalid          ),
    .awready      (icache_awready          ),
    //w               
    .wid          (icache_wid              ),
    .wdata        (icache_wdata            ),
    .wstrb        (icache_wstrb            ),
    .wlast        (icache_wlast            ),
    .wvalid       (icache_wvalid           ),
    .wready       (icache_wready           ),
    //b              
    .bid          (icache_bid              ),
    .bresp        (icache_bresp            ),
    .bvalid       (icache_bvalid           ),
    .bready       (icache_bready           ),

    ////cpu_control
    //------inst sram-like-------
    .inst_req          (cpu_inst_req     ),
    .inst_wr           (cpu_inst_wr      ),
    .inst_size         (cpu_inst_size    ),
    .inst_addr         (cpu_inst_addr    ),
    .inst_wdata        (cpu_inst_wdata   ),
    .inst_rdata        (cpu_inst_rdata   ),
    .inst_addr_ok      (cpu_inst_addr_ok ),
    .inst_data_ok      (cpu_inst_data_ok )

);

wire [3:0] arlen_before;

axi_cache_bridge u_axi_cache_bridge(

    .aclk             ( aclk              ), // i, 1                 
    .aresetn          ( aresetn           ), // i, 1                 

    .s_axi_arid       ( {oldbridge_arid, icache_arid}        ),
    .s_axi_araddr     ( {oldbridge_araddr, icache_araddr}      ),
    .s_axi_arlen      ( {oldbridge_arlen[3:0], icache_arlen[3:0]}  ),
    .s_axi_arsize     ( {oldbridge_arsize, icache_arsize}      ),
    .s_axi_arburst    ( {oldbridge_arburst, icache_arburst}     ),
    .s_axi_arlock     ( {oldbridge_arlock, icache_arlock}      ),
    .s_axi_arcache    ( {oldbridge_arcache, icache_arcache}     ),
    .s_axi_arprot     ( {oldbridge_arprot, icache_arprot}      ),
    .s_axi_arqos      ( {4'd0,4'd0}          ),
    .s_axi_arvalid    ( {oldbridge_arvalid, icache_arvalid}     ),
    .s_axi_arready    ( {oldbridge_arready, icache_arready}     ),
    .s_axi_rid        ( {oldbridge_rid, icache_rid}         ),
    .s_axi_rdata      ( {oldbridge_rdata, icache_rdata}       ),
    .s_axi_rresp      ( {oldbridge_rresp, icache_rresp}       ),
    .s_axi_rlast      ( {oldbridge_rlast, icache_rlast}       ),
    .s_axi_rvalid     ( {oldbridge_rvalid, icache_rvalid}      ),
    .s_axi_rready     ( {oldbridge_rready, icache_rready}      ),
    .s_axi_awid       ( {oldbridge_awid, icache_awid}        ),
    .s_axi_awaddr     ( {oldbridge_awaddr, icache_awaddr}      ),
    .s_axi_awlen      ( {oldbridge_awlen[3:0], icache_awlen[3:0]}  ),
    .s_axi_awsize     ( {oldbridge_awsize, icache_awsize}      ),
    .s_axi_awburst    ( {oldbridge_awburst, icache_awburst}     ),
    .s_axi_awlock     ( {oldbridge_awlock, icache_awlock}      ),
    .s_axi_awcache    ( {oldbridge_awcache, icache_awcache}     ),
    .s_axi_awprot     ( {oldbridge_awprot, icache_awprot}      ),
    .s_axi_awqos      ( {4'd0,4'd0}          ),
    .s_axi_awvalid    ( {oldbridge_awvalid, icache_awvalid}     ),
    .s_axi_awready    ( {oldbridge_awready, icache_awready}     ),
    .s_axi_wid        ( {oldbridge_wid, icache_wid}         ),
    .s_axi_wdata      ( {oldbridge_wdata, icache_wdata}       ),
    .s_axi_wstrb      ( {oldbridge_wstrb, icache_wstrb}       ),
    .s_axi_wlast      ( {oldbridge_wlast, icache_wlast}       ),
    .s_axi_wvalid     ( {oldbridge_wvalid, icache_wvalid}      ),
    .s_axi_wready     ( {oldbridge_wready, icache_wready}      ),
    .s_axi_bid        ( {oldbridge_bid, icache_bid}         ),
    .s_axi_bresp      ( {oldbridge_bresp, icache_bresp}       ),
    .s_axi_bvalid     ( {oldbridge_bvalid, icache_bvalid}      ),
    .s_axi_bready     ( {oldbridge_bready, icache_bready}      ),

    .m_axi_arid       (arid      ),
    .m_axi_araddr     (araddr_before    ),
    .m_axi_arlen      (arlen_before     ),
    .m_axi_arsize     (arsize    ),
    .m_axi_arburst    (arburst   ),
    .m_axi_arlock     (arlock    ),
    .m_axi_arcache    (arcache   ),
    .m_axi_arprot     (arprot    ),
    .m_axi_arqos      (          ),
    .m_axi_arvalid    (arvalid   ),
    .m_axi_arready    (arready   ),
    .m_axi_rid        (rid       ),
    .m_axi_rdata      (rdata     ),
    .m_axi_rresp      (rresp     ),
    .m_axi_rlast      (rlast     ),
    .m_axi_rvalid     (rvalid    ),
    .m_axi_rready     (rready    ),
    .m_axi_awid       (awid      ),
    .m_axi_awaddr     (awaddr_before    ),
    .m_axi_awlen      (awlen     ),
    .m_axi_awsize     (awsize    ),
    .m_axi_awburst    (awburst   ),
    .m_axi_awlock     (awlock    ),
    .m_axi_awcache    (awcache   ),
    .m_axi_awprot     (awprot    ),
    .m_axi_awqos      (          ),
    .m_axi_awvalid    (awvalid   ),
    .m_axi_awready    (awready   ),
    .m_axi_wid        (wid       ),
    .m_axi_wdata      (wdata     ),
    .m_axi_wstrb      (wstrb     ),
    .m_axi_wlast      (wlast     ),
    .m_axi_wvalid     (wvalid    ),
    .m_axi_wready     (wready    ),
    .m_axi_bid        (bid       ),
    .m_axi_bresp      (bresp     ),
    .m_axi_bvalid     (bvalid    ),
    .m_axi_bready     (bready    )

 );

 
//
assign araddr = {3'd0, araddr_before[28:0]};
assign awaddr = {3'd0, awaddr_before[28:0]};
assign arlen  = {4'd0,arlen_before};

endmodule