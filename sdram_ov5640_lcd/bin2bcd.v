`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:09:04 02/15/2017 
// Design Name: 
// Module Name:    bin2bcd 
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
module bin2bcd(
            input [7:0] A,
				output [3:0] sgZ0,
				output [3:0] sgZ1,
				output [3:0] sgZ2);

wire [3:0] c1,c2,c3,c4,c5;
wire [3:0] d1,d2,d3,d4,d5;

assign d1 = {1'b0,A[7:5]};
assign d2 = {c1[2:0],A[4]};
assign d3 = {c2[2:0],A[3]};
assign d4 = {c3[2:0],A[2]};
assign d5 = {c4[2:0],A[1]};
add3 m1(d1,c1);
add3 m2(d2,c2);
add3 m3(d3,c3);
add3 m4(d4,c4);
add3 m5(d5,c5);
assign sgZ0 = {c5[2:0],A[0]};
assign sgZ1 = {c2[3],c3[3],c4[3],c5[3]};
assign sgZ2 = {c1[3:0]};
endmodule

