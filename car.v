module car(gate,fr_sens,bk_sens,pswd,clk,car);

input clk;
input car;
input [7:0]pswd;
output fr_sens,bk_sens;

output gate;
reg flag;
parameter s0=3'b000, s1=3'b001 , s2=3'b010;
reg [1:0]state;
always@(posedge clk)
begin
	case(state)
	s0: begin
		if(car==1)
begin
		fk_sens=1;
		state<= s1;
end
		else
		state<=s0; 
	   
end
	s1: begin
		if(pswd==8'd253)
		begin
		gate=1;		
		state<=s2;
		end
		else
		gate=0;
		state<=s1;	
		end

	s2: begin
		if(bk_sens==1)
		state<=s0;
		else
		state<=s2;
		end

	default: state<=s0;
	endcase
end
endmodule
		
