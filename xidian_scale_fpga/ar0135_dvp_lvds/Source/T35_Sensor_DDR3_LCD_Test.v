
`timescale 100ps/10ps

//`include  "ParamDefine.v"

//`include "ddr_calibration_defines.v"
module  T35_Sensor_DDR3_LCD_Test 
(
  //System Signal
//  input clk_12M_i,
//  input clk_24M_i

  input           Axi_Clk   , //Axi 0 Channel Clock, 400MHz
  input           tx_slowclk,	//48MHz
  input           tx_fastclk,	//168MHz
  
  input       pll_clk_200m,

	input 			hdmi_clk1x_i	,
	input 			hdmi_clk2x_i	,
	input 			hdmi_clk5x_i	,

  //input           pll_148m,
  
//  input           clk_cmos,		//27MHz
  input   [ 1:0]  PllLocked , //PLL Locked
  
 
  //DDR Controner Control Signal
  output          DdrCtrl_CFG_RST_N          , //(O)[Control]DDR Controner Reset(Low Active)     
  output          DdrCtrl_CFG_SEQ_RST   , //(O)[Control]DDR Controner Sequencer Reset 
  output          DdrCtrl_CFG_SEQ_START , //(O)[Control]DDR Controner Sequencer Start 
  
  //auto calibration
//  output          DdrCtrl_CFG_SCL_IN,       //ddr_slave_i2c_scl,   
//  output          DdrCtrl_CFG_SDA_IN,       //ddr_slave_i2c_sda,   
//  input           DdrCtrl_CFG_SDA_OEN,      //ddr_slave_i2c_sda_in,
  
  //DDR Controner AXI4 0 Signal
  output  [ 7:0]  DdrCtrl_AID_0     , //(O)[Addres] Address ID
  output  [31:0]  DdrCtrl_AADDR_0   , //(O)[Addres] Address
  output  [ 7:0]  DdrCtrl_ALEN_0    , //(O)[Addres] Address Brust Length
  output  [ 2:0]  DdrCtrl_ASIZE_0   , //(O)[Addres] Address Burst size
  output  [ 1:0]  DdrCtrl_ABURST_0  , //(O)[Addres] Address Burst type
  output  [ 1:0]  DdrCtrl_ALOCK_0   , //(O)[Addres] Address Lock type
  output          DdrCtrl_AVALID_0  , //(O)[Addres] Address Valid
  input           DdrCtrl_AREADY_0  , //(I)[Addres] Address Ready
  output          DdrCtrl_ATYPE_0   , //(O)[Addres] Operate Type 0=Read, 1=Write

  output  [ 7:0]  DdrCtrl_WID_0     , //(O)[Write]  ID
  output [127:0]  DdrCtrl_WDATA_0   , //(O)[Write]  Data
  output  [15:0]  DdrCtrl_WSTRB_0   , //(O)[Write]  Data Strobes(Byte valid)
  output          DdrCtrl_WLAST_0   , //(O)[Write]  Data Last
  output          DdrCtrl_WVALID_0  , //(O)[Write]  Data Valid
  input           DdrCtrl_WREADY_0  , //(I)[Write]  Data Ready

  input   [ 7:0]  DdrCtrl_RID_0     , //(I)[Read]   ID
  input  [127:0]  DdrCtrl_RDATA_0   , //(I)[Read]   Data
  input           DdrCtrl_RLAST_0   , //(I)[Read]   Data Last
  input           DdrCtrl_RVALID_0  , //(I)[Read]   Data Valid
  output          DdrCtrl_RREADY_0  , //(O)[Read]   Data Ready
  input   [ 1:0]  DdrCtrl_RRESP_0   , //(I)[Read]   Response

  input   [ 7:0]  DdrCtrl_BID_0     , //(I)[Answer] Response Write ID
  input           DdrCtrl_BVALID_0  , //(I)[Answer] Response valid
  output          DdrCtrl_BREADY_0  , //(O)[Answer] Response Ready

  //Other Signal
  output  [7:0]   LED               ,
  
    //  cmos sensor
    output                      cmos_sclk,
    input                       cmos_sdat_IN,
    output                      cmos_sdat_OUT,
    output                      cmos_sdat_OE,
    // output                      cmos_xclk,
    input                       cmos_pclk,
    input                       cmos_vsync,
    input                       cmos_href,
    input           [7:0]       cmos_data,
    output                      cmos_ctl0,
    input                       cmos_ctl1,
    output                      cmos_ctl2,
    output                      cmos_ctl3,
    
	output 	[4:0] 	hdmi_tx0_o,
	output 	[4:0] 	hdmi_tx1_o,
	output 	[4:0] 	hdmi_tx2_o,
	output 	[4:0] 	hdmi_txc_o,

    output          lcd_pwm,
    output  [6:0]   lvds_tx_clk_DATA,
    output  [6:0]   lvds_tx0_DATA,
    output  [6:0]   lvds_tx1_DATA,
    output  [6:0]   lvds_tx2_DATA,
    output  [6:0]   lvds_tx3_DATA
);
//----------------------------------------------------------------------
assign cmos_ctl0 = 1'b1;       //NC
assign cmos_ctl2 = 1'b0;       //cmos control 2, trigger output
assign cmos_ctl3 = 1'b0;       //cmos control 3, oe output

