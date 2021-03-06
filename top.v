`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:01:43 11/06/2015 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
    input clkin,
    input reset
    );
	 
	 reg[31:0] pc, add4;
	 wire choose4;
	 wire[31:0] expand2, mux2, mux3, mux4, mux5, address, jmpaddr, inst;
	 wire[4:0] mux1;
	 wire reg_dst, jmp, branch, memread, memwrite, memtoreg;
	 wire[1:0] aluop;
	 wire alu_src, regwrite;
	 wire zero;
	 wire[31:0] aluRes;
	 wire[3:0] aluCtr;
	 wire[31:0] memreaddata;
	 wire[31:0] RsData, RtData;
	 wire[31:0] expand;
	 
	 always @(negedge clkin)
	 begin
		if(!reset)
		begin
			pc = mux5;
			add4 = pc + 4;
		end
		else
		begin
			pc = 32'b0;
			add4 = 32'h4;
		end
	end
	
	ctr mainctr(
		.opCode(inst[31:26]),
		.regDst(reg_dst),
		.aluSrc(alu_src),
		.memToReg(memtoreg),
		.regWrite(regwrite),
		.memRead(memread),
		.memWrite(memwrite),
		.branch(branch),
		.aluop(aluop),
		.jmp(jmp));
	alu alu(.input1(RsData),
		.input2(mux2),
		.aluCtr(aluCtr),
		.zero(zero),
		.aluRes(aluRes));
	aluctr aluctr1(
		.ALUOp(aluop),
		.funct(inst[5:0]),
		.ALUCtr(aluCtr));
	dram dmem(
		.a(aluRes[7:2]),
		.d(RtData),
		.clk(!clkin),
		.we(memwrite),
		.spo(memreaddata)
	);
	irom imem(
		.a(pc[8:2]),
		.clk(clkin),
		.spo(inst)
	);
	regFile regfile(
		.RsAddr(inst[25:21]), 
		.RtAddr(inst[20:16]),
		.clk(!clkin),
		.reset(reset),
		.regWriteAddr(mux1),
		.regWriteData(mux3),
		.regWriteEn(regwrite),
		.RsData(RsData),
		.RtData(RtData)
	);
	signext signext(.inst(inst[15:0]), .data(expand));
	
	assign mux1 = reg_dst ? inst[15:11] : inst[20:16];
	assign mux2 = alu_src ? expand : RtData;
	assign mux3 = memtoreg ? memreaddata : aluRes;
	assign mux4 = choose4 ? address : add4;
	assign mux5 = jmp ? jmpaddr : mux4;
	assign choose4 = branch & zero;
	assign expand2 = expand << 2;
	assign jmpaddr = {add4[31:28], inst[25:0], 2'b00};
	assign address = pc + expand2;
endmodule
