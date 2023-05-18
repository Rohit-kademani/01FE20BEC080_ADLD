module vending_test;

reg [3:0]coin;
reg [1:0]product;
reg [3:0]cost;
wire [3:0]change;

vending a(coin,cost,change,product);

initial
begin 
#10
coin=4'd5;
product=0;
cost=5;
#10
$display("Change is : %2d",change);

coin=3*4'd5;
product=1;
cost=0;
#10
$display("Change is : %2d",change);

coin=4'd10;
product=1;
cost=0;
#10
$display("Change is : %2d",change);

end
endmodule


module vending(coin,cost,change,product);

input [3:0]coin;
input [1:0]product;
input [3:0]cost;
output reg [3:0]change;
parameter s0=3'b000, s1=3'b001, s2=3'b010, s3=3'b011;
reg [2:0]state;

always@(*)
begin
	case(state)
	
	s0:begin
	if(coin==5 || coin ==10)
	state<=s1;
	else
	state<=s0;
	end

	s1:begin
	if(product==0 || product==1 || product==2 || product==3)
	state<=s2;
	else
	state<=s1;
	end

	s2:begin
	if(product==0 && (coin==4'd5))
	state<=s3;
	else if(product==1 && (coin==2*4'd5 || coin == 4'd10))
	state<=s3;
	else if(product==2 && (coin==3*4'd5  || coin==(4'd10+4'd5)))
	state<=s3;
	else if(product==3 && (coin==4*4'd5 || coin== 2*4'd10 || coin== (2*4'd5+ 4'd10)))
	state<=s3;
	else
	state<=s2;
	end

	s3:begin 
	if(product==0)begin
	change=coin-5;
	//state<=s0;
	end
	else if(product==1)
	begin	
	change=coin-10;
	//state<=s0;
	end
	else if(product==2)
	begin	
	change=coin-15;
	//state<=s0;
	end
	else if(product==3)
	begin
	change=coin-20;
	//state<=s0;
	end
	else
	state<=s0;
	end
	default: state<=s0;

endcase
end
endmodule
