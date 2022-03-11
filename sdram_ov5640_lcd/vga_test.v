`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:19:09 02/02/2017 
// Design Name: 
// Module Name:    vga_test 
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
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    vga_test 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_test(
			input  vga_clk,
			output vga_hs,
			output vga_vs,
			output [4:0] vga_r,
			output [5:0] vga_g,
			output [4:0] vga_b,
			input key3,  //Key key3
	      //----------------------------
	      input CMOS_VSYNC,		//cmos vsync
	      input CMOS_HREF,		//cmos hsync refrence
	      input CMOS_PCLK,		//cmos pxiel clock
	      input CMOS_XCLK,		//cmos externl clock
	      input [7:0]CMOS_DB,	//cmos data
	      input cmos_rst_n,		//cmos reset

			output vga_CMOS_XCLK,   
			output vga_CMOS_PCLK,  
			output vga_CMOS_HREF,  
			output vga_CMOS_VSYNC,   
			output vga_CMOS_DB03  			
    );
//-----------------------------------------------------------//
// Horizontal scan parameters 1024*768 60Hz VGA
//-----------------------------------------------------------//
parameter LinePeriod =1344;            //Number of rows
parameter H_SyncPulse=136;             //Line sync pulse (Sync a)
parameter H_BackPorch=160;             //Display trailing edge (Back porch b)
parameter H_ActivePix=1024;            //display interval (Display interval c)
parameter H_FrontPorch=24;             //Display front(Front porch d)
parameter Hde_start=296;
parameter Hde_end=1320;

//-----------------------------------------------------------//
// Vertical scan parameters 1024*768 60Hz VGA
//-----------------------------------------------------------//
parameter FramePeriod =806;           //Cycle number
parameter V_SyncPulse=6;              //Column sync pulse(Sync o)
parameter V_BackPorch=29;             //Display trailing edge(Back porch p)
parameter V_ActivePix=768;            //display interval(Display interval q)
parameter V_FrontPorch=3;             //Display front(Front porch r)
parameter Vde_start=35;
parameter Vde_end=803;

//-----------------------------------------------------------//
// Horizontal scan parameters 800*600 VGA
//-----------------------------------------------------------//
//parameter LinePeriod =1056;           //Number of rows
//parameter H_SyncPulse=128;            //Line synchronizing pulse(Sync a)
//parameter H_BackPorch=88;             //Display trailing edge(Back porch b)
//parameter H_ActivePix=800;            //display interval(Display interval c)
//parameter H_FrontPorch=40;            //Display front(Front porch d)

//-----------------------------------------------------------//
// Vertical scan parameters 800*600 VGA
//-----------------------------------------------------------//
//parameter FramePeriod =628;           //Cycle number
//parameter V_SyncPulse=4;              //Column sync pulse(Sync o)
//parameter V_BackPorch=23;             //Display trailing edge(Back porch p)
//parameter V_ActivePix=600;            //display interval(Display interval q)
//parameter V_FrontPorch=1;             //Display front(Front porch r)


  reg[10 : 0] x_cnt;
  reg[9 : 0]  y_cnt;
  reg[15 : 0] grid_data_1;
  reg[15 : 0] grid_data_2;
  reg[15 : 0] bar_data;
  reg[3 : 0] vga_dis_mode;
  reg[4 : 0]  vga_r_reg;
  reg[5 : 0]  vga_g_reg;
  reg[4 : 0]  vga_b_reg;  
  reg hsync_r;
  reg vsync_r; 
  reg hsync_de;
  reg vsync_de;
  
  reg [15:0] key3_counter;                 //Key detection register
  
  //wire vga_clk;
  //wire CLK_OUT1; 
  
///test
  reg rg_CMOS_XCLK;
  reg [7:0] cn_CMOS_XCLK;
  
  reg rg_CMOS_PCLK;
  reg [11:0] cn_CMOS_PCLK; 
//---------------------------
  reg [4:0] img_dat [0:2499];//[0:307199];//640x480// [0:2499]; //50x50
  reg [11:0] cnt_img_dat;
  //reg [11:0] cnt_hs;
  //reg [11:0] cnt_vs;
//---------------------------  
  
assign vga_CMOS_XCLK=rg_CMOS_XCLK;   
assign vga_CMOS_PCLK=rg_CMOS_PCLK;  
assign vga_CMOS_HREF=CMOS_HREF;  
assign vga_CMOS_VSYNC=CMOS_VSYNC;   
assign vga_CMOS_DB03=CMOS_DB[3];  	

///---  в тесте соотношение сигналов на выходах
// CMOS_XCLK и CMOS_PCLK  приблизительно 1/3, XCLK=24 MHz, PCLK=72 MHz  
always @ (posedge CMOS_XCLK or negedge cmos_rst_n)
  begin
   if(!cmos_rst_n) begin
       cn_CMOS_XCLK<=0; 
		 rg_CMOS_XCLK<=0;
   end
	else begin
	   if (cn_CMOS_XCLK<8) cn_CMOS_XCLK<=cn_CMOS_XCLK+1;
      else begin
       cn_CMOS_XCLK<=0; 
		 rg_CMOS_XCLK<=~rg_CMOS_XCLK;		
      end;		
	end;
  end
//  
always @ (posedge CMOS_PCLK or negedge cmos_rst_n)
  begin
   if(!cmos_rst_n) begin
       cn_CMOS_PCLK<=0; 
		 rg_CMOS_PCLK<=0;
   end
	else begin
	   if (cn_CMOS_PCLK<8) cn_CMOS_PCLK<=cn_CMOS_PCLK+1;
      else begin
       cn_CMOS_PCLK<=0; 
		 rg_CMOS_PCLK<=~rg_CMOS_PCLK;		
      end;		
	end;
  end	  
//---end test----
//---test 2------
//-----------------------------------------------------
//Change the sensor data from 8 bits to 16 bits.
reg [1:0] 	byte_state;		//byte state count
//reg [7:0]  	Pre_CMOS_iDATA;
reg [15:0]	CMOS_oDATA;		//16Bits RGB

always@(posedge CMOS_PCLK or negedge cmos_rst_n)
begin
	if(!cmos_rst_n)
		begin
		byte_state <= 0;
		//Pre_CMOS_iDATA <= 8'd0;
		CMOS_oDATA <= 16'd0;
      //cnt_img_dat<=0;
      //cnt_hs<=0;
      //cnt_vs<=0;		
		end
	else
		begin
      if(CMOS_VSYNC & CMOS_HREF)	//Line field effective,{first_byte, second_byte}	
			begin
			//if (cnt_vs<=0;
			//byte_state <= byte_state + 1'b1;	//(rgb565 = {first _ bytes, second _ bytes))
			case(byte_state)
				0:	begin
				     CMOS_oDATA[4:0] <= CMOS_DB[4:0];
					  byte_state <=1;
					end  
				1:	begin
				     CMOS_oDATA[10:5] <= CMOS_DB[7:2];
					  byte_state <=2;
					end 
				2:	begin
				     CMOS_oDATA[15:11] <= CMOS_DB[7:3];
					  byte_state <=3;
					end 
				3:	begin
				     //CMOS_oDATA[4:0] <= CMOS_DB[4:0];
					  byte_state <=0;
					end 					
			endcase
			end
		else
			begin
			   byte_state <= 0;
			   //Pre_CMOS_iDATA <= 8'd0;
			   CMOS_oDATA <= CMOS_oDATA;
			end
		end
end
//---end test2--- 
//----------------------------------------------------------------
////////// Horizontal sweep count //sweep - развертка
//----------------------------------------------------------------
always @ (posedge vga_clk)
  begin
       if(1'b0)    x_cnt <= 1;
       else if(x_cnt == LinePeriod) x_cnt <= 1;
       else x_cnt <= x_cnt+ 1;
  end		 
//----------------------------------------------------------------
////////// Horizontal sweep signal Hsync, hsync_de generation
//----------------------------------------------------------------
always @ (posedge vga_clk)
   begin
       if(1'b0) hsync_r <= 1'b1;
       else if(x_cnt == 1) hsync_r <= 1'b0;            //Generate Hsync signal
       else if(x_cnt == H_SyncPulse) hsync_r <= 1'b1;
		 
		 		 
	    if(1'b0) hsync_de <= 1'b0;
       else if(x_cnt == Hde_start) hsync_de <= 1'b1;    //Generate hsync_de signal
       else if(x_cnt == Hde_end) hsync_de <= 1'b0;	
	end

//----------------------------------------------------------------
////////// Vertical sweep count
//----------------------------------------------------------------
always @ (posedge vga_clk)
  begin
       if(1'b0) y_cnt <= 1;
       else if(y_cnt == FramePeriod) y_cnt <= 1;
       else if(x_cnt == LinePeriod) y_cnt <= y_cnt+1;
  end
//----------------------------------------------------------------
////////// Vertical scan signal Vsync, vsync_de generation
//----------------------------------------------------------------
always @ (posedge vga_clk)
  begin
       if(1'b0) vsync_r <= 1'b1;
       else if(y_cnt == 1) vsync_r <= 1'b0;    //Generate Vsync signal
       else if(y_cnt == V_SyncPulse) vsync_r <= 1'b1;
		 
	    if(1'b0) vsync_de <= 1'b0;
       else if(y_cnt == Vde_start) vsync_de <= 1'b1;    //Generate vsync_de signal
       else if(y_cnt == Vde_end) vsync_de <= 1'b0;	 
  end
		 

//----------------------------------------------------------------
////////// Grid test image generation
//----------------------------------------------------------------
 always @(negedge vga_clk)   
   begin
     if ((x_cnt[4]==1'b1) ^ (y_cnt[4]==1'b1))            //Grid 1 image
			    grid_data_1<= 16'h0000;
	  else
			    grid_data_1<= 16'hffff;
				 
	  if ((x_cnt[6]==1'b1) ^ (y_cnt[6]==1'b1))            //Grid 2 image 
			    grid_data_2<=16'h0000;
	  else
				 grid_data_2<=16'hffff; 
   
	end
	
//----------------------------------------------------------------
////////// Color bar test image generation
//----------------------------------------------------------------
 always @(negedge vga_clk)   
   begin
     if (x_cnt==300)            
			    bar_data<= 16'hf800;
	  else if (x_cnt==420)
			    bar_data<= 16'h07e0;				 
	  else if (x_cnt==540)            
			    bar_data<=16'h001f;
	  else if (x_cnt==660)            
			    bar_data<=16'hf81f;
	  else if (x_cnt==780)            
			    bar_data<=16'hffe0;
	  else if (x_cnt==900)            
			    bar_data<=16'h07ff;
	  else if (x_cnt==1020)            
			    bar_data<=16'hffff;
	  else if (x_cnt==1140)            
			    bar_data<=16'hfc00;
	  else if (x_cnt==1260)            
			    bar_data<=16'h0000;
   
	end
	
//----------------------------------------------------------------
////////// VGA image select output
//----------------------------------------------------------------
 //LCD data signal selection 
 always @(negedge vga_clk)
  begin 
    if(1'b0) begin 
	    vga_r_reg<=0; 
	    vga_g_reg<=0;
	    vga_b_reg<=0;
       cnt_img_dat<=0;		 
	end
   else
     case(vga_dis_mode)
         4'b0000:begin
			        //CMOS_oDATA
					  if ((x_cnt<640) && (y_cnt<480)) begin
			             vga_r_reg<=5'b00000;//CMOS_oDATA[4:0];                     
                      vga_g_reg<=6'b111111;//CMOS_oDATA[10:5];
                      vga_b_reg<=5'b00000;//CMOS_oDATA[15:11];
							 cnt_img_dat<=cnt_img_dat+1;					  
					     /*
					     if (cnt_img_dat<2499) begin
			             vga_r_reg<=img_dat[cnt_img_dat];//5'b00000;//CMOS_oDATA[4:0];                     
                      vga_g_reg<=6'b000000;//CMOS_oDATA[10:5];
                      vga_b_reg<=img_dat[cnt_img_dat];//5'b00000;//CMOS_oDATA[15:11];
							 cnt_img_dat<=cnt_img_dat+1;
						  end
						  else begin
						    cnt_img_dat<=0;
						  end;
						  */
					  end
                 else begin 					  
			           vga_r_reg<=5'b11111;                     
                    vga_g_reg<=6'b111111;
                    vga_b_reg<=5'b11111;	
                 end;					  
			end
			4'b0001:begin
			        vga_r_reg<=5'b11111;                 //VGA display all white
                 vga_g_reg<=6'b111111;
                 vga_b_reg<=5'b11111;
			end
			4'b0010:begin
			        vga_r_reg<=5'b11111;                //VGA display red
                 vga_g_reg<=0;
                 vga_b_reg<=0;  
         end			  
	      4'b0011:begin
			        vga_r_reg<=0;                      //VGA show full green
                 vga_g_reg<=6'b111111;
                 vga_b_reg<=0; 
         end					  
         4'b0100:begin     
			        vga_r_reg<=0;                      //VGA display full blue
                 vga_g_reg<=0;
                 vga_b_reg<=5'b11111;
			end
         4'b0101:begin     
			        vga_r_reg<=grid_data_1[15:11];     // VGA display box 1
                 vga_g_reg<=grid_data_1[10:5];
                 vga_b_reg<=grid_data_1[4:0];
         end					  
         4'b0110:begin     
			        vga_r_reg<=grid_data_2[15:11];    // VGA display box 2
                 vga_g_reg<=grid_data_2[10:5];
                 vga_b_reg<=grid_data_2[4:0];
			end
		   4'b0111:begin     
			        vga_r_reg<=x_cnt[6:2];            //VGA display horizontal gradient color
                 vga_g_reg<=x_cnt[6:1];
                 vga_b_reg<=x_cnt[6:2];
			end
		   4'b1000:begin     
			        vga_r_reg<=y_cnt[6:2];            //VGA display vertical gradient color
                 vga_g_reg<=y_cnt[6:1];
                 vga_b_reg<=y_cnt[6:2];
			end
		   4'b1001:begin     
			        vga_r_reg<=x_cnt[6:2];            //VGA display red gradient color
                 vga_g_reg<=0;
                 vga_b_reg<=0;
			end
		   4'b1010:begin     
			        vga_r_reg<=0;                     //VGA display green gradient color
                 vga_g_reg<=x_cnt[6:1];
                 vga_b_reg<=0;
			end
		   4'b1011:begin     
			        vga_r_reg<=0;                            //VGA display blue gradient color
                 vga_g_reg<=0;
                 vga_b_reg<=x_cnt[6:2];			
			end
		   4'b1100:begin     
			        vga_r_reg<=bar_data[15:11];              //VGA display color bar
                 vga_g_reg<=bar_data[10:5];
                 vga_b_reg<=bar_data[4:0];			
			end
		   default:begin
			        vga_r_reg<=5'b11111;                 //VGA display all white
                 vga_g_reg<=6'b111111;
                 vga_b_reg<=5'b11111;
			end					  
         endcase;
	end

  assign vga_hs = hsync_r;
  assign vga_vs = vsync_r;  
  assign vga_r = (hsync_de & vsync_de)?vga_r_reg:5'b00000;
  assign vga_g = (hsync_de & vsync_de)?vga_g_reg:6'b000000;
  assign vga_b = (hsync_de & vsync_de)?vga_b_reg:5'b00000;
  //assign vga_clk = CLK_OUT1;
  
   ////////////////////////////////////////////////////////
	//Clocking Wizard IP for pll1
	//------------------------------------------------------
	//Input Clock 50MHz
	//Input Jitter 0.010
	//Single ended clock capable pin
	//Clocking Features: +Frecquency Sunthesis; +Phase alignment;
	//Jitter Optimization: +Balanced
	//Mode: +Auto
	//Input Jitter Unit: +UI
	//---shit 2----
	//+Reset;
	//+Locked;
	//Clock Feedback: +Automatic
	//CLK_OUT1: 65MHz, Phase 0, Duty 50%, Drives BUFG
	//---------------------------------------------------------
   //1.175Mhz for 640x480(60hz)/ 40.0Mhz for 800x600(60hz) / 65.0Mhz for 1024x768(60hz)/108.0Mhz for 1280x1024(60hz)
/*	
   pll1 pll1_inst
  (// Clock in ports
   .CLK_IN1(fpga_gclk),      // IN
   .CLK_OUT1(CLK_OUT1),     // 65.0Mhz for 1024x768(60hz)
   .RESET(0),               // reset input 
   .LOCKED());        // OUT
*/
////////////////////////////////////////////////////////////////
 //Button handler	
  always @(posedge vga_clk)
	  begin
	    if (key3==1'b0)                               //If the button is not pressed, the register is 0
	       key3_counter<=0;
	    else if ((key3==1'b1)& (key3_counter<=16'hc350)) //If the button is pressed and press time less than 1ms, count      
          key3_counter<=key3_counter+1'b1;
  	  
       if (key3_counter==16'hc349)                //A button to change the display mode
		    begin
		      if(vga_dis_mode==4'b1101)
			      vga_dis_mode<=4'b0000;
			   else
			      vga_dis_mode<=vga_dis_mode+1'b1; 
          end	
     end			 
	  

endmodule
