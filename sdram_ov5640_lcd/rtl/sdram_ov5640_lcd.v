/*-------------------------------------------------------------------------
Filename			:		sdram_ov5640_lcd.v
Description			:		sdram vga controller with ov5640 display 480 * 272.
Modification History	:
Data			By			Version			Change Description
===========================================================================
15/02/1
--------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module sdram_ov5640_lcd
(
	//global clock 50MHz
	input			CLOCK,	
	input			rst_n,			//global reset
	
   input          key1,      //KEY1 input
	input          key2,      //KEY2 input
	input          key3,      //KEY2 input
	input          key4,      //KEY2 input
	//output	[3:0]	LED,		//led data input	

   //j2
   output               flash,
   output               frame,
   input                sensor1,
   input                sensor2,
   output               red_led_1,
   output               red_led_2, 
   output               green_led_1,
   output               green_led_2,
   output               green_led_3,

   //j3
   input                j3sensor1,
   input                j3sensor2,
   output               j3red_led_1,
   output               j3red_led_2, 
   output               j3green_led_1,
   output               j3green_led_2,
   output               j3green_led_3,		
	
	//smg: 7-Seg Indicator
	output  [7:0]           SMG_Data,
	output  [5:0]           Scan_Sig
 
);
//---------------------------------------------

reg [31:0] my_reg;
reg [31:0] my_speed;
reg my_reg_acceleration;
//wire flashwr;
//wire framewr;
//wire sensor1wr;
//wire sensor2wr;	 

reg red_led_1r;
reg red_led_2r; 
reg green_led_1r;
reg green_led_2r;
reg green_led_3r;	

reg j3red_led_1r;
reg j3red_led_2r; 
reg j3green_led_1r;
reg j3green_led_2r;
reg j3green_led_3r;	
  
//assign flash=flashwr;
//assign sensor2=sensor2wr;

assign red_led_1=red_led_1r;
assign red_led_2=red_led_2r; 
assign green_led_1=green_led_1r;
assign green_led_2=green_led_2r;
assign green_led_3=green_led_3r;	

assign j3red_led_1=j3red_led_1r;
assign j3red_led_2=j3red_led_2r; 
assign j3green_led_1=j3green_led_1r;
assign j3green_led_2=j3green_led_2r;
assign j3green_led_3=j3green_led_3r;	


//---------------------------------------------
wire [23:0] binaryDATA;
wire bn_test_clk;
wire bn_vga_clk;
//---------------------------------------------
wire  clk_camera;
wire	clk_vga;		//lcd clock
wire	clk_ref;		//sdram ctrl clock
wire	clk_refout;		//sdram clock output

wire	sys_rst_n;		//global reset

//---------------------------------
//---Clocking---
system_ctrl	u_system_ctrl
(
	.clk				(CLOCK),			//global clock  50MHZ
	.rst_n				(rst_n),		//external reset
	
	.sys_rst_n			(sys_rst_n),	//global reset
	.clk_c0				(clk_camera),	//24MHz
	.clk_c1				(clk_ref),	   //125MHz
	.clk_c2				(clk_refout),	//125MHz
	.clk_c3				(clk_vga),   	//96MHz //76MHz for Benq GW2265//65MHz-//9MHz LCD clock
	.bn_vga_clk       (bn_vga_clk),  //50Mhz fo VGA pll clock)
	.bn_test_clk      (bn_test_clk)  //12MHz //175MHz//24MHz
);
//--------------------------------- 
//---Power up delay part--- 
wire initial_en; 
power_on_delay	power_on_delay_inst(
	.clk_24M                 (clk_camera),
	.reset_n                 (sys_rst_n),	
	.camera_rstn             (),
	.camera_pwnd             (),
	.initial_en              (initial_en),
   .cmos_reset_bar          ()  	
);
//---------------------------------

//---------------------------------
//---Counter---
reg [15:0] regFiltr;
reg regTest;
assign frame=regTest;
reg regTest2;
assign flash=regTest2;

reg [15:0] keyCount;
reg [15:0] keyCountOld;
reg fl_key1;
//reg [15:0] keyCount2;
reg fl_key2;
reg fl_key3;
reg fl_key4;

reg [15:0] key1pushCount;
reg [15:0] key2pushCount;
reg [15:0] key3pushCount;
reg [15:0] key4pushCount;
//---
reg [31:0] counterTest1; 
reg [31:0] counterTest2;
reg [31:0] counterTest3;
reg [31:0] counterTestOld;

reg [31:0] counterSoftStop;

reg [31:0] counterTestAdd1;
reg [31:0] counterTestAdd2;
reg [31:0] counterTestAdd3;
reg [31:0] counterTestAdd4;

reg [31:0] counterTestAdd5;
reg [31:0] counterTestAdd6;
reg [31:0] counterTestAdd7;
reg [31:0] counterTestAdd8;

reg [31:0] counterTestAdds; 
 
reg [3:0]  fl_count1;
reg [3:0]  fl_count2;

reg fl_new_cnt;
reg fl_new_cnt2;
reg fl_invert; 
reg fl_invert2;
reg [23:0] binaryDATA2;
reg fl_start;
reg [7:0] fl_sum;
reg fl_startstop;
reg fl_anilox_stop;
reg fl_soft_stop;
reg fl_soft_stop2;

reg [31:0] counterAnilox; 

//==========================================
//always@ (posedge clk96MHz) //negedge clk96MHz
//always@ (posedge sensor1)
//always@ (posedge clk96MHz or negedge clk96MHz)
//always@ (posedge sensor1 or negedge sensor1)
//always@ (posedge clk96MHz or negedge clk96MHz)
//always@ (posedge clk_vga) //96 MHz
//(bn_test_clk)   //175MHz//24MHz
//(clk_camera),	//24MHz
//--------------
//always@ (posedge clk_ref)   //125MHz
//--------------
always@ (posedge bn_test_clk)   //12MHz//175MHz
//--------------
//always@ (posedge clk_vga)   //96MHz
//--------------
//always@ (posedge clk_camera)   //24MHz
begin
 if (initial_en==0) begin
	 my_reg<=0;
	 my_speed<=0;
	 my_reg_acceleration<=1;
	 regFiltr<=0;
	 regTest<=0;
	 regTest2<=0;

	 red_led_1r<=0; red_led_2r<=0; green_led_1r<=0; green_led_2r<=0; green_led_3r<=1;
	 j3red_led_1r<=0; j3red_led_2r<=0; j3green_led_1r<=0; j3green_led_2r<=0; j3green_led_3r<=0;
	 fl_startstop<=1;
	 fl_anilox_stop<=0;
	 fl_soft_stop<=0;
	 fl_soft_stop2<=0;
	 
	 keyCount<=1000;//540;
	 keyCountOld<=0;//540;
	 //binaryDATA2<=keyCount;
	 fl_key1<=0;

	 //keyCount2<=0;
	 fl_key2<=0;	
	 fl_key3<=0;
	 fl_key4<=0;
	 
	 fl_start<=0;

    counterTest1<=0; 
	 counterTest2<=0;
    counterTest3<=0;
    counterTestOld<=0;
	 
	 counterTestAdd1<=0;
	 counterTestAdd2<=0;
	 counterTestAdd3<=0;
	 counterTestAdd4<=0;
	 
	 counterTestAdd5<=0;
	 counterTestAdd6<=0;
	 counterTestAdd7<=0;
	 counterTestAdd8<=0;
	 
	 counterTestAdds<=0;
	 
	 counterAnilox<=0;
	 
	 counterSoftStop<=0;
	 
	 fl_sum<=0;
	 
    fl_count1<=0;	
    fl_count2<=0;	

    fl_new_cnt<=0;
    fl_new_cnt2<=0;
    fl_invert<=0;	
	 fl_invert2<=0;	

    key1pushCount<=0;
    key2pushCount<=0;
	 key3pushCount<=0;
    key4pushCount<=0;
	 
 end
 else begin
   
	/*
 	//Flash-test
   //if (sensor1==0) begin
	if (sensor1==1) begin
       regTest<=1; 
		 red_led_1r<=1;
	end //if (sensor1>0)
	else begin
       regTest<=0;
		 red_led_1r<=0;
	end
	*/
  //---------------------------------------------------
 
  //sensor2 Start/Stop
  if ((sensor2==1)||(fl_soft_stop==1)||(fl_soft_stop2==1)) begin 
    //Stop
    fl_startstop<=1; 
	 red_led_1r<=1;
	 green_led_3r<=0;	
	 //regTest<=0;
	 //Stop Motor-Start Anilox
  end 
  //else begin
  if ((sensor2==0)&&(fl_soft_stop==0)&&(fl_soft_stop2==0)) begin 
    //Start
    fl_startstop<=0;
	 red_led_1r<=0;
    green_led_3r<=1;
  end  
  //---------------------------------------------------
    if (j3sensor1==1) begin 
    //Stop Anilox
    fl_anilox_stop<=1; 
	 j3red_led_1r<=1;
	 j3green_led_3r<=0;	
	 //regTest<=0;
	 //Stop Motor-Start Anilox
  end 
  else begin
    //Start Anilox
    fl_anilox_stop<=0;
	 j3red_led_1r<=0;
    j3green_led_3r<=1;
  end  
 
  //===================================================
  if (fl_sum==1) begin
    counterTestAdd8<=counterTestAdd7;
    fl_sum<=2;
  end
  if (fl_sum==2) begin
    counterTestAdd7<=counterTestAdd6;
    fl_sum<=3;
  end
  if (fl_sum==3) begin
    counterTestAdd6<=counterTestAdd5;
    fl_sum<=4;
  end
  if (fl_sum==4) begin
    counterTestAdd5<=counterTestAdd4;
    fl_sum<=5;
  end 
  if (fl_sum==5) begin
    counterTestAdd4<=counterTestAdd3;
    fl_sum<=6;
  end 
  if (fl_sum==6) begin
    counterTestAdd3<=counterTestAdd2;
    fl_sum<=7;
  end
  if (fl_sum==7) begin
    counterTestAdd2<=counterTestAdd1;
    fl_sum<=8;
  end
  if (fl_sum==8) begin
    counterTestAdd1<=counterTest1;
    fl_sum<=9;
  end
  if (fl_sum==9) begin
    counterTestAdds<=(counterTestAdd1+counterTestAdd2+counterTestAdd3+counterTestAdd4+counterTestAdd5+counterTestAdd6+counterTestAdd7+counterTestAdd8)>>3;
    fl_sum<=10;
  end 
  //test 7
  if ((sensor1==0) && (fl_count1==0)) begin
     fl_count1<=1;
     fl_count2<=0;
	  if ((fl_new_cnt==1)&& (fl_sum==0)) begin
	     fl_sum<=1;
	  end
	  if ((fl_new_cnt==1)&& (fl_sum==10)) begin

		  //counterTest3<=counterTest1*keyCount/10000;
		  //counterTestAdd8<=counterTestAdd7;
		  //counterTestAdd7<=counterTestAdd6;
		  //counterTestAdd6<=counterTestAdd5;
		  //counterTestAdd5<=counterTestAdd4;
		  //counterTestAdd4<=counterTestAdd3;
		  //counterTestAdd3<=counterTestAdd2;
		  //counterTestAdd2<=counterTestAdd1;
		  //counterTestAdd1<=counterTest1;
		  //counterTestAdds<=(counterTestAdd1+counterTestAdd2+counterTestAdd3+counterTestAdd4+counterTestAdd5+counterTestAdd6+counterTestAdd7+counterTestAdd8)>>3;
        counterTest3<=counterTestAdds*keyCount/10000;
        		  
		  fl_new_cnt<=0;
		  fl_new_cnt2<=1;
		  counterTest2<=0;
		  fl_sum<=0;
	  end  
  end
  if ((sensor1==1) && (fl_count1==1)) begin
     counterTest1<=0; 
	  fl_count1<=0;
	  fl_count2<=1;
  end
  //---------------------------------------
  /*
  if ((sensor1==1) && (fl_count2==1)) begin
     //if (counterTest1 < 325000) begin 
	  if (counterTest1 < 500000) begin 
	     counterTest1<=counterTest1+1;
		  fl_new_cnt<=1;
		  fl_soft_stop<=0;
		  red_led_2r<=0;
        green_led_2r<=1;
		  //binaryDATA2<=0;
	  end
     else begin //soft stop
	     fl_new_cnt2<=0;
		  //---
		  fl_count1<=1;
		  //----
		  fl_soft_stop<=1;
		  //----
		  red_led_2r<=1;
        green_led_2r<=0;
		  //binaryDATA2<=counterTest1;
		  //counterTest1<=0;
     end 	  
  end; 
  */
  //---------------------------------------
  if (sensor1==1) begin
     green_led_1r<=1;
	  counterSoftStop<=0;
	  fl_soft_stop2<=0;
	  //if (counterSoftStop<500000) begin
	     //counterSoftStop<=counterSoftStop+1;
	  //end
	  //else begin
	     //counterSoftStop<=0;
	  //end
  end
  else begin
     green_led_1r<=0;
	  if (counterSoftStop<500000) begin//300000
	     counterSoftStop<=counterSoftStop+1;
	  end
	  else begin
	     counterSoftStop<=0;
		  fl_soft_stop2<=1;
	  end
  end
  //--------------------------------------  
  if ((sensor1==1) && (fl_count2==1)) begin
	     counterTest1<=counterTest1+1;
		  fl_new_cnt<=1;
		  fl_soft_stop<=0;
		  red_led_2r<=0;
        green_led_2r<=1;
   end
   if (counterTest1 > 500000) begin//300000
	     fl_new_cnt2<=0;
		  fl_count1<=1;
		  fl_soft_stop<=1;
		  red_led_2r<=1;
        green_led_2r<=0;
   end	
  //-----------------------------------------------
  //if ((sensor1==1) && (fl_sum==1)) begin
    //counterTestAdds<=(counterTestAdd1+counterTestAdd2+counterTestAdd3+counterTestAdd4)>>2;
    //fl_sum<=0;
  //end;
  //---------------------------------------------
	//Anilox speed generator
	if (my_reg > 0) begin
		my_reg <= my_reg - 1;	//my_reg_acceleration
	end
	else begin
		my_reg <= 3300000;
		
		if (my_reg_acceleration > 0) begin						// 0 or 1 (1 - speed positiv)
			if (my_speed > 80) begin
				my_reg_acceleration <= my_reg_acceleration + 1;		// direction invert
			end	
			else
				my_speed <= my_speed + 1;
		end
		else begin
			if (my_speed < 1) begin
				my_reg_acceleration <= my_reg_acceleration + 1;
			end	
			else
				my_speed <= my_speed - 1;
		end
	end
	
	if (counterAnilox < (120 - my_speed) ) begin 			//2000 small//300000 - very small speed
		counterAnilox<=counterAnilox+1;
	end
	else begin
		counterAnilox<=0;
		fl_invert2<=fl_invert2+1;
	end
	
  //---------------------------------------------
  if (fl_startstop==0) begin 
         //Print ON
		   regTest<=fl_invert;
  end
  //if ((fl_soft_stop==1)||(fl_startstop==1)) begin
  else begin
         //Print OFF
			//------------------------
		   //fl_new_cnt<=0;
		   //fl_new_cnt2<=1;
		   //counterTest2<=0;
		   //fl_sum<=0;			
			//------------------------
			if (fl_anilox_stop==0) begin
			   //anilox on
				regTest<=fl_invert2;
			end
			else begin
			   //anilox off
			end
  end
  //---------------------------------------------
  if (fl_new_cnt2==1) begin
    if (counterTest2<counterTest3) begin //no stop
	    counterTest2<=counterTest2+1;
	    //regTest<=fl_invert;
		 //Flex Stop 
		 //if (fl_startstop==0) begin 
		     //regTest<=fl_invert;
	    //end
       /*		 
       else begin
		   if (counterAnilox<300000) begin
			   counterAnilox<=counterAnilox+1;
			end
			else begin
			   counterAnilox<=0;
				if (regTest==0) regTest<=1;
				else regTest<=0;
			end 
       end 
      */		 
	 end
	 else begin
	    counterTest2<=0;
		 //if (fl_soft_stop==0) 
		 fl_invert<=fl_invert+1;
	 end
  end
  //----------------------------------------------------
  //key1 -10
  //----------------------------------------------------
  if ((key1==0)&& (fl_key1==0)) begin //button pressed
    fl_key1<=1; 
	 if (keyCount>100) begin
		 keyCount<=keyCount-10;
		 //binaryDATA2<=keyCount;
		 key1pushCount<=0;
	 end
  end	
  if ((key1==1)&& (fl_key1==1)) begin //button released
    if (key1pushCount<1000) key1pushCount<=key1pushCount+1; 
    else fl_key1<=0; 
  end	
  //----------------------------------------------------
  //key2 -1
  //----------------------------------------------------
  if ((key2==0)&& (fl_key2==0)) begin //button pressed
    fl_key2<=1; 
	 if (keyCount>100) begin
		 keyCount<=keyCount-1;
		 //binaryDATA2<=keyCount;
		 key2pushCount<=0;
	 end
  end	
  if ((key2==1)&& (fl_key2==1)) begin //button  released
    if (key2pushCount<1000) key2pushCount<=key2pushCount+1; 
    else fl_key2<=0; 
  end		  
  //----------------------------------------------------
  //key3 +1
  //----------------------------------------------------
  if ((key3==0)&& (fl_key3==0)) begin //button pressed
    fl_key3<=1; 
	 if (keyCount<2000) begin
		 keyCount<=keyCount+1;
		 //binaryDATA2<=keyCount;
		 key3pushCount<=0;
	 end
  end	
  if ((key3==1)&& (fl_key3==1)) begin //button released
    if (key3pushCount<1000) key3pushCount<=key3pushCount+1;
    else fl_key3<=0; 
  end	
  //----------------------------------------------------
  //key4 +10
  //----------------------------------------------------
  if ((key4==0)&& (fl_key4==0)) begin //button pressed
    fl_key4<=1; 
	 if (keyCount<2000) begin
		 keyCount<=keyCount+10;
		 //binaryDATA2<=keyCount;
		 key4pushCount<=0;
	 end
  end	
  if ((key4==1)&& (fl_key4==1)) begin //button released
    if (key4pushCount<1000) key4pushCount<=key4pushCount+1;
    else fl_key4<=0; 
  end	
  //====================================================
  if (keyCount!=keyCountOld) begin
     binaryDATA2<=keyCount;
	  keyCountOld<=keyCount;	  
  end
  
 end //else if (initial_en==0)
 
end

//---------------------------------
//---smg: 6 digit led indicator----
//reg [23:0] binaryDATA2=123456; 
smg_interface_demo u4(

		.CLK         (bn_vga_clk),
		.RSTn        (sys_rst_n),
	   .SMG_Data    (SMG_Data),
	 	.Scan_Sig    (Scan_Sig),
		.binaryDATA  (binaryDATA2)
);
//---------------------------------
endmodule
