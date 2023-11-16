//  by CrazyBird
module axi4_ctrl
(
    input  wire                 axi_clk         ,
    input  wire                 axi_reset       ,
    
    output reg      [ 7:0]      axi_aid         ,
    output reg      [31:0]      axi_aaddr       ,
    output reg      [ 7:0]      axi_alen        ,
    output reg      [ 2:0]      axi_asize       ,
    output reg      [ 1:0]      axi_aburst      ,
    output reg      [ 1:0]      axi_alock       ,
    output reg                  axi_avalid      ,
    input  wire                 axi_aready      ,
    output reg                  axi_atype       ,
    
    output reg      [  7:0]     axi_wid         ,
    output reg      [127:0]     axi_wdata       ,
    output reg      [ 15:0]     axi_wstrb       ,
    output reg                  axi_wlast       ,
    output reg                  axi_wvalid      ,
    input  wire                 axi_wready      ,
    
    input  wire     [  7:0]     axi_bid         ,
    input  wire                 axi_bvalid      ,
    output reg                  axi_bready      ,
    
    input  wire     [  7:0]     axi_rid         ,
    input  wire     [127:0]     axi_rdata       ,
    input  wire                 axi_rlast       ,
    input  wire                 axi_rvalid      ,
    output reg                  axi_rready      ,
    input  wire     [  1:0]     axi_rresp       ,
    
    input  wire                 wframe_pclk     ,
    input  wire                 wframe_vsync    ,
    input  wire                 wframe_data_en  ,
    input  wire     [  7:0]     wframe_data     ,
    
    input  wire                 rframe_pclk     ,
    input  wire                 rframe_vsync    ,
    input  wire                 rframe_data_en  ,
    output wire     [  7:0]     rframe_data     
);
//----------------------------------------------------------------------
parameter C_BURST_LEN = 64;
parameter C_ADDR_INC  = C_BURST_LEN * 16;

parameter ADDR_STOP = 1024*600 - C_ADDR_INC;

//----------------------------------------------------------------------
always @(posedge axi_clk)
begin
    axi_aid    <= 8'b0;
    axi_alen   <= C_BURST_LEN - 1'b1;
    axi_asize  <= 3'b100;
    axi_aburst <= 2'b01;
    axi_alock  <= 1'b0;
    axi_wid    <= 8'b0;
    axi_wstrb  <= 16'hffff;
end

//----------------------------------------------------------------------
reg             [3:0]           wframe_vsync_dly;
reg             [3:0]           rframe_vsync_dly;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
    begin
        wframe_vsync_dly <= 4'b0;
        rframe_vsync_dly <= 4'b0;
    end
    else
    begin
        wframe_vsync_dly <= {wframe_vsync_dly[2:0],wframe_vsync};
        rframe_vsync_dly <= {rframe_vsync_dly[2:0],rframe_vsync};
    end
end

