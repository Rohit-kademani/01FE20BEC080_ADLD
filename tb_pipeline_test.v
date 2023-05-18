module pipeline_test;

reg [9:0] A,B,C,D;
reg clk;
wire [9:0] F;

pipeline a(F,A,B,C,D,clk);
initial clk=1'b0;
always #1 clk=~clk;
initial

begin
A=5;
B=6;
C=7;
D=8;
#20
$display("RESULT=%d",F);
A=10;
B=6;
C=7;
D=8;
#20;
$display("RESULT=%d",F);
A=5;
B=6;
C=7;
D=8;
#20; 

$display("RESULT=%d",F);
end


endmodule 

module pipeline(F,A,B,C,D,clk);


input [9:0]A,B,C,D;
input clk;
output [9:0]F;
reg [9:0] L12_x1,L12_x2,L12_D,L23_x3,L23_D,L34_f;

always@(posedge clk)


begin

L12_x1= #4 A+B;
L12_x2= #4 C-D;
L12_D=D;

L23_x3= #4 L12_x1+L12_x2;
L23_D= L12_D;

L34_f= #6 L23_x3 * L23_D;

end
assign F=L34_f;

endmodule 
