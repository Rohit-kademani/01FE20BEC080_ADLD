module assign_sm_test;

reg clk;
reg car;
reg fr_sens,bk_sens;
reg [7:0]pswd;
wire gate;

assign_sm a(gate,fr_sens,bk_sens,pswd,clk,car);
initial clk=1'b0;
always #1 clk=~clk;
initial 
begin

$display("0: closed gate_____ 1: Opened gate");
#2
car=1;
#2
fr_sens=1;pswd=8'dx;bk_sens=0;
#2
fr_sens=0;pswd=8'd194;bk_sens=0;
#2
fr_sens=0;pswd=8'dx;bk_sens=1;
#2
fr_sens=0;pswd=8'dx;bk_sens=0;
#20
$display("Gate status=%d",gate);

#2
car=1;
#2
fr_sens=1;pswd=8'dx;bk_sens=0;
#2
fr_sens=0;pswd=8'd255;bk_sens=0;
#2
fr_sens=0;pswd=8'dx;bk_sens=1;
#2
fr_sens=0;pswd=8'dx;bk_sens=0;
#20
$display("Gate status=%d",gate);


#2
car=0;
#2
fr_sens=0;pswd=8'dx;bk_sens=0;
#2
fr_sens=0;pswd=8'd194;bk_sens=0;
#2
fr_sens=0;pswd=8'dx;bk_sens=0;
#2
fr_sens=0;pswd=8'dx;bk_sens=0;
#20
$display("Gate status=%d",gate);
/*fr_sens=1;pswd=8'd250;bk_sens=0;
#20
$display("Gate status=%d",gate);*/


/*fr_sens=1;bk_sens=1;pswd=8'd253;
#20
$display("RESULT=%d",gate);

fr_sens=1;bk_sens=1;pswd=8'd194;
#20
$display("RESULT=%d",gate);

fr_sens=1;bk_sens=1;pswd=8'd100;
#20
$display("RESULT=%d",gate);*/
end
endmodule



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
			