reg             [4:0]           wfifo_cnt;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        wfifo_cnt <= 5'h1f;
    else
    begin
        if(wframe_vsync_dly[3:2] == 2'b01)
            wfifo_cnt <= 5'h1f;
        else if(wfifo_cnt > 5'd0)
            wfifo_cnt <= wfifo_cnt - 1'b1;
        else
            wfifo_cnt <= 5'b0;
    end
end

reg                             wfifo_rst;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        wfifo_rst <= 1'b1;
    else
    begin
        if(wfifo_cnt == 5'b0)
            wfifo_rst <= 1'b0;
        else
            wfifo_rst <= 1'b1;
    end
end

//----------------------------------------------------------------------
wire                            wfifo_full;
wire                            wfifo_empty;
wire            [127:0]         wfifo_rdata;
wire                            wfifo_renb;
wire            [ 11:0]         wfifo_rcnt;

W0_FIFO u_W0_FIFO
(
    .full_o         (wfifo_full     ),
    .empty_o        (wfifo_empty    ),
    .rdata          (wfifo_rdata    ),
    .wr_clk_i       (wframe_pclk    ),
    .rd_clk_i       (axi_clk        ),
    .wr_en_i        (wframe_data_en ),
    .rd_en_i        (wfifo_renb     ),
    .a_rst_i        (axi_reset      ),
    .wdata          (wframe_data    ),
    .wr_datacount_o (               ),
    .rd_datacount_o (wfifo_rcnt     ),
    .rst_busy       (               )
);

wire                            rfifo_full;
wire                            rfifo_empty;
reg                             rfifo_wenb;
reg             [127:0]         rfifo_wdata;
wire            [  7:0]         rfifo_wcnt;

R0_FIFO u_R0_FIFO
(
    .full_o         (rfifo_full     ),
    .empty_o        (rfifo_empty    ),
    .rdata          (rframe_data    ),
    .wr_clk_i       (axi_clk        ),
    .rd_clk_i       (rframe_pclk    ),
    .wr_en_i        (rfifo_wenb     ),
    .rd_en_i        (rframe_data_en ),
    .a_rst_i        (axi_reset      ),
    .wdata          (rfifo_wdata    ),
    .wr_datacount_o (rfifo_wcnt     ),
    .rd_datacount_o (               ),
    .rst_busy       (               )
);

//----------------------------------------------------------------------
reg             [1:0]               wframe_index;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        wframe_index <= 2'b0;
    else
    begin
        if(wframe_vsync_dly[3:2] == 2'b10)
        begin
            if(wframe_index < 2'd2)
                wframe_index <= wframe_index + 1'b1;
            else
                wframe_index <= 2'b0;
        end
        else
            wframe_index <= wframe_index;
    end
end

reg             [1:0]               rframe_index;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        rframe_index <= 2'd2;
    else
    begin
        if(rframe_vsync_dly[3:2] == 2'b10)
        begin
            if(wframe_index == 2'd0)
                rframe_index <= 2'd2;
            else
                rframe_index <= wframe_index - 1'b1;
        end
        else
            rframe_index <= rframe_index;
    end
end

//----------------------------------------------------------------------
localparam S_IDLE         = 3'd0;
localparam S_WRITE_ADDR   = 3'd1;
localparam S_WRITE_DATA   = 3'd2;
localparam S_WRITE_BVALID = 3'd3;
localparam S_READ_ADDR    = 3'd4;
localparam S_READ_DATA    = 3'd5;

reg             [2:0]           state;
reg             [8:0]           wdata_cnt;
reg             [8:0]           rdata_cnt;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        state <= S_IDLE;
    else
    begin
        case(state)
            S_IDLE : 
            begin
                if(rfifo_wcnt <= C_BURST_LEN)
                    state <= S_READ_ADDR;
                else if(wfifo_rcnt >= C_BURST_LEN)
                    state <= S_WRITE_ADDR;
                else
                    state <= S_IDLE;
            end
            S_WRITE_ADDR : 
            begin
                if((axi_avalid == 1'b1)&&(axi_aready == 1'b1))
                    state <= S_WRITE_DATA;
                else
                    state <= S_WRITE_ADDR;
            end
            S_WRITE_DATA : 
            begin
                if((axi_wvalid == 1'b1)&&(axi_wready == 1'b1)&&(wdata_cnt == C_BURST_LEN))
                    state <= S_WRITE_BVALID;
                else
                    state <= S_WRITE_DATA;
            end
            S_WRITE_BVALID : 
            begin
                if((axi_bvalid == 1'b1)&&(axi_bready == 1'b1))
                    state <= S_IDLE;
                else
                    state <= S_WRITE_BVALID;
            end
            S_READ_ADDR : 
            begin
                if((axi_avalid == 1'b1)&&(axi_aready == 1'b1))
                    state <= S_READ_DATA;
                else
                    state <= S_READ_ADDR;
            end
            S_READ_DATA : 
            begin
                if((axi_rvalid == 1'b1)&&(axi_rready == 1'b1)&&(rdata_cnt == C_BURST_LEN))
                    state <= S_IDLE;
                else
                    state <= S_READ_DATA;
            end
            default : 
            begin
                state <= S_IDLE;
            end
        endcase
    end
end

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        axi_atype <= 1'b0;
    else
    begin
        if((state == S_IDLE)&&(rfifo_wcnt <= C_BURST_LEN))
            axi_atype <= 1'b0;
        else if((state == S_IDLE)&&(wfifo_rcnt >= C_BURST_LEN))
            axi_atype <= 1'b1;
        else
            axi_atype <= axi_atype;
    end
end

reg             [23:0]          awaddr;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        awaddr <= 24'b0;
    else
    begin
        if(wframe_vsync_dly[3:2] == 2'b01)
//        if(awaddr == ADDR_STOP)
            awaddr <= 24'b0;
        else if((axi_bvalid == 1'b1)&&(axi_bready == 1'b1))
            awaddr <= awaddr + C_ADDR_INC;
        else
            awaddr <= awaddr;
    end
end

reg             [23:0]          araddr;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        araddr <= 24'b0;
    else
    begin
        if(rframe_vsync_dly[3:2] == 2'b01)
//        if(araddr == ADDR_STOP)
            araddr <= 24'b0;
        else if((axi_rvalid == 1'b1)&&(axi_rready == 1'b1)&&(rdata_cnt == C_BURST_LEN))
            araddr <= araddr + C_ADDR_INC;
        else
            araddr <= araddr;
    end
end

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        axi_aaddr <= 32'b0;
    else
    begin
        if((state == S_IDLE)&&(rfifo_wcnt <= C_BURST_LEN))
            axi_aaddr <= {rframe_index,araddr};
        else if((state == S_IDLE)&&(wfifo_rcnt >= C_BURST_LEN))
            axi_aaddr <= {wframe_index,awaddr};
        else 
            axi_aaddr <= axi_aaddr;
    end
end

always @(*)
begin
    if((state == S_WRITE_ADDR)||(state == S_READ_ADDR))
        axi_avalid = 1'b1;
    else
        axi_avalid = 1'b0;
end

reg             [8:0]           wdata_cnt_dly;

always @(posedge axi_clk)
begin
    wdata_cnt_dly <= wdata_cnt;
end

always @(*)
begin
    if(state == S_WRITE_DATA)
        begin
        if((axi_wvalid == 1'b1)&&(axi_wready == 1'b1))
            wdata_cnt = wdata_cnt_dly + 1'b1;
        else
            wdata_cnt = wdata_cnt_dly;
        end
    else
        wdata_cnt = 9'b0;
end

always @(*)
begin
    axi_wdata = wfifo_rdata;
end

always @(*)
begin
    if(state == S_WRITE_DATA)
        axi_wvalid = 1'b1;
    else
        axi_wvalid = 1'b0;
end

always @(*)
begin
    if((state == S_WRITE_DATA)&&(wdata_cnt == C_BURST_LEN))
        axi_wlast = 1'b1;
    else
        axi_wlast = 1'b0;
end

assign wfifo_renb = (axi_wvalid & axi_wready) ? 1'b1 : 1'b0;

always @(*)
begin
    if((state == S_WRITE_BVALID)||(state == S_WRITE_DATA))
        axi_bready = 1'b1;
    else
        axi_bready = 1'b0;
end

reg             [8:0]           rdata_cnt_dly;

always @(posedge axi_clk)
begin
    rdata_cnt_dly <= rdata_cnt;
end

always @(*)
begin
    if(state == S_READ_DATA)
        begin
        if((axi_rvalid == 1'b1)&&(axi_rready == 1'b1))
            rdata_cnt = rdata_cnt_dly + 1'b1;
        else
            rdata_cnt = rdata_cnt_dly;
        end
    else
        rdata_cnt = 9'b0;
end

always @(*)
begin
    if(state == S_READ_DATA)
        axi_rready = 1'b1;
    else
        axi_rready = 1'b0;
end

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        rfifo_wenb <= 1'b0;
    else
    begin
        if((axi_rvalid == 1'b1)&&(axi_rready == 1'b1))
            rfifo_wenb <= 1'b1;
        else
            rfifo_wenb <= 1'b0;
    end
end

always @(posedge axi_clk)
begin
    rfifo_wdata <= axi_rdata;
end

endmodule


/*
module axi4_ctrl
(
    input  wire                 axi_clk         ,
    input  wire                 axi_reset       ,
    
    output reg      [ 7:0]      axi_aid         ,
    output reg      [31:0]      axi_aaddr       ,
    output reg      [ 7:0]      axi_alen        ,
    output reg      [ 2:0]      axi_asize       ,
    output reg      [ 1:0]      axi_aburst      ,
    output reg      [ 1:0]      axi_alock       ,
    output reg                  axi_avalid      ,
    input  wire                 axi_aready      ,
    output reg                  axi_atype       ,
    
    output reg      [  7:0]     axi_wid         ,
    output reg      [127:0]     axi_wdata       ,
    output reg      [ 15:0]     axi_wstrb       ,
    output reg                  axi_wlast       ,
    output reg                  axi_wvalid      ,
    input  wire                 axi_wready      ,
    
    input  wire     [  7:0]     axi_bid         ,
    input  wire                 axi_bvalid      ,
    output reg                  axi_bready      ,
    
    input  wire     [  7:0]     axi_rid         ,
    input  wire     [127:0]     axi_rdata       ,
    input  wire                 axi_rlast       ,
    input  wire                 axi_rvalid      ,
    output reg                  axi_rready      ,
    input  wire     [  1:0]     axi_rresp       ,
    
    input  wire                 wframe_pclk     ,
    input  wire                 wframe_vsync    ,
    input  wire                 wframe_data_en  ,
    input  wire     [  7:0]     wframe_data     ,
    
    input  wire                 rframe_pclk     ,
    input  wire                 rframe_vsync    ,
    input  wire                 rframe_data_en  ,
    output wire     [  7:0]     rframe_data     
);
//----------------------------------------------------------------------
parameter C_BURST_LEN = 64;
parameter C_ADDR_INC  = C_BURST_LEN * 16;

parameter ADDR_STOP = 1024*600 - 64*16;

//----------------------------------------------------------------------
always @(posedge axi_clk)
begin
    axi_aid    <= 8'b0;
    axi_alen   <= C_BURST_LEN - 1'b1;
    axi_asize  <= 3'b100;
    axi_aburst <= 2'b01;
    axi_alock  <= 1'b0;
    axi_wid    <= 8'b0;
    axi_wstrb  <= 16'hffff;
end

//----------------------------------------------------------------------
reg             [3:0]           wframe_vsync_dly;
reg             [3:0]           rframe_vsync_dly;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
    begin
        wframe_vsync_dly <= 4'b0;
        rframe_vsync_dly <= 4'b0;
    end
    else
    begin
        wframe_vsync_dly <= {wframe_vsync_dly[2:0],wframe_vsync};
        rframe_vsync_dly <= {rframe_vsync_dly[2:0],rframe_vsync};
    end
end

reg             [4:0]           wfifo_cnt;



always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        wfifo_cnt <= 5'h1f;
    else
    begin
//        if(wframe_vsync_dly[3:2] == 2'b01)
        if(awaddr == ADDR_STOP)
            wfifo_cnt <= 5'h1f;
        else if(wfifo_cnt > 5'd0)
            wfifo_cnt <= wfifo_cnt - 1'b1;
        else
            wfifo_cnt <= 5'b0;
    end
end

reg                             wfifo_rst;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        wfifo_rst <= 1'b1;
    else
    begin
        if(wfifo_cnt == 5'b0)
            wfifo_rst <= 1'b0;
        else
            wfifo_rst <= 1'b1;
    end
end

//----------------------------------------------------------------------
wire                            wfifo_full;
wire                            wfifo_empty;
wire            [127:0]         wfifo_rdata;
wire                            wfifo_renb;
wire            [ 11:0]         wfifo_rcnt;

W0_FIFO u_W0_FIFO
(
    .full_o         (wfifo_full     ),
    .empty_o        (wfifo_empty    ),
    .rdata          (wfifo_rdata    ),
    .wr_clk_i       (wframe_pclk    ),
    .rd_clk_i       (axi_clk        ),
    .wr_en_i        (wframe_data_en ),
    .rd_en_i        (wfifo_renb     ),
    .a_rst_i        (wfifo_rst      ),
    .wdata          (wframe_data    ),
    .wr_datacount_o (               ),
    .rd_datacount_o (wfifo_rcnt     ),
    .rst_busy       (               )
);

wire                            rfifo_full;
wire                            rfifo_empty;
reg                             rfifo_wenb;
reg             [127:0]         rfifo_wdata;
wire            [  7:0]         rfifo_wcnt;

R0_FIFO u_R0_FIFO
(
    .full_o         (rfifo_full     ),
    .empty_o        (rfifo_empty    ),
    .rdata          (rframe_data    ),
    .wr_clk_i       (axi_clk        ),
    .rd_clk_i       (rframe_pclk    ),
    .wr_en_i        (rfifo_wenb     ),
    .rd_en_i        (rframe_data_en ),
    .a_rst_i        (axi_reset      ),
    .wdata          (rfifo_wdata    ),
    .wr_datacount_o (rfifo_wcnt     ),
    .rd_datacount_o (               ),
    .rst_busy       (               )
);

//----------------------------------------------------------------------
reg             [1:0]               wframe_index;

reg             [1:0]   vs_cnt;

always @(posedge axi_clk) begin
    if (axi_reset) begin
        vs_cnt <= 'd0;
    end
    else if (vs_cnt == 'd3) begin
        vs_cnt <= 'd0;
    end
    else if (awaddr == ADDR_STOP) begin
        vs_cnt <= vs_cnt + 1'b1;
    end
end

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        wframe_index <= 2'b0;
    else
    begin
        if(vs_cnt == 'd3)
        begin
            if(wframe_index < 2'd2)
                wframe_index <= wframe_index + 1'b1;
            else
                wframe_index <= 2'b0;
        end
        else
            wframe_index <= wframe_index;
    end
end

reg             [1:0]               rframe_index;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        rframe_index <= 2'd2;
    else
    begin
        if(rframe_vsync_dly[3:2] == 2'b10)
        begin
            if(wframe_index == 2'd0)
                rframe_index <= 2'd2;
            else
                rframe_index <= wframe_index - 1'b1;
        end
        else
            rframe_index <= rframe_index;
    end
end

//----------------------------------------------------------------------
localparam S_IDLE         = 3'd0;
localparam S_WRITE_ADDR   = 3'd1;
localparam S_WRITE_DATA   = 3'd2;
localparam S_WRITE_BVALID = 3'd3;
localparam S_READ_ADDR    = 3'd4;
localparam S_READ_DATA    = 3'd5;

reg             [2:0]           state;
reg             [8:0]           wdata_cnt;
reg             [8:0]           rdata_cnt;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        state <= S_IDLE;
    else
    begin
        case(state)
            S_IDLE : 
            begin
                if(rfifo_wcnt <= C_BURST_LEN)
                    state <= S_READ_ADDR;
                else if(wfifo_rcnt >= C_BURST_LEN)
                    state <= S_WRITE_ADDR;
                else
                    state <= S_IDLE;
            end
            S_WRITE_ADDR : 
            begin
                if((axi_avalid == 1'b1)&&(axi_aready == 1'b1))
                    state <= S_WRITE_DATA;
                else
                    state <= S_WRITE_ADDR;
            end
            S_WRITE_DATA : 
            begin
                if((axi_wvalid == 1'b1)&&(axi_wready == 1'b1)&&(wdata_cnt == C_BURST_LEN))
                    state <= S_WRITE_BVALID;
                else
                    state <= S_WRITE_DATA;
            end
            S_WRITE_BVALID : 
            begin
                if((axi_bvalid == 1'b1)&&(axi_bready == 1'b1))
                    state <= S_IDLE;
                else
                    state <= S_WRITE_BVALID;
            end
            S_READ_ADDR : 
            begin
                if((axi_avalid == 1'b1)&&(axi_aready == 1'b1))
                    state <= S_READ_DATA;
                else
                    state <= S_READ_ADDR;
            end
            S_READ_DATA : 
            begin
                if((axi_rvalid == 1'b1)&&(axi_rready == 1'b1)&&(rdata_cnt == C_BURST_LEN))
                    state <= S_IDLE;
                else
                    state <= S_READ_DATA;
            end
            default : 
            begin
                state <= S_IDLE;
            end
        endcase
    end
end

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        axi_atype <= 1'b0;
    else
    begin
        if((state == S_IDLE)&&(rfifo_wcnt <= C_BURST_LEN))
            axi_atype <= 1'b0;
        else if((state == S_IDLE)&&(wfifo_rcnt >= C_BURST_LEN))
            axi_atype <= 1'b1;
        else
            axi_atype <= axi_atype;
    end
end

reg             [23:0]          awaddr;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        awaddr <= 24'b0;
    else
    begin
//        if(wframe_vsync_dly[3:2] == 2'b01)
          if(awaddr == ADDR_STOP)
            awaddr <= 24'b0;
        else if((axi_bvalid == 1'b1)&&(axi_bready == 1'b1))
            awaddr <= awaddr + C_ADDR_INC;
        else
            awaddr <= awaddr;
    end
end

reg             [23:0]          araddr;

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        araddr <= 24'b0;
    else
    begin
        if(rframe_vsync_dly[3:2] == 2'b01)
            araddr <= 24'b0;
        else if((axi_rvalid == 1'b1)&&(axi_rready == 1'b1)&&(rdata_cnt == C_BURST_LEN))
            araddr <= araddr + C_ADDR_INC;
        else
            araddr <= araddr;
    end
end

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        axi_aaddr <= 32'b0;
    else
    begin
        if((state == S_IDLE)&&(rfifo_wcnt <= C_BURST_LEN))
            axi_aaddr <= {rframe_index,araddr};
        else if((state == S_IDLE)&&(wfifo_rcnt >= C_BURST_LEN))
            axi_aaddr <= {wframe_index,awaddr};
        else 
            axi_aaddr <= axi_aaddr;
    end
end

always @(*)
begin
    if((state == S_WRITE_ADDR)||(state == S_READ_ADDR))
        axi_avalid = 1'b1;
    else
        axi_avalid = 1'b0;
end

reg             [8:0]           wdata_cnt_dly;

always @(posedge axi_clk)
begin
    wdata_cnt_dly <= wdata_cnt;
end

always @(*)
begin
    if(state == S_WRITE_DATA)
        begin
        if((axi_wvalid == 1'b1)&&(axi_wready == 1'b1))
            wdata_cnt = wdata_cnt_dly + 1'b1;
        else
            wdata_cnt = wdata_cnt_dly;
        end
    else
        wdata_cnt = 9'b0;
end

always @(*)
begin
    axi_wdata = wfifo_rdata;
end

always @(*)
begin
    if(state == S_WRITE_DATA)
        axi_wvalid = 1'b1;
    else
        axi_wvalid = 1'b0;
end

always @(*)
begin
    if((state == S_WRITE_DATA)&&(wdata_cnt == C_BURST_LEN))
        axi_wlast = 1'b1;
    else
        axi_wlast = 1'b0;
end

assign wfifo_renb = (axi_wvalid & axi_wready) ? 1'b1 : 1'b0;

always @(*)
begin
    if((state == S_WRITE_BVALID)||(state == S_WRITE_DATA))
        axi_bready = 1'b1;
    else
        axi_bready = 1'b0;
end

reg             [8:0]           rdata_cnt_dly;

always @(posedge axi_clk)
begin
    rdata_cnt_dly <= rdata_cnt;
end

always @(*)
begin
    if(state == S_READ_DATA)
        begin
        if((axi_rvalid == 1'b1)&&(axi_rready == 1'b1))
            rdata_cnt = rdata_cnt_dly + 1'b1;
        else
            rdata_cnt = rdata_cnt_dly;
        end
    else
        rdata_cnt = 9'b0;
end

always @(*)
begin
    if(state == S_READ_DATA)
        axi_rready = 1'b1;
    else
        axi_rready = 1'b0;
end

always @(posedge axi_clk)
begin
    if(axi_reset == 1'b1)
        rfifo_wenb <= 1'b0;
    else
    begin
        if((axi_rvalid == 1'b1)&&(axi_rready == 1'b1))
            rfifo_wenb <= 1'b1;
        else
            rfifo_wenb <= 1'b0;
    end
end

always @(posedge axi_clk)
begin
    rfifo_wdata <= axi_rdata;
end

endmodule
*/