module mips32_test;

reg clk1,clk2;
integer k;

mips32 mips(clk1,clk2);

initial 
	begin
			clk1=0; clk2=0;
	  repeat(200)
		begin
		  #5 clk1=1; #5 clk1=0;
		  #5 clk2=1; #5 clk2=0;
		end
	end

initial 
	begin
	  for(k=0;k<31;k=k+1)
	  mips.Reg[k] =k;

mips.Mem[0] = 32'h280a00c8;   // R10,R0,200
mips.Mem[1] = 32'h28020001;   //R3,
mips.Mem[2] = 32'h0e94a000;    // dummy
mips.Mem[3] = 32'h21430000;    
mips.Mem[4] = 32'h0e94a000;   //dummy instruction
mips.Mem[5] = 32'h14431000;
mips.Mem[6] = 32'h2c630001;   
mips.Mem[7] = 32'h0e94a000;   // dummy
mips.Mem[8] = 32'h3460fffc;
mips.Mem[9] = 32'h2542fffe;
mips.Mem[10] = 32'hfc00000;


mips.Mem[200]= 32'h0000000a;

mips.HALTED=0;
mips.PC=0;
mips.TAKEN_BRANCH=0;

#10000 $display("Mem[200] = %2d", mips.Mem[200] );
      $display("Mem[198] = %2d", mips.Mem[198] );
 
end
 initial
 begin
 
	$monitor("R2 - %4d",mips.Reg[2]);
        #200000
	$finish;
 end

/*initial 
 begin
  $dumpfile("mips.vcd");
  $dumpvars(0,test_mips32);
  #300 $finish;
 end*/

endmodule

module mips32(clk1,clk2);

input clk1,clk2;

reg [31:0] PC,IF_ID_IR,IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
reg EX_MEM_cond;
reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;

reg [31:0] Reg [0:31];
reg [31:0] Mem [0:1023];

parameter ADD=6'b000000, SUB=6'b000001, AND=6'B000010, OR=6'B000011 , SLT=6'B000100, MUL=6'B000101, HLT=6'b111111, LW=6'b001000, SW=6'b001001, ADDI=6'b001010, SUBI=6'b001011, SLTI=6'b001100, BNEQZ=6'b001101, BEQZ=6'b001110;

parameter RR_ALU=3'b000, RM_ALU=3'b001, LOAD=3'b010, STORE=3'b011, BRANCH=3'b100, HALT=3'b101;

reg HALTED;

reg TAKEN_BRANCH;


always@(posedge clk1)

	if(HALTED==0)
	begin
	if(((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) || ((EX_MEM_IR[31:26] == BNEQZ ) && (EX_MEM_cond==0)))
	  begin
	    IF_ID_IR<= #2 Mem[EX_MEM_ALUOut];
	    TAKEN_BRANCH<= #2 1'b1;
	    IF_ID_NPC <= #2 EX_MEM_ALUOut +1;
	    PC <= #2 EX_MEM_ALUOut+1;
	  end
	else
	  begin
	    IF_ID_IR <= #2 Mem[PC];
	    IF_ID_NPC <= #2 PC+1;
	    PC <= #2 PC+1;
	  end
	end


always@(posedge clk2)
begin
	if(HALTED== 0)
	begin	
	  if(IF_ID_IR[25:21] == 5'b00000)
	    ID_EX_A <= 0;
	  else
	    ID_EX_A <= #2 Reg [IF_ID_IR[25:21]];

	  if(IF_ID_IR[20:16] == 5'b00000)
	    ID_EX_B<= 0;
	  else
	    ID_EX_B<= #2 Reg[IF_ID_IR[20:16]];

		

	ID_EX_NPC<= #2 IF_ID_NPC;
	ID_EX_IR <= #2 IF_ID_IR;
	ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};

	case(IF_ID_IR[31:26])

	    ADD,SUB,MUL,AND,OR,SLT: 		ID_EX_type <= #2 RR_ALU;
		ADDI,SUBI,SLTI: 		ID_EX_type <= #2 RM_ALU;
		LW:				ID_EX_type <= #2 LOAD;
		SW:				ID_EX_type <= #2 STORE;
		BNEQZ,BEQZ:   			ID_EX_type <= #2 BRANCH;
		HLT:				ID_EX_type <= #2 HALT;
		default:    			ID_EX_type <= #2 HALT;
	
	endcase
		
	  end
end

always@(posedge clk1)

	if(HALTED==0)
	begin
		EX_MEM_type <= #2 ID_EX_type;
		EX_MEM_IR   <= #2 ID_EX_IR;
		TAKEN_BRANCH<= #2 0;

	case(ID_EX_type)
		RR_ALU:	begin
					case(ID_EX_IR[31:26])
						ADD:EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
						SUB:EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
						AND:EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
						OR :EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
						SLT:EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
						MUL:EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
						default:EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
					endcase
				end

		RM_ALU: begin
					case(ID_EX_IR[31:26])
						ADDI: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
						SUBI: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
						SLTI: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
						default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
					endcase
				end

		LOAD,STORE:
			begin
				EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
				EX_MEM_B      <= #2 ID_EX_B;
			end

		BRANCH:begin
				EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
				EX_MEM_cond   <= #2 (ID_EX_A == 0);
				end
	endcase

end

always@(posedge clk2)
begin
	if(HALTED == 0)
	begin 
			MEM_WB_type <= EX_MEM_type;
			MEM_WB_IR   <= #2 EX_MEM_IR;

			case(EX_MEM_type)
				RR_ALU,RM_ALU:
 				MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
 				LOAD:		   MEM_WB_LMD    <= #2 Mem[EX_MEM_ALUOut];
				STORE:         if(TAKEN_BRANCH == 0)
						Mem[EX_MEM_ALUOut] <= #2 EX_MEM_B;
			endcase
	end
end

always@(posedge clk1)
begin
	if(TAKEN_BRANCH ==0)
	case(MEM_WB_type)
		RR_ALU: Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut;
		
		RM_ALU: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut;

		LOAD: Reg[MEM_WB_IR[20:16]]  <= #2 MEM_WB_LMD;

		HALT: HALTED <= #2 1'b1;
	endcase
	end

endmodule

