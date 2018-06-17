`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:25:29 06/17/2018 
// Design Name: 
// Module Name:    Fake7501 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Fake7501(input _reset,
                input clock,
                input r_w_6502,
                output r_w_7501,
                input [15:0]address_6502,
                output [15:0]address_7501,
                inout [7:0]data_6502,
                inout [7:0]data_7501,
                input aec,
                output _rdy_6502,
                input _rdy_7501,
                inout [6:0]pio
               );
wire ce_pio;
wire ce_0000;
wire ce_0001;
reg [6:0]data_pio;
reg [6:0]ddr_pio;
reg [7:0]data_6502_out;
reg [7:0]data_7501_out;

assign ce_pio =            (address_6502[15:1] == 0);
assign ce_0000 =           ce_pio & !address_6502[0];
assign ce_0001 =           ce_pio & address_6502[0];

assign address_7501 =      (aec ? address_6502 : 16'bz);
assign data_6502 =         data_6502_out;
assign data_7501 =         data_7501_out;
assign r_w_7501 =          (aec ? r_w_6502 : 'bz);
assign _rdy_6502 =         _rdy_7501;
assign pio[6] =            (ddr_pio[6] ? data_pio[6] : 'bz);
assign pio[5] =            (ddr_pio[5] ? data_pio[5] : 'bz);
assign pio[4] =            (ddr_pio[4] ? data_pio[4] : 'bz);
assign pio[3] =            (ddr_pio[3] ? data_pio[3] : 'bz);
assign pio[2] =            (ddr_pio[2] ? data_pio[2] : 'bz);
assign pio[1] =            (ddr_pio[1] ? data_pio[1] : 'bz);
assign pio[0] =            (ddr_pio[0] ? data_pio[0] : 'bz);

always @(*)
begin
   if(!ce_pio & clock & !r_w_6502) // write cycle
   begin
      data_7501_out = data_6502;
      data_6502_out = 8'bz;
   end
   else if (ce_pio & clock & !r_w_6502) // emulate no data on PIO write
   begin
      data_7501_out = 8'bz;
      data_6502_out = 8'bz;
   end
   else if (ce_0000 & clock & r_w_6502) // read PIO
   begin
      data_7501_out = 8'bz;
      data_6502_out = {pio[6:5],'b0,pio[4:0]};
   end
   else if (ce_0001 & clock & r_w_6502) // read ddr
   begin
      data_7501_out = 8'bz;
      data_6502_out = {ddr_pio[6:5],'b0,ddr_pio[4:0]};
   end
   else
   begin
      data_7501_out = 8'bz;
      data_6502_out = data_7501;
   end
end

always @(negedge clock, negedge _reset)
begin
   if(!_reset)
   begin
      ddr_pio <= 0;
      data_pio <= 0;
   end
   else if(r_w_6502 & ce_0000)
   begin
      data_pio <= {data_6502[7:6],data_6502[4:0]};
   end
   else if(r_w_6502 & ce_0001)
   begin
      ddr_pio <= {data_6502[7:6],data_6502[4:0]};
   end
end

endmodule
