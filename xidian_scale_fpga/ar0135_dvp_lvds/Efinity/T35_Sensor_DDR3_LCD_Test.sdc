
# Efinity Interface Designer SDC
# Version: 2023.1.150.4.10
# Date: 2023-11-02 22:09

# Copyright (C) 2017 - 2023 Efinix Inc. All rights reserved.

# Device: T35F324
# Project: T35_Sensor_DDR3_LCD_Test
# Timing Model: C4 (final)

# PLL Constraints
#################
create_clock -period 7.1429 pll_clk_200m
create_clock -period 2.5063 Ddr_Clk
create_clock -period 37.5940 clk_cmos
create_clock -period 20.0803 hdmi_clk1x_i
create_clock -period 10.0402 hdmi_clk2x_i
create_clock -waveform {1.0040 3.0120} -period 4.0161 hdmi_clk5x_i
create_clock -period 10.4167 Axi_Clk
create_clock -waveform {1.4881 4.4643} -period 5.9524 tx_fastclk
create_clock -period 20.8333 tx_slowclk

# GPIO Constraints
####################
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {clk_12M_i}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {clk_12M_i}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {clk_24M_i}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {clk_24M_i}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {clk_24Mr}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {clk_24Mr}]
create_clock -period <USER_PERIOD> [get_ports {cmos_pclk}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[0]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[0]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[1]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[1]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[2]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[2]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[3]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[3]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[4]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[4]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[5]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[5]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[6]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[6]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[7]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[7]}]

# LVDS RX GPIO Constraints
############################
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {lcd_pwm}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {lcd_pwm}]

# LVDS Rx Constraints
####################

# LVDS TX GPIO Constraints
############################
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_ctl1}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_ctl1}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_data[0]}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_data[0]}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_data[1]}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_data[1]}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_data[2]}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_data[2]}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_data[3]}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_data[3]}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_data[4]}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_data[4]}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_data[5]}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_data[5]}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_data[6]}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_data[6]}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_data[7]}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_data[7]}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_href}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_href}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_vsync}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_vsync}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_ctl0}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_ctl0}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_ctl2}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_ctl2}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_ctl3}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_ctl3}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_sclk}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_sclk}]
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_sdat_IN}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_sdat_IN}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_sdat_OUT}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_sdat_OUT}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {cmos_sdat_OE}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {cmos_sdat_OE}]

