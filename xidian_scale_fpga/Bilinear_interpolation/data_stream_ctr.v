module data_stream_ctr
                          #(parameter ADJUST_MODE = 0,
                            parameter BRAM_DEEPTH = 4096,
                            parameter DATA_WIDTH  = 8,
                            parameter INDEX_WIDTH = 16,
                            parameter INT_WIDTH   = 8,   // <= INDEX_WIDTH
                            parameter FIX_WIDTH   = 12)
                          (
                           input                            clk_i,
                           input                            rst_i,
                           
                           input                            tvalid_i,
                           input[DATA_WIDTH-1:0]            tdata_i,//image stream
                           output                           tready_o,
                           
                           
                           input[15 : 0]                    src_width_i,//
                           input[15 : 0]                    src_height_i,//
                           input[15 : 0]                    dest_width_i,//
                           input[15 : 0]                    dest_height_i,//
                                                     
                           
                           input[INDEX_WIDTH-1:0]           srcx_int_i,//addr width
                           input[INDEX_WIDTH-1:0]           srcy_int_i,//addr height                                                     
         
                           output[INDEX_WIDTH-1:0]          destx_o,//current x location
                           output[INDEX_WIDTH-1:0]          desty_o,//current y location
         
                           input[INT_WIDTH + FIX_WIDTH-1:0] scale_factorx_i,//srcx_width/destx_width
                           input[INT_WIDTH + FIX_WIDTH-1:0] scale_factory_i,//srcy_height/desty_height

                           output                           tvalid_o,
                           output[DATA_WIDTH-1:0]           tdata00_o,//
                           output[DATA_WIDTH-1:0]           tdata01_o,// 
                           output[DATA_WIDTH-1:0]           tdata10_o,//
                           output[DATA_WIDTH-1:0]           tdata11_o //                                                             
                           );
                           
function integer clogb2 (input integer bit_depth);              
  begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
      bit_depth = bit_depth >> 1;                                 
  end                                                           
endfunction                       
                      
                   
localparam BRAM_ADDR_WIDTH  = clogb2(BRAM_DEEPTH - 1);
localparam BRAM_DATA_WIDTH  = DATA_WIDTH;
localparam BRAM_MEMORY_SIZE = BRAM_DEEPTH * BRAM_DATA_WIDTH;                           
                           
                                                      
reg[15:0] w_row_pixel_cnt;
always@(posedge clk_i)begin
  if(rst_i)begin
    w_row_pixel_cnt <= 16'd0;
  end else begin
    if((w_row_pixel_cnt == src_width_i -1) & tvalid_i)begin
      w_row_pixel_cnt <= 16'd0;
    end else if(tvalid_i) begin
      w_row_pixel_cnt <= w_row_pixel_cnt + 16'd1;
    end
  end
end

wire w_image_tlast;//image row end;
assign w_image_tlast = (w_row_pixel_cnt == src_width_i -1) & tvalid_i;

reg[15:0] w_row_cnt;
always@(posedge clk_i)begin
  if(rst_i)begin
    w_row_cnt <= 16'd0;
  end else begin
    if(scaler_done)begin  //
      w_row_cnt <= 16'd0;
    end else if(w_image_tlast) begin
      w_row_cnt <= w_row_cnt + 16'd1;
    end else begin
      w_row_cnt <= w_row_cnt;
    end
  end
end

