`timescale 1ns / 1ps

module datapath(input wire start,
                input wire clk,
                input wire ALUSrc,
                input wire [4:0] ALUOp,
                input wire PCSrcCont,
                input wire MemWrite,
                input wire MemRead,
                input wire MemToReg,
                input wire RegWrite,
                input wire IsStall,
                output wire [6:0] opcode,
                output wire [2:0] funct3,
                output wire [6:0] funct7,
                output wire load_stall,
                output wire [1:0] br_stall,
                output reg branch_flag,
                output reg prediction_false_flag,
                output reg [1:0] br_stall_prev);

reg [31:0] PC, OG_PC;
reg [7:0] Inst_Mem [0:16383];
reg [31:0] Data_Mem [0:16383];
reg [31:0] reg_file [0:31];

localparam OP_REG = 7'b0110011,OP_LW = 7'b0000011,OP_SW = 7'b0100011,OP_BR = 7'b1100011;


reg [2:0] pcsrc_counter = 3'b000;


wire branch_pred_bht,branch_pred_btb,branch_prediction;
wire [31:0] PPC;
reg prev_branch_prediction;
reg bht_update, btb_update, bht_update_direction;
reg [31:0] btb_update_address, bpu_update_PC;


reg [31:0] IF_ID_IR, IF_ID_PC;
reg IF_ID_branch_prediction;
wire [31:0] ID_BR_PC;
wire [4:0] IF_ID_rs1_loc, IF_ID_rs2_loc,IF_ID_rd_loc;
wire [31:0] IF_ID_rs1, IF_ID_rs2;
wire ID_PCSrc;


reg [31:0] ID_EX_IR, ID_EX_PC, ID_EX_rs1, ID_EX_rs2, ID_EX_Imm;
reg ID_EX_branch_prediction;
reg [4:0] ID_EX_rs1_loc,ID_EX_rs2_loc,ID_EX_rd_loc;
reg ID_EX_RegWrite,ID_EX_ALUSrc,ID_EX_MemWrite,ID_EX_MemRead,ID_EX_PCSrcCont,ID_EX_MemToReg;
reg [4:0] ID_EX_ALUOp;

wire [31:0] imm_gen_out;
wire [31:0] ALU_A,ALU_B;
wire [31:0] BR_A,BR_B,BR_verify_A,BR_verify_B;
wire BR_Test,BR_verify_test;


reg [31:0] EX_MEM_IR,EX_MEM_PC,EX_MEM_ALUOut,EX_MEM_rs2; wire [31:0] ex_mem_aluout;
reg [4:0] EX_MEM_rs1_loc,EX_MEM_rs2_loc,EX_MEM_rd_loc;
reg EX_MEM_MemWrite,EX_MEM_MemRead,EX_MEM_RegWrite,EX_MEM_MemToReg,EX_MEM_PCSrcCont; 


reg [31:0] MEM_WB_IR,MEM_WB_ReadData,MEM_WB_ALUOut;
reg [4:0] MEM_WB_rs1_loc,MEM_WB_rs2_loc,MEM_WB_rd_loc;
reg MEM_WB_RegWrite,MEM_WB_MemToReg;


Imm_Gen riscv_immgen(IF_ID_IR,imm_gen_out);


forwarding_unit ALU_Forward(.comp_loc_rs1(ID_EX_rs1_loc),.comp_loc_rs2(ID_EX_rs2_loc),.comp_loc_exmem(EX_MEM_rd_loc),.comp_loc_memwb(MEM_WB_rd_loc),
.cont_idex_alusrc(ID_EX_ALUSrc),.cont_exmem_rw(EX_MEM_RegWrite),.cont_memwb_rw(MEM_WB_RegWrite),.cont_memwb_mtr(MEM_WB_MemToReg),
.memwb_readdata(MEM_WB_ReadData),.memwb_aluout(MEM_WB_ALUOut),.exmem_aluout(EX_MEM_ALUOut),
.forw_rs1(ID_EX_rs1),.forw_rs2(ID_EX_rs2),.forw_imm(ID_EX_Imm),.pcsrc_counter(pcsrc_counter),
.out_A(ALU_A),.out_B(ALU_B));


forwarding_unit BR_Forward(.comp_loc_rs1(IF_ID_rs1_loc),.comp_loc_rs2(IF_ID_rs2_loc),.comp_loc_exmem(EX_MEM_rd_loc),.comp_loc_memwb(MEM_WB_rd_loc),
.cont_idex_alusrc(1'b0),.cont_exmem_rw(EX_MEM_RegWrite),.cont_memwb_rw(MEM_WB_RegWrite),.cont_memwb_mtr(MEM_WB_MemToReg),
.memwb_readdata(MEM_WB_ReadData),.memwb_aluout(MEM_WB_ALUOut),.exmem_aluout(EX_MEM_ALUOut),
.forw_rs1(IF_ID_rs1),.forw_rs2(IF_ID_rs2),.forw_imm(32'b0),.pcsrc_counter(pcsrc_counter),
.out_A(BR_A),.out_B(BR_B));


BR_Test_Unit riscv_BR_test(BR_A,BR_B,BR_Test);


ALU riscvALU(.ALUOp(ID_EX_ALUOp),.A(ALU_A),.B(ALU_B),.ALUOut(ex_mem_aluout));


hazard_detect riscv_hazard_detect(.pcsrc_counter(pcsrc_counter),.idex_rdloc(ID_EX_rd_loc),
.ifid_rs1loc(IF_ID_rs1_loc),.ifid_rs2loc(IF_ID_rs2_loc),.opcode(opcode),
.idex_regwrite(ID_EX_RegWrite),.idex_memread(ID_EX_MemRead),
.load_stall(load_stall),.br_stall(br_stall));


BHT riscv_bht(.clk(clk),.PC_lower_predict(PC[4:0]),.PC_lower_update(bpu_update_PC[4:0]),
.update(bht_update),.start(start),.take_branch(branch_pred_bht),
.update_direction(bht_update_direction));


BTB riscv_btb(.clk(clk),.start(start),.PC_predict(PC),.PC_update(bpu_update_PC),
.update(btb_update),.target_address_update(btb_update_address),.target_address_predict(PPC),.hit(branch_pred_btb));


assign branch_prediction = branch_pred_bht && branch_pred_btb;

assign IF_ID_rs1_loc =  IF_ID_IR[19:15];
assign IF_ID_rs2_loc = IF_ID_IR[24:20];
assign IF_ID_rd_loc = IF_ID_IR[11:7];
assign IF_ID_rs1 = reg_file[IF_ID_rs1_loc];
assign IF_ID_rs2 = reg_file[IF_ID_rs2_loc];

assign IF_ID_BR_verify_rd_loc = IF_ID_IR[11:7];


assign opcode = IF_ID_IR[6:0];
assign funct3 = IF_ID_IR[14:12];
assign funct7 = IF_ID_IR[31:25];


assign ID_PCSrc = (pcsrc_counter > 3'b010) ? (PCSrcCont && BR_Test) : 1'b0;
assign ID_BR_PC = IF_ID_PC + (4*imm_gen_out);

always @(posedge start)
    begin
        PC <= 32'h00000000;
        prev_branch_prediction <= 1'b0;
    end
    

always @(posedge clk)
    begin
        if (start && pcsrc_counter < 3'b100)
            begin
                pcsrc_counter <= pcsrc_counter + 1;
            end
        
        br_stall_prev <= br_stall;
        
        prev_branch_prediction <= branch_prediction;
        
        if (IsStall)
            PC <= PC; 
        if (!IsStall)
            begin
                if (!ID_PCSrc)
                    begin
                        if (IF_ID_branch_prediction)
                            begin
                                PC <= OG_PC + 4;
                                prediction_false_flag <= 1'b1;
                            end
                        if (!IF_ID_branch_prediction)
                            begin
                                if (branch_prediction && !prev_branch_prediction)
                                    begin
                                        PC <= PPC;
                                        OG_PC <= PC;
                                    end
                                else
                                    begin
                                        PC <= PC + 4;
                                    end
                            end
                    end
                if (ID_PCSrc)
                    begin
                        if (IF_ID_branch_prediction)
                            begin
                                PC <= PC + 4;
                            end
                        if (!IF_ID_branch_prediction)
                            begin
                                PC <= ID_BR_PC;
                                branch_flag <= 1'b1;
                            end
                    end
            end
        
        
        IF_ID_IR <= IsStall ? IF_ID_IR : {Inst_Mem[PC],Inst_Mem[PC+1],Inst_Mem[PC+2],Inst_Mem[PC+3]};
        IF_ID_PC <= IsStall ? IF_ID_PC : PC;
        IF_ID_branch_prediction <= IsStall ? IF_ID_branch_prediction : branch_prediction;
        
        if (!IsStall)
            begin
                if (IF_ID_branch_prediction && ID_PCSrc)
                    begin
                        bht_update <= 1'b1;
                        bht_update_direction <= 1'b1;
                        btb_update <= 1'b1;
                        bpu_update_PC <= IF_ID_PC;
                        btb_update_address <= PC;
                    end
                if (IF_ID_branch_prediction && !ID_PCSrc)
                    begin
                        bht_update <= 1'b1;
                        bht_update_direction <= 1'b0;
                        btb_update <= 1'b0;
                        bpu_update_PC <= IF_ID_PC;
                        btb_update_address <= PC;
                    end
                if (!IF_ID_branch_prediction && ID_PCSrc)
                    begin
                        bht_update <= 1'b1;
                        bht_update_direction <= 1'b1;
                        btb_update <= 1'b1;
                        bpu_update_PC <= IF_ID_PC;
                        btb_update_address <= ID_BR_PC;
                    end
            end
        
        ID_EX_IR <=  IF_ID_IR;
        ID_EX_PC <= IF_ID_PC;
        ID_EX_rs1 <= reg_file[IF_ID_rs1_loc];
        ID_EX_rs2 <= reg_file[IF_ID_rs2_loc];
        ID_EX_rs1_loc <= IF_ID_rs1_loc;
        ID_EX_rs2_loc <= IF_ID_rs2_loc;
        ID_EX_rd_loc <= IF_ID_rd_loc;
        ID_EX_Imm <= imm_gen_out;
        ID_EX_ALUSrc <= ALUSrc;
        ID_EX_ALUOp <= ALUOp;
        ID_EX_PCSrcCont <= PCSrcCont;
        ID_EX_MemWrite <= MemWrite;
        ID_EX_MemRead <= MemRead;
        ID_EX_RegWrite <= RegWrite;
        ID_EX_MemToReg <= MemToReg;
        
        
        EX_MEM_IR <= ID_EX_IR;
        EX_MEM_PC <= ID_EX_PC;
        EX_MEM_rs2 <= ID_EX_rs2;
        EX_MEM_rs1_loc <= ID_EX_rs1_loc;
        EX_MEM_rs2_loc <= ID_EX_rs2_loc;
        EX_MEM_rd_loc <= ID_EX_rd_loc;
        EX_MEM_ALUOut <= ex_mem_aluout;
        EX_MEM_MemWrite <= ID_EX_MemWrite;
        EX_MEM_MemRead <= ID_EX_MemRead;
        EX_MEM_RegWrite <= ID_EX_RegWrite;
        EX_MEM_MemToReg <= ID_EX_MemToReg;
        EX_MEM_PCSrcCont <= ID_EX_PCSrcCont;
        
        
        if (EX_MEM_MemWrite)
            Data_Mem[EX_MEM_ALUOut] <= EX_MEM_rs2; 
        if (EX_MEM_MemRead)
            MEM_WB_ReadData <= Data_Mem[EX_MEM_ALUOut];
        MEM_WB_IR <= EX_MEM_IR;    
        MEM_WB_RegWrite <= EX_MEM_RegWrite;
        MEM_WB_MemToReg <= EX_MEM_MemToReg;
        MEM_WB_ALUOut <= EX_MEM_ALUOut;
        MEM_WB_rs1_loc <= EX_MEM_rs1_loc;
        MEM_WB_rs2_loc <= EX_MEM_rs2_loc;
        MEM_WB_rd_loc <= EX_MEM_rd_loc;
        
        
        if (MEM_WB_RegWrite)
            begin
                if (MEM_WB_MemToReg)
                    reg_file[MEM_WB_rd_loc] <= MEM_WB_ReadData;
                if (!MEM_WB_MemToReg)
                    reg_file[MEM_WB_rd_loc] <= MEM_WB_ALUOut;
            end
        
    end
    
endmodule