# LVDS Tx Constraints
####################
set_output_delay -clock hdmi_clk2x_i -max -4.230 [get_ports {hdmi_tx0_o[4] hdmi_tx0_o[3] hdmi_tx0_o[2] hdmi_tx0_o[1] hdmi_tx0_o[0]}]
set_output_delay -clock hdmi_clk2x_i -min -2.235 [get_ports {hdmi_tx0_o[4] hdmi_tx0_o[3] hdmi_tx0_o[2] hdmi_tx0_o[1] hdmi_tx0_o[0]}]
set_output_delay -clock hdmi_clk2x_i -max -4.230 [get_ports {hdmi_tx1_o[4] hdmi_tx1_o[3] hdmi_tx1_o[2] hdmi_tx1_o[1] hdmi_tx1_o[0]}]
set_output_delay -clock hdmi_clk2x_i -min -2.235 [get_ports {hdmi_tx1_o[4] hdmi_tx1_o[3] hdmi_tx1_o[2] hdmi_tx1_o[1] hdmi_tx1_o[0]}]
set_output_delay -clock hdmi_clk2x_i -max -4.230 [get_ports {hdmi_tx2_o[4] hdmi_tx2_o[3] hdmi_tx2_o[2] hdmi_tx2_o[1] hdmi_tx2_o[0]}]
set_output_delay -clock hdmi_clk2x_i -min -2.235 [get_ports {hdmi_tx2_o[4] hdmi_tx2_o[3] hdmi_tx2_o[2] hdmi_tx2_o[1] hdmi_tx2_o[0]}]
set_output_delay -clock hdmi_clk2x_i -max -4.230 [get_ports {hdmi_txc_o[4] hdmi_txc_o[3] hdmi_txc_o[2] hdmi_txc_o[1] hdmi_txc_o[0]}]
set_output_delay -clock hdmi_clk2x_i -min -2.235 [get_ports {hdmi_txc_o[4] hdmi_txc_o[3] hdmi_txc_o[2] hdmi_txc_o[1] hdmi_txc_o[0]}]
set_output_delay -clock tx_slowclk -max -4.230 [get_ports {lvds_tx0_DATA[6] lvds_tx0_DATA[5] lvds_tx0_DATA[4] lvds_tx0_DATA[3] lvds_tx0_DATA[2] lvds_tx0_DATA[1] lvds_tx0_DATA[0]}]
set_output_delay -clock tx_slowclk -min -2.235 [get_ports {lvds_tx0_DATA[6] lvds_tx0_DATA[5] lvds_tx0_DATA[4] lvds_tx0_DATA[3] lvds_tx0_DATA[2] lvds_tx0_DATA[1] lvds_tx0_DATA[0]}]
set_output_delay -clock tx_slowclk -max -4.230 [get_ports {lvds_tx1_DATA[6] lvds_tx1_DATA[5] lvds_tx1_DATA[4] lvds_tx1_DATA[3] lvds_tx1_DATA[2] lvds_tx1_DATA[1] lvds_tx1_DATA[0]}]
set_output_delay -clock tx_slowclk -min -2.235 [get_ports {lvds_tx1_DATA[6] lvds_tx1_DATA[5] lvds_tx1_DATA[4] lvds_tx1_DATA[3] lvds_tx1_DATA[2] lvds_tx1_DATA[1] lvds_tx1_DATA[0]}]
set_output_delay -clock tx_slowclk -max -4.230 [get_ports {lvds_tx2_DATA[6] lvds_tx2_DATA[5] lvds_tx2_DATA[4] lvds_tx2_DATA[3] lvds_tx2_DATA[2] lvds_tx2_DATA[1] lvds_tx2_DATA[0]}]
set_output_delay -clock tx_slowclk -min -2.235 [get_ports {lvds_tx2_DATA[6] lvds_tx2_DATA[5] lvds_tx2_DATA[4] lvds_tx2_DATA[3] lvds_tx2_DATA[2] lvds_tx2_DATA[1] lvds_tx2_DATA[0]}]
set_output_delay -clock tx_slowclk -max -4.230 [get_ports {lvds_tx3_DATA[6] lvds_tx3_DATA[5] lvds_tx3_DATA[4] lvds_tx3_DATA[3] lvds_tx3_DATA[2] lvds_tx3_DATA[1] lvds_tx3_DATA[0]}]
set_output_delay -clock tx_slowclk -min -2.235 [get_ports {lvds_tx3_DATA[6] lvds_tx3_DATA[5] lvds_tx3_DATA[4] lvds_tx3_DATA[3] lvds_tx3_DATA[2] lvds_tx3_DATA[1] lvds_tx3_DATA[0]}]
set_output_delay -clock tx_slowclk -max -4.230 [get_ports {lvds_tx_clk_DATA[6] lvds_tx_clk_DATA[5] lvds_tx_clk_DATA[4] lvds_tx_clk_DATA[3] lvds_tx_clk_DATA[2] lvds_tx_clk_DATA[1] lvds_tx_clk_DATA[0]}]
set_output_delay -clock tx_slowclk -min -2.235 [get_ports {lvds_tx_clk_DATA[6] lvds_tx_clk_DATA[5] lvds_tx_clk_DATA[4] lvds_tx_clk_DATA[3] lvds_tx_clk_DATA[2] lvds_tx_clk_DATA[1] lvds_tx_clk_DATA[0]}]

# DDR Constraints
#####################
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_AADDR_0[*]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_AADDR_0[*]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_ABURST_0[1] DdrCtrl_ABURST_0[0]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_ABURST_0[1] DdrCtrl_ABURST_0[0]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_AID_0[*]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_AID_0[*]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_ALEN_0[*]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_ALEN_0[*]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_ALOCK_0[1] DdrCtrl_ALOCK_0[0]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_ALOCK_0[1] DdrCtrl_ALOCK_0[0]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_ASIZE_0[2] DdrCtrl_ASIZE_0[1] DdrCtrl_ASIZE_0[0]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_ASIZE_0[2] DdrCtrl_ASIZE_0[1] DdrCtrl_ASIZE_0[0]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_ATYPE_0}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_ATYPE_0}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_AVALID_0}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_AVALID_0}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_BREADY_0}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_BREADY_0}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_RREADY_0}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_RREADY_0}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_WDATA_0[*]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_WDATA_0[*]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_WID_0[*]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_WID_0[*]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_WLAST_0}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_WLAST_0}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_WSTRB_0[*]}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_WSTRB_0[*]}]
set_output_delay -clock Axi_Clk -max -1.810 [get_ports {DdrCtrl_WVALID_0}]
set_output_delay -clock Axi_Clk -min -2.555 [get_ports {DdrCtrl_WVALID_0}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_AREADY_0}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_AREADY_0}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_BID_0[*]}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_BID_0[*]}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_BVALID_0}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_BVALID_0}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_RDATA_0[*]}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_RDATA_0[*]}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_RID_0[*]}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_RID_0[*]}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_RLAST_0}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_RLAST_0}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_RRESP_0[1] DdrCtrl_RRESP_0[0]}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_RRESP_0[1] DdrCtrl_RRESP_0[0]}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_RVALID_0}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_RVALID_0}]
set_input_delay -clock Axi_Clk -max 7.310 [get_ports {DdrCtrl_WREADY_0}]
set_input_delay -clock Axi_Clk -min 3.655 [get_ports {DdrCtrl_WREADY_0}]
