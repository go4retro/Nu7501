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

//`define LATCH

module Fake7501(input _reset,
                input clock,
                input r_w_6502,
`ifdef LATCH                
                output r_w_7501,
`else                
                output r_w_7501,
`endif                
                input [15:0]address_6502,
                output [15:0]address_7501,
                inout [7:0]data_6502,
                inout [7:0]data_7501,
                input aec,
                input gate_in,
                inout [6:0]pio
               );
reg [6:0]data_pio;
reg [6:0]ddr_pio;
reg [7:0]data_6502_out;
reg [7:0]data_7501_out;
reg r_w_latched;

wire ce_pio =            ~|address_6502[15:1];
wire ce_0000 =           ce_pio & !address_6502[0];
wire ce_0001 =           ce_pio & address_6502[0];

assign address_7501 =      (aec ? address_6502 : 16'bz);
assign data_6502 =         data_6502_out;
assign data_7501 =         data_7501_out;
assign pio[6] =            (ddr_pio[6] ? data_pio[6] : 'bz);
assign pio[5] =            (ddr_pio[5] ? data_pio[5] : 'bz);
assign pio[4] =            (ddr_pio[4] ? data_pio[4] : 'bz);
assign pio[3] =            (ddr_pio[3] ? data_pio[3] : 'bz);
assign pio[2] =            (ddr_pio[2] ? data_pio[2] : 'bz);
assign pio[1] =            (ddr_pio[1] ? data_pio[1] : 'bz);
assign pio[0] =            (ddr_pio[0] ? data_pio[0] : 'bz);

assign r_w_7501 = (aec ? (ce_pio ? 'bz : r_w_6502) : 'bz);

always @(*)
begin
   if(aec & !ce_pio &!r_w_6502) // write cycle
   begin
      data_7501_out = data_6502;
      data_6502_out = 8'bz;
   end
	else if(aec & ce_pio &!r_w_6502) // write cycle to PIO
   begin
      data_7501_out = 8'bz;	//Do not write to peripherials
      data_6502_out = 8'bz;
   end
	else if (aec & ce_0000 & r_w_6502) // read PIO DDR
   begin
      data_7501_out = 8'bz;
      data_6502_out = {ddr_pio[6:5], 1'b0, ddr_pio[4:0]};
   end
   else if (aec & ce_0001 & r_w_6502) // read PIO value
   begin
      data_7501_out = 8'bz;
      data_6502_out = {pio[6:5], 1'b0, pio[4:0]};
   end
	else if (aec & r_w_6502) // read cycle
   begin
      data_7501_out = 8'bz;
      data_6502_out = data_7501;
   end
	else
	begin
		//aec active
		data_7501_out = 8'bz;
		data_6502_out = 8'bz;
	end
end

always @(negedge clock, negedge _reset)
begin
   if(!_reset)
   begin
      ddr_pio <= 0;
      data_pio <= 0;
   end
   else if(!r_w_6502 & ce_0000)
   begin
		//Write PIO direction
      ddr_pio <= {data_6502[7:6],data_6502[4:0]};
   end
   else if(!r_w_6502 & ce_0001)
   begin
		//Write data to PIO
      data_pio <= {data_6502[7:6],data_6502[4:0]};
   end
end

/*
always @(*)
begin
   if(aec & !ce_pio & clock & !r_w_6502) // write cycle
   begin
      data_7501_out = data_6502;
      data_6502_out = 8'bz;
   end
   else if (aec & ce_pio & clock & !r_w_6502) // emulate no data on PIO write
   begin
      data_7501_out = 8'bz;
      data_6502_out = 8'bz;
   end
   else if (aec & ce_0000 & clock & r_w_6502) // read PIO
   begin
      data_7501_out = 8'bz;
      data_6502_out = {pio[6:5],'b0,pio[4:0]};
   end
   else if (aec & ce_0001 & clock & r_w_6502) // read ddr
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
   else if(!r_w_6502 & ce_0000)
   begin
      data_pio <= {data_6502[7:6],data_6502[4:0]};
   end
   else if(!r_w_6502 & ce_0001)
   begin
      ddr_pio <= {data_6502[7:6],data_6502[4:0]};
   end
end
/*
`ifdef LATCH
assign r_w_7501 =          (aec ? r_w_latched : 'bz);

always @(gate_in, r_w_6502)
begin
   if(gate_in)
      r_w_latched = r_w_6502;
end

`else

always @(negedge gate_in)
begin
    r_w_latched <= r_w_6502;
end

always @(*)
begin
   if(aec & gate_in)
      r_w_7501 = r_w_6502;
   else if (aec & !gate_in)
      r_w_7501 = r_w_latched;
   else
      r_w_7501 = 'bz;
end

`endif
*/
endmodule
