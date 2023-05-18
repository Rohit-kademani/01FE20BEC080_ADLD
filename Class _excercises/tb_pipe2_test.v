module pipe2_test;
reg clk1,clk2;
reg [15:0]rs1,rs2,rd;
reg [3:0]func;
reg [7:0]addr;
wire [15:0]y;
integer k;

pipe2 a(rs1,rs2,rd,func,addr,clk1,clk2,y);

initial clk1=1'b0;
initial clk2=1'b0;

always #5 clk1=~clk1;
always #5 clk2=~clk2;

initial
begin
for(k=0;k<16;k=k+1)
a.regbank[k]=k;
end

initial
begin
#5 rs1=7;rs2=2;rd=9;func=4'b0000;addr=4'b0000;
#15 rs1=5;rs2=6;rd=10;func=4'b0001;addr=4'b0001;
#45 rs1=8;rs2=4;rd=11;func=4'b0010;addr=4'b0010;
#135 rs1=3;rs2=1;rd=12;func=4'b0011;addr=4'b0011;
//#20
$display("RESULT=%d",y);
$display("RESULT=%3d",func);


//#20 rs1=3;rs2=2;rd=7;func=4'd4;addr=4'd3;
//#20
//$display("RESULT=%d",y);

//rs1=5;
//rs2=6;
//rd=7;
//func=4'd4;
//addr=4'd3;
//#20
//$display("RESULT=%d",y);

end
/*initial 
begin
$mointor ( "time:%d,F=%3d",$time,y);
#200 $finish;
end*/
endmodule

module pipe2(rs1,rs2,rd,func,addr,clk1,clk2,y);

input clk1,clk2;
input [15:0]rs1,rs2,rd;
input [3:0]func;
input [7:0]addr;
reg [15:0]mem [255:0];
output [15:0]y;
reg [15:0]A,B,Z,l34_Z,l12_rd,l23_rd;
reg [3:0]l12_func;
reg [15:0] regbank [0:15];
reg [7:0]l12_addr,l23_addr,l34_addr;



always@(posedge clk1)
begin

A<=regbank[rs1];
B<=regbank[rs2];
l12_rd<=rd;
l12_func<=func;
l12_addr<=addr;

end

always@(posedge clk2)
begin

case(l12_func)
0000: Z<=A+B;
0001: Z<=A>>1;
0010: Z<=A/B;
0011: Z<=A*B;
0100: Z<=B>>1;
0101: Z<=A-B;
0110: Z<=B<<1;
0111: Z<=A;
0100: Z<=~B;
default : Z<=16'b1111;
endcase
l23_rd<=l12_rd;
l23_addr<=l12_addr;

end

always@(posedge clk1)
begin
regbank[l23_rd]<=Z;
l34_Z<=Z;
l34_addr<=l23_addr;

end

always@(posedge clk2)
begin
mem[l34_addr]<=l34_Z;
end

assign y=l34_Z;
endmodule 

