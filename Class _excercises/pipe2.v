module pipe2(rs1,rs2,rd,func,addr,clk1,clk2,y)

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
0001: Z<=A-B;
0010: Z<=A*B;
0011: Z<=A>>1;
0100: Z<=B>>1;
0101: Z<=A<<1;
0110: Z<=B<<1;
0111: Z<=~A;
0100: Z<=~B;
default : Z<=16'1111;
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
