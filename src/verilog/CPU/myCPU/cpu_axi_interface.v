`define RINIT   5'b00001
`define RINST   5'b00010
`define RDATA   5'b00100
`define RVALID  5'b01000
`define REND    5'b10000
`define WINIT   5'b00001
`define WINST   5'b00010
`define WDATA   5'b00100
`define WEND    5'b01000

module cpu_axi_interface(
    input     clk,
    input     resetn,

    //inst sram-like 
    input             inst_req     ,
    input             inst_wr      ,
    input      [ 1:0] inst_size    ,
    input      [31:0] inst_addr    ,
    input      [31:0] inst_wdata   ,
    output reg [31:0] inst_rdata   ,
    output            inst_addr_ok ,
    output reg        inst_data_ok ,
    
    //data sram-like 
    input             data_req     ,
    input             data_wr      ,
    input      [ 1:0] data_size    ,
    input      [31:0] data_addr    ,
    input      [31:0] data_wdata   ,
    output reg [31:0] data_rdata   ,
    output            data_addr_ok ,
    output            data_data_ok ,

    //axi
    //ar
    output reg [ 3:0] arid    ,
    output reg [31:0] araddr  ,
    output     [ 7:0] arlen   ,
    output reg [ 2:0] arsize  ,
    output     [ 1:0] arburst ,
    output     [ 1:0] arlock  ,
    output     [ 3:0] arcache ,
    output     [ 2:0] arprot  ,
    output reg        arvalid ,
    input             arready ,
    //r              
    input      [ 3:0] rid     ,
    input      [31:0] rdata   ,
    input      [ 1:0] rresp   ,
    input             rlast   ,
    input             rvalid  ,
    output reg        rready  ,
    //aw               
    output     [ 3:0] awid    ,
    output reg [31:0] awaddr  ,
    output     [ 7:0] awlen   ,
    output reg [ 2:0] awsize  ,
    output     [ 1:0] awburst ,
    output     [ 1:0] awlock  ,
    output     [ 3:0] awcache ,
    output     [ 2:0] awprot  ,
    output reg        awvalid ,
    input             awready ,
    //w               
    output     [ 3:0] wid     ,
    output reg [31:0] wdata   ,
    output reg [ 3:0] wstrb   ,
    output            wlast   ,
    output reg        wvalid  ,
    input             wready  ,
    //b              
    input      [ 3:0] bid     ,
    input      [ 1:0] bresp   ,
    input             bvalid  ,
    output reg        bready    
);
reg        rvalid_r;
reg [31:0] awaddr_r;
//==========| AXI STATE |==========
reg [4:0] Rcur;
reg [4:0] Rnxt;
reg [4:0] Wcur;
reg [4:0] Wnxt;
reg       reading;
reg       writing;

always@(posedge clk)
begin
    if(~resetn)
    begin
        Rcur <= `RINIT;
        Wcur <= `WINIT;
    end
    else
    begin
        Rcur <= Rnxt;
        Wcur <= Wnxt;
    end
end

always@(*)
begin
    case(Rcur)
        `RINIT:
        begin
            if(inst_req && ~inst_wr)
                Rnxt = `RINST;
            else if(data_req && ~data_wr)
                Rnxt = `RDATA;
            else
                Rnxt = `RINIT;
        end 
        `RINST:
        begin
            if(rvalid)
                Rnxt = `REND;
            else
                Rnxt = `RINST;
        end
        `RDATA:
        begin
            if(awaddr_r[31:2]==araddr[31:2] && bready)
                Rnxt = `RDATA;
            else
                Rnxt = `RVALID;
        end
        `RVALID:
        begin
            if(rvalid)
                Rnxt = `REND;
            else
                Rnxt = `RVALID;
        end
        `REND:
        begin
            if(reading)
                Rnxt = `REND;
            else
                Rnxt = `RINIT;
        end
        default:
            Rnxt = `RINIT;
    endcase
end

