module ram1_test;

reg [9:0]addr=8'bz;
wire [7:0]data_out;
reg [7:0]data=8'bz;
reg wr,rd,cs;
integer k;

ram1 a(addr,data,data_out,clk,rd,wr,cs);

initial 
begin
for(k=0;k<1023;k++)
begin
addr=addr+1;
data=data+1;
end
end
always #2 clk=~clk;

endmodule 
