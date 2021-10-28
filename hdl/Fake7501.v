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
assign data_6502 =          data_6502_out;
assign data_7501 =          data_7501_out;
assign pio[6] =            (ddr_pio[6] ? data_pio[6] : 'bz);
assign pio[5] =            (ddr_pio[5] ? data_pio[5] : 'bz);
assign pio[4] =            (ddr_pio[4] ? data_pio[4] : 'bz);
assign pio[3] =            (ddr_pio[3] ? data_pio[3] : 'bz);
assign pio[2] =            (ddr_pio[2] ? data_pio[2] : 'bz);
assign pio[1] =            (ddr_pio[1] ? data_pio[1] : 'bz);
assign pio[0] =            (ddr_pio[0] ? data_pio[0] : 'bz);

assign r_w_7501 = (aec ? (r_w_latched ? 'bz : r_w_6502) : 'bz);

always @(posedge gate_in)
begin
	if(!aec)
		begin
			r_w_latched = 'b1;
		end
	else
		begin
			r_w_latched = 'b0;
		end
end

always @(*)
begin
	if(!aec)
		begin
			data_7501_out = 8'bz;
			data_6502_out = 8'bz;
		end
	else if (ce_0000 & r_w_6502) // read PIO DDR
		begin
			data_7501_out = 8'bz;
			data_6502_out = {ddr_pio[6:5], 1'b0, ddr_pio[4:0]};
		end
	else if (ce_0001 & r_w_6502) // read PIO value
		begin
			data_7501_out = 8'bz;
			data_6502_out = {pio[6:5], 1'b0, pio[4:0]};
		end
	else if(r_w_6502)
	//Read from outside
		begin
			data_7501_out = 8'bz;
			data_6502_out = data_7501;
		end
	else
	//Write to outside
		begin
			data_7501_out = data_6502;
			data_6502_out = 8'bz;
		end 
end

//PIO write 
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

endmodule
