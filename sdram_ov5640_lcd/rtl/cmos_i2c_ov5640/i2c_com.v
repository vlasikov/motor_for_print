//SCLK, SDIN data transmission timing code (I2C write control code)
module i2c_com(/*clock_i2c3,*/
               clock_i2c2,
               clock_i2c,          //I2C control interface to transmit the required clock, 0-400khz, here is 20K
               camera_rstn,     
               ack,              //Response signal
               i2c_data,          //32 bit data transmitted by SDIN interface
               start,             //Start flag¾
               tr_end,           //End of transmission flag¾
               i2c_sclk,          //fpga and camera iic clock interface
               i2c_sdat,
					fl_read);         //FPGA and camera iic data interface
    input [31:0]i2c_data;
    input camera_rstn;
	 //input clock_i2c3;
	 input clock_i2c2;
    input clock_i2c;
    output ack;
    input start;
    output tr_end;
    output i2c_sclk;
    inout i2c_sdat;
    reg [5:0] cyc_count1;
	 reg [5:0] cyc_count2;
	 reg [15:0] read_data;
    reg reg_sdat;
    reg sclk;
    //reg ack1,ack2,ack3;
    reg tr_end;
	 reg fl_sclk;
   
    wire i2c_sclk;
	 wire i2c_sclk1;
	 wire i2c_sclk2;
    wire i2c_sdat;
    wire ack;
	 input fl_read;
	 
	 assign ack=1'b1;
    //assign ack=ack1|ack2|ack3;
	 //assign i2c_sclk=i2c_sclk1|i2c_sclk2;
	 assign i2c_sclk=fl_read?i2c_sclk2:i2c_sclk1;
	 assign i2c_sclk1=sclk|(((cyc_count1>=4)&(cyc_count1<=39))?~clock_i2c:0);
    //assign i2c_sclk2=sclk|(((cyc_count2>=4)&(cyc_count2<=18))?~clock_i2c:0);
    assign i2c_sclk2=fl_sclk?(sclk|(((cyc_count2>=4)&(cyc_count2<=54))?~clock_i2c:0)):0;		 
    //assign i2c_sdat=reg_sdat?1'bz:0;
	 assign i2c_sdat=reg_sdat;
      
    always@(posedge clock_i2c2 or  negedge camera_rstn)
    begin
       if(!camera_rstn)
         cyc_count1<=6'b111111;//0x3f, 63
       else 
		   begin
           if(start==0)
             cyc_count1<=0;
           else if(cyc_count1<6'b111111)
             cyc_count1<=cyc_count1+1;
         end
    end
	 
    always@(posedge clock_i2c2 or  negedge camera_rstn)
    begin
       if(!camera_rstn)
         cyc_count2<=6'b111111;//0x3f, 63
       else 
		   begin
           if(start==0)
             cyc_count2<=0;
           else if(cyc_count2<6'b111111)
             cyc_count2<=cyc_count2+1;
         end
    end	 
	 	 
    always@(posedge clock_i2c2 or negedge camera_rstn)
    begin
       if(!camera_rstn)
       begin
          tr_end<=0;
          //ack1<=1;
          //ack2<=1;
          //ack3<=1;
          sclk<=1;
          reg_sdat<=1;
       end
       else
		 if (fl_read==0)
		 begin
          case(cyc_count1)
          0:begin /*ack1<=1;ack2<=1;ack3<=1;*/tr_end<=0;sclk<=1;reg_sdat<=1;end
          1:reg_sdat<=0;                 // Start transmission
          2:sclk<=0;
          3:reg_sdat<=i2c_data[31];
          4:reg_sdat<=i2c_data[30];
          5:reg_sdat<=i2c_data[29];
          6:reg_sdat<=i2c_data[28];
          7:reg_sdat<=i2c_data[27];
          8:reg_sdat<=i2c_data[26];
          9:reg_sdat<=i2c_data[25];
          10:reg_sdat<=i2c_data[24];
          11:begin reg_sdat<=1'bz; end                //Response signal
          12:begin reg_sdat<=i2c_data[23]; /*ack1<=i2c_sdat;*/end
          13:reg_sdat<=i2c_data[22];
          14:reg_sdat<=i2c_data[21];
          15:reg_sdat<=i2c_data[20];
          16:reg_sdat<=i2c_data[19];
          17:reg_sdat<=i2c_data[18];
          18:reg_sdat<=i2c_data[17];
          19:reg_sdat<=i2c_data[16];
          20:begin reg_sdat<=1'bz; end//1;                //Response signal       
          21:begin /*fl_write_sdat<=1;*/ reg_sdat<=i2c_data[15];/*ack1<=i2c_sdat;*/end
          22:reg_sdat<=i2c_data[14];
          23:reg_sdat<=i2c_data[13];
          24:reg_sdat<=i2c_data[12];
          25:reg_sdat<=i2c_data[11];
          26:reg_sdat<=i2c_data[10];
          27:reg_sdat<=i2c_data[9];
          28:reg_sdat<=i2c_data[8];
          29:begin /*fl_write_sdat<=0;*/ reg_sdat<=1'bz;end//1;                //Response signal       
          30:begin /*fl_write_sdat<=0;*/ reg_sdat<=i2c_data[7];/*ack2<=i2c_sdat;*/end
          31:reg_sdat<=i2c_data[6];
          32:reg_sdat<=i2c_data[5];
          33:reg_sdat<=i2c_data[4];
          34:reg_sdat<=i2c_data[3];
          35:reg_sdat<=i2c_data[2];
          36:reg_sdat<=i2c_data[1];
          37:reg_sdat<=i2c_data[0];
          38:begin /*fl_write_sdat<=0;*/ reg_sdat<=1'bz; end//1;                //Response signal 
          39:begin /*ack3<=i2c_sdat;*/sclk<=1;reg_sdat<=0;end
          40:begin /*sclk<=1;*/reg_sdat<=1; tr_end<=1; end
          41:begin /*reg_sdat<=1;tr_end<=1;*/ end			 
          //39:begin /*ack3<=i2c_sdat;*/sclk<=0;reg_sdat<=0;end
          //40:sclk<=1;
          //41:begin reg_sdat<=1;tr_end<=1;end
          endcase
			 end //
			 else //if (fl_read==0)
			 begin
			 /////////////////////////////////////////////////////////
          case(cyc_count2)
          0:begin /*fl_write_sdat<=1;fl_sclk<=1;ack1<=1;ack2<=1;ack3<=1;*/tr_end<=0;sclk<=1;reg_sdat<=1;end
          1:reg_sdat<=0;                 // Start transmission
          2:sclk<=0;
          3:reg_sdat<=1'b1;//i2c_data[31];
          4:reg_sdat<=1'b0;//i2c_data[30];
          5:reg_sdat<=1'b0;//i2c_data[29];
          6:reg_sdat<=1'b1;//i2c_data[28];
          7:reg_sdat<=1'b0;//i2c_data[27];
          8:reg_sdat<=1'b0;//i2c_data[26];
          9:reg_sdat<=1'b0;//i2c_data[25];
          10:reg_sdat<=1'b0;//i2c_data[24];
          11:begin /*fl_write_sdat<=0;*/reg_sdat<=1'bz;end//1;                //Response signal
          12:begin /*fl_write_sdat<=1;*/reg_sdat<=1'b0;/*i2c_data[23];*//*ack1<=i2c_sdat;*/end
          13:reg_sdat<=1'b0;//i2c_data[22];
          14:reg_sdat<=1'b0;//i2c_data[21];
          15:reg_sdat<=1'b0;//i2c_data[20];
          16:reg_sdat<=1'b0;//i2c_data[19];
          17:reg_sdat<=1'b1;//i2c_data[18];
          18:reg_sdat<=1'b0;//i2c_data[17];
          19:reg_sdat<=1'b0;//i2c_data[16];
          20:begin /*fl_write_sdat<=0;*/ reg_sdat<=1'bz; end//1;                //Response signal       
          //21:begin reg_sdat<=i2c_data[15];ack1<=i2c_sdat;end
			 21:begin /*ack3<=i2c_sdat;*/sclk<=1;reg_sdat<=0;end//-----
          22:begin reg_sdat<=1;/*sclk<=1; */end
          23:begin /*reg_sdat<=1;*//*tr_end<=1;*/end			 

          24:begin /*ack1<=1;ack2<=1;ack3<=1;*/tr_end<=0;sclk<=1;reg_sdat<=1;end
          25:begin reg_sdat<=0; end                // Start transmission
          26:begin fl_sclk<=0; sclk<=0; end		 
          27:begin fl_sclk<=1; reg_sdat<=1'b1; end//i2c_data[31];
          28:reg_sdat<=1'b0;//i2c_data[30];
          29:reg_sdat<=1'b0;//i2c_data[29];
          30:reg_sdat<=1'b1;//i2c_data[28];
          31:reg_sdat<=1'b0;//i2c_data[27];
          32:reg_sdat<=1'b0;//i2c_data[26];
          33:reg_sdat<=1'b0;//i2c_data[25];
          34:reg_sdat<=1'b1;//i2c_data[24];
          35:reg_sdat<=1'bz;//1; //ack               //Response signal
			 
          36:begin reg_sdat<=1'bz;/*i2c_data[23];*//*ack1<=i2c_sdat;*/end//read_data[15]<=i2c_sdat; ack1<=i2c_sdat;/*i2c_data[23]; ack1<=i2c_sdat;*/ end			 
          37:begin reg_sdat<=1'bz;end
          38:begin reg_sdat<=1'bz; end
          39:begin reg_sdat<=1'bz;end
          40:reg_sdat<=1'bz;//read_data[11]<=i2c_sdat;
          41:reg_sdat<=1'bz;//read_data[10]<=i2c_sdat;
          42:reg_sdat<=1'bz;//read_data[9]<=i2c_sdat;
          43:reg_sdat<=1'bz;//read_data[8]<=i2c_sdat;
          44:reg_sdat<=1'bz;//reg_sdat<=1;                //Response signal       
          45:begin reg_sdat<=1'bz;  /*ack1<=i2c_sdat;*/ end
          46:reg_sdat<=1'bz;//read_data[6]<=i2c_sdat;
          47:reg_sdat<=1'bz;//read_data[5]<=i2c_sdat;
          48:reg_sdat<=1'bz;//read_data[4]<=i2c_sdat;
          49:reg_sdat<=1'bz;//read_data[3]<=i2c_sdat;
          50:reg_sdat<=1'bz;//read_data[2]<=i2c_sdat;
          51:reg_sdat<=1'bz;//read_data[1]<=i2c_sdat;
          52:reg_sdat<=1'bz;//read_data[0]<=i2c_sdat;
          53:reg_sdat<=1'b1;//reg_sdat<=1;                //Response signal       
          54:begin /*reg_sdat<=1'bz;*/ /*ack1<=i2c_sdat; ack3<=i2c_sdat;*/sclk<=1;reg_sdat<=0;end
          55:begin reg_sdat<=1;tr_end<=1;end/*sclk<=1;*/
          56:begin /*reg_sdat<=1;tr_end<=1;*/end
          endcase			 
			 /////////////////////////////////////////////////////////
			 end; //else if (fl_read==0)
       
end
/////////////////////////////////////////////////////////
endmodule

