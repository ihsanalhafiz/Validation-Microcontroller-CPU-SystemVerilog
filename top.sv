//`include "cpu_if.sv"
import instr_package::*;
module top;
   bit clk;
   always #5 clk = ~clk;

   logic Din[15:0];
   logic Dout[15:0];
   logic [15:0]Address;
   logic RW;
   logic reset;

   bit [7:0] ST_Count=0;
   bit [7:0] LD_Count=0;
   
	bit signed [15:0] Q;
	bit [15:0] pc;
	logic [15:0]prevAddress;
/*
   cpu_if cpuif(clk);
   memory mem (cpuif);

  memory mem (.clk(cpuif.clk),
	.reset(cpuif.reset),
	.Din(cpuif.cb.Din),
	.Dout(cpuif.cb.Dout),
	.Address(cpuif.cb.Address),
	.RW(cpuif.cb.RW));

   initial begin
      cpuif.reset = 1'b0;
      @(posedge clk);
      cpuif.reset=1'b1;
      @(posedge clk);
      cpuif.reset=1'b0;
   end;      
*/
   cpu #(.N(16),.M(3)) dut 
	(.clk(clk),
           .reset(reset),
           .Din(Din),
           .Dout(Dout),
           .Address(Address),
           .RW(RW));

  //test test(cpu_bus);   

  memory mem (.clk(clk),
	.reset(reset),
	.Din(Dout),
	.Dout(Din),
	.Address(Address),
	.RW(RW));

   initial begin
      reset = 1'b0;
      @(posedge clk);
      reset=1'b1;
      @(posedge clk);
      reset=1'b0;
   end;      

   // Instruction properties
