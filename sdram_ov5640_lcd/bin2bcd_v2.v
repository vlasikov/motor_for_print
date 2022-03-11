`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:07:29 02/15/2017 
// Design Name: 
// Module Name:    bin2bcd_v2 
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
module bin2bcd_v2(
            input [23:0] binary,
				output reg [3:0] sgZ0,
				output reg [3:0] sgZ1,
				output reg [3:0] sgZ2,
				output reg [3:0] sgZ3,
				output reg [3:0] sgZ4,
				output reg [3:0] sgZ5				
				);
integer i;
always @(binary)
begin
  sgZ5=4'd0;
  sgZ4=4'd0;
  sgZ3=4'd0;
  sgZ2=4'd0;
  sgZ1=4'd0;
  sgZ0=4'd0;
  for (i=23; i>=0; i=i-1)
  begin
     //add 3 to columns>=5
	  if (sgZ5>=5) sgZ5=sgZ5+3;
	  if (sgZ4>=5) sgZ4=sgZ4+3;
	  if (sgZ3>=5) sgZ3=sgZ3+3;
	  if (sgZ2>=5) sgZ2=sgZ2+3;
	  if (sgZ1>=5) sgZ1=sgZ1+3;
	  if (sgZ0>=5) sgZ0=sgZ0+3;
	  
	  //shift left one
	  sgZ5=sgZ5<<1;
	  sgZ5[0]=sgZ4[3];	  
	  sgZ4=sgZ4<<1;
	  sgZ4[0]=sgZ3[3];	  
	  sgZ3=sgZ3<<1;
	  sgZ3[0]=sgZ2[3];
	  
	  sgZ2=sgZ2<<1;
	  sgZ2[0]=sgZ1[3];
	  sgZ1=sgZ1<<1;
	  sgZ1[0]=sgZ0[3];
	  sgZ0=sgZ0<<1;
	  sgZ0[0]=binary[i];
  end
end				
endmodule
