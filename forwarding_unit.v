`timescale 1ns / 1ps


module forwarding_unit(input wire [4:0] comp_loc_rs1,
                       input wire [4:0] comp_loc_rs2,
                       input wire [4:0] comp_loc_exmem,
                       input wire [4:0] comp_loc_memwb,
                       input wire cont_idex_alusrc,
                       input wire cont_exmem_rw,
                       input wire cont_memwb_rw,
                       input wire cont_memwb_mtr,
                       input wire [31:0] memwb_readdata,
                       input wire [31:0] memwb_aluout,
                       input wire [31:0] exmem_aluout,
                       input wire [31:0] forw_rs1,
                       input wire [31:0] forw_rs2,
                       input wire [31:0] forw_imm,
                       input wire [2:0] pcsrc_counter,
                       output wire [31:0] out_A,
                       output wire [31:0] out_B
                       );
                       
wire [1:0] forwardA,forwardB;
assign forwardA[0] = (pcsrc_counter < 3'b011) ? 1'b0 : (comp_loc_exmem == comp_loc_rs1) && (cont_exmem_rw);
assign forwardB[0] = (pcsrc_counter < 3'b011) ? 1'b0 : (comp_loc_exmem == comp_loc_rs2) && (cont_exmem_rw);
assign forwardA[1] = (pcsrc_counter < 3'b100) ? 1'b0 : (comp_loc_memwb == comp_loc_rs1) && (cont_memwb_rw) && (comp_loc_exmem != comp_loc_rs1);
assign forwardB[1] = (pcsrc_counter < 3'b100) ? 1'b0 : (comp_loc_memwb == comp_loc_rs2) && (cont_memwb_rw) && (comp_loc_exmem != comp_loc_rs2);
assign out_A = forwardA[1] ? (cont_memwb_mtr ? memwb_readdata : memwb_aluout) : forwardA[0] ? exmem_aluout : forw_rs1;
assign out_B = forwardB[1] ? (cont_memwb_mtr ? memwb_readdata : memwb_aluout) : forwardB[0] ? exmem_aluout : cont_idex_alusrc ? forw_imm : forw_rs2;


endmodule
