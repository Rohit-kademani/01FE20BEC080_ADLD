`include "parameter.v" 						
module image_read
#(
  parameter WIDTH 	= 768, 					
			HEIGHT 	= 8512, 						
			INFILE  = "img.hex", 	
			START_UP_DELAY = 100, 				
			HSYNC_DELAY = 160,					
			VALUE= 100,														
			SIGN=0									
)
(
	input HCLK,														
	input HRESETn,									
	output VSYNC,								
	output reg HSYNC,								
	// An HSYNC indicates that one line of the image is transmitted.
	// Used to be a horizontal synchronous signals for writing bmp file.
    output reg [7:0]  DATA_R0,				
    output reg [7:0]  DATA_G0,				
    output reg [7:0]  DATA_B0,				
    output reg [7:0]  DATA_R1,				
    output reg [7:0]  DATA_G1,				
    output reg [7:0]  DATA_B1,				
	// Process and transmit 2 pixels in parallel to make the process faster, you can modify to transmit 1 pixels or more if needed
	output			  ctrl_done					// Done flag
);			




parameter sizeOfWidth = 8;						
parameter sizeOfLengthReal = 1179648; 		

localparam		ST_IDLE 	= 2'b00,		
				ST_VSYNC	= 2'b01,			 
				ST_HSYNC	= 2'b10,			 
				ST_DATA		= 2'b11;		 
reg [1:0] cstate, 						
		  nstate;									
reg start;									
reg HRESETn_d;								
reg 		ctrl_vsync_run; 				  
reg [8:0]	ctrl_vsync_cnt;			
reg 		ctrl_hsync_run;				
reg [8:0]	ctrl_hsync_cnt;			
reg 		ctrl_data_run;					
reg [31 : 0]  in_memory    [0 : sizeOfLengthReal/4]; 	
reg [7 : 0]   total_memory [0 : sizeOfLengthReal-1];	

integer temp_BMP   [0 : WIDTH*HEIGHT*3 - 1];			
integer org_R  [0 : WIDTH*HEIGHT - 1]; 	
integer org_G  [0 : WIDTH*HEIGHT - 1];	
integer org_B  [0 : WIDTH*HEIGHT - 1];	
integer i, j;
integer tempR0,tempR1,tempG0,tempG1,tempB0,tempB1; 

integer value,value1,value2,value4;
reg [ 9:0] row; 
reg [10:0] col; 
reg [18:0] data_count; 

// -------- Reading data from input file ----------

initial begin
    $readmemh(INFILE,total_memory,0,sizeOfLengthReal-1); 
end
always@(start) begin
    if(start == 1'b1) begin
        for(i=0; i<WIDTH*HEIGHT*3 ; i=i+1) begin
            temp_BMP[i] = total_memory[i+0][7:0]; 
        end
        
        for(i=0; i<HEIGHT; i=i+1) begin
            for(j=0; j<WIDTH; j=j+1) begin
                org_R[WIDTH*i+j] = temp_BMP[WIDTH*3*(HEIGHT-i-1)+3*j+0]; 
                org_G[WIDTH*i+j] = temp_BMP[WIDTH*3*(HEIGHT-i-1)+3*j+1];
                org_B[WIDTH*i+j] = temp_BMP[WIDTH*3*(HEIGHT-i-1)+3*j+2];
            end
        end
    end
end


always@(posedge HCLK, negedge HRESETn)
begin
    if(!HRESETn) begin
        start <= 0;
		HRESETn_d <= 0;
    end
    else begin											      					
        HRESETn_d <= HRESETn;							
		if(HRESETn == 1'b1 && HRESETn_d == 1'b0)	
			start <= 1'b1;
		else
			start <= 1'b0;
    end
end


always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        cstate <= ST_IDLE;
    end
    else begin
        cstate <= nstate; 
    end
end

//--------- State Transition --------------

// IDLE . VSYNC . HSYNC . DATA
always @(*) begin
	case(cstate)
		ST_IDLE: begin
			if(start)
				nstate = ST_VSYNC;
			else
				nstate = ST_IDLE;
		end			
		ST_VSYNC: begin
			if(ctrl_vsync_cnt == START_UP_DELAY) 
				nstate = ST_HSYNC;
			else
				nstate = ST_VSYNC;
		end
		ST_HSYNC: begin
			if(ctrl_hsync_cnt == HSYNC_DELAY) 
				nstate = ST_DATA;
			else
				nstate = ST_HSYNC;
		end		
		ST_DATA: begin
			if(ctrl_done)
				nstate = ST_IDLE;
			else begin
				if(col == WIDTH - 2)
					nstate = ST_HSYNC;
				else
					nstate = ST_DATA;
			end
		end
	endcase
end
// --- counting for time period of vsync, hsync, data processing ----
always @(*) begin
	ctrl_vsync_run = 0;
	ctrl_hsync_run = 0;
	ctrl_data_run  = 0;
	case(cstate)
		ST_VSYNC: 	begin ctrl_vsync_run = 1; end 
		ST_HSYNC: 	begin ctrl_hsync_run = 1; end	
		ST_DATA: 	begin ctrl_data_run  = 1; end	
	endcase
end
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        ctrl_vsync_cnt <= 0;
		ctrl_hsync_cnt <= 0;
    end
    else begin
        if(ctrl_vsync_run)
			ctrl_vsync_cnt <= ctrl_vsync_cnt + 1; 
		else 
			ctrl_vsync_cnt <= 0;
			
        if(ctrl_hsync_run)
			ctrl_hsync_cnt <= ctrl_hsync_cnt + 1;			
		else
			ctrl_hsync_cnt <= 0;
    end
end
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        row <= 0;
		col <= 0;
    end
	else begin
		if(ctrl_data_run) begin
			if(col == WIDTH - 2) begin
				row <= row + 1;
			end
			if(col == WIDTH - 2) 
				col <= 0;
			else 
				col <= col + 2; 
		end
	end
end

//---------------- Data counting -------------------

always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        data_count <= 0;
    end
    else begin
        if(ctrl_data_run)
			data_count <= data_count + 1;
    end
end
assign VSYNC = ctrl_vsync_run;
assign ctrl_done = (data_count == 196607)? 1'b1: 1'b0; 

//-------------  Image processing  ---------------
always @(*) begin
	
	HSYNC   = 1'b0;
	DATA_R0 = 0;
	DATA_G0 = 0;
	DATA_B0 = 0;                                       
	DATA_R1 = 0;
	DATA_G1 = 0;
	DATA_B1 = 0;                                         
	if(ctrl_data_run) begin
		
		HSYNC   = 1'b1;
		`ifdef BRIGHTNESS_OPERATION	
				
		//		BRIGHTNESS ADDITION OPERATION 
		
		if(SIGN == 1) begin
		// R0
		tempR0 = org_R[WIDTH * row + col   ] + VALUE;
		if (tempR0 > 255)
			DATA_R0 = 255;
		else
			DATA_R0 = org_R[WIDTH * row + col   ] + VALUE;
		// R1	
		tempR1 = org_R[WIDTH * row + col+1   ] + VALUE;
		if (tempR1 > 255)
			DATA_R1 = 255;
		else
			DATA_R1 = org_R[WIDTH * row + col+1   ] + VALUE;	
		// G0	
		tempG0 = org_G[WIDTH * row + col   ] + VALUE;
		if (tempG0 > 255)
			DATA_G0 = 255;
		else
			DATA_G0 = org_G[WIDTH * row + col   ] + VALUE;
		tempG1 = org_G[WIDTH * row + col+1   ] + VALUE;
		if (tempG1 > 255)
			DATA_G1 = 255;
		else
			DATA_G1 = org_G[WIDTH * row + col+1   ] + VALUE;		
		// B
		tempB0 = org_B[WIDTH * row + col   ] + VALUE;
		if (tempB0 > 255)
			DATA_B0 = 255;
		else
			DATA_B0 = org_B[WIDTH * row + col   ] + VALUE;
		tempB1 = org_B[WIDTH * row + col+1   ] + VALUE;
		if (tempB1 > 255)
			DATA_B1 = 255;
		else
			DATA_B1 = org_B[WIDTH * row + col+1   ] + VALUE;
	end
	else begin
			
	            //BRIGHTNESS SUBTRACTION OPERATION 
	
		tempR0 = org_R[WIDTH * row + col   ] - VALUE;
		if (tempR0 < 0)
			DATA_R0 = 0;
		else
			DATA_R0 = org_R[WIDTH * row + col   ] - VALUE;
		// R1	
		tempR1 = org_R[WIDTH * row + col+1   ] - VALUE;
		if (tempR1 < 0)
			DATA_R1 = 0;
		else
			DATA_R1 = org_R[WIDTH * row + col+1   ] - VALUE;	
		// G0	
		tempG0 = org_G[WIDTH * row + col   ] - VALUE;
		if (tempG0 < 0)
			DATA_G0 = 0;
		else
			DATA_G0 = org_G[WIDTH * row + col   ] - VALUE;
		tempG1 = org_G[WIDTH * row + col+1   ] - VALUE;
		if (tempG1 < 0)
			DATA_G1 = 0;
		else
			DATA_G1 = org_G[WIDTH * row + col+1   ] - VALUE;		
		// B
		tempB0 = org_B[WIDTH * row + col   ] - VALUE;
		if (tempB0 < 0)
			DATA_B0 = 0;
		else
			DATA_B0 = org_B[WIDTH * row + col   ] - VALUE;
		tempB1 = org_B[WIDTH * row + col+1   ] - VALUE;
		if (tempB1 < 0)
			DATA_B1 = 0;
		else
			DATA_B1 = org_B[WIDTH * row + col+1   ] - VALUE;
	 end
		`endif
		
	end
end

endmodule