assign  lcd_pwm = 1'b1;

localparam CLOCK_MAIN  = 96_000000;
localparam CLOCK_CMOS  = 27_000000;
localparam CLOCK_PIXEL = 74_250000;
    
/*------------------------------------------------------
//  Clock & Reset Process
//***************************************************/
  
  /////////////////////////////////////////////////////////
  //Power On Reset Process
  reg [7:0] PowerOnResetCnt = 8'h0  ; //Power On Reset Counter
  reg [2:0] ResetShiftReg   = 3'h0  ; //Reset Shift Regist
  
  always @( posedge Axi_Clk) if (&PllLocked)    
  begin
    PowerOnResetCnt <= PowerOnResetCnt + {7'h0,(~&PowerOnResetCnt)};
  end
  
  always @( posedge Axi_Clk)  
  begin
    ResetShiftReg[2] <= ResetShiftReg[1] ;
    ResetShiftReg[1] <= ResetShiftReg[0] ;
    ResetShiftReg[0] <= (&PowerOnResetCnt);
  end    
  
  /////////////////////////////////////////////////////////
  //DDR Reset  
  wire  DDrCtrlReset  ;  //DDR Controner Reset(Low Active)  
  wire  DdrSeqReset   ;  //DDR Controner Sequencer Reset    
  wire  DDrSeqStart   ;  //DDR Controner Sequencer Start    
  wire  DdrInitDone   ;  //DDR Initial Done status
  
  etx_ddr3_reset_controller U0_DDR_Reset
  (
    .ddr_rstn_i         ( ResetShiftReg[2]      ), // main user DDR reset, active low
    .clk                ( Axi_Clk                ), // user clock
    /* Connect these three signals to DDR reset interface */
    .ddr_rstn           ( DdrCtrl_CFG_RST_N     ), // Master Reset
    .ddr_cfg_seq_rst    ( DdrCtrl_CFG_SEQ_RST   ), // Sequencer Reset
    .ddr_cfg_seq_start  ( DdrCtrl_CFG_SEQ_START ), // Sequencer Start
    /* optional status monitor for user logic */
    .ddr_init_done        ( DdrInitDone           )  // Done status
  );
  
  
  
//---------------------------------
//AXI Reset Generate
  
reg   [2:0] Axi0ResetReg = 3'h0;    
  
  always @( posedge Axi_Clk)  
  begin
  Axi0ResetReg[2] <= Axi0ResetReg[1] ;
  Axi0ResetReg[1] <= Axi0ResetReg[0] ;
  Axi0ResetReg[0] <= DdrInitDone;
  end
    
  wire    Axi_Rst_N  = Axi0ResetReg[2]; //System Reset (Low Active)
  

wire	User_Clk = Axi_Clk;
wire	User_Rst_N = Axi_Rst_N;
  
    
  
//----------------------------------------------
//i2c timing controller module of 16Bit
wire    [7:0]   i2c_config_index;
wire    [31:0]  i2c_config_data;
wire    [7:0]   i2c_config_size;
wire            i2c_config_done;
wire    [15:0]  i2c_rdata;      //i2c register data
i2c_timing_ctrl_reg16_dat16
#(
    .CLK_FREQ           (CLOCK_MAIN     ),      //100 MHz
    .I2C_FREQ           (10_000         )       //10 KHz(<= 400KHz)
)
u_i2c_timing_ctrl_16reg_16bit
(
    //global clock
    .clk               (User_Clk            ),  //96MHz
    .rst_n             (User_Rst_N          ),  //system reset

    //i2c interface
    .i2c_sclk          (cmos_sclk          ),  //i2c clock
    .i2c_sdat_IN       (cmos_sdat_IN       ),
    .i2c_sdat_OUT      (cmos_sdat_OUT      ),
    .i2c_sdat_OE       (cmos_sdat_OE       ),

    //i2c config data
    .i2c_config_index   (i2c_config_index   ),  //i2c config reg index, read 2 reg and write xx reg
    .i2c_config_data    ({8'h20, i2c_config_data}), //i2c config data
    .i2c_config_size    (i2c_config_size    ),  //i2c config data counte
    .i2c_config_done    (i2c_config_done    ),  //i2c config timing complete
    .i2c_rdata          (i2c_rdata          )   //i2c register data while read i2c slave
);


//----------------------------------
//I2C Configure Data of AR0135
I2C_AR0135_1280720_Config u_I2C_AR0135_1280720_Config    //Auto/Manual Exposure
(
    .LUT_INDEX  (i2c_config_index   ),
    .LUT_DATA   (i2c_config_data    ),
    .LUT_SIZE   (i2c_config_size    )
);


//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
//cmos video image capture
wire            cmos_frame_vsync;   //cmos frame data vsync valid signal
wire            cmos_frame_href;    //cmos frame data href vaild  signal
wire    [7:0]   cmos_frame_Gray;     //cmos frame data output: 8 Bit raw data    
wire            cmos_vsync_end;

CMOS_Capture_RAW_Gray   
#(
    .CMOS_FRAME_WAITCNT     (4'd3),             //Wait n fps for steady(OmniVision need 10 Frame)
    .CMOS_PCLK_FREQ         (CLOCK_PIXEL)      //74.25 MHz
)
u_CMOS_Capture_RAW_Gray
(
    //global clock
    .clk_cmos               (1'b0),//(clk_cmos),         //27MHz CMOS Driver clock input
    .rst_n                  (User_Rst_N),   //global reset

    //CMOS Sensor Interface
    .cmos_pclk              (cmos_pclk),        //37.125MHz CMOS Pixel clock input
    .cmos_xclk              (),//cmos_xclk),        //27MHz drive clock
    .cmos_data              (cmos_data),        //8 bits cmos data input
    .cmos_vsync             (cmos_vsync),       //L: vaild, H: invalid
    .cmos_href              (cmos_href),        //H: vaild, L: invalid
    
    //CMOS SYNC Data output
    .cmos_frame_vsync       (cmos_frame_vsync), //cmos frame data vsync valid signal
    .cmos_frame_href        (cmos_frame_href),  //cmos frame data href vaild  signal
    .cmos_frame_data        (cmos_frame_Gray),  //cmos frame data output: 8 Bit raw data    
    
    //user interface
    .cmos_fps_rate          (),     //cmos image output rate
    .cmos_vsync_end         (cmos_vsync_end),
    .pixel_cnt              (), 
    .line_cnt               ()  
);

wire            XYCrop_frame_vsync; 
wire            XYCrop_frame_href;
wire    [7:0]   XYCrop_frame_Gray;

Sensor_Image_XYCrop
#(
    .IMAGE_HSIZE_SOURCE (1280),
    .IMAGE_VSIZE_SOURCE (720 ),
    .IMAGE_HSIZE_TARGET (1280),
    .IMAGE_YSIZE_TARGET (720 )
)
u_Sensor_Image_XYCrop
(
    //  globel clock
    .clk            (cmos_pclk          ),          //  image pixel clock
    .rst_n          (User_Rst_N   		),          //  system reset
    
    //CMOS Sensor interface
    .image_in_vsync (cmos_frame_vsync   ),          //H : Data Valid; L : Frame Sync(Set it by register)
    .image_in_href  (cmos_frame_href    ),          //H : Data vaild, L : Line Sync
    .image_in_data  (cmos_frame_Gray    ),          //8 bits cmos data input
    .image_out_vsync(XYCrop_frame_vsync ),          //H : Data Valid; L : Frame Sync(Set it by register)
    .image_out_href (XYCrop_frame_href  ),          //H : Data vaild, L : Line Sync
    .image_out_data (XYCrop_frame_Gray  )           //8 bits cmos data input    
);



//--------------------------------------
//Detect the frame rate of sensor
wire    [7:0]   cmos_fps_rate;      //cmos image output rate
sensor_frame_count
#(
	.CLOCK_MAIN 	(CLOCK_MAIN)														
)u_sensor_frame_count
(
	//global clock
	.clk            (User_Clk),			    //System Main clock
	.rst_n          (User_Rst_N),				//global reset
    //sensor frame signal
    .cmos_vsync     (cmos_vsync),
    //sensor frame count
    .cmos_fps_rate  (cmos_fps_rate)
);
assign  LED = cmos_fps_rate;
//----------------------------------------------------------------------
	
/*
ar0135_data u_ar0135_data(
    .s_rst_n      (User_Rst_N      ),

    .ar0135_pclk  (cmos_pclk  ),
    .ar0135_href  (           ),
    .ar0135_vsync (           ),
    .ar0135_data  (           ),

    .m_data       (m_data       ),
    .m_wr_en      (m_wr_en      )
);
*/

wire        tready_o;
wire        tvalid_i;
wire [7:0]  tdata_i ;
wire        tvalid_o;
wire [7:0]  tdata_o ;
wire        tvsync_o;
wire        empty;


assign tvalid_i = (tready_o&&~empty)?1'b1:1'b0;

afifo_buf u_afifo_buf(
.full_o (  ),
.empty_o ( empty ),
.wr_clk_i ( cmos_pclk ),
.rd_clk_i ( Axi_Clk ),
.wr_en_i ( cmos_frame_href),
.rd_en_i ( tvalid_i ),
.wdata ( cmos_frame_Gray ),
.wr_datacount_o (  ),
.rd_datacount_o (  ),
.rst_busy (  ),
.rdata ( tdata_i ),
.a_rst_i ( ~User_Rst_N )
);

wire  			lcd_de_r;
wire  			lcd_hs_r;      
wire  			lcd_vs_r;
wire	[7:0]	lcd_data_r;
wire  	[7:0]   lcd_red_r;
wire  	[7:0]   lcd_green_r;
wire  	[7:0]   lcd_blue_r;
wire  	    lcd_request;

localparam SRC_IMAGE_WIDTH   = 1280;
localparam SRC_IMAGE_HEIGHT  = 720 ;

localparam DEST_IMAGE_WIDTH  = 1024;
localparam DEST_IMAGE_HEIGHT = 600 ;

localparam SCALE_INTX = SRC_IMAGE_WIDTH  / DEST_IMAGE_WIDTH;
localparam SCALE_INTY = SRC_IMAGE_HEIGHT / DEST_IMAGE_HEIGHT;

localparam SCALE_FRACX = ((SRC_IMAGE_WIDTH - SCALE_INTX * DEST_IMAGE_WIDTH)  << 12) / DEST_IMAGE_WIDTH;
localparam SCALE_FRACY = ((SRC_IMAGE_HEIGHT - SCALE_INTY * DEST_IMAGE_HEIGHT)  << 12) / DEST_IMAGE_HEIGHT;

localparam SCALE_FACTORX = (SCALE_INTX  << 12) + SCALE_FRACX;//SRC_IMAGE_WIDTH / DEST_IMAGE_WIDTH
localparam SCALE_FACTORY = (SCALE_INTY  << 12) + SCALE_FRACY;//SRC_IMAGE_HEIGHT / DEST_IMAGE_HEIGHT

scaler_gray 
#(
  .ADJUST_MODE (1     ),
  .BRAM_DEEPTH (SRC_IMAGE_WIDTH *2  ),
  .DATA_WIDTH  (8     ),
  .INDEX_WIDTH (16    ),
  .INT_WIDTH   (8     ),
  .FIX_WIDTH   (12    )
)
u_scaler_gray(
  .clk_i           (Axi_Clk     ),
  .rst_i           (~User_Rst_N   ),

  .tvalid_i        (tvalid_i      ),
  .tdata_i         (tdata_i       ),
  .tready_o        (tready_o      ),

  .src_width_i     (SRC_IMAGE_WIDTH     ),
  .src_height_i    (SRC_IMAGE_HEIGHT    ),
  .dest_width_i    (DEST_IMAGE_WIDTH    ),
  .dest_height_i   (DEST_IMAGE_HEIGHT   ),

  .scale_factorx_i (SCALE_FACTORX       ),
  .scale_factory_i (SCALE_FACTORY       ),

  .tvsync_o        (tvsync_o      ),
  .tvalid_o        (tvalid_o      ),
  .tdata_o         (tdata_o       )
);