/*
   assert property (
      @(posedge clk) ((dut.Instr[15:12]==ST) && (dut.uPC==1)) |-> ##2 !(RW)
   );
*/
always @(posedge clk)
begin
	
	case (dut.instruction_reg[15:12])
	
		ADD: begin 
			if(dut.uPC==1) begin
				Q = dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]] + dut.datapath_port.REG.reg_file_q[dut.instruction_reg[5:3]];
			end
			if(dut.uPC==2) begin
				assert (Q == dut.datapath_port.REG.reg_file_q[dut.instruction_reg[11:9]]) $display("%0T: ADD works ok",$time);
				else $error("%0T: ADD does not work -- error --",$time);
			end

		end
		
		iSUB: begin 
			if(dut.uPC==1) begin
				Q = dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]] - dut.datapath_port.REG.reg_file_q[dut.instruction_reg[5:3]];
			end
			if(dut.uPC==2) begin
				assert (Q == dut.datapath_port.REG.reg_file_q[dut.instruction_reg[11:9]]) $display("%0T: SUB works ok",$time);
				else $error("%0T: SUB does not work -- error --",$time);
			end
		end
		iAND: begin 
			if(dut.uPC==1) begin
				Q = dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]] & dut.datapath_port.REG.reg_file_q[dut.instruction_reg[5:3]];
			end
			if(dut.uPC==2) begin
				assert (Q == dut.datapath_port.REG.reg_file_q[dut.instruction_reg[11:9]]) $display ("%0T: AND works ok",$time);
				else $error("%0T: AND does not work -- error --",$time);
			end
		end
		iOR: begin 
			if(dut.uPC==1) begin
				Q = dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]] | dut.datapath_port.REG.reg_file_q[dut.instruction_reg[5:3]];
			end
			if(dut.uPC==2) begin
				assert (Q == dut.datapath_port.REG.reg_file_q[dut.instruction_reg[11:9]]) $display ("%0T: OR works ok",$time);
				else $error("%0T: OR does not work -- error --",$time);
			end
		end
		
		iXOR: begin 
			if(dut.uPC==1) begin
				Q = dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]] ^ dut.datapath_port.REG.reg_file_q[dut.instruction_reg[5:3]];
			end
			if(dut.uPC==2) begin
				assert (Q == dut.datapath_port.REG.reg_file_q[dut.instruction_reg[11:9]]) $display ("%0T: XOR works ok",$time);
				else $error("%0T: XOR does not work -- error --",$time);
			end
			
		end
		iNOT: begin 
			if(dut.uPC==1) begin
				Q = ~(dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]]);
			end
			if(dut.uPC==2) begin
				assert (Q == dut.datapath_port.REG.reg_file_q[dut.instruction_reg[11:9]]) $display ("%0T: NOT works ok",$time);
				else $error("%0T: NOT does not work -- error --",$time);
			end
		end
		MOV: begin 
			if(dut.uPC==1) begin
				Q = dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]];
			end
			if(dut.uPC==2) begin
				assert (Q == dut.datapath_port.REG.reg_file_q[dut.instruction_reg[11:9]]) $display ("%0T: MOV works ok",$time);
				else $error("%0T: MOV does not work -- error --",$time);
			end
		end
		/*
		NOP: begin 
			if(dut.uPC==2) begin
				prevAddress = Address;
			end
			if(dut.uPC==3) begin
				prevAddress++;
				assert ((prevAddress == Address)) //$display("%0T: PC for MOV works ok",$time);
				else $error("%0T: PC for NOP does not work -- error --",$time);
			end
		end
		*/
		LD: begin
		    assert (dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]]<4096) 
			else $display("%0t: LD instruction out of range,address=%x",$time,dut.datapath_port.REG.reg_file_q[dut.instruction_reg[8:6]]);

			if (dut.uPC==1) assert (RW) begin
				$display("%0T: LD works ok",$time);
				LD_Count++;
	        end
			else $display("%0t: LD instruction has an error",$time);
			
			
			end
		ST: begin 
			if (dut.uPC==3) assert (!(RW)) begin
				$display("%0T: ST works ok",$time);
				ST_Count++;
	        end
			else $display("%0t: ST instruction has an error",$time);
			end
		LDI: begin 
			if(dut.uPC==1) begin
				Q = $signed(dut.instruction_reg[8:0]);
			end
			if(dut.uPC==2) begin
				assert (Q == dut.datapath_port.REG.reg_file_q[dut.instruction_reg[11:9]]) $display ("%0T: LDI works ok",$time);
				else $error("%0T: LDI does not work -- error --",$time);
			end

		end
		
		BRZ: begin 
			if (dut.ZNO_flag_buf) begin
				if (dut.uPC==1) begin
				Q = $signed(dut.instruction_reg[11:0]);
				pc = (dut.datapath_port.REG.reg_file_q[7]);
				end
				if (dut.uPC==3) begin 
					assert (dut.datapath_port.REG.reg_file_q[7]==Q+$signed(pc))
					$display("%0T: BRZ works ok",$time);
					else $error("%0t: BRZ instruction(flag=1) has an error",$time);
				end
			end else begin
				if (dut.uPC==1) begin
					Q = $signed(dut.instruction_reg[11:0]);
					pc = (dut.datapath_port.REG.reg_file_q[7]);
				end
				if (dut.uPC==3) begin 
					assert (dut.datapath_port.REG.reg_file_q[7]==pc+1)
					$display("%0T: BRZ works ok",$time);
					else $error("%0t: BRZ instruction(flag=0) has an error",$time);
				end
			end
		end
		
		BRN: begin 
			if (dut.ZNO_flag_buf) begin
				if (dut.uPC==1) begin
				Q = $signed(dut.instruction_reg[11:0]);
				pc = (dut.datapath_port.REG.reg_file_q[7]);
				end
				if (dut.uPC==3) begin 
					assert (dut.datapath_port.REG.reg_file_q[7]==Q+$signed(pc))
					$display("%0T: BRN works ok",$time);
					else $error("%0t: BRN instruction(flag=1) has an error",$time);
				end
			end else begin
				if (dut.uPC==1) begin
					Q = $signed(dut.instruction_reg[11:0]);
					pc = (dut.datapath_port.REG.reg_file_q[7]);
				end
				if (dut.uPC==3) begin 
					assert (dut.datapath_port.REG.reg_file_q[7]==pc+1)
					$display("%0T: BRN works ok",$time);
					else $error("%0t: BRN instruction(flag=0) has an error",$time);
				end
			end
		end
		
		BRO: begin 
			if (dut.ZNO_flag_buf) begin
				if (dut.uPC==1) begin
				Q = $signed(dut.instruction_reg[11:0]);
				pc = (dut.datapath_port.REG.reg_file_q[7]);
				end
				if (dut.uPC==3) begin 
					assert (dut.datapath_port.REG.reg_file_q[7]==Q+$signed(pc))
					$display("%0T: BRO works ok",$time);
					else $error("%0t: BRO instruction(flag=1) has an error",$time);
				end
			end else begin
				if (dut.uPC==1) begin
					Q = $signed(dut.instruction_reg[11:0]);
					pc = (dut.datapath_port.REG.reg_file_q[7]);
				end
				if (dut.uPC==3) begin 
					assert (dut.datapath_port.REG.reg_file_q[7]==pc+1)
					$display("%0T: BRO works ok",$time);
					else $error("%0t: BRO instruction(flag=0) has an error",$time);
				end
			end
		end
		
		BRA: begin 
			if (dut.uPC==1) begin
				Q = $signed(dut.instruction_reg[11:0]);
				pc = (dut.datapath_port.REG.reg_file_q[7]);
			end
			if (dut.uPC==3) begin 
				$display("%x==%x+%x",dut.datapath_port.REG.reg_file_q[7],Q,$signed(pc));
				assert (dut.datapath_port.REG.reg_file_q[7]==Q+$signed(pc))
				$display("%0T: BRA works ok",$time);
				else begin
				$display("%0t: BRA instruction has an error",$time);
				$display("%x==%x+%x",dut.datapath_port.REG.reg_file_q[7],Q,$signed(pc));
				end
			end
		end
		
    default: $display("%0t: Not Used instruction",$time);
	
   endcase
end 

endmodule

