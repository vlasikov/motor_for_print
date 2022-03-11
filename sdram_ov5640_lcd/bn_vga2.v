`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module bn_vga2(
   input  CLK,     
   //output [4:0] RED,   
   //output [5:0] GREEN,   
   //output [4:0] BLUE,   
   //output HS, //vga HS 
   //output VS, //vga VS 

	//----------------------------
	input CMOS_VSYNC,		//cmos vsync
	input CMOS_HREF,		//cmos hsync refrence
	input CMOS_PCLK,		//cmos pxiel clock
	input CMOS_XCLK,		//cmos externl clock
	input [11:0]CMOS_DB,	//cmos data
	input cmos_rst_n,		//cmos reset
   output [3:0] LED,

   //test out CMOS
	output out_CMOS_VSYNC,   
	output out_CMOS_HREF,	 	
   output frameDelay,

   //input  key1, 	
	input  key2, 
   input  key3,
 	//input  key4
	//output [11:0] out_cmos_vs_cnt,
	//output [11:0] out_cmos_hs_cnt
	/*
	output reg CMOS_oCLK,			//Data PCLK
	output reg	[15:0]	CMOS_oDATA,  	//16Bits RGB
	output reg CMOS_VALID		//Data Enable 	
   */	
	//Ouput Sensor Data
	output	reg			 CMOS_oCLK,		//1/2 PCLK
	output	reg	[15:0] CMOS_oDATA,		//16Bits RGB		
	output	reg			 CMOS_VALID,		//Data Enable	
	//---------------------
	output  [23:0] binaryDATA,
	input bn_test_clk
);

  reg [23:0] rg_binaryDATA; 
  reg [23:0] rg_binaryDATA_tmp; 
  reg [1:0] fl_stop;
  assign binaryDATA=rg_binaryDATA;
  //assign CMOS_oCLK = CMOS_PCLK; 
  //-----------------------------
  parameter Hmax=1024;//100;//320;//160;//160;//120;//160
  parameter Vmax=720;//60;//240;//120;//120;//80;//120
  parameter HVmax=Hmax*Vmax;
  parameter HVmax_1=HVmax-1; 
  
  parameter Hmax_1=Hmax-1;
  parameter Vmax_1=Vmax-1;

  //parameter Hmax11=Hmax-40;
  //parameter Vmax11=Vmax-40;
  
  //parameter Hmax12=Hmax11+20;
  //parameter Vmax12=Vmax11+20;  
  //--------------------------------  
  //reg fl_frame_view=0;
  
  reg rgLED0=1'b0;
  reg rgLED1=1'b0;
  reg rgLED2=1'b0;
  reg rgLED3=1'b0;
  //-----------------------------	  
  //reg vga_rg_hs,vga_rg_vs;   
  //reg [11:0] vga_hs_cnt;  
  //reg [9:0]  vga_vs_cnt;   
 
  //reg [4:0]  rgRED;
  //reg [5:0]  rgGREEN;   
  //reg [4:0]  rgBLUE;   
   
  //reg [5:0]  mImgG[0:HVmax];
  //reg [4:0]  mImgR[0:HVmax_1];
  //reg [4:0]  mImgB[0:HVmax_1];
  
  //reg [5:0] m2ImgG[0:Hmax_1] [0:Vmax_1];
  
  //reg rgStart=1'b1; 

  //reg [17:0] cn2_mImg=0;
  //reg [17:0] cn3_mImg=0;  
 
  wire nCMOS_VSYNC;   
  wire nCMOS_HREF;  
  
  assign nCMOS_VSYNC=~CMOS_VSYNC;
  assign nCMOS_HREF=~CMOS_HREF;

  assign out_CMOS_VSYNC=nCMOS_VSYNC;
  assign out_CMOS_HREF=nCMOS_HREF;
	
  //assign HS=vga_rg_hs;
  //assign VS=vga_rg_vs; 
  
  //assign RED=rgRED;
  //assign GREEN=rgGREEN;
  //assign BLUE=rgBLUE;
   	  
  assign LED[0]=rgLED0;
  assign LED[1]=rgLED1;
  assign LED[2]=rgLED2;
  assign LED[3]=rgLED3;
  
  //-------------------------------
  //start delay 4 s
  reg [27:0] count_startDelay;//=123456;
  reg fl_StartDelay;
  reg fl_StartDelay_stop;
  
  //reg [1:0] rgkey1=0;
  //reg rgkey1=0;
  reg rgkey2=0;
  reg rgkey3=0;
  reg odd=0;
   
  always @(posedge key3)//key4
  begin
     odd=~odd;
	  if (odd==1) rgLED3<=1;
	  else rgLED3<=0;
  end

  always @(posedge key2)
  begin
     rgkey2=~rgkey2;
  end

  assign frameDelay=fl_StartDelay_stop;
  
  always @(posedge CLK or negedge cmos_rst_n) //50MHz  
  begin
  	if(!cmos_rst_n) begin
		rgLED0<=1'b0;
		count_startDelay<=0;
		fl_StartDelay_stop<=0;
	end	
	else begin
		if (count_startDelay<200_000_000) count_startDelay<=count_startDelay+1;
		else begin
		  if (fl_StartDelay_stop==0) begin
		      rgLED0<=1'b1;
		      fl_StartDelay_stop<=1;
		  end;
		end
	end
  end
  //---------------------------------------------- 
  /*
  always @(posedge CLK) //50MHz  
  begin
      if ((857<=vga_hs_cnt)&&(vga_hs_cnt<=977)) vga_rg_hs<=0;  
      else vga_rg_hs<=1;   
      if(vga_hs_cnt==1039)  
		  begin                   
              vga_hs_cnt<=0;    
              if (vga_vs_cnt==665)    vga_vs_cnt<=0;   
              else vga_vs_cnt<=vga_vs_cnt+1; 
		  end               
        else vga_hs_cnt<=vga_hs_cnt+1; 
        if ((638<=vga_vs_cnt)&&(vga_vs_cnt<=644)) vga_rg_vs<=0;  
        else vga_rg_vs<=1;             
  end   
  //-------------------------------
  always @(posedge CLK)//or posedge fl_StartDelay_stop)  
  begin   
	 if (fl_StartDelay_stop==0) begin 	 
		 rgRED   <=5'b00000;
		 rgGREEN <=6'b000000;
		 rgBLUE  <=5'b00000; 
		 //cn2_mImg<=0;
	 end
	 else begin
		 if (vga_vs_cnt<Vmax) begin 
			 if (vga_hs_cnt<Hmax) begin 
				 //cn2_mImg<=cn2_mImg+1;
				 rgRED   <=5'b00000;//mImgR[cn2_mImg];//5'b00111;
				 //rgGREEN <=mImgG[cn2_mImg];
				 rgGREEN <=m2ImgG[vga_hs_cnt][vga_vs_cnt];
				 rgBLUE  <=5'b00000;//5'b00011;
			 end	//if (vga_hs_cnt<Hmax)	
          else begin
	          rgRED   <=5'b00000;
		       rgGREEN <=6'b000000;
		       rgBLUE  <=5'b00000; 				 
          end			 
		 end //if (vga_vs_cnt<Vmax)		 
		 else begin
		    //cn2_mImg<=0;
	       rgRED   <=5'b00000;
		    rgGREEN <=6'b000000;
		    rgBLUE  <=5'b00000; 			 
		 end;//else if (vga_vs_cnt<Vmax)
	 end //else if (fl_StartDelay_stop==0)
  end 
//----------------------------------------------------
*/
reg [11:0]	cmos_vs_cnt;
reg [17:0]  cmos_shift_cnt;
//reg string_state;
assign out_cmos_vs_cnt=cmos_vs_cnt;
always@ (posedge nCMOS_HREF)//(negedge nCMOS_HREF)// or posedge fl_StartDelay_stop)// or negedge cmos_rst_n)
begin
	if(fl_StartDelay_stop==0) begin
		cmos_vs_cnt<=0;
		//string_state<=0;//odd;
		//fl_frame_view<=0;
		cmos_shift_cnt<=0;
		//fl_stop<=0;
		//rg_binaryDATA_tmp<=0;
		//rg_binaryDATA<=0;		
		CMOS_VALID <=0;
		//Frame_valid<=0;
	end	
	else begin
		if (nCMOS_VSYNC==1) begin
		    //CMOS_VALID <= nCMOS_VSYNC;
			 //Frame_valid<=1;
			 CMOS_VALID <=1;
		   //fl_stop<=1;
			cmos_vs_cnt<=cmos_vs_cnt+1;
			//string_state<=~string_state;
			cmos_shift_cnt<=cmos_vs_cnt*Hmax;
		end	
		else begin
        //if (fl_stop==1) begin
		    //fl_stop<=2;
			 //rg_binaryDATA[11:0]<=cmos_vs_cnt;	
        //end	
        CMOS_VALID <=0;		  
		  cmos_vs_cnt<=0;
		  cmos_shift_cnt<=0;
          //if (fl_stop==1) begin //
			    //fl_stop<=2;
				 //rg_binaryDATA<=rg_binaryDATA_tmp;	
          //end				 
		  //string_state<=0;//odd;
		end  
	end //else if(!cmos_rst_n)
end	
//-------------------------------------------------
//-------------------------------------------------
//reg [1:0] byte_state;		//byte state count
reg [11:0] cmos_hs_cnt;	
assign out_cmos_hs_cnt=cmos_hs_cnt;
always@(posedge CMOS_PCLK)// or posedge fl_StartDelay_stop)// or negedge cmos_rst_n)
begin
	if(fl_StartDelay_stop==0) begin
		//byte_state <= 0;
      cmos_hs_cnt<=0;
		//cn3_mImg<=0;
		fl_stop<=0;
		rg_binaryDATA<=0;
		rg_binaryDATA_tmp<=0;
      //CMOS_VALID <=0;
      CMOS_oCLK <= 0;		
	end
	else begin
			  if (nCMOS_VSYNC ==1) begin
			   //CMOS_VALID <=1; 
				if (nCMOS_HREF==1)	begin//Line field effective
				  //cmos_hs_cnt<=cmos_hs_cnt+1;
				  //CMOS_oCLK <= 1;
				  //fl_stop<=1;
				  //CMOS_oDATA[10:5] <= CMOS_DB[11:6];
				  /*
				  //---------------------------
              if(cmos_vs_cnt<272) begin					
				    if (cmos_hs_cnt<480)begin
					     CMOS_oDATA[10:5] <= CMOS_DB[11:6];
                end
              end	
              */				  
				  //---------------------------
              if(cmos_vs_cnt<Vmax) begin					
				   if (cmos_hs_cnt<Hmax)begin	
					       if (fl_stop==0) fl_stop<=1;
					       cmos_hs_cnt<=cmos_hs_cnt+1;
					       //---CMOS_VALID <=1; 
							 CMOS_oCLK <= 1;
							 if((cmos_hs_cnt==0) || (cmos_hs_cnt==1023) || (cmos_hs_cnt==511) || (cmos_vs_cnt==354) || (cmos_vs_cnt==0) || (cmos_vs_cnt==719)) CMOS_oDATA[15:0] <= 16'b00000_000000_11111;
							 else CMOS_oDATA[15:0] <= {5'b00000,CMOS_DB[11:6],5'b00000};
							 if (fl_stop==1) rg_binaryDATA_tmp<=rg_binaryDATA_tmp+1;
					       //CMOS_oDATA[10:5] <= 6'b011111;
							 //if((cmos_hs_cnt<500) && (cmos_vs_cnt<370)) CMOS_oDATA[15:0] <= 16'b01111_000000_00000;
							 //else CMOS_oDATA[15:0] <= 16'b00000_011111_00000;//{5'b00000,CMOS_DB[11:6],5'b00000};//16'b01111_000000_00000;
							 //---if (fl_stop==0) rg_binaryDATA_tmp<=rg_binaryDATA_tmp+1;
							 
							 /*
                      if ((lcd_xpos == 512 ) || (lcd_ypos == 372 )) rg_lcd_data2= 16'b00000_111111_00000;
                      else rg_lcd_data2= sys_data_out;//16'b00000_000000_00000;							 
							 */
                      //cn3_mImg<=cmos_shift_cnt + cmos_hs_cnt;
                      //mImgG[cn3_mImg]<=CMOS_DB[11:6];
							 
							 //m2ImgG[cmos_hs_cnt][cmos_vs_cnt]<=CMOS_DB[11:6];
							 
							 /*
                      if (string_state==odd) begin
									case (rgkey2)
									0:begin
										rgLED1<=1'b0;
										rgLED2<=1'b0;
										case(byte_state)
										0:	begin							  								  
												mImgG[cn3_mImg]<=CMOS_DB[11:6];																  
												byte_state <=1;
										end  
										1:	begin
											  mImgG[cn3_mImg]<=0;
											  byte_state <=0;
										end 					
										endcase //(byte_state)
									end
									1:begin
										rgLED1<=1'b1;
										rgLED2<=1'b0;
										case(byte_state)
										0:	begin							  								  
												mImgG[cn3_mImg]<=0;														  
												byte_state <=1;
										end  
										1:	begin
											  mImgG[cn3_mImg]<=CMOS_DB[11:6];
											  byte_state <=0;
										end 					
										endcase //(byte_state)
									end								
									endcase //rgkey1
							 end	//if (string_state==0)
							 else begin
							    mImgG[cn3_mImg]<=0;
							 end;//end else if (string_state==0)
							 */
                end //if (cmos_vga_hs_cnt<cmosHmax)
					 else begin
					    CMOS_oCLK <= 0;
					 end
              end	//if (cmos_vga_vs_cnt<cmosVmax)	
              else begin
				     //cn3_mImg<=0;
					  //CMOS_VALID <=0;
					  //CMOS_oCLK <= 0;
                 //CMOS_oDATA[10:5] <= 6'b000000;	
				     //if (fl_stop==1) begin
					     //---fl_stop<=1;
					     //rg_binaryDATA[11:0]<=cmos_hs_cnt;
                    //---rg_binaryDATA<=rg_binaryDATA_tmp;					  
				     //end						  
              end				  
				end //if (CMOS_HREF==1)
				else begin
				   /*
				   if (fl_stop==1) begin
					  fl_stop<=2;
					  //rg_binaryDATA[11:0]<=cmos_hs_cnt;
                 rg_binaryDATA<=rg_binaryDATA_tmp;					  
				   end	
               */					
					cmos_hs_cnt<=0;
					//CMOS_oCLK <= 0;
					//byte_state <= 0;
				end //else if (CMOS_HREF==1)
			end //if(CMOS_VSYNC ==1)
			else begin			
				cmos_hs_cnt<=0;
				//CMOS_oCLK <= 0;
				//CMOS_VALID <=0;
            //byte_state <= 0;
            if (fl_stop==1) begin //
			      fl_stop<=2;
				   rg_binaryDATA<=rg_binaryDATA_tmp;
				   //result:rg_binaryDATA=//737279// 1023*720=737280
            end 
            if (fl_stop==2) begin
				   if (odd==1) begin
		             fl_stop<=0;
		             rg_binaryDATA<=0;
		             rg_binaryDATA_tmp<=0;					
					end
            end				
			end;//else if(CMOS_VSYNC ==1)
		//end;//if (fl_StartDelay_stop==1) begin 
	end;//else if (fl_StartDelay_stop==0)
end 
 
//-------------------
//CMOS_DATA Data synchronous output enable clock
/*
always@(CMOS_PCLK)// or negedge iRST_N)
begin
	if(fl_StartDelay_stop==0) begin
		CMOS_oCLK <= 0;
	end	
	else begin
	     CMOS_oCLK <= CMOS_PCLK;
   end		
end
*/
//assign CMOS_oCLK = CMOS_PCLK;
/*
always@(posedge CMOS_PCLK)// or negedge iRST_N)
begin
	if(fl_StartDelay_stop==0) begin
		CMOS_oCLK <= 0;
	end	
	else begin
	     if (nCMOS_HREF==1) CMOS_oCLK <= CMOS_PCLK;
	     else  CMOS_oCLK <= 0;
   end		
end
*/
/*
//-------------------
//CMOS_VALID
//assign CMOS_VALID=nCMOS_VSYNC;
always@(posedge CMOS_PCLK)// or negedge iRST_N)
begin
	if(fl_StartDelay_stop==0) begin
		CMOS_VALID <= 0;
	end	
	else begin
	     if (nCMOS_VSYNC==1) begin
		    if(cmos_vs_cnt<272) begin
			    CMOS_VALID <= 1;
			 end
			 else begin
			    CMOS_VALID <= 0;
			 end
		  end
		  else begin
		     CMOS_VALID <= 0;
		  end
   end		
end
//-------------------
*/
reg [11:0] test_hs_cnt;	
reg [11:0] test_vs_cnt;	

always@(posedge bn_test_clk)// or negedge iRST_N)
begin
	if(fl_StartDelay_stop==0) begin
		//CMOS_oCLK <= 0;
		//CMOS_VALID <= 0;
		//rg_binaryDATA<=0;
		//rg_binaryDATA_tmp<=0;
      test_hs_cnt<=0;
      test_vs_cnt<=0;
      //fl_stop<=0;		
	end	
	else begin
	     if(test_vs_cnt<Vmax) begin
		     //CMOS_VALID <= 1;
		     //test_vs_cnt<=test_vs_cnt+1; 		  
		     if (test_hs_cnt<Hmax) begin
			     test_hs_cnt<=test_hs_cnt+1; 
			     //CMOS_oCLK <= 1;
				  //if (fl_stop==0) fl_stop<=1;
              /*			  
				  if((test_hs_cnt==0) || (test_hs_cnt==1023) || (test_hs_cnt==511) || (test_vs_cnt==354) || (test_vs_cnt==0) || (test_vs_cnt==719)) CMOS_oDATA[15:0] <= 16'b00000_000000_11111;
				  else begin
				     if((test_hs_cnt<510) && (test_vs_cnt<353)) CMOS_oDATA[15:0] <= 16'b01111_000000_00000;
				     else CMOS_oDATA[15:0] <= 16'b00000_001111_00000;
              end;						  
              if (fl_stop==1) rg_binaryDATA_tmp<=rg_binaryDATA_tmp+1;
				  */
				  //CMOS_oDATA[15:0] <= 16'b00000_001111_00000;
           end //if (test_hs_cnt<Hmax)
			  else begin
			     //CMOS_oCLK <=0;
				  test_hs_cnt<=0;
				  test_vs_cnt<=test_vs_cnt+1; 	
              //if (fl_stop==1) begin //
			       //fl_stop<=2;
				    //rg_binaryDATA<=rg_binaryDATA_tmp;
				    //result:rg_binaryDATA=1023
              //end  				  
			  end
        end //if(test_vs_cnt<Vmax)
		  else begin
		    //CMOS_VALID <= 0; 
			 test_vs_cnt<=0;
          //if (fl_stop==1) begin //
			    //fl_stop<=2;
				 //rg_binaryDATA<=rg_binaryDATA_tmp;
				 ////result:rg_binaryDATA=//737279// 1023*720=737280
          //end  			 
		  end
   end		
end

/*
always@(posedge bn_test_clk)// or negedge iRST_N)
begin
	if(fl_StartDelay_stop==0) begin
		CMOS_oCLK <= 0;
		CMOS_VALID <= 0;
		rg_binaryDATA<=0;
		rg_binaryDATA_tmp<=0;		
	end	
	else begin
	     //CMOS_oCLK <= bn_test_clk;
		  if (rg_binaryDATA_tmp<HVmax) begin
		     CMOS_VALID <= 1;
			  CMOS_oCLK <= 1;
			  rg_binaryDATA_tmp<=rg_binaryDATA_tmp+1;
			  CMOS_oDATA[15:0] <= 16'b01111_000000_00000;
		  end
        else begin
		     CMOS_VALID <= 0;
			  CMOS_oCLK <= 0;
			  rg_binaryDATA_tmp<=0;
        end  		  
   end		
end
*/
endmodule
