`timescale 1ns / 1ps

module Imm_Gen(input wire [31:0] IF_ID_IR,
               output reg [31:0] Imm);
      
localparam OP_REG = 7'b0110011,OP_LW = 7'b0000011,OP_SW = 7'b0100011,OP_B = 7'b1100011;      
               
always @(*)
begin
    case(IF_ID_IR[6:0])
        OP_REG: Imm = 32'h00000000;
         OP_LW: Imm = {20'h00000,IF_ID_IR[31:20]};
         OP_SW: Imm = {20'h00000,{IF_ID_IR[31:25],IF_ID_IR[11:7]}};
          OP_B: Imm = {20'h00000,{IF_ID_IR[31],IF_ID_IR[7],IF_ID_IR[30:25],IF_ID_IR[11:8]}};
    endcase
end


endmodule
