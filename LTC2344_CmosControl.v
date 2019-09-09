`timescale 1ns / 1ps
module LTC2344_CMOS # 
(
	parameter initial_SoftSpan = 12'b000000111111
)
(
	output reg CS = 1, //Chip Select, Serial data output is enabled when CS is low
	input[3:0] SDO, //Digital Data In
//	input SDO0, //Digital Data In - Channel 1
//	input SDO1, //Digital Data In - Channel 2
//	input SDO2, //Digital Data In - Channel 3
//	input SDO3, //Digital Data In - Channel 4
	input busy, //data can be read on the serial clock cycle after busy goes low
	output SCLK, //Serial Clock
	
	output reg cnv = 0, //Start Signal
//	output reg [17:0] outData0 = 18'd0, //Channel 1 Data Out
//	output reg [17:0] outData1 = 18'd0, //Channel 2 Data Out
//	output reg [17:0] outData2 = 18'b0, //Channel 3 Data Out
//	output reg [17:0] outData3 = 18'b0, //Channel 4 Data Out
	output reg [15:0] outData0 = 18'd0, //Channel 1 Data Out
	output reg [15:0] outData1 = 18'd0, //Channel 2 Data Out
	output reg [15:0] outData2 = 18'b0, //Channel 3 Data Out
	output reg [15:0] outData3 = 18'b0, //Channel 4 Data Out
	output reg dataRdy = 1'b0, //Digital Data Ready
	output reg SDI = 1'b0, //Serial input
	
	input [11:0] softspan, //used before every conversion to set the input range, output 
	input extTrig, //External Trigger
	input serialClock,
	output reg[4:0] progressCounter = STARTUP														//turned into an ouput for testing
	);
	
	//reg [4:0] progressCounter = 5'd30; //Keep track of state machine							turned into an ouput for testing
	reg [4:0] startupCount = 5'd1;
	reg [15:0] temp0 = 16'd0; //temporary storage for first ADC data
	reg [15:0] temp1 = 16'd0; //temporary storage for second ADC data
	reg [15:0] temp2 = 16'd0; //temporary storage for third ADC data
	reg [15:0] temp3 = 16'd0; //temporary storage for fourth ADC data
	reg [11:0] SDI_reg = initial_SoftSpan; //Defaulted to softspan 7 for four channels				should disable channels 3 and 4 for testing
	
	localparam STARTUP = 5'd0, READY = 5'd1, CONVERT0 = 5'd2, AQ17 = 5'd4, AQ16 = 5'd5, AQ15 = 5'd6, AQ14 = 5'd7, AQ13 = 5'd8, AQ12 = 5'd9, AQ11 = 5'd10, AQ10 = 5'd11, AQ9 = 5'd12, AQ8 = 5'd13, AQ7 = 5'd14, AQ6 = 5'd15, AQ5 = 5'd16, AQ4 = 5'd17, AQ3 = 5'd18, AQ2 = 5'd19, AQ1 = 5'd20, AQ0 = 5'd21;
	localparam CONVERT1 = 5'd3, OUTPUTS = 5'd22, RESTART = 5'd23;
	
	oddr_0 clock_forward_inst (
      .clk_in(serialClock),    // input wire clk_in
      .clk_out(SCLK)  // output wire clk_out
    );
	
	
	always @ (posedge serialClock)
	begin
		case (progressCounter)
			STARTUP : begin 												//On startup the ADC is set to SS7 for all 4 channels. This runs a quick conversion so it can then input the initial SS config set in block diagram GUI
				case(startupCount)
					1 : begin
						cnv <= 1;
						SDI_reg <= initial_SoftSpan;
						startupCount <= 5'd2;
					end
					2 : begin 
						if(busy)
							startupCount <= 5'd3;
						else
							startupCount <= 5'd2;
					end
					3 : begin
						if(busy == 0) begin
							cnv <= 0;
							startupCount <= 5'd4;
							CS <= 0;
						end
						else begin
							startupCount <= 5'd3;
						end
					end
					4 : begin
						SDI = SDI_reg[11]; 
						startupCount <= startupCount + 1'b1;
					end
					5 : begin
						SDI = SDI_reg[10]; 
						startupCount <= startupCount + 1'b1;
					end
					6 : begin
						SDI = SDI_reg[9]; 
						startupCount <= startupCount + 1'b1;
					end
					7 : begin
						SDI = SDI_reg[8]; 
						startupCount <= startupCount + 1'b1;
					end
					8 : begin
						SDI = SDI_reg[7]; 
						startupCount <= startupCount + 1'b1;
					end
					9 : begin
						SDI = SDI_reg[6]; 
						startupCount <= startupCount + 1'b1;
					end
					10: begin
						SDI = SDI_reg[5]; 
						startupCount <= startupCount + 1'b1;
					end
					11: begin
						SDI = SDI_reg[4]; 
						startupCount <= startupCount + 1'b1;
					end
					12: begin
						SDI = SDI_reg[3]; 
						startupCount <= startupCount + 1'b1;
					end
					13: begin
						SDI = SDI_reg[2]; 
						startupCount <= startupCount + 1'b1;
					end
					14: begin
						SDI = SDI_reg[1]; 
						startupCount <= startupCount + 1'b1;
					end
					15: begin
						SDI = SDI_reg[0]; 
						startupCount <= startupCount + 1'b1;
					end
					16: begin
						CS = 1;
						SDI = 0;
						progressCounter <= READY;
					end
					default : startupCount <= 5'd0;
				endcase
			end
			
			READY : begin //Wait for the trigger
				dataRdy <= 1'd0;
				SDI_reg <= softspan;
				if (extTrig) begin
					if(!busy) begin 
						progressCounter <= CONVERT0;
						cnv <= 1;
					end
				end
				else
					progressCounter <= READY;
			end
			
			// CONVERT
			CONVERT0 : begin 
				SDI_reg <= softspan;
				
				if(busy)
					progressCounter <= CONVERT1;
				else
					progressCounter <= CONVERT0;
			end
			
			CONVERT1 : begin
				if(busy == 0) begin
					CS <= 0;
					cnv <= 0;
					progressCounter <= AQ15;
				end
				else
					progressCounter <= CONVERT1;
			end
			
			
			// AQUIRE
//			AQ17 : begin  												//States commented out because 16 bit ADC not 18 bit
//				if(busy == 0) begin
//					cnv <= 0;
//					progressCounter <= AQ16;
//					CS <= 0;
//					temp0[17] = SDO[0];
//					temp1[17] = SDO[1];
//					temp2[17] = SDO[2];
//					temp3[17] = SDO[3];
//					SDI = SDI_reg[11];
//				end
//				else
//					progressCounter <= AQ17;
//			end
//			AQ16 : begin
//					temp0[16] = SDO[0];
//					temp1[16] = SDO[1];
//					temp2[16] = SDO[2];
//					temp3[16] = SDO[3];
//					SDI = SDI_reg[10];
//					progressCounter <= progressCounter + 1'b1;
////				end
//			AQ15 : begin
//					temp0[15] = SDO[0];
//					temp1[15] = SDO[1];
//					temp2[15] = SDO[2];
//					temp3[15] = SDO[3];
//					SDI = SDI_reg[9];
//					progressCounter <= progressCounter + 1'b1;
//				end
			AQ15 : begin
				//if(busy == 0) begin
					cnv <= 0;
					//CS <= 0;
					progressCounter <= AQ14;
					temp0[15] = SDO[0];
					temp1[15] = SDO[1];
					temp2[15] = SDO[2];
					temp3[15] = SDO[3];
					SDI = SDI_reg[11];
				//end
				//else
				//	progressCounter <= AQ15;
			end
			AQ14 : begin
				temp0[14] = SDO[0];
				temp1[14] = SDO[1];
				temp2[14] = SDO[2];
				temp3[14] = SDO[3];
				SDI = SDI_reg[10];
				progressCounter <= AQ13;
			end
			AQ13 : begin
				temp0[13] = SDO[0];
				temp1[13] = SDO[1];
				temp2[13] = SDO[2];
				temp3[13] = SDO[3];
				SDI = SDI_reg[9];
				progressCounter <= AQ12;
			end
			AQ12 : begin
				temp0[12] = SDO[0];
				temp1[12] = SDO[1];
				temp2[12] = SDO[2];
				temp3[12] = SDO[3];
				SDI = SDI_reg[8];
				progressCounter <= AQ11;
			end
			AQ11 : begin
				temp0[11] = SDO[0];
				temp1[11] = SDO[1];
				temp2[11] = SDO[2];
				temp3[11] = SDO[3];
				SDI = SDI_reg[7];
				progressCounter <= AQ10;
			end
			AQ10 : begin
				temp0[10] = SDO[0];
				temp1[10] = SDO[1];
				temp2[10] = SDO[2];
				temp3[10] = SDO[3];
				SDI = SDI_reg[6];
				progressCounter <= AQ9;
			end
			AQ9 : begin
				temp0[9] = SDO[0];
				temp1[9] = SDO[1];
				temp2[9] = SDO[2];
				temp3[9] = SDO[3];
				SDI = SDI_reg[5];
				progressCounter <= AQ8;
			end
			AQ8 : begin
				temp0[8] = SDO[0];
				temp1[8] = SDO[1];
				temp2[8] = SDO[2];
				temp3[8] = SDO[3];
				SDI = SDI_reg[4];
				progressCounter <= AQ7;
			end
			AQ7 : begin
				temp0[7] = SDO[0];
				temp1[7] = SDO[1];
				temp2[7] = SDO[2];
				temp3[7] = SDO[3];
				SDI = SDI_reg[3];
				progressCounter <= AQ6;
			end
			AQ6 : begin
				temp0[6] = SDO[0];
				temp1[6] = SDO[1];
				temp2[6] = SDO[2];
				temp3[6] = SDO[3];
				SDI = SDI_reg[2];
				progressCounter <= AQ5;
			end
			AQ5 : begin
				temp0[5] = SDO[0];
				temp1[5] = SDO[1];
				temp2[5] = SDO[2];
				temp3[5] = SDO[3];
				SDI = SDI_reg[1];
				progressCounter <= AQ4;
			end
			AQ4 : begin
				temp0[4] = SDO[0];
				temp1[4] = SDO[1];
				temp2[4] = SDO[2];
				temp3[4] = SDO[3];
				SDI = SDI_reg[0];
				progressCounter <= AQ3;
			end
			AQ3 : begin
				temp0[3] = SDO[0];
				temp1[3] = SDO[1];
				temp2[3] = SDO[2];
				temp3[3] = SDO[3];
				SDI <= 0;
				progressCounter <= AQ2;
			end
			AQ2 : begin
				temp0[2] = SDO[0];
				temp1[2] = SDO[1];
				temp2[2] = SDO[2];
				temp3[2] = SDO[3];
				progressCounter <= AQ1;
			end
			AQ1 : begin
				temp0[1] = SDO[0];
				temp1[1] = SDO[1];
				temp2[1] = SDO[2];
				temp3[1] = SDO[3];
				progressCounter <= AQ0;
		 end
			AQ0 : begin
				temp0[0] = SDO[0];
				temp1[0] = SDO[1];
				temp2[0] = SDO[2];
				temp3[0] = SDO[3];
				progressCounter <= OUTPUTS;
			end
			
			//OUTPUTS
			OUTPUTS : begin
				CS <= 1;
				dataRdy <= 1'd1;
				outData0 <= temp0;
				outData1 <= temp1;
				outData2 <= temp2;
				outData3 <= temp3;
				progressCounter <= RESTART;
			end
			
			//AQUIRE
			RESTART : begin
				progressCounter <= READY;
			end
			
			default : begin
				progressCounter <= READY;
			end
		endcase
	end
	
endmodule

