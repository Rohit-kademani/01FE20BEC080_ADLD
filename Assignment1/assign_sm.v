module assign_sm(gate,fr_sens,bk_sens,pswd,clk,car);

input clk;
input car;
input fr_sens,bk_sens;
input [7:0]pswd;
output reg gate;
reg flag;
parameter s0=3'b000, s1=3'b001 , s2=3'b010;
reg [1:0]state;
always@(*)
begin
if(car==1)
begin
	case(state)
	s0: begin
		if(fr_sens==1)
	
		state<= s1;
		else
begin
		gate=0;
		state<=s0;
end 
	    end

	s1: begin
		if( pswd==8'd253)
		begin
		
		gate=1;		
		state<=s2;
		end
		else
		begin
		gate=0;
		state<=s1;
		end	
		end

	s2: begin
		if(bk_sens==1)
		begin
		//gate=1;
		state<=s0;
		end
		else
		begin
		//gate=0;
		state<=s2;
		end
		end

	default: begin gate=0; state<=s0; end
	endcase
end

 else
	begin
	gate=0;
	end
end

endmodule
			

