
`timescale 100ps/10ps

//`include  "ParamDefine.v"

`include "ddr_calibration_defines.v"
module  T35_Sensor_DDR3_LCD_Test 
(
  //System Signal
//  input AxiPllClkIn,
//  input DdrPllClkIn
  // input           SysClk    , //System Clock
  input           Axi0Clk   , //Axi 0 Channel Clock, 400MHz
//  input           Axi1Clk   , //Axi 1 Channel Clock
  input           clk_cmos,		//25MHz
  input           tx_slowclk,	//48MHz
  input           tx_fastclk,	//168MHz
  input   [ 1:0]  PllLocked , //PLL Locked
  
 
  //DDR Controner Control Signal
  output          DdrCtrl_RSTN          , //(O)[Control]DDR Controner Reset(Low Active)     
  output          DdrCtrl_CFG_SEQ_RST   , //(O)[Control]DDR Controner Sequencer Reset 
  output          DdrCtrl_CFG_SEQ_START , //(O)[Control]DDR Controner Sequencer Start 
  
  
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
  output  [7:0]   led_data,
  
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
    output                      cmos1_ctl0,
    input                       cmos1_ctl1,
    output                      cmos1_ctl2,
    output                      cmos1_ctl3,
    
    output          lcd_pwm,
    output  [6:0]   lvds_tx_clk_DATA,
    output  [6:0]   lvds_tx0_DATA,
    output  [6:0]   lvds_tx1_DATA,
    output  [6:0]   lvds_tx2_DATA,
    output  [6:0]   lvds_tx3_DATA
);
//----------------------------------------------------------------------
assign cmos1_ctl0 = 1'b1;       //NC
assign cmos1_ctl2 = 1'b0;       //cmos control 2, trigger output
assign cmos1_ctl3 = 1'b0;       //cmos control 3, oe output

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
  
  always @( posedge Axi0Clk) if (&PllLocked)    
  begin
    PowerOnResetCnt <= PowerOnResetCnt + {7'h0,(~&PowerOnResetCnt)};
  end
  
  always @( posedge Axi0Clk)  
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
    .clk                ( Axi0Clk                ), // user clock
    /* Connect these three signals to DDR reset interface */
    .ddr_rstn           ( DdrCtrl_RSTN          ), // Master Reset
    .ddr_cfg_seq_rst    ( DdrCtrl_CFG_SEQ_RST   ), // Sequencer Reset
    .ddr_cfg_seq_start  ( DdrCtrl_CFG_SEQ_START ), // Sequencer Start
    /* optional status monitor for user logic */
    .ddr_init_done        ( DdrInitDone           )  // Done status
  );
  
  


    
    
  
//---------------------------------
//AXI Reset Generate
  
reg   [2:0] Axi0ResetReg = 3'h0;    
  
  always @( posedge Axi0Clk)  
  begin
  Axi0ResetReg[2] <= Axi0ResetReg[1] ;
  Axi0ResetReg[1] <= Axi0ResetReg[0] ;
  Axi0ResetReg[0] <= DdrInitDone;
  end
    
  wire    Axi0Rst_N  = Axi0ResetReg[2]; //System Reset (Low Active)
  

wire	User_Clk = Axi0Clk;
wire	User_Rst_N = Axi0Rst_N;
  
    
  
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
    .clk_cmos               (clk_cmos),         //27MHz CMOS Driver clock input
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

//--------------------------------------
//Detect the frame rate of sensor
wire    [7:0]   cmos_fps_rate;      //cmos image output rate
sensor_frame_count
#(
	.CLOCK_MAIN 	(CLOCK_CMOS)														
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
assign  led_data = cmos_fps_rate;
//----------------------------------------------------------------------
wire            XYCrop_frame_vsync; 
wire            XYCrop_frame_href;
wire    [7:0]   XYCrop_frame_Gray;

Sensor_Image_XYCrop
#(
    .IMAGE_HSIZE_SOURCE (1280),
    .IMAGE_VSIZE_SOURCE (720 ),
    .IMAGE_HSIZE_TARGET (1024),
    .IMAGE_YSIZE_TARGET (600 )
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

//----------------------------------------------------------------------
axi4_ctrl u_axi4_ctrl
(
    .axi_clk        (Axi0Clk    ),
    .axi_reset      (~Axi0Rst_N ),
    
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
    
    .wframe_pclk    (cmos_pclk),
    .wframe_vsync   (XYCrop_frame_vsync),
    .wframe_data_en (XYCrop_frame_href),
    .wframe_data    (XYCrop_frame_Gray),
    
    .rframe_pclk    (tx_slowclk),
    .rframe_vsync   (lcd_vs),
    .rframe_data_en (lcd_de),
    .rframe_data    (lcd_data)
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
lcd_driver u_lcd_driver
(
	//global clock
	.clk			(tx_slowclk),		
	.rst_n			(User_Rst_N), 
	 
	 //lcd interface
	.lcd_dclk		(),//(lcd_dclk),
	.lcd_blank		(),//lcd_blank
	.lcd_sync		(),		    	
	.lcd_hs			(lcd_hs),		
	.lcd_vs			(lcd_vs),
	.lcd_en			(lcd_de),		
	.lcd_rgb		({lcd_red, lcd_green, lcd_blue}),

	
	//user interface
	// .lcd_request	(),
	.lcd_data		({3{lcd_data}})//,	
	// .lcd_xpos		(lcd_xpos),	
	// .lcd_ypos		(lcd_ypos)
);



wire    [7:0]   c0 = 7'b1100011;
wire    [7:0]   d0 = {lcd_green[0],  lcd_red[5:0]};
wire    [7:0]   d1 = {lcd_blue[1:0], lcd_green[5:1]};
wire    [7:0]   d2 = {lcd_de, 2'b0,  lcd_blue[5:2]};   //vs hs is reserved
wire    [7:0]   d3 = {1'b0, lcd_blue[7:6], lcd_green[7:6], lcd_red[7:6]};

assign  lvds_tx_clk_DATA = {c0[0], c0[1], c0[2], c0[3], c0[4], c0[5], c0[6]};
assign  lvds_tx0_DATA    = {d0[0], d0[1], d0[2], d0[3], d0[4], d0[5], d0[6]};
assign  lvds_tx1_DATA    = {d1[0], d1[1], d1[2], d1[3], d1[4], d1[5], d1[6]};
assign  lvds_tx2_DATA    = {d2[0], d2[1], d2[2], d2[3], d2[4], d2[5], d2[6]};
assign  lvds_tx3_DATA    = {d3[0], d3[1], d3[2], d3[3], d3[4], d3[5], d3[6]};

endmodule