/*-------------------------------------------------------------------------
Description			:		sdram test with uart interface.
Modification History	:
Data			By			Version			Change Description
===========================================================================

--------------------------------------------------------------------------*/

`timescale 1ns/1ns
module CMOS_Capture
(
	//Global Clock
	input				iCLK,			//24MHz
	input				iRST_N,

	//I2C Initilize Done
	input				Init_Done,		//Init Done
	
	//Sensor Interface
	output				CMOS_XCLK,		//24MHz
	input				CMOS_PCLK,		//24MHz
	input	[7:0]		CMOS_iDATA,		//CMOS Data
	input				invCMOS_VSYNC,		//L: Vaild
	input				invCMOS_HREF,		//H: Vaild
	
	//Ouput Sensor Data
/*	
	output	reg			CMOS_oCLK,		//1/2 PCLK
	output	reg	[15:0]	CMOS_oDATA,		//16Bits RGB		
	output	reg			CMOS_VALID,		//Data Enable
	output	reg	[7:0]	CMOS_FPS_DATA,	//cmos fps
*/	
   input wire frameDelay,

	input [11:0] in_cmos_vs_cnt,
	input [11:0] in_cmos_hs_cnt
   //output  [23:0] binaryDATA	
);

assign	CMOS_XCLK = iCLK;		//24MHz XCLK

wire		CMOS_VSYNC;		//L: Vaild
wire		CMOS_HREF;		//H: Vaild

assign   CMOS_VSYNC=~invCMOS_VSYNC;
assign   CMOS_HREF=~invCMOS_HREF;

//reg [23:0] rg_binaryDATA; 
//reg [23:0] rg_binaryDATA_tmp; 
//reg fl_stop;
//assign binaryDATA=rg_binaryDATA;

//-----------------------------------------------------
//同步输入//Sensor HS & VS Vaild Capture
/**************************************************
________							       ________
VS		|_________________________________|
HS			  _______	 	   _______
_____________|       |__...___|       |____________
**************************************************/
/*
//----------------------------------------------
reg		mCMOS_VSYNC;
always@(posedge CMOS_PCLK)// or negedge iRST_N)
begin
	//if(!iRST_N)
	if (frameDelay==0)
		mCMOS_VSYNC <= 1;
	else
		mCMOS_VSYNC <= CMOS_VSYNC;		//场同步：低电平有效
end
wire	CMOS_VSYNC_over = ({mCMOS_VSYNC,CMOS_VSYNC} == 2'b01) ? 1'b1 : 1'b0;	//VSYNC上升沿结束

//-----------------------------------------------------
//Change the sensor data from 8 bits to 16 bits.

reg			byte_state;		//byte state count
reg [7:0]  	Pre_CMOS_iDATA;
//reg [19:0]  data_count;
always@(posedge CMOS_PCLK)// or negedge iRST_N)
begin
	//if(!iRST_N)
	if (frameDelay==0)
		begin
		byte_state <= 0;
		Pre_CMOS_iDATA <= 8'd0;
		CMOS_oDATA <= 16'd0;
		//fl_stop<=0;
		//rg_binaryDATA_tmp<=0;
		//rg_binaryDATA<=0;
		//data_count<=0;
		end
	else
		begin
		 if(CMOS_VSYNC & CMOS_HREF)			//行场有效，{first_byte, second_byte} 
			begin
			//if (fl_stop==0) rg_binaryDATA_tmp<=rg_binaryDATA_tmp+1; 
			//if (Pre_CMOS_iDATA<255) Pre_CMOS_iDATA<=Pre_CMOS_iDATA+1;
			//else Pre_CMOS_iDATA<=0;
			byte_state <= byte_state + 1'b1;	//（RGB565 = {first_byte, second_byte}）
			case(byte_state)
			1'b0 :	CMOS_oDATA[7:0]<=CMOS_iDATA;//Pre_CMOS_iDATA[7:0] <= CMOS_iDATA;
			1'b1 : 	CMOS_oDATA[7:0]<=CMOS_iDATA;//CMOS_oDATA[15:0] <= {Pre_CMOS_iDATA[7:0], CMOS_iDATA[7:0]};
			endcase
			end
		 else
			begin
			//if (fl_stop==0) begin
			  //fl_stop<=1;
			  //rg_binaryDATA<=rg_binaryDATA_tmp;
			//end;  
			byte_state <= 0;
			Pre_CMOS_iDATA <= 8'd0;
			CMOS_oDATA <= CMOS_oDATA;
			end
		 end
end

//--------------------------------------------
//Wait for Sensor output Data valid， 10 Franme
reg	[3:0] 	Frame_Cont;
reg 		Frame_valid;
always@(posedge CMOS_PCLK)// or negedge iRST_N)
begin
	//if(!iRST_N)
	if (frameDelay==0) begin
		Frame_Cont <= 0;
		Frame_valid <= 0;
	end
	//else if(Init_Done)					//CMOS I2C初始化完毕
	else
		begin
		 //if (CMOS_VSYNC==1)	Frame_valid <= 1;
		 Frame_valid <= 1;
		end
end

//-----------------------------------------------------
//CMOS_DATA数据同步输出使能时钟
always@(posedge CMOS_PCLK)// or negedge iRST_N)
begin
	//if(!iRST_N)
	if (frameDelay==0)
		CMOS_oCLK <= 0;
	else if(Frame_valid == 1'b1 && byte_state)//(X_Cont >= 12'd1 && X_Cont <= H_DISP))
		CMOS_oCLK <= ~CMOS_oCLK;
	else
		CMOS_oCLK <= 0;
end

//----------------------------------------------------
//数据输出有效CMOS_VALID
always@(posedge CMOS_PCLK)// or negedge iRST_N)
begin
	//if(!iRST_N)
	if (frameDelay==0)
		CMOS_VALID <= 0;
	else if(Frame_valid == 1'b1)
		CMOS_VALID <= CMOS_VSYNC;
	else
		CMOS_VALID <= 0;
end
*/
endmodule



