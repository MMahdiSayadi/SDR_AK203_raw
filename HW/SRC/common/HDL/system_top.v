// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top (

  inout   [14:0]  ddr_addr,
  inout   [ 2:0]  ddr_ba,
  inout           ddr_cas_n,
  inout           ddr_ck_n,
  inout           ddr_ck_p,
  inout           ddr_cke,
  inout           ddr_cs_n,
  inout   [ 3:0]  ddr_dm,
  inout   [31:0]  ddr_dq,
  inout   [ 3:0]  ddr_dqs_n,
  inout   [ 3:0]  ddr_dqs_p,
  inout           ddr_odt,
  inout           ddr_ras_n,
  inout           ddr_reset_n,
  inout           ddr_we_n,

  inout           fixed_io_ddr_vrn,
  inout           fixed_io_ddr_vrp,
  inout   [31:0]  fixed_io_mio,
  inout           fixed_io_ps_clk,
  inout           fixed_io_ps_porb,
  inout           fixed_io_ps_srstb,


  input                   rx_clk_in_p,
  input                   rx_clk_in_n,
  input                   rx_frame_in_p,
  input                   rx_frame_in_n,
  input       [ 5:0]      rx_data_in_p,
  input       [ 5:0]      rx_data_in_n,
  output                  tx_clk_out_p,
  output                  tx_clk_out_n,
  output                  tx_frame_out_p,
  output                  tx_frame_out_n,
  output      [ 5:0]      tx_data_out_p,
  output      [ 5:0]      tx_data_out_n,

  output                  txnrx,
  output                  enable,

  inout                   gpio_resetb,
  inout                   gpio_sync,
  inout                   gpio_en_agc,
  inout       [ 3:0]      gpio_ctl,
  inout       [ 7:0]      gpio_status,

  output                  spi_csn,
  output                  spi_clk,
  output                  spi_mosi,
  input                   spi_miso,

  output          MDIO_PHY_mdc,
  inout           MDIO_PHY_mdio_io,
  input [3:0]     RGMII_rd,
  input           RGMII_rx_ctl,
  input           RGMII_rxc,
  output [3:0]    RGMII_td,
  output          RGMII_tx_ctl,
  output          RGMII_txc,
  
  output          TRX1_nTX_RX,
  output          RX1_TRX_nRX,
  output          RX2_nTRX_RX,
  output          TRX2_TX_nRX,
  //GPS M10 Signals
  output 				  nrst,
  output 				  GPS_rx,
  input 				  GPS_tx,
  output 			  GPS_tx_loop_back,
  input 			  GPS_rx_loop_back

  );
	
//GPS signal loop back

assign nrst	=1'b1;
assign GPS_tx_loop_back=GPS_tx;
assign GPS_rx=GPS_rx_loop_back;
assign os_output = 1'b1;
/*  reg temp;
 always @(posedge clk_out)
		begin
			temp<=GPS_tx;
		// end */
	
	
  // internal signals

  wire    [63:0]  gpio_i;
  wire    [63:0]  gpio_o;
  wire    [63:0]  gpio_t;

  wire    [31:0]      gpio_bd;
  wire                gpio_muxout_tx;
  wire                gpio_muxout_rx;
  // instantiations

  ad_iobuf #(.DATA_WIDTH(49)) i_iobuf_gpio (
    .dio_t ({gpio_t[50:49], gpio_t[46:0]}),
    .dio_i ({gpio_o[50:49], gpio_o[46:0]}),
    .dio_o ({gpio_i[50:49], gpio_i[46:0]}),
    .dio_p ({ gpio_muxout_tx,
              gpio_muxout_rx,
              gpio_resetb,
              gpio_sync,
              gpio_en_agc,
              gpio_ctl,
              gpio_status,
              gpio_bd}));

  assign gpio_i[63:51] = gpio_o[63:51];
  assign gpio_i[48:47] = gpio_o[48:47];


  assign   TRX1_nTX_RX = 0;
  assign   RX1_TRX_nRX = 0;
  assign   RX2_nTRX_RX = 1;
  assign   TRX2_TX_nRX = 1;


  system_wrapper i_system_wrapper (
	.eth_rxerr(),
	.eth_tx_clk(),
    .eth_rxd(RGMII_rd),
    .eth_rx_dv(RGMII_rx_ctl),
    .eth_Rx_Clk(RGMII_rxc),
    .eth_txd(RGMII_td),
    .eth_tx_enable(RGMII_tx_ctl),
    .eth_gtx_Clk(RGMII_txc), 
    .clk_out(clk_out),
    .ddr_addr(ddr_addr),
    .ddr_ba(ddr_ba),
    .ddr_cas_n(ddr_cas_n),
    .ddr_ck_n(ddr_ck_n),
    .ddr_ck_p(ddr_ck_p),
    .ddr_cke(ddr_cke),
    .ddr_cs_n(ddr_cs_n),
    .ddr_dm(ddr_dm),
    .ddr_dq(ddr_dq),
    .ddr_dqs_n(ddr_dqs_n),
    .ddr_dqs_p(ddr_dqs_p),
    .ddr_odt(ddr_odt),
    .ddr_ras_n(ddr_ras_n),
    .ddr_reset_n(ddr_reset_n),
    .ddr_we_n(ddr_we_n),
    .fixed_io_ddr_vrn(fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp(fixed_io_ddr_vrp),
    .fixed_io_mio(fixed_io_mio),
    .fixed_io_ps_clk(fixed_io_ps_clk),
    .fixed_io_ps_porb(fixed_io_ps_porb),
    .fixed_io_ps_srstb(fixed_io_ps_srstb),
    .gpio_i(gpio_i),
    .gpio_o(gpio_o),
    .gpio_t(gpio_t),
    .otg_vbusoc(),
    .rx_clk_in_n(rx_clk_in_n),
    .rx_clk_in_p(rx_clk_in_p),
    .rx_data_in_n(rx_data_in_n),
    .rx_data_in_p(rx_data_in_p),
    .rx_frame_in_n(rx_frame_in_n),
    .rx_frame_in_p(rx_frame_in_p),
    .tdd_sync_i(1'b0),
    .tdd_sync_o(),
    .tdd_sync_t(),
    .spi0_clk_i(1'b0),
    .spi0_clk_o(spi_clk),
    .spi0_csn_0_o(spi_csn),
    .spi0_csn_i(1'b1),
    .spi0_sdi_i(spi_miso),
    .spi0_sdo_i(1'b0),
    .spi0_sdo_o(spi_mosi),
    .tx_clk_out_n(tx_clk_out_n),
    .tx_clk_out_p(tx_clk_out_p),
    .tx_data_out_n(tx_data_out_n),
    .tx_data_out_p(tx_data_out_p),
    .tx_frame_out_n(tx_frame_out_n),
    .tx_frame_out_p(tx_frame_out_p),
    .enable(enable),
    .txnrx(txnrx),
    .up_enable(gpio_o[47]),
    .up_txnrx(gpio_o[48])
	);


endmodule