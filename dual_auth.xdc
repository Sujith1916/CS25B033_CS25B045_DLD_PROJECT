## =====================================================
## DUAL AUTHORIZATION SECURITY SYSTEM
## EDGE ARTIX-7 FPGA DEVELOPMENT BOARD
## FPGA: XC7A35T-1FTG256C
## Vivado Part: xc7a35tftg256-1
## =====================================================

## Configuration voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


## =====================================================
## 50 MHz CLOCK
## =====================================================

set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports { clk }]

create_clock -period 20.000 -name sys_clk_pin \
    -waveform {0.000 10.000} [get_ports { clk }]


## =====================================================
## 16 SLIDE SWITCHES
## switches[0]  = SW3
## switches[15] = SW18
## =====================================================

set_property -dict { PACKAGE_PIN L5 IOSTANDARD LVCMOS33 } [get_ports { switches[0] }]
set_property -dict { PACKAGE_PIN L4 IOSTANDARD LVCMOS33 } [get_ports { switches[1] }]
set_property -dict { PACKAGE_PIN M4 IOSTANDARD LVCMOS33 } [get_ports { switches[2] }]
set_property -dict { PACKAGE_PIN M2 IOSTANDARD LVCMOS33 } [get_ports { switches[3] }]

set_property -dict { PACKAGE_PIN M1 IOSTANDARD LVCMOS33 } [get_ports { switches[4] }]
set_property -dict { PACKAGE_PIN N3 IOSTANDARD LVCMOS33 } [get_ports { switches[5] }]
set_property -dict { PACKAGE_PIN N2 IOSTANDARD LVCMOS33 } [get_ports { switches[6] }]
set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS33 } [get_ports { switches[7] }]

set_property -dict { PACKAGE_PIN P1 IOSTANDARD LVCMOS33 } [get_ports { switches[8] }]
set_property -dict { PACKAGE_PIN P4 IOSTANDARD LVCMOS33 } [get_ports { switches[9] }]
set_property -dict { PACKAGE_PIN T8 IOSTANDARD LVCMOS33 } [get_ports { switches[10] }]
set_property -dict { PACKAGE_PIN R8 IOSTANDARD LVCMOS33 } [get_ports { switches[11] }]

set_property -dict { PACKAGE_PIN N6 IOSTANDARD LVCMOS33 } [get_ports { switches[12] }]
set_property -dict { PACKAGE_PIN T7 IOSTANDARD LVCMOS33 } [get_ports { switches[13] }]
set_property -dict { PACKAGE_PIN P8 IOSTANDARD LVCMOS33 } [get_ports { switches[14] }]
set_property -dict { PACKAGE_PIN M6 IOSTANDARD LVCMOS33 } [get_ports { switches[15] }]


## =====================================================
## PUSH BUTTONS
## ENTER = SW21 (TOP)
## RESET = SW22 (CENTRE)
## =====================================================

set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { enter_btn }]

set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { reset_btn }]


## =====================================================
## 16x2 LCD DISPLAY
## CONNECTOR J7
## =====================================================

## LCD DATA DB0 - DB7

set_property -dict { PACKAGE_PIN T4 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[0] }]
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[1] }]
set_property -dict { PACKAGE_PIN R3 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[2] }]
set_property -dict { PACKAGE_PIN R1 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[3] }]

set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[4] }]
set_property -dict { PACKAGE_PIN N4 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[5] }]
set_property -dict { PACKAGE_PIN M5 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[6] }]
set_property -dict { PACKAGE_PIN P3 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[7] }]


## LCD CONTROL

set_property -dict { PACKAGE_PIN P5 IOSTANDARD LVCMOS33 } [get_ports { lcd_rs }]
set_property -dict { PACKAGE_PIN T3 IOSTANDARD LVCMOS33 } [get_ports { lcd_e }]


## =====================================================
## END OF CONSTRAINTS
## =====================================================