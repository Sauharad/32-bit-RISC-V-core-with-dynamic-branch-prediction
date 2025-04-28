`timescale 1ns / 1ps

module ALU(input wire [4:0] ALUOp,
           input wire [31:0] A,
           input wire [31:0] B,
           output reg [31:0] ALUOut);


always @(*)
    begin
        case (ALUOp)
            5'b00000: ALUOut = A+B;
            5'b00001: ALUOut = A-B;
            5'b00010: ALUOut = A&B;
            5'b00011: ALUOut = A|B;
            5'b00100: ALUOut = {32{(A==B)}};
        endcase
    end
    
    
endmodule
