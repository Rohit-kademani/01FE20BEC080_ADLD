module rom_test();
reg [8:0]addr;
reg rd_en,cs;
wire [7:0]data;
integer k;

initial begin
for(k=0;k<1023;k=k+1)
begin
addr=addr+1;
rd_en=1;
cs=1;
$display("Data = %4d",data);
end
end
endmodule


module rom(addr,data,rd_en,cs);
input [8:0]addr;
input rd_en,cs;
output reg [7:0]data;

always@(addr or rd_en or cs)
	case(addr)
	0:data = 32;
	1:data = 32;
	2:data = 32;
	3:data = 32;
	4:data = 32;
	5:data = 32;
	endcase
endmodule 
