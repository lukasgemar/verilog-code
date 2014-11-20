`timescale 1ns/1ps
`default_nettype none
module alu_decoder(
	input wire [5:0] Funct,
	input wire [1:0] ALUOp,
	output reg [3:0] ALUControl
);

	// Function Enumeration 
	`define FUNCT_ADD 6'b100000
	`define FUNCT_SUB 6'b100010
	`define FUNCT_AND 6'b100100
	`define FUNCT_OR 6'b100101
	`define FUNCT_SLT 6'b101010

	// Opcode enumeration 
	`define ALU_ADD 4'b0101
	`define ALU_SUBTRACT 4'b0110
	`define ALU_AND 4'b0000
	`define ALU_OR 4'b0001
	`define ALU_SLT 4'b0111

	always @(*) begin
		if (ALUOp == 2'b00) begin
			ALUControl <= `ALU_ADD;
		end
		else if (ALUOp[0]) begin
			ALUControl <= `ALU_SUBTRACT;
		end
		else begin
			case(Funct)
				`FUNCT_ADD: ALUControl <= `ALU_ADD;
				`FUNCT_SUB: ALUControl <= `ALU_SUBTRACT;
				`FUNCT_AND: ALUControl <= `ALU_AND;
				`FUNCT_OR: ALUControl <= `ALU_OR;
				`FUNCT_SLT: ALUControl <= `ALU_SLT;
			endcase
		end
	end
endmodule
`default_nettype wire
