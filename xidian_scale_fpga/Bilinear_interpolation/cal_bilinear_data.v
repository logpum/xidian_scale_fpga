module cal_bilinear_data
                        #(parameter DATA_WIDTH = 8,
                          parameter FIX_WIDTH  = 12
         
                        )
                        (
                         input                  clk_i,
                         input                  rst_i,
         
                         input                  tvalid_i,
                         input[DATA_WIDTH-1:0]  tdata00_i,//插值点左上角数据
                         input[DATA_WIDTH-1:0]  tdata01_i,//插值点右上角数据  
                         input[DATA_WIDTH-1:0]  tdata10_i,//插值点左下角数据
                         input[DATA_WIDTH-1:0]  tdata11_i,//插值点右下角数据
         
                         input[FIX_WIDTH -1:0]  weight00_i,//w00
                         input[FIX_WIDTH -1:0]  weight01_i,//w01 
                         input[FIX_WIDTH -1:0]  weight10_i,//w10
                         input[FIX_WIDTH -1:0]  weight11_i,//w11                  
         
                         output                 tvalid_o,
                         output[DATA_WIDTH-1:0] tdata_o
                         );

localparam MULTI_WIDTH = FIX_WIDTH + DATA_WIDTH;
//---------calculation ------------
reg[MULTI_WIDTH - 1 : 0] multi00 = 0;
reg[MULTI_WIDTH - 1 : 0] multi01 = 0;
reg[MULTI_WIDTH - 1 : 0] multi10 = 0;
reg[MULTI_WIDTH - 1 : 0] multi11 = 0;
always@(posedge clk_i)begin
  multi00 <=  weight00_i * tdata00_i;  
  multi01 <=  weight01_i * tdata01_i;
  multi10 <=  weight10_i * tdata10_i;
  multi11 <=  weight11_i * tdata11_i;     
end

reg[MULTI_WIDTH : 0] level1_add0 = 0;
reg[MULTI_WIDTH : 0] level1_add1 = 0;
always@(posedge clk_i)begin
  level1_add0 <= multi00 + multi01;  
  level1_add1 <= multi10 + multi11;     
end

reg[MULTI_WIDTH + 1 : 0] level2_add0 = 0;
always@(posedge clk_i)begin
  level2_add0 <= level1_add0 + level1_add1;     
end


reg[DATA_WIDTH + 1 : 0] round_data = 0;
always@(posedge clk_i)begin
  if(&level2_add0[MULTI_WIDTH + 1 : FIX_WIDTH])begin
    round_data <= level2_add0[MULTI_WIDTH + 1 : FIX_WIDTH];
  end else if(level2_add0[FIX_WIDTH - 1])begin
    round_data <= level2_add0[MULTI_WIDTH + 1 : FIX_WIDTH] + 1;
  end else begin
    round_data <= level2_add0[MULTI_WIDTH + 1 : FIX_WIDTH]; 
  end                                                
end

reg[DATA_WIDTH - 1 : 0] tdata = 0;
always@(posedge clk_i)begin
  tdata <= (|round_data[DATA_WIDTH + 1 -: 2]) ? {DATA_WIDTH{1'b1}} : round_data[DATA_WIDTH - 1 : 0];     
end

reg[4:0] tvalid_d = 0;
always@(posedge clk_i)begin
  tvalid_d <= {tvalid_d[3:0],tvalid_i};     
end

assign tvalid_o = tvalid_d[4];
assign tdata_o  = tdata;

endmodule