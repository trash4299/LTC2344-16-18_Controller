`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: V. Lobo
// 
// Design Name: 
// Module Name:    ADC controller
// Project Name: 
// Target Devices: 	LTC2344-16 ADC
//////////////////////////////////////////////////////////////////////////////////

module LTC2344_CMOS (
	output reg CS = 1, //Chip Select, Serial data output is enabled when CS is low
	input[3:0] SDO, //Digital Data In
	input busy, //Busy signal from the ADC
	output SCKI, //Serial Clock to ADC
	output reg cnv = 0, //Start conversion signal to ADC
	output reg [15:0] outData0 = 16'd0, //Channel 1 Data Out
	output reg [15:0] outData1 = 16'd0, //Channel 2 Data Out
	output reg [15:0] outData2 = 16'd0, //Channel 3 Data Out
	output reg [15:0] outData3 = 16'd0, //Channel 4 Data Out
	output reg dataRdy = 0, //Digital Data Ready
	output reg SDI = 0, //Serial input to ADC
	input [11:0] softspan, //used before every conversion to set the input range and output format
	input extTrig, //External Trigger in
	input serialClock, //clock to be forwarded to the ADC
	
	//turned into outputs for testing
	output reg CE = 0,
	output reg[4:0] progressCounter = 5'd1,
	output reg[4:0] readData = 5'd0,
	output reg [4:0] busyCount = 4'd0,
	output reg [4:0] outputCycle = 5'd0
	);
	
	reg [4:0]  startupCount = 5'd1;
	reg [15:0] temp0 = 16'd0; //temporary storage for first ADC data
	reg [15:0] temp1 = 16'd0; //temporary storage for second ADC data
	reg [15:0] temp2 = 16'd0; //temporary storage for third ADC data
	reg [15:0] temp3 = 16'd0; //temporary storage for fourth ADC data
	reg [11:0] SDI_reg = 12'd0; //takes the value from the softspan input
	
	localparam STARTUP = 5'd0, READY = 5'd1, CONVERT0 = 5'd2, CONVERT1 = 5'd3, ACQUIRE = 5'd30, OUTPUTS = 5'd22, RESTART = 5'd23, DELAY = 5'd31;
	localparam AQ17 = 5'd4, AQ16 = 5'd5, AQ15 = 5'd6, AQ14 = 5'd7, AQ13 = 5'd8, AQ12 = 5'd9, AQ11 = 5'd10, AQ10 = 5'd11, AQ9 = 5'd12, AQ8 = 5'd13, AQ7 = 5'd14, AQ6 = 5'd15, AQ5 = 5'd16, AQ4 = 5'd17, AQ3 = 5'd18, AQ2 = 5'd19, AQ1 = 5'd20, AQ0 = 5'd21;
	localparam IDLE = 5'd29, FINISHED = 5'd28;
	
   ODDR #(
       .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
       .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
       .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
    ) ODDR_inst (
       .Q(SCKI),   // 1-bit DDR output
       .C(serialClock),   // 1-bit clock input
       .CE(CE), // 1-bit clock enable input
       .D1(1'd0), // 1-bit data input (positive edge)
       .D2(1'd1), // 1-bit data input (negative edge)
       .R(R),   // 1-bit reset
       .S(S)    // 1-bit set
    );
	
	always @ (posedge serialClock) begin
		case (progressCounter)
			// STARTUP : begin 			//Device is initially configured for SS7 on startup so this was supposed to run a quick conversion so it could set the desired SS
				// case(startupCount)
					// 1 : begin
						// cnv <= 1;
						// SDI_reg <= initial_SoftSpan;
						// startupCount <= 5'd2;
					// end
					// 2 : begin
						// if(busy) begin
							// startupCount <= 5'd3;
							// cnv <= 0;
						// end
						// else
							// startupCount <= 5'd2;
					// end
					// 3 : begin
						// if(busy == 0) begin
							// startupCount <= 5'd4;
							// CS <= 0;
						// end
						// else begin
							// startupCount <= 5'd3;
						// end
					// end
					// 4 : begin
						// SDI = SDI_reg[11]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 5 : begin
						// SDI = SDI_reg[10]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 6 : begin
						// SDI = SDI_reg[9]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 7 : begin
						// SDI = SDI_reg[8]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 8 : begin
						// SDI = SDI_reg[7]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 9 : begin
						// SDI = SDI_reg[6]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 10: begin
						// SDI = SDI_reg[5]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 11: begin
						// SDI = SDI_reg[4]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 12: begin
						// SDI = SDI_reg[3]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 13: begin
						// SDI = SDI_reg[2]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 14: begin
						// SDI = SDI_reg[1]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 15: begin
						// SDI = SDI_reg[0]; 
						// startupCount <= startupCount + 1'b1;
					// end
					// 16: begin
						// CS = 0;
						// SDI = 0;
						// progressCounter <= READY;
					// end
					// default : startupCount <= 5'd0;
				// endcase
			// end
			
			READY : begin
				dataRdy <= 1'd0;
				SDI_reg <= softspan;
				busyCount <= 4'd0;
				outputCycle <= 5'd0;
				if (extTrig) begin
					if(!busy) begin 
						progressCounter <= CONVERT0;
						cnv <= 1;
						outputCycle <= 5'd1;
					end
				end
				else
					progressCounter <= READY;
			end
			
			CONVERT0 : begin
				SDI_reg <= softspan;
				if(busy) begin
					progressCounter <= CONVERT1;
					cnv <= 0;
                    outputCycle <= outputCycle + 1'd1;
				end
				else begin //if there is no response (busy signal) from the ADC, then start over
					if(busyCount == 4'd4) begin
						progressCounter <= READY;
						busyCount <= 4'd0;
						cnv <= 0;
						outputCycle <= 5'd0;
					end
					else begin
						progressCounter <= CONVERT0;
						busyCount <= busyCount + 1'd1;
					end
				end
			end
			
			CONVERT1 : begin
				if(busy == 0) begin
					CS <= 0;
					readData <= AQ16;
					progressCounter <= ACQUIRE;
				end
				else
					progressCounter <= CONVERT1;
			end
			
			ACQUIRE : begin
				if (readData == FINISHED) begin
					progressCounter = RESTART;
				end
				else
					progressCounter <= ACQUIRE;
			end
			
            OUTPUTS : begin
                CS <= 1;
                dataRdy <= 1'd1;
                outData0 <= temp0;
                outData1 <= temp1;
                outData2 <= temp2;
                outData3 <= temp3;
                outputCycle <= outputCycle + 1;
                progressCounter <= DELAY;
				readData <= FINISHED;
            end
			
            DELAY : begin
                outputCycle <= outputCycle + 1;
                if (outputCycle > 5'd20) begin
                    progressCounter <= RESTART;
                end
                else begin
                    progressCounter <= DELAY;
                end
            end
			
            RESTART : begin
                progressCounter <= READY;
            end
            
            default : begin
                progressCounter <= READY;
            end  
		endcase
		
		case (readData)			
			AQ16 : begin
					readData <= AQ15;
					CE <= 1;
				end
			AQ15 : begin
					temp0[15] <= SDO[0];
					temp1[15] <= SDO[1];
					temp2[15] <= SDO[2];
					temp3[15] <= SDO[3];
					SDI <= SDI_reg[11];
					readData <= AQ14;
					outputCycle <= outputCycle + 1;
			end
			AQ14 : begin
				temp0[14] <= SDO[0];
				temp1[14] <= SDO[1];
				temp2[14] <= SDO[2];
				temp3[14] <= SDO[3];
				SDI <= SDI_reg[10];
				outputCycle <= outputCycle + 1;
				readData <= AQ13;
			end
			AQ13 : begin
				temp0[13] <= SDO[0];
				temp1[13] <= SDO[1];
				temp2[13] <= SDO[2];
				temp3[13] <= SDO[3];
				SDI <= SDI_reg[9];
				outputCycle <= outputCycle + 1;
				readData <= AQ12;
			end
			AQ12 : begin
				temp0[12] <= SDO[0];
				temp1[12] <= SDO[1];
				temp2[12] <= SDO[2];
				temp3[12] <= SDO[3];
				SDI <= SDI_reg[8];
				outputCycle <= outputCycle + 1;
				readData <= AQ11;
			end
			AQ11 : begin
				temp0[11] <= SDO[0];
				temp1[11] <= SDO[1];
				temp2[11] <= SDO[2];
				temp3[11] <= SDO[3];
				SDI <= SDI_reg[7];
				outputCycle <= outputCycle + 1;
				readData <= AQ10;
			end
			AQ10 : begin
				temp0[10] <= SDO[0];
				temp1[10] <= SDO[1];
				temp2[10] <= SDO[2];
				temp3[10] <= SDO[3];
				SDI <= SDI_reg[6];
				outputCycle <= outputCycle + 1;
				readData <= AQ9;
			end
			AQ9 : begin
				temp0[9] <= SDO[0];
				temp1[9] <= SDO[1];
				temp2[9] <= SDO[2];
				temp3[9] <= SDO[3];
				SDI <= SDI_reg[5];
				outputCycle <= outputCycle + 1;
				readData <= AQ8;
			end
			AQ8 : begin
				temp0[8] <= SDO[0];
				temp1[8] <= SDO[1];
				temp2[8] <= SDO[2];
				temp3[8] <= SDO[3];
				SDI <= SDI_reg[4];
				outputCycle <= outputCycle + 1;
				readData <= AQ7;
			end
			AQ7 : begin
				temp0[7] <= SDO[0];
				temp1[7] <= SDO[1];
				temp2[7] <= SDO[2];
				temp3[7] <= SDO[3];
				SDI <= SDI_reg[3];
				outputCycle <= outputCycle + 1;
				readData <= AQ6;
			end
			AQ6 : begin
				temp0[6] <= SDO[0];
				temp1[6] <= SDO[1];
				temp2[6] <= SDO[2];
				temp3[6] <= SDO[3];
				SDI <= SDI_reg[2];
				outputCycle <= outputCycle + 1;
				readData <= AQ5;
			end
			AQ5 : begin
				temp0[5] <= SDO[0];
				temp1[5] <= SDO[1];
				temp2[5] <= SDO[2];
				temp3[5] <= SDO[3];
				SDI <= SDI_reg[1];
				outputCycle <= outputCycle + 1;
				readData <= AQ4;
			end
			AQ4 : begin
				temp0[4] <= SDO[0];
				temp1[4] <= SDO[1];
				temp2[4] <= SDO[2];
				temp3[4] <= SDO[3];
				SDI <= SDI_reg[0];
				outputCycle <= outputCycle + 1;
				readData <= AQ3;
			end
			AQ3 : begin
				temp0[3] <= SDO[0];
				temp1[3] <= SDO[1];
				temp2[3] <= SDO[2];
				temp3[3] <= SDO[3];
				SDI <= 0;
				outputCycle <= outputCycle + 1;
				readData <= AQ2;
			end
			AQ2 : begin
				temp0[2] <= SDO[0];
				temp1[2] <= SDO[1];
				temp2[2] <= SDO[2];
				temp3[2] <= SDO[3];
				outputCycle <= outputCycle + 1;
				readData <= AQ1;
			end
			AQ1 : begin
				temp0[1] <= SDO[0];
				temp1[1] <= SDO[1];
				temp2[1] <= SDO[2];
				temp3[1] <= SDO[3];
				outputCycle <= outputCycle + 1;
				readData <= AQ0;
			end
			AQ0 : begin
				temp0[0] <= SDO[0];
				temp1[0] <= SDO[1];
				temp2[0] <= SDO[2];
				temp3[0] <= SDO[3];
				outputCycle <= outputCycle + 1;
				progressCounter <= OUTPUTS;
				readData <= IDLE;
                CE <= 0;
			end
			IDLE: begin
				 end     
		endcase
	end
endmodule