//-------------------------------------
//LCD driver timing
wire  			lcd_de;
wire  			lcd_hs;      
wire  			lcd_vs;
wire  	[7:0]   lcd_red;
wire  	[7:0]   lcd_green;
wire  	[7:0]   lcd_blue;
// wire	[11:0]	lcd_xpos;		//lcd horizontal coordinate
// wire	[11:0]	lcd_ypos;		//lcd vertical coordinate
wire	[7:0]	lcd_data;		//lcd data

//----------------------------------------------------------------------
axi4_ctrl u_axi4_ctrl
(
    .axi_clk        (Axi_Clk    ),
    .axi_reset      (~User_Rst_N ),
    
    .axi_aid        (DdrCtrl_AID_0),
    .axi_aaddr      (DdrCtrl_AADDR_0),
    .axi_alen       (DdrCtrl_ALEN_0),
    .axi_asize      (DdrCtrl_ASIZE_0),
    .axi_aburst     (DdrCtrl_ABURST_0),
    .axi_alock      (DdrCtrl_ALOCK_0),
    .axi_avalid     (DdrCtrl_AVALID_0),
    .axi_aready     (DdrCtrl_AREADY_0),
    .axi_atype      (DdrCtrl_ATYPE_0),
    
    .axi_wid        (DdrCtrl_WID_0),
    .axi_wdata      (DdrCtrl_WDATA_0),
    .axi_wstrb      (DdrCtrl_WSTRB_0),
    .axi_wlast      (DdrCtrl_WLAST_0),
    .axi_wvalid     (DdrCtrl_WVALID_0),
    .axi_wready     (DdrCtrl_WREADY_0),
    
    .axi_bid        (DdrCtrl_BID_0),
    .axi_bvalid     (DdrCtrl_BVALID_0),
    .axi_bready     (DdrCtrl_BREADY_0),
    
    .axi_rid        (DdrCtrl_RID_0),
    .axi_rdata      (DdrCtrl_RDATA_0),
    .axi_rlast      (DdrCtrl_RLAST_0),
    .axi_rvalid     (DdrCtrl_RVALID_0),
    .axi_rready     (DdrCtrl_RREADY_0),
    .axi_rresp      (DdrCtrl_RRESP_0),
    
    .wframe_pclk    (Axi_Clk),
    .wframe_vsync   (tvsync_o    ),
    .wframe_data_en (tvalid_o    ),
    .wframe_data    (tdata_o     ),

    .rframe_pclk    (hdmi_clk1x_i ),
    .rframe_vsync   (lcd_vs       ),
    .rframe_data_en (lcd_de  ),
    .rframe_data    (lcd_data     )
);


	//	HDMI clock is 5x:2x:1x. 
	reg 			r_hdmi_rst_n = 0; 
	always @(posedge hdmi_clk1x_i)
		r_hdmi_rst_n <= User_Rst_N; 
	
	lcd_driver u_lcd_driver
	(
		//global clock
		.clk			(hdmi_clk1x_i), 	//	tx_slowclk),		
		.rst_n			(r_hdmi_rst_n), 
		 
		 //lcd interface
		.lcd_dclk		(),//(lcd_dclk),
		.lcd_blank		(),//lcd_blank
		.lcd_sync		(),				
		.lcd_hs			(lcd_hs),		
		.lcd_vs			(lcd_vs),
		.lcd_en			(lcd_de),		
		.lcd_rgb		({lcd_red, lcd_green, lcd_blue}),
	
		
		//user interface
		.lcd_request	(lcd_request),
		.lcd_data		({3{lcd_data}}), 	//	{3{lcd_xpos[8:0]}}), 	//	//,	
		.lcd_xpos		(lcd_xpos),	
		.lcd_ypos		(lcd_ypos)
	);
	
	
	//wire	[7:0]	 c0 = 7'b1100011;
	//wire	[7:0]	 d0 = {lcd_green[0],	lcd_red[5:0]};
	//wire	[7:0]	 d1 = {lcd_blue[1:0], lcd_green[5:1]};
	//wire	[7:0]	 d2 = {lcd_de, 2'b0,	lcd_blue[5:2]};	 //vs hs is reserved
	//wire	[7:0]	 d3 = {1'b0, lcd_blue[7:6], lcd_green[7:6], lcd_red[7:6]};
	//
	//assign	lvds_tx_clk_DATA = {c0[0], c0[1], c0[2], c0[3], c0[4], c0[5], c0[6]};
	//assign	lvds_tx0_DATA	= {d0[0], d0[1], d0[2], d0[3], d0[4], d0[5], d0[6]};
	//assign	lvds_tx1_DATA	= {d1[0], d1[1], d1[2], d1[3], d1[4], d1[5], d1[6]};
	//assign	lvds_tx2_DATA	= {d2[0], d2[1], d2[2], d2[3], d2[4], d2[5], d2[6]};
	//assign	lvds_tx3_DATA	= {d3[0], d3[1], d3[2], d3[3], d3[4], d3[5], d3[6]};
	
	assign lcd_pwm = 1; 
	
	
	
	
	////////////////////////////////////////////////////////////////
	//	HDMI Interface. 
	
	//-------------------------------------
	//Digilent HDMI-TX IP Modified by CB elec.
	
	//	Convert into 2x rate. 
	wire 	[9:0] 	w_hdmi_txc, w_hdmi_txd0, w_hdmi_txd1, w_hdmi_txd2; 
	
	rgb2dvi #(.ENABLE_OSERDES(0)) u_rgb2dvi 
	(
		.oe_i 		(1), 			//	Always enable output
		.bitflip_i 		(4'b0000), 		//	Reverse clock & data lanes. 
		
		.aRst			(1'b0), 
		.aRst_n		(1'b1), 
		
		.PixelClk		(hdmi_clk1x_i        ),//pixel clk = 74.25M
		.SerialClk		(     ),//pixel clk *5 = 371.25M
		
		.vid_pVSync		(lcd_vs), 
		.vid_pHSync		(lcd_hs), 
		.vid_pVDE		(lcd_de), 
		.vid_pData		({lcd_red, lcd_green, lcd_blue}), 
		
		.txc_o			(w_hdmi_txc), 
		.txd0_o			(w_hdmi_txd0), 
		.txd1_o			(w_hdmi_txd1), 
		.txd2_o			(w_hdmi_txd2)
	); 
	
	reg 			rc_hdmi_tx = 0; 
	reg 	[9:0] 	r_hdmi_txc_o = 0, r_hdmi_tx0_o = 0, r_hdmi_tx1_o = 0, r_hdmi_tx2_o = 0; 
	always @(posedge hdmi_clk2x_i) begin
		rc_hdmi_tx <= ~rc_hdmi_tx; 
		if(rc_hdmi_tx) begin
			r_hdmi_txc_o <= w_hdmi_txc; 
			r_hdmi_tx0_o <= w_hdmi_txd0; 
			r_hdmi_tx1_o <= w_hdmi_txd1; 
			r_hdmi_tx2_o <= w_hdmi_txd2; 
		end else begin
			r_hdmi_txc_o <= r_hdmi_txc_o >> 5; 
			r_hdmi_tx0_o <= r_hdmi_tx0_o >> 5; 
			r_hdmi_tx1_o <= r_hdmi_tx1_o >> 5; 
			r_hdmi_tx2_o <= r_hdmi_tx2_o >> 5; 
		end
	end
	assign hdmi_txc_o = r_hdmi_txc_o;
	assign hdmi_tx0_o = r_hdmi_tx0_o;
	assign hdmi_tx1_o = r_hdmi_tx1_o;
	assign hdmi_tx2_o = r_hdmi_tx2_o; 
	
	

endmodule
