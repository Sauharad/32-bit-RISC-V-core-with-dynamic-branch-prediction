`timescale 1ns / 1ps

module hazard_detect(input wire [2:0] pcsrc_counter,
                     input wire [4:0] idex_rdloc,
                     input wire [4:0] ifid_rs1loc,
                     input wire [4:0] ifid_rs2loc,
                     input wire [6:0] opcode,
                     input wire idex_regwrite,
                     input wire idex_memread,
                     output wire load_stall,
                     output wire [1:0] br_stall);
                     
localparam OP_B = 7'b1100011;

assign br_stall[0] = (pcsrc_counter < 3'b010) ? 1'b0 : 
(((idex_rdloc == ifid_rs1loc) || (idex_rdloc == ifid_rs2loc)) && (idex_regwrite)) && (opcode == OP_B);
assign br_stall[1] = (pcsrc_counter < 3'b010) ? 1'b0 : 
(((idex_rdloc == ifid_rs1loc) || (idex_rdloc == ifid_rs2loc)) && (idex_memread)) && (opcode == OP_B);


assign load_stall = (pcsrc_counter < 3'b010) ? 1'b0 : ((idex_memread) && ((idex_rdloc == ifid_rs1loc) || (idex_rdloc == ifid_rs2loc)));


endmodule
