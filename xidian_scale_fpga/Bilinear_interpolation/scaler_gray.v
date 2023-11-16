module scaler_gray
                          #(parameter ADJUST_MODE = 1,
                            parameter BRAM_DEEPTH = 3840,//src_width_i * 2
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
         
                           input[INT_WIDTH + FIX_WIDTH-1:0] scale_factorx_i,//srcx_width/destx_width
                           input[INT_WIDTH + FIX_WIDTH-1:0] scale_factory_i,//srcy_height/desty_height
                           
                           output reg                          tvsync_o,
                           output                           tvalid_o,
                           output[DATA_WIDTH-1:0]           tdata_o //                                                             
                           );





wire[INDEX_WIDTH-1:0]  destx;
wire[INDEX_WIDTH-1:0]  desty;

wire[INDEX_WIDTH-1:0]  srcx_int;
wire[INDEX_WIDTH-1:0]  srcy_int;

wire                  tvalid ;
wire[DATA_WIDTH-1:0]  tdata00;
wire[DATA_WIDTH-1:0]  tdata01;
wire[DATA_WIDTH-1:0]  tdata10;
wire[DATA_WIDTH-1:0]  tdata11;

wire[4*DATA_WIDTH:0]  tdata_d;


data_stream_ctr
                          #(.ADJUST_MODE(ADJUST_MODE),
                            .BRAM_DEEPTH(BRAM_DEEPTH),
                            .DATA_WIDTH(DATA_WIDTH),
                            .INDEX_WIDTH(INDEX_WIDTH),
                            .INT_WIDTH(INT_WIDTH),   // <= INDEX_WIDTH
                            .FIX_WIDTH(FIX_WIDTH))
                            
                          u0_data_stream_ctr  
                          (
                           .clk_i(clk_i),
                           .rst_i(rst_i),
                           
                           .tvalid_i(tvalid_i),
                           .tdata_i(tdata_i),//image stream
                           .tready_o(tready_o),
                           
                           
                           .src_width_i(src_width_i),//
                           .src_height_i(src_height_i),//
                           .dest_width_i(dest_width_i),//
                           .dest_height_i(dest_height_i),//
                           
                           
                           .srcx_int_i(srcx_int),//addr width
                           .srcy_int_i(srcy_int),//addr height                                                     
                           
                           .destx_o(destx),//current x location
                           .desty_o(desty),//current y location
                           
                           .scale_factorx_i(scale_factorx_i),//srcx_width/destx_width
                           .scale_factory_i(scale_factory_i),//srcy_height/desty_height
                           
                           .tvalid_o(tvalid),
                           .tdata00_o(tdata00),//
                           .tdata01_o(tdata01),// 
                           .tdata10_o(tdata10),//
                           .tdata11_o(tdata11) //                                                             
                           );


reg [15:0]      vs_cnt;
reg             tvalid_o_r;
wire            neg_vld;
wire            pos_vld;

always @(posedge clk_i) begin
  tvalid_o_r <= tvalid_o;
end

assign neg_vld = tvalid_o_r & ~tvalid_o;
assign pos_vld = ~tvalid_o_r & tvalid_o;

always @(posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    vs_cnt <= 'd0;
  end
  else if (vs_cnt == 599 && neg_vld) begin
    vs_cnt <= 'd0;
  end
  else if (neg_vld) begin
    vs_cnt <= vs_cnt + 1'b1;
  end
end

always @(posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    tvsync_o <= 1'b0;
  end
  else if (vs_cnt == 0 && pos_vld) begin
    tvsync_o <= 1'b0;
  end
  else if (vs_cnt == 599 && neg_vld) begin
    tvsync_o <= 1'b1;
  end
end

bilinear_gray
                          #(.ADJUST_MODE(ADJUST_MODE),
                            .DATA_WIDTH(DATA_WIDTH),
                            .INDEX_WIDTH(INDEX_WIDTH),
                            .INT_WIDTH(INT_WIDTH),
                            .FIX_WIDTH(FIX_WIDTH))
                            
                          u1_bilinear_gray  
                          (
                           .clk_i(clk_i),
                           .rst_i(rst_i),
                           
                           .destx_i(destx),//current x location
                           .desty_i(desty),//current y location
                           
                           .scale_factorx_i(scale_factorx_i),//srcx_width/destx_width
                           .scale_factory_i(scale_factory_i),//srcy_height/desty_height
                           
                           .srcx_int_o(srcx_int),
                           .srcy_int_o(srcy_int),

                           .tvalid_i (tvalid),
                           .tdata00_i(tdata00),//left top
                           .tdata01_i(tdata01),//right top 
                           .tdata10_i(tdata10),//left down
                           .tdata11_i(tdata11),//right down   
                                                                       
                           .tvalid_o(tvalid_o),
                           .tdata_o(tdata_o)                                
                           );



endmodule
