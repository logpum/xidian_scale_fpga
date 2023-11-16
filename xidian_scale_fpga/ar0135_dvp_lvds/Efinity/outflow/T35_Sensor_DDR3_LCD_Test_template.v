
// Efinity Top-level template
// Version: 2023.1.150.4.10
// Date: 2023-11-02 22:54

// Copyright (C) 2017 - 2023 Efinix Inc. All rights reserved.

// This file may be used as a starting point for Efinity synthesis top-level target.
// The port list here matches what is expected by Efinity constraint files generated
// by the Efinity Interface Designer.

// To use this:
//     #1)  Save this file with a different name to a different directory, where source files are kept.
//              Example: you may wish to save as C:\Users\Yuanbing Ouyang\Desktop\xidianFPGA\T35\scale\01efx_bilinear_scaler_hdmi\ar0135_dvp_lvds\Efinity\T35_Sensor_DDR3_LCD_Test.v
//     #2)  Add the newly saved file into Efinity project as design file
//     #3)  Edit the top level entity in Efinity project to:  T35_Sensor_DDR3_LCD_Test
//     #4)  Insert design content.


module T35_Sensor_DDR3_LCD_Test
(
  input clk_12M_i,
  input clk_24M_i,
  input clk_24Mr,
  input [1:0] PllLocked,
  input cmos_ctl1,
  input [7:0] cmos_data,
  input cmos_href,
  input cmos_sdat_IN,
  input cmos_vsync,
  input cmos_pclk,
  input pll_clk_200m,
  input Axi_Clk,
  input tx_fastclk,
  input tx_slowclk,
  input hdmi_clk2x_i,
  input hdmi_clk5x_i,
  input clk_cmos,
  input hdmi_clk1x_i,
  input jtag_inst1_CAPTURE,
  input jtag_inst1_DRCK,
  input jtag_inst1_RESET,
  input jtag_inst1_RUNTEST,
  input jtag_inst1_SEL,
  input jtag_inst1_SHIFT,
  input jtag_inst1_TCK,
  input jtag_inst1_TDI,
  input jtag_inst1_TMS,
  input jtag_inst1_UPDATE,
  input DdrCtrl_AREADY_0,
  input [7:0] DdrCtrl_BID_0,
  input DdrCtrl_BVALID_0,
  input [127:0] DdrCtrl_RDATA_0,
  input [7:0] DdrCtrl_RID_0,
  input DdrCtrl_RLAST_0,
  input [1:0] DdrCtrl_RRESP_0,
  input DdrCtrl_RVALID_0,
  input DdrCtrl_WREADY_0,
  output [7:0] LED,
  output lcd_pwm,
  output [4:0] hdmi_tx0_o,
  output [4:0] hdmi_tx1_o,
  output [4:0] hdmi_tx2_o,
  output [4:0] hdmi_txc_o,
  output [6:0] lvds_tx0_DATA,
  output [6:0] lvds_tx1_DATA,
  output [6:0] lvds_tx2_DATA,
  output [6:0] lvds_tx3_DATA,
  output [6:0] lvds_tx_clk_DATA,
  output cmos_ctl0,
  output cmos_ctl2,
  output cmos_ctl3,
  output cmos_sclk,
  output cmos_sdat_OUT,
  output cmos_sdat_OE,
  output jtag_inst1_TDO,
  output [31:0] DdrCtrl_AADDR_0,
  output [1:0] DdrCtrl_ABURST_0,
  output [7:0] DdrCtrl_AID_0,
  output [7:0] DdrCtrl_ALEN_0,
  output [1:0] DdrCtrl_ALOCK_0,
  output [2:0] DdrCtrl_ASIZE_0,
  output DdrCtrl_ATYPE_0,
  output DdrCtrl_AVALID_0,
  output DdrCtrl_BREADY_0,
  output DdrCtrl_CFG_SEQ_RST,
  output DdrCtrl_CFG_SEQ_START,
  output DdrCtrl_RREADY_0,
  output DdrCtrl_CFG_RST_N,
  output [127:0] DdrCtrl_WDATA_0,
  output [7:0] DdrCtrl_WID_0,
  output DdrCtrl_WLAST_0,
  output [15:0] DdrCtrl_WSTRB_0,
  output DdrCtrl_WVALID_0
);


endmodule

