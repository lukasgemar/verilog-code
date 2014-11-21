`timescale 1ns/1ps
`default_nettype none

module control_unit(
	input wire cclk, rstb, // clock and reset pins
	input wire [31:0] Instr,

	// Multiplexer selects
	output reg MemtoReg, IorD,
	output reg [1:0] RegDst, PCSrc, ALUSrcA,
	output reg [1:0] ALUSrcB, 

	// TODO: extend Branch 2 bits (MSB - bne logic, LSB - beq logic)
	output reg [1:0] Branch,
	output reg IRWrite, MemWrite, PCWrite, RegWrite,
	// TODO: add ExtOp (depending on the type of itype instructions, we need 
	// either sign extend or zero extend). ORI, XORI, ANDI are zero extended,
	// ADDI, SLTI, BEQ, BNE, LW, SW
	output reg ExtOp,

	// TODO: ALU has 16bit mux, so 4bits for control, not 3
	output wire [3:0] ALUControl
);

	// Internal Vars
	// ALU communication
	reg [1:0] ALUOp;
	// Opcodes and Funct codes
	wire [5:0] Opcode, Funct;
	assign Opcode = Instr[31:26];
	assign Funct = Instr[5:0];

	reg [5:0] ALUFunctCode;

	// Internal State Defines
	`define PRE_FETCH 4'd12
	`define FETCH 4'd0
	`define DECODE 4'd1
	`define MEM_ADR 4'd2
	`define MEM_READ 4'd3
	`define MEM_WRITEBACK 4'd4
	`define MEM_WRITE 4'd5
	`define EXECUTE 4'd6
	`define ALU_WRITEBACK 4'd7
	`define BRANCH 4'd8
	`define ITYPE_EXECUTE 4'd9
	`define ITYPE_WRITEBACK 4'd10
	`define JUMP 4'd11
	// TODO: we also need JAL and probably 
	
	always @(*) begin
		case(state)
			`PRE_FETCH, `FETCH, `EXECUTE, `ALU_WRITEBACK: ALUFunctCode <= Funct;
			`ITYPE_EXECUTE, `ITYPE_WRITEBACK: ALUFunctCode <= Opcode;
		endcase
	end

	alu_decoder ALU_DECODER (
		.Funct(ALUFunctCode), 
		.ALUOp(ALUOp), 
		.ALUControl(ALUControl)
	);

	// Instruction Opcode Defines: current operations supported by controller
	// R-type opcodes
	`define R_TYPE 6'd0
	// Memory opcodes
	`define SW 6'd43
	`define LW 6'd35
	// Branch opcodes
	`define BEQ 6'd4
	// Itype opcodes
	`define ADDI 6'd8
	`define SLTI 6'hA
	`define ANDI 6'hC
	`define ORI 6'hD
	`define XORI 6'hE
	`define LUI 6'hF
	// J-type opcodes
	`define J_TYPE 6'd2

	// Internal Vars
	reg [3:0] state;

	always@(*) begin
		case(state)
			`PRE_FETCH: begin
				// Multiplexer selects
				MemtoReg <= 1'b0; // x
				RegDst <= 2'd0; // x
				IorD <= 1'b0;
				PCSrc <= 2'b00; 
				ALUSrcA <= 2'd0;
				ALUSrcB <= 2'b01;
				// Register Enables
				IRWrite <= 1'b1;
				MemWrite <= 1'b0; // x
				PCWrite <= 1'b1;
				Branch <= 1'b0; // x
				RegWrite <= 1'b0; // x
				// ALU Op
				ALUOp <= 2'b00;
				// Sign Extension Code
				ExtOp <= 1'b0;
			end
			`FETCH: begin
				// Multiplexer selects
				MemtoReg <= 1'b0; // x
				RegDst <= 2'd0; // x
				IorD <= 1'b0;
				PCSrc <= 2'b00; 
				ALUSrcA <= 2'd0;
				ALUSrcB <= 2'b01;
				// Register Enables
				IRWrite <= 1'b1;
				MemWrite <= 1'b0; // x
				PCWrite <= 1'b0;
				Branch <= 1'b0; // x
				RegWrite <= 1'b0; // x
				// ALU Op
				ALUOp <= 2'b00;
			end
			`DECODE: begin
				// Multiplexer selects
				ALUSrcA <= 2'd0;
				ALUSrcB <= 2'b11;
				// Register Enables
				IRWrite <= 1'b0;
				PCWrite <= 1'b0;
				// ALU Op
				ALUOp <= 2'b00;
			end
			`MEM_ADR: begin
				// Multiplexer selects
				ALUSrcA <= 2'd1;
				ALUSrcB <= 2'b10;
				// Register Enables
				// ALU Op
				ALUOp <= 2'b00;
			end
			`MEM_READ: begin
				// Multiplexer selects
				IorD <= 1'b1;
				// Register Enables
				// ALU Op
			end
			`MEM_WRITEBACK: begin
				// Multiplexer selects
				MemtoReg <= 1'b1;
				RegDst <= 2'd0;
				// Register Enables
				RegWrite <= 1'b1; // x
				// ALU Op
			end
			`MEM_WRITE: begin
				// Multiplexer selects
				IorD <= 1'b1;
				// Register Enables
				MemWrite <= 1'b1; // x
				// ALU Op
			end
			`EXECUTE: begin
				// Multiplexer selects
				ALUSrcA <= 2'd1;
				ALUSrcB <= 2'b00;
				// Register Enables
				// ALU Op
				ALUOp <= 2'b10;
			end
			`ALU_WRITEBACK: begin
				// Multiplexer selects
				MemtoReg <= 1'b0;
				RegDst <= 2'd1;
				// Register Enables
				RegWrite <= 1'b1;
				// ALU Op
			end
			`BRANCH: begin
				// Multiplexer selects
				PCSrc <= 2'b01;
				ALUSrcA <= 2'd1;
				ALUSrcB <= 2'b00;
				// Register Enables
				Branch <= 1'b1;
				// ALU Op
				ALUOp <= 2'b01;
			end
			`ITYPE_EXECUTE: begin
				// Multiplexer selects
				ALUSrcA <= 2'd1;
				ALUSrcB <= 2'b10;
				// Register Enables
				// ALU Op
				ALUOp <= 2'b11;
				// Sign Extension Code
				ExtOp <= 1'b1;
			end
			`ITYPE_WRITEBACK: begin
				// Multiplexer selects
				MemtoReg <= 1'b0;
				RegDst <= 2'd0;
				// Register Enables
				RegWrite <= 1'b1;
				// ALU Op
			end
			`JUMP: begin
				// Multiplexer selects
				PCSrc <= 2'b10;
				// Register Enables
				PCWrite <= 1'b1;
				// ALU Op
			end
		endcase
	end

	always @(posedge cclk) begin
		if(~rstb) begin
			// State reset, same as fetch
			state <= `PRE_FETCH;
			// Multiplexer selects
			MemtoReg <= 1'b0; // x
			RegDst <= 2'b0; // x
			IorD <= 1'b0;
			PCSrc <= 2'b00;
			ALUSrcA <= 2'd0;
			ALUSrcB <= 2'b01;
			// Register Enables
			IRWrite <= 1'b1;
			MemWrite <= 1'b0; // x
			PCWrite <= 1'b1;
			Branch <= 1'b0; // x
			RegWrite <= 1'b0; // x
			// ALU Op
			ALUOp <= 2'b00;
		end 
		else begin
			case(state)
				`PRE_FETCH: begin
					state <= `FETCH;
				end
				`FETCH: begin
					// State update
					state <= `DECODE;
				end
				`DECODE: begin
					case(Opcode)
						`LW, `SW: state <= `MEM_ADR;
						`R_TYPE: state <= `EXECUTE;
						`BEQ: state <= `BRANCH;
						`ADDI, `ANDI, `ORI, `XORI, `SLTI, `LUI: begin
							state <= `ITYPE_EXECUTE;
						end
						`J_TYPE: state <= `JUMP;
					endcase
				end
				`MEM_ADR: begin
					case(Opcode)
						`LW: state <= `MEM_READ;
						`SW: state <= `MEM_WRITE;
					endcase
				end
				`MEM_READ: begin
					state <= `MEM_WRITEBACK;
				end
				`MEM_WRITEBACK: begin
					state <= `PRE_FETCH;
				end
				`MEM_WRITE: begin
					state <= `PRE_FETCH;
				end
				`EXECUTE: begin
					state <= `ALU_WRITEBACK;
				end
				`ALU_WRITEBACK: begin
					state <= `PRE_FETCH;
				end
				`BRANCH: begin
					state <= `PRE_FETCH;
				end
				`ITYPE_EXECUTE: begin
					state <= `ITYPE_WRITEBACK;
				end
				`ITYPE_WRITEBACK: begin
					state <= `PRE_FETCH;
				end
				`JUMP: begin
					state <= `PRE_FETCH;
				end
			endcase
		end
	end
endmodule
`default_nettype wire
