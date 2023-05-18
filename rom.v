module rom(addr,data,rd_en,cs);
input [2:0]addr;
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
