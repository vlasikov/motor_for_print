module smg_interface_demo
(
    input CLK,
	 input RSTn,
	 output [7:0]SMG_Data,				// 
	 output [5:0]Scan_Sig,				// текущее значение на дисплее
	 input  [23:0] binaryDATA
);

    /******************************/
 
//reg [23:0] A=699999; 
wire [3:0] sgZ0; //ONES
wire [3:0] sgZ1; //TENS
wire [3:0] sgZ2; 
wire [3:0] sgZ3;
wire [3:0] sgZ4;
wire [3:0] sgZ5;

bin2bcd_v2 instance_name (
    .binary(binaryDATA), 
    .sgZ0(sgZ0), 
    .sgZ1(sgZ1), 
    .sgZ2(sgZ2),
    .sgZ3(sgZ3),
    .sgZ4(sgZ4),
    .sgZ5(sgZ5)	 
    );

/*	 
bin2bcd instance_name (
    .A(A), 
    .sgZ0(sgZ0), 
    .sgZ1(sgZ1),
	 .sgZ2(sgZ2)
    ); 
*/ 
wire [23:0]Number_Sig;
//reg [23:0]Data_View={4'd1,4'd2,4'd3,4'd4,4'd5,4'd6};
//reg [23:0] Number_Sig ={4'd1,4'd2,4'd3,4'd4,4'd5,4'd6};
//reg [23:0]Data_View={4'd1,4'd2,4'd3,4'd4,TENS[3:0],ONES[3:0]};
//wire [23:0]Data_View;
assign Number_Sig={sgZ5[3:0],sgZ4[3:0],sgZ3[3:0],sgZ2[3:0],sgZ1[3:0],sgZ0[3:0]};
/*
    demo_control_module U1
	 (
	     .CLK( CLK ),
		  .RSTn( RSTn ),
		  .Data_View( Data_View ),
		  .Number_Sig( Number_Sig ) // output - to U2
	 );
*/
	 /******************************/ 
	 
	 smg_interface U2
	 (
	     .CLK( CLK ),
		  .RSTn( RSTn ),
		  .Number_Sig( Number_Sig ), // input - from U1
		  .SMG_Data( SMG_Data ),     // output - to top
		  .Scan_Sig( Scan_Sig )      // output - to top
	 );
	 
    /******************************/ 

endmodule
