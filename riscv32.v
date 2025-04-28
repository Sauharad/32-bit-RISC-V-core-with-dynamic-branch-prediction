`timescale 1ns / 1ps


module riscv32(input wire clk,
               input wire start);
               
wire [6:0] opcode, funct7; wire [2:0] funct3;
wire [4:0] ALUOp;
wire ALUSrc,MemToReg,RegWrite,MemRead,MemWrite,PCSrcCont, load_stall, IsStall;
wire branch_flag, prediction_false_flag;
wire [1:0] br_stall, br_stall_prev;               
               
controlpath riscv_controlpath(.opcode(opcode),.funct7(funct7),.funct3(funct3),
                              .ALUOp(ALUOp),.ALUSrc(ALUSrc),
                              .MemWrite(MemWrite),.MemRead(MemRead),
                              .MemToReg(MemToReg),.RegWrite(RegWrite),
                              .PCSrcCont(PCSrcCont),.load_stall(load_stall),
                              .br_stall(br_stall),.br_stall_prev(br_stall_prev),
                              .IsStall(IsStall),.branch_flag(branch_flag),.prediction_false_flag(prediction_false_flag));               
               
datapath riscv_datapath(.start(start),.clk(clk),
                        .ALUSrc(ALUSrc),.ALUOp(ALUOp),
                        .PCSrcCont(PCSrcCont),.MemRead(MemRead),
                        .MemWrite(MemWrite),.MemToReg(MemToReg),
                        .RegWrite(RegWrite),
                        .opcode(opcode),.funct7(funct7),.funct3(funct3),.load_stall(load_stall),
                        .br_stall(br_stall),.br_stall_prev(br_stall_prev),
                        .IsStall(IsStall),.branch_flag(branch_flag),.prediction_false_flag(prediction_false_flag));
endmodule