reg[15:0] w_addra;
always@(posedge clk_i)begin
  if(rst_i)begin
    w_addra <= 16'd0;
  end else begin
    if((w_addra == {src_width_i,1'b0} - 1) & tvalid_i)begin
      w_addra <= 16'd0;
    end else if(tvalid_i) begin
      w_addra <= w_addra + 16'd1;
    end
  end
end

wire[DATA_WIDTH-1:0] w_dina;
assign w_dina = tdata_i;

wire[DATA_WIDTH-1:0] w_dinb;
assign w_dinb = tdata_i;

wire w_ena;
assign w_ena = tvalid_i;


//----------------------read----------------

reg[2:0] scaler_st;
reg[1:0] delay_cnt;
always@(posedge clk_i)begin
  if(rst_i)begin
    scaler_st <= 'd0;
    delay_cnt <= 'd0;
  end else begin
    case(scaler_st)
    0:begin
      delay_cnt <= 0;
      if(w_row_cnt > srcy_int_i + 1 || (srcy_int_i == src_height_i - 1))begin //
        scaler_st <= 'd1;
      end else begin
        scaler_st <= 'd0;
      end    
    end
       
    1:begin
      if(r_row_pixel_cnt == dest_width_i - 1)begin //one line end
        scaler_st <= 'd2;
      end else begin
        scaler_st <= 'd1;
      end    
    end
       
    2:begin
      if(r_row_cnt == 0)begin//read last row done 
        scaler_st <= 'd4;
      end else begin
        scaler_st <= 'd3;
      end    
    end
    
    3:begin
      delay_cnt <= delay_cnt + 1;
      if(delay_cnt == 2)begin 
        scaler_st <= 'd0;
      end else begin
        scaler_st <= 'd3;
      end        
    end    
    
    4:begin
      if(scale_factory_i[INT_WIDTH + FIX_WIDTH - 1 : FIX_WIDTH])begin//scaler down 
        scaler_st <= 'd5;
      end else begin
        scaler_st <= 'd6;
      end
    end 
      
    5:begin
      if(w_row_cnt == src_height_i)begin 
        scaler_st <= 'd6;
      end else begin
        scaler_st <= 'd5;
      end         
    end   

    6:begin
      scaler_st <= 'd7;        
    end
    
    7:begin
      scaler_st <= 'd0;        
    end    
                               
    endcase
  end
end

wire scaler_done;
assign scaler_done = &scaler_st;

wire scaler_valid;
assign scaler_valid = (scaler_st == 1) ? 1 : 0; 
 
reg[15:0] r_row_pixel_cnt;
always@(posedge clk_i)begin
  if(rst_i)begin
    r_row_pixel_cnt <= 16'd0;
  end else begin
    if((r_row_pixel_cnt == dest_width_i -1) & scaler_valid)begin
      r_row_pixel_cnt <= 16'd0;
    end else if(scaler_valid) begin
      r_row_pixel_cnt <= r_row_pixel_cnt + 16'd1;
    end
  end
end

wire r_image_tlast;//image row end;
assign r_image_tlast = (r_row_pixel_cnt == dest_width_i -1) & scaler_valid;


reg[15:0] r_row_cnt;
always@(posedge clk_i)begin
  if(rst_i)begin
    r_row_cnt <= 16'd0;
  end else begin
    if((r_row_cnt == dest_height_i -1) & r_image_tlast)begin  //
      r_row_cnt <= 16'd0;
    end else if(r_image_tlast) begin
      r_row_cnt <= r_row_cnt + 16'd1;
    end else begin
      r_row_cnt <= r_row_cnt;
    end
  end
end


reg[15:0] r_addrb00 = 16'hffff;
reg[15:0] r_addrb01 = 16'hffff;
reg[15:0] r_addrb10 = 16'hffff;
reg[15:0] r_addrb11 = 16'hffff;
always@(posedge clk_i)begin
  if(srcy_int_i[0])begin//start of odd line
    if(srcx_int_i == src_width_i - 1)begin//last pixel in line
      r_addrb00 <= src_width_i + srcx_int_i - 1;
      r_addrb01 <= src_width_i + srcx_int_i;
      r_addrb10 <= srcx_int_i - 1;
      r_addrb11 <= srcx_int_i;
    end else begin
      r_addrb00 <= src_width_i + srcx_int_i;
      r_addrb01 <= src_width_i + srcx_int_i + 1;
      r_addrb10 <= srcx_int_i;
      r_addrb11 <= srcx_int_i + 1;    
    end
  end else begin
    if(srcx_int_i == src_width_i - 1)begin  
      r_addrb00 <= srcx_int_i -1;
      r_addrb01 <= srcx_int_i;
      r_addrb10 <= src_width_i + srcx_int_i - 1;
      r_addrb11 <= src_width_i + srcx_int_i;
    end else begin
      r_addrb00 <= srcx_int_i;
      r_addrb01 <= srcx_int_i + 1;
      r_addrb10 <= src_width_i + srcx_int_i;
      r_addrb11 <= src_width_i + srcx_int_i + 1;    
    end
  end
end

//------------------------

reg[INDEX_WIDTH-1:0] destx = 0;//current x location
reg[INDEX_WIDTH-1:0] desty = 0;//current y location

always@(*)begin
  destx <= r_row_pixel_cnt;
  desty <= r_row_cnt;  
end

assign destx_o = destx;
assign desty_o = desty;

reg[7:0] scaler_valid_d;
always@(posedge clk_i)begin
  scaler_valid_d <= {scaler_valid_d[6:0],scaler_valid};
end

wire r_enb;
generate
  if(ADJUST_MODE == 0)begin//-------------normal mode: delay 1+2 clk-------------------------
                             
  assign tvalid_o = scaler_valid_d[3];
  assign r_enb    = scaler_valid_d[1];
  
  end else begin//---------------adjust mode: delay 3+2 clk-------------------------
  
  assign tvalid_o = scaler_valid_d[5];
  assign r_enb    = scaler_valid_d[3];
  
  end
endgenerate

wire[DATA_WIDTH -1:0] r_doutb00;
wire[DATA_WIDTH -1:0] r_doutb01;
wire[DATA_WIDTH -1:0] r_doutb10;
wire[DATA_WIDTH -1:0] r_doutb11;

reg[DATA_WIDTH -1:0] r_doutb00_d;
reg[DATA_WIDTH -1:0] r_doutb01_d;
reg[DATA_WIDTH -1:0] r_doutb10_d;
reg[DATA_WIDTH -1:0] r_doutb11_d;

always@(posedge clk_i)begin//sync to weight
  r_doutb00_d <= r_doutb00;
  r_doutb01_d <= r_doutb01;
  r_doutb10_d <= r_doutb10;
  r_doutb11_d <= r_doutb11;
end

assign tdata00_o = r_doutb00_d;
assign tdata01_o = r_doutb01_d;
assign tdata10_o = r_doutb10_d;
assign tdata11_o = r_doutb11_d;

wire wr_end;
assign wr_end = (w_row_cnt == src_height_i);

wire tready;
assign tready = (w_row_cnt < srcy_int_i + 2) ? 1: 0;
assign tready_o = tready  && (!wr_end); 

simple_dual_port_ram 
#(
  .DATA_WIDTH    (BRAM_DATA_WIDTH     ),
  .ADDR_WIDTH    (BRAM_ADDR_WIDTH     ),
  .OUTPUT_REG    ("FALSE"             ),
  .RAM_INIT_FILE ("ram_init_file.mem" )
)
u_simple_dual_port_ram00(
  .wdata (w_dina    ),
  .waddr (w_addra   ),
  .we    (w_ena     ),
  .wclk  (clk_i     ),
  .rclk  (clk_i     ),
  .re    (r_enb     ),
  .raddr (r_addrb00 ),
  .rdata (r_doutb00 )
);

                                               
simple_dual_port_ram 
#(
  .DATA_WIDTH    (BRAM_DATA_WIDTH     ),
  .ADDR_WIDTH    (BRAM_ADDR_WIDTH     ),
  .OUTPUT_REG    ("FALSE"             ),
  .RAM_INIT_FILE ("ram_init_file.mem" )
)
u_simple_dual_port_ram01(
  .wdata (w_dina    ),
  .waddr (w_addra   ),
  .we    (w_ena     ),
  .wclk  (clk_i     ),
  .rclk  (clk_i     ),
  .re    (r_enb     ),
  .raddr (r_addrb01 ),
  .rdata (r_doutb01 )
);
 
simple_dual_port_ram 
#(
  .DATA_WIDTH    (BRAM_DATA_WIDTH     ),
  .ADDR_WIDTH    (BRAM_ADDR_WIDTH     ),
  .OUTPUT_REG    ("FALSE"             ),
  .RAM_INIT_FILE ("ram_init_file.mem" )
)
u_simple_dual_port_ram10(
  .wdata (w_dina    ),
  .waddr (w_addra   ),
  .we    (w_ena     ),
  .wclk  (clk_i     ),
  .rclk  (clk_i     ),
  .re    (r_enb     ),
  .raddr (r_addrb10 ),
  .rdata (r_doutb10 )
);                             
     
simple_dual_port_ram 
#(
  .DATA_WIDTH    (BRAM_DATA_WIDTH     ),
  .ADDR_WIDTH    (BRAM_ADDR_WIDTH     ),
  .OUTPUT_REG    ("FALSE"             ),
  .RAM_INIT_FILE ("ram_init_file.mem" )
)
u_simple_dual_port_ram11(
  .wdata (w_dina    ),
  .waddr (w_addra   ),
  .we    (w_ena     ),
  .wclk  (clk_i     ),
  .rclk  (clk_i     ),
  .re    (r_enb     ),
  .raddr (r_addrb11 ),
  .rdata (r_doutb11 )
);                                             
   
endmodule