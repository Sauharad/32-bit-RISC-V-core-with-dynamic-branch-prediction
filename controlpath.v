`timescale 1ns / 1ps


module controlpath(input wire [6:0] opcode,
                   input wire [2:0] funct3,
                   input wire [6:0] funct7,
                   input wire load_stall,
                   input wire [1:0] br_stall,
                   input wire [1:0] br_stall_prev,
                   input wire branch_flag,
                   input wire prediction_false_flag,
                   output reg [4:0] ALUOp,
                   output reg ALUSrc,
                   output reg PCSrcCont,
                   output reg MemWrite,
                   output reg MemRead,
                   output reg MemToReg,
                   output reg RegWrite,
                   output reg IsStall);
                   
localparam OP_REG = 7'b0110011,OP_LW = 7'b0000011,OP_SW = 7'b0100011,OP_BR = 7'b1100011;


always @(*)
    begin
        if (!load_stall && !br_stall[0] && !br_stall_prev[1])
            begin
                IsStall = 1'b0;
                if (branch_flag || prediction_false_flag)
                    begin
                        RegWrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        MemToReg = 1'b0;
                        ALUSrc = 1'b0;
                        PCSrcCont = 1'b0;
                        ALUOp = 5'b11111;
                    end
                else
                    begin
                        case (opcode)
                            OP_REG: begin
                                        ALUSrc = 1'b0;
                                        PCSrcCont = 1'b0;
                                        MemWrite = 1'b0;
                                        MemRead = 1'b0;
                                        MemToReg = 1'b0;
                                        RegWrite = 1'b1;
                                        case (funct7)
                                            7'b0000000: case (funct3)
                                                            3'b000: ALUOp = 5'b00000;
                                                            3'b110: ALUOp = 5'b00011;
                                                            3'b111: ALUOp = 5'b00010;
                                                        endcase
                                            7'b0100000: case (funct3)
                                                            3'b000: ALUOp = 3'b00001;
                                                        endcase
                                        endcase
                                    end
                             OP_LW: begin
                                        ALUSrc = 1'b1;
                                        PCSrcCont = 1'b0;
                                        MemWrite = 1'b0;
                                        MemRead = 1'b1;
                                        MemToReg = 1'b1;
                                        RegWrite = 1'b1;
                                        case (funct3)
                                            3'b010: ALUOp = 5'b00000;
                                        endcase
                                    end
                             OP_SW: begin
                                        ALUSrc = 1'b1;
                                        PCSrcCont = 1'b0;
                                        MemWrite = 1'b1;
                                        MemRead = 1'b0;
                                        MemToReg = 1'b0;
                                        RegWrite = 1'b0;
                                        case(funct3)
                                            3'b010: ALUOp = 5'b00000;
                                        endcase
                                    end
                              OP_BR: begin
                                        ALUSrc = 1'b0;
                                        PCSrcCont = 1'b1;
                                        MemWrite = 1'b0;
                                        MemRead = 1'b0;
                                        MemToReg = 1'b0;
                                        RegWrite = 1'b0;
                                        case (funct3)
                                            3'b000: ALUOp = 5'b00100;
                                        endcase
                                    end
                           default: begin
                                        RegWrite = 1'b0;
                                        MemWrite = 1'b0;
                                        MemRead = 1'b0;
                                        MemToReg = 1'b0;
                                        ALUSrc = 1'b0;
                                        PCSrcCont = 1'b0;
                                        ALUOp = 5'b11111;
                                    end
                        endcase
                    end 
            end
        if (load_stall || br_stall || br_stall_prev[1])
            begin
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                MemToReg = 1'b0;
                ALUSrc = 1'b0;
                PCSrcCont = 1'b0;
                ALUOp = 5'b11111;
                IsStall = 1'b1;
            end
        
            
    end

                   
endmodule