always@(*)
begin
    case(Wcur)
        `WINIT:
        begin
            if(inst_req && inst_wr)
                Wnxt = `WINST;
            else if(data_req && data_wr)
                Wnxt = `WDATA;
            else
                Wnxt = `WINIT;
        end 
        `WINST:
        begin
            if(bvalid)
                Wnxt = `WEND;
            else
                Wnxt = `WINST;
        end        
        `WDATA:
        begin
            if(bvalid)
                Wnxt = `WEND;
            else
                Wnxt = `WDATA;
        end
        `WEND:
        begin
            if(writing)
                Wnxt = `WEND;
            else
                Wnxt = `WINIT;
        end
        default:
            Wnxt = `WINIT;
    endcase
end

always@(posedge clk)
begin
    if(~resetn) 
        reading <= 1'b0;
    else if(bready && ~bvalid && Rcur==`RINIT && Rnxt==`RDATA)
        reading <= 1'b1;
    else if(bvalid)
        reading <= 1'b0;
end

always@(posedge clk)
begin
    if(~resetn)
        writing <= 1'b0;
    else if(rready && ~rvalid && Wcur==`WINIT && Wnxt==`WDATA)
        writing <= 1'b1;
    else if(rvalid)
        writing <= 1'b0;
end

//==========| CPU |==========
always@(posedge clk)
begin
    if(rvalid && arid==4'b0001)
        data_rdata <= rdata;
end

assign inst_addr_ok = (Wcur==`WINIT && Wnxt==`WINST) || (Rcur==`RINIT && Rnxt==`RINST);

always@(posedge clk)
begin
    inst_data_ok <= rvalid && arid==4'b0000;
end

always@(posedge clk)
begin
    if(rvalid && arid==4'b0000)
        inst_rdata <= rdata;
end

assign data_addr_ok = (Wcur==`WINIT && Wnxt==`WDATA) || (Rcur==`RINIT && Rnxt==`RDATA);

assign data_data_ok = Rcur==`REND && Rnxt==`RINIT && arid == 4'b0001 
                   || Wcur==`WEND && Wnxt==`WINIT || rvalid_r;
                   
//==========| AXI AR |==========
always@(posedge clk)
begin
    if(Rcur==`RINIT && Rnxt==`RINST)
        arid <= 4'b0000;
    else if(Rcur==`RINIT && Rnxt==`RDATA)
        arid <= 4'b0001;
end

always@(posedge clk)
begin
    if(Rcur==`RINIT && Rnxt==`RINST)
        araddr <= inst_addr;
    else if(Rcur==`RINIT && Rnxt==`RDATA)
        araddr <= data_addr;
    else if(Rcur==`REND)
        araddr <= 32'd0;
end

assign arlen = 8'b00000000;

always@(posedge clk)
begin
    if(Rcur==`RINIT && Rnxt==`RINST)
        arsize <= {inst_size, {!(inst_size[0]|inst_size[1])}};
    else if(Rcur==`RINIT && Rnxt==`RDATA)
        arsize <= {data_size, {!(data_size[0]|data_size[1])}};
end

assign arburst = 2'b01;
assign arlock  = 2'b00;
assign arcache = 4'b0000;
assign arprot  = 3'b000;

always@(posedge clk)
begin
    if(~resetn)
        arvalid <= 1'b0;
    else if((Rcur==`RINIT && Rnxt==`RINST) || (Rcur==`RDATA && Rnxt==`RVALID))
        arvalid <= 1'b1;
    else if(arready)
        arvalid <= 1'b0;
end

//==========| AXI R |==========
always@(posedge clk)
begin
    if(~resetn)
        rvalid_r <= 1'b0;
    else if(Wcur==`WEND && Wnxt==`WINIT && Rcur==`REND && Rnxt==`RINIT && rid==4'b0001)
        rvalid_r <= 1'b1;
    else
        rvalid_r <= 1'b0;
end

always@(posedge clk)
begin
    if(~resetn)
        rready <= 1'b1;
    else if(Rnxt==`RINST || Rnxt==`RDATA)
        rready <= 1'b1;
    else if(rvalid)
        rready <= 1'b0;
end

//==========| AXI AW |==========
assign awid = 4'b0001;

always@(posedge clk)
begin
    if(~resetn)
        awaddr_r <= 32'd0;
    else if(data_req && data_wr && Wcur==`WINIT)
        awaddr_r <= data_addr;
    else if(bvalid)
        awaddr_r <= 32'd0;
end

always@(posedge clk)
begin
    if(Wcur==`WINIT && Wnxt==`WINST)
        awaddr <= inst_addr;
    else if(Wcur==`WINIT && Wnxt==`WDATA)
        awaddr <= data_addr;
end

assign awlen = 8'b00000000 ;

always@(posedge clk)
begin
    if(Wcur==`WINIT && Wnxt==`WINST)
        awsize <= {inst_size, {!(inst_size[0]|inst_size[1])}};
    else if(Wcur==`WINIT && Wnxt==`WDATA)
        awsize <= {inst_size, {!(data_size[0]|data_size[1])}};
end

assign awburst = 2'b01;
assign awlock  = 2'b00;
assign awcache = 4'b0000;
assign awprot  = 3'b000;

always@(posedge clk)
begin
    if(~resetn)
        awvalid <= 1'b0;
    else if(Wcur==`WINIT && (Wnxt==`WINST || Wnxt==`WDATA))
        awvalid <= 1'b1;
    else if(awready)
        awvalid <= 1'b0;
end

//==========| AXI W |==========
assign wid = 4'b0001;

always@(posedge clk)
begin
    if(Wcur==`WINIT && Wnxt==`WINST)
        wdata <= inst_wdata;
    else if(Wcur==`WINIT && Wnxt==`WDATA)
        wdata <= data_wdata;
end

always@(posedge clk)
begin
    if(Wcur==`WINIT && Wnxt==`WINST)
        wstrb <= (inst_size==2'b00 && inst_addr[1:0]==2'b00) ? 4'b0001 :
                 (inst_size==2'b00 && inst_addr[1:0]==2'b01) ? 4'b0010 :
                 (inst_size==2'b00 && inst_addr[1:0]==2'b10) ? 4'b0100 :
                 (inst_size==2'b00 && inst_addr[1:0]==2'b11) ? 4'b1000 :
                 (inst_size==2'b01 && inst_addr[1:0]==2'b00) ? 4'b0011 :
                 (inst_size==2'b01 && inst_addr[1:0]==2'b10) ? 4'b1100 :
                                                               4'b1111 ;
    else if(Wcur==`WINIT && Wnxt==`WDATA)
        wstrb <= (data_size==2'b00 && data_addr[1:0]==2'b00) ? 4'b0001 :
                 (data_size==2'b00 && data_addr[1:0]==2'b01) ? 4'b0010 :
                 (data_size==2'b00 && data_addr[1:0]==2'b10) ? 4'b0100 :
                 (data_size==2'b00 && data_addr[1:0]==2'b11) ? 4'b1000 :
                 (data_size==2'b01 && data_addr[1:0]==2'b00) ? 4'b0011 :
                 (data_size==2'b01 && data_addr[1:0]==2'b10) ? 4'b1100 :
                                                               4'b1111 ;
end

assign wlast = 1'b1;

always@(posedge clk)
begin
    if(~resetn)
        wvalid <= 1'b0;
    else if(Wcur==`WINIT && (Wnxt==`WINST || Wnxt==`WDATA))
        wvalid <= 1'b1;
    else if(wready)
        wvalid <= 1'b0;
end

//==========| AXI B |==========
always@(posedge clk)
begin
    if(~resetn)
        bready <= 1'b0;
    else if(Wnxt==`WINST || Wnxt==`WDATA)
        bready <= 1'b1;
    else if(bvalid)
        bready <= 1'b0;
end

endmodule