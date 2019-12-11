`timescale 1ns/1ps
`default_nettype none

module LTC2344CMOS_tb;
	wire CS_tb;
	reg[3:0] SDO_tb = 4'bzzzz; //Digital Data In
	reg busy_tb = 0; //data can be read on the serial clock cycle after busy goes low
	wire SCKI_tb; //Serial Clock
	wire cnv_tb;
	wire [15:0] outData0_tb; //Channel 1 Digital Data Out from ADC
	wire [15:0] outData1_tb; //Channel 2 Digital Data Out from ADC
	wire [15:0] outData2_tb; //Channel 3 Digital Data Out from ADC
	wire [15:0] outData3_tb; //Channel 4 Digital Data Out from ADC
	wire dataRdy_tb;
	wire SDI_tb; //Serial input
	reg [11:0] softspan_tb = 12'b101101101101; //used before every conversion to set the input range, output 
	reg extTrig_tb = 0;
	reg serialClock_tb = 0;
	
	wire CE_tb;
	wire [4:0] progressCounter_tb;
	wire [4:0] readData_tb;
	wire [4:0] busyCount_tb;
	wire [4:0] outputCycle_tb;
	
	LTC2344_CMOS DUT(
	.CS(CS_tb),
	.SDO(SDO_tb),
	.busy(busy_tb),
	.SCKI(SCKI_tb),
	.cnv(cnv_tb),
	.outData0(outData0_tb),
	.outData1(outData1_tb),
	.outData2(outData2_tb),
	.outData3(outData3_tb),
	.dataRdy(dataRdy_tb),
	.SDI(SDI_tb),
	.softspan(softspan_tb),
	.extTrig(extTrig_tb),
	.serialClock(serialClock_tb),
	
	.CE(CE_tb),
	.progressCounter(progressCounter_tb),
	.readData(readData_tb),
	.busyCount(busyCount_tb),
	.outputCycle(outputCycle_tb));
	
	
    localparam numOfChannels = 4'd4;
    integer TBstate = 32'd40;           //this allows me to start the state machine when I want by setting TBstate = 0
    reg [15:0] testTemp = 16'b1010101010101010;
	
	initial begin 
		serialClock_tb = 0;
		forever begin
			#11.11111111; //90Mhz
			serialClock_tb = ~serialClock_tb;
		end
	end
	
	always@(posedge cnv_tb) begin //models the busy signal from the ADC
		busy_tb = 1;
		#((425*numOfChannels-20):(475*numOfChannels-20):(525*numOfChannels-20)); //minimum:typical:maximum time it will take to convert from datasheet
		busy_tb = 0;
	end
	
	initial begin
		extTrig_tb = 0;
		softspan_tb = 12'b101101101101;
		#500;
		extTrig_tb = 1;
		TBstate = 32'd2;
		#50;
		extTrig_tb = 0;
		#4000;
		extTrig_tb = 1;
		TBstate = 32'd2;
		#50;
		extTrig_tb = 0;
		#4000;
		$finish;
	end
	
	always@(posedge SCKI_tb) begin
		case(TBstate)
			// 0 : begin
				// TBstate <= TBstate + 1'd1;
			// end
			// 1 : begin
				// extTrig_tb = 1;
				// TBstate <= TBstate + 1'd1;
			// end
			2 : begin
				if(busy_tb == 0) begin
					SDO_tb[3] <= testTemp[15];
					SDO_tb[2] <= testTemp[15];
					SDO_tb[1] <= testTemp[15];
					SDO_tb[0] <= testTemp[15];
					TBstate <= TBstate + 1'd1;
				end
			end
			32'd3 : begin
				SDO_tb[3] <= testTemp[14];
				SDO_tb[2] <= testTemp[14];
				SDO_tb[1] <= testTemp[14];
				SDO_tb[0] <= testTemp[14];
				TBstate <= TBstate + 1'd1;
			end
			32'd4 : begin
				SDO_tb[3] <= testTemp[13];
				SDO_tb[2] <= testTemp[13];
				SDO_tb[1] <= testTemp[13];
				SDO_tb[0] <= testTemp[13];
				TBstate <= TBstate + 1'd1;
			end
			32'd5 : begin
				SDO_tb[3] <= testTemp[12];
				SDO_tb[2] <= testTemp[12];
				SDO_tb[1] <= testTemp[12];
				SDO_tb[0] <= testTemp[12];
				TBstate <= TBstate + 1'd1;
			end
			32'd6 : begin
				SDO_tb[3] <= testTemp[11];
				SDO_tb[2] <= testTemp[11];
				SDO_tb[1] <= testTemp[11];
				SDO_tb[0] <= testTemp[11];
				TBstate <= TBstate + 1'd1;
			end
			32'd7 : begin
				SDO_tb[3] <= testTemp[10];
				SDO_tb[2] <= testTemp[10];
				SDO_tb[1] <= testTemp[10];
				SDO_tb[0] <= testTemp[10];
				TBstate <= TBstate + 1'd1;
			end
			32'd8 : begin
				SDO_tb[3] <= testTemp[9];
				SDO_tb[2] <= testTemp[9];
				SDO_tb[1] <= testTemp[9];
				SDO_tb[0] <= testTemp[9];
				TBstate <= TBstate + 1'd1;
			end
			32'd9 : begin
				SDO_tb[3] <= testTemp[8];
				SDO_tb[2] <= testTemp[8];
				SDO_tb[1] <= testTemp[8];
				SDO_tb[0] <= testTemp[8];
				TBstate <= TBstate + 1'd1;
			end
			32'd10: begin
				SDO_tb[3] <= testTemp[7];
				SDO_tb[2] <= testTemp[7];
				SDO_tb[1] <= testTemp[7];
				SDO_tb[0] <= testTemp[7];
				TBstate <= TBstate + 1'd1;
			end
			32'd11: begin
				SDO_tb[3] <= testTemp[6];
				SDO_tb[2] <= testTemp[6];
				SDO_tb[1] <= testTemp[6];
				SDO_tb[0] <= testTemp[6];
				TBstate <= TBstate + 1'd1;
			end
			32'd12: begin
				SDO_tb[3] <= testTemp[5];
				SDO_tb[2] <= testTemp[5];
				SDO_tb[1] <= testTemp[5];
				SDO_tb[0] <= testTemp[5];
				TBstate <= TBstate + 1'd1;
			end
			32'd13: begin
				SDO_tb[3] <= testTemp[4];
				SDO_tb[2] <= testTemp[4];
				SDO_tb[1] <= testTemp[4];
				SDO_tb[0] <= testTemp[4];
				TBstate <= TBstate + 1'd1;
			end
			32'd14: begin
				SDO_tb[3] <= testTemp[3];
				SDO_tb[2] <= testTemp[3];
				SDO_tb[1] <= testTemp[3];
				SDO_tb[0] <= testTemp[3];
				TBstate <= TBstate + 1'd1;
			end
			32'd15: begin
				SDO_tb[3] <= testTemp[2];
				SDO_tb[2] <= testTemp[2];
				SDO_tb[1] <= testTemp[2];
				SDO_tb[0] <= testTemp[2];
				TBstate <= TBstate + 1'd1;
			end
			32'd16: begin
				SDO_tb[3] <= testTemp[1];
				SDO_tb[2] <= testTemp[1];
				SDO_tb[1] <= testTemp[1];
				SDO_tb[0] <= testTemp[1];
				TBstate <= TBstate + 1'd1;
			end
			32'd17: begin
				SDO_tb[3] <= testTemp[0];
				SDO_tb[2] <= testTemp[0];
				SDO_tb[1] <= testTemp[0];
				SDO_tb[0] <= testTemp[0];
				TBstate <= TBstate + 1'd1;
			end
			32'd18: begin
				SDO_tb[3] <= 1'bz;
				SDO_tb[2] <= 1'bz;
				SDO_tb[1] <= 1'bz;
				SDO_tb[0] <= 1'bz;
				TBstate <= TBstate + 1'd1;
			end
		endcase
	end
	
endmodule
