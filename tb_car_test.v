module car_test;


reg clk;
reg car;
wire fr_sens,bk_sens;
reg [7:0]pswd;
wire gate;


car a(gate,fr_sens,bk_sens,pswd,clk,car);
initial clk=1'b0;
always #1 clk=~clk;
initial 
begin

$display("0: closed gate_____ 1: Opened gate");

car=1;
pswd=8'd194;
#20
$display("Gate status=%d",gate);

car=1;
pswd=8'd194;
#20
$display("Gate status=%d",gate);

/*fr_sens=1;pswd=8'd250; bk_sens=0;
#20
$display("Gate status=%d",gate);

fr_sens=0;pswd=8'd255;bk_sens=1;
#20
$display("Gate status=%d",gate);*/

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


module assign1(gate,fr_sens,bk_sens,pswd,clk,car);

input clk;
input car;
input [7:0]pswd;
output reg fr_sens,bk_sens;
output reg gate;
reg flag;

always@(posedge clk)
begin
if(car==1)
begin
	fr_sens=1;

if(pswd==8'd194)
begin
gate=1;
fr_sens=0;
bk_sens=1; 
end
else
begin
gate=0;
fr_sens=0;
bk_sens=0;
end
bk_sens=0;
end
else
begin
gate=0;
end



end
endmodule

							


