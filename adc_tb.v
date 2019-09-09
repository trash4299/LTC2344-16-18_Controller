`timescale 1ns/1fs
`default_nettype none

module LTC2344CMOS_tb;
	reg[3:0] SDO_tb = 4'bzzzz; //Digital Data In
	reg busy_tb = 0; //data can be read on the serial clock cycle after busy goes low
	wire SCLK_tb; //Serial Clock
	
	wire cnv_tb;
	wire [15:0] outData0_tb; //Channel 1 Data Out
	wire [15:0] outData1_tb; //Channel 2 Data Out
	wire [15:0] outData2_tb; //Channel 3 Data Out
	wire [15:0] outData3_tb; //Channel 4 Data Out
	wire dataRdy_tb;
	wire SDI_tb; //Serial input
	
	reg [11:0] softspan_tb; //used before every conversion to set the input range, output 
	reg extTrig_tb;
	reg serialClock_tb;
    
    parameter numOfChannels = 4;
    integer TBstate = 32'd40;
    reg inputTemp = 16'b1010101010101010;
    
	LTC2344_CMOS DUT(
	.SDO(SDO_tb),
	.busy(busy_tb),
	.SCLK(SCLK_tb),
	.cnv(cnv_tb),
	.outData0(outData0_tb),
	.outData1(outData1_tb),
	.outData2(outData2_tb),
	.outData3(outData3_tb),
	.dataRdy(dataRdy_tb),
	.SDI(SDI_tb),
	.softspan(softspan_tb),
	.extTrig(extTrig_tb),
	.serialClock(serialClock_tb));
	
	initial begin 
       serialClock_tb = 0;
       forever begin
           #22.222222222; //45Mhz
           serialClock_tb = ~serialClock_tb;
       end
    end
	
	always@(posedge cnv_tb) begin //models the busy signal from the ADC
	   busy_tb = 1;
	   #((425*numOfChannels-20):(475*numOfChannels-20):(525*numOfChannels-20)); //minimum:typical:maximum time it will take to convert 
	   busy_tb = 0;
	   //TBstate <= TBstate + 1'd1;
	end
	
	initial begin
		extTrig_tb = 0;
		softspan_tb = 12'b111111000000;
		#3000;
		extTrig_tb = 1;
        TBstate = 32'd0;
		#50;
		extTrig_tb = 0;
        #8000;
		$finish;
	end
	
	always@(posedge serialClock_tb) begin
	    case(TBstate)
	        0 : begin
				TBstate <= TBstate + 1'd1;
	        end
	        1 : begin
				//extTrig_tb = 1;
				TBstate <= TBstate + 1'd1;
		    end
	        2 : begin
				extTrig_tb = 0;
				if(busy_tb == 0) begin
					SDO_tb[3] <= 1;
					SDO_tb[2] <= 1;
					SDO_tb[1] <= 1;
					SDO_tb[0] <= 1;
					TBstate <= TBstate + 1'd1;
				end
		    end
	        3 : begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        4 : begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        5 : begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        6 : begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        7 : begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        8 : begin
				SDO_tb[3] <= 0;
				SDO_tb[2] <= 0;
				SDO_tb[1] <= 0;
				SDO_tb[0] <= 0;
				TBstate <= TBstate + 1'd1;
	        end
	        9 : begin
				SDO_tb[3] <= 0;
				SDO_tb[2] <= 0;
				SDO_tb[1] <= 0;
				SDO_tb[0] <= 0;
				TBstate <= TBstate + 1'd1;
	        end
	        10: begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        11: begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        12: begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        13: begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        14: begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        15: begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        16: begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[1] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        17: begin
				SDO_tb[3] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[2] <= 1;
				SDO_tb[0] <= 1;
				TBstate <= TBstate + 1'd1;
	        end
	        18: begin
				SDO_tb[3] <= 1'bz;
				SDO_tb[2] <= 1'bz;
				SDO_tb[1] <= 1'bz;
				SDO_tb[0] <= 1'bz;
				TBstate <= 0;
	        end
			
	   endcase
	end
	
endmodule
