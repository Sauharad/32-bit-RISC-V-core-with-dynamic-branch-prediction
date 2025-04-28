`timescale 1ns / 1ps


module riscvsim;
reg clk,start;

riscv32 DUT(.clk(clk),.start(start));

wire [31:0] regfile [0:31] = DUT.riscv_datapath.reg_file;

wire [31:0] PC = DUT.riscv_datapath.PC;
wire [31:0] PPC = DUT.riscv_datapath.PPC;
wire [6:0] opcode = DUT.riscv_datapath.opcode;
wire [6:0] funct7 = DUT.riscv_datapath.funct7;
wire [6:0] funct3 = DUT.riscv_datapath.funct3;

wire branch_pred_bht = DUT.riscv_datapath.branch_pred_bht;
wire branch_pred_btb = DUT.riscv_datapath.branch_pred_btb;
wire branch_prediction = DUT.riscv_datapath.branch_prediction;
wire prev_branch_prediction = DUT.riscv_datapath.prev_branch_prediction;

wire bht_update = DUT.riscv_datapath.bht_update;
wire bht_update_direction = DUT.riscv_datapath.bht_update_direction;
wire btb_update = DUT.riscv_datapath.btb_update;

wire regwrite = DUT.riscv_datapath.RegWrite;
wire memtoreg = DUT.riscv_datapath.MemToReg;
wire memread = DUT.riscv_datapath.MemRead;
wire memwrite = DUT.riscv_datapath.MemWrite;
wire alusrc = DUT.riscv_datapath.ALUSrc;
wire isstall = DUT.riscv_datapath.IsStall;
wire load_stall = DUT.riscv_datapath.load_stall;
wire [1:0] br_stall = DUT.riscv_datapath.br_stall;
wire [1:0] br_stall_prev = DUT.riscv_datapath.br_stall_prev;
wire [4:0] aluop = DUT.riscv_datapath.ALUOp;
wire pcsrccont = DUT.riscv_datapath.PCSrcCont;
wire [2:0] pcsrc_counter = DUT.riscv_datapath.pcsrc_counter;



wire [31:0] IF_ID_IR = DUT.riscv_datapath.IF_ID_IR;
wire [31:0] IF_ID_PC = DUT.riscv_datapath.IF_ID_PC;
wire [31:0] IF_ID_branch_prediction = DUT.riscv_datapath.IF_ID_branch_prediction;
wire [4:0] IF_ID_rs1_loc = DUT.riscv_datapath.IF_ID_rs1_loc;
wire [4:0] IF_ID_rs2_loc = DUT.riscv_datapath.IF_ID_rs2_loc;
wire [4:0] IF_ID_rd_loc = DUT.riscv_datapath.IF_ID_rd_loc;

wire [31:0] ID_BR_PC = DUT.riscv_datapath.ID_BR_PC;
wire ID_PCSrc = DUT.riscv_datapath.ID_PCSrc;

wire [31:0] BR_A = DUT.riscv_datapath.BR_A;
wire [31:0] BR_B = DUT.riscv_datapath.BR_B;
wire BR_Test = DUT.riscv_datapath.BR_Test;

wire [31:0] imm_gen_out = DUT.riscv_datapath.imm_gen_out;



wire [31:0] ID_EX_IR = DUT.riscv_datapath.ID_EX_IR;
wire [31:0] ID_EX_PC = DUT.riscv_datapath.ID_EX_PC;
wire [31:0] ID_EX_rs1 = DUT.riscv_datapath.ID_EX_rs1;
wire [31:0] ID_EX_rs2 = DUT.riscv_datapath.ID_EX_rs2;
wire [4:0] ID_EX_rs1_loc = DUT.riscv_datapath.ID_EX_rs1_loc;
wire [4:0] ID_EX_rs2_loc = DUT.riscv_datapath.ID_EX_rs2_loc;
wire [4:0] ID_EX_rd_loc = DUT.riscv_datapath.ID_EX_rd_loc;
wire [31:0] ID_EX_Imm = DUT.riscv_datapath.ID_EX_Imm;
wire ID_EX_RegWrite = DUT.riscv_datapath.ID_EX_RegWrite;
wire ID_EX_MemWrite = DUT.riscv_datapath.ID_EX_MemWrite;
wire ID_EX_MemRead = DUT.riscv_datapath.ID_EX_MemRead;
wire ID_EX_MemToReg = DUT.riscv_datapath.ID_EX_MemToReg;
wire ID_EX_ALUSrc = DUT.riscv_datapath.ID_EX_ALUSrc;
wire [4:0] ID_EX_ALUOp = DUT.riscv_datapath.ID_EX_ALUOp;
wire ID_EX_PCSrcCont = DUT.riscv_datapath.ID_EX_PCSrcCont;


wire [31:0] ALU_A = DUT.riscv_datapath.ALU_A;
wire [31:0] ALU_B = DUT.riscv_datapath.ALU_B;
wire [31:0] ALU_OUT = DUT.riscv_datapath.ex_mem_aluout;


wire [31:0] EX_MEM_ALUOut = DUT.riscv_datapath.EX_MEM_ALUOut;
wire [31:0] EX_MEM_rs2 = DUT.riscv_datapath.EX_MEM_rs2;
wire [4:0] EX_MEM_rs1_loc = DUT.riscv_datapath.EX_MEM_rs1_loc;
wire [4:0] EX_MEM_rs2_loc = DUT.riscv_datapath.EX_MEM_rs2_loc;
wire [4:0] EX_MEM_rd_loc = DUT.riscv_datapath.EX_MEM_rd_loc;
wire [31:0] EX_MEM_PC = DUT.riscv_datapath.EX_MEM_PC;
wire EX_MEM_RegWrite = DUT.riscv_datapath.EX_MEM_RegWrite;
wire EX_MEM_MemWrite = DUT.riscv_datapath.EX_MEM_MemWrite;
wire EX_MEM_MemRead = DUT.riscv_datapath.EX_MEM_MemRead;
wire EX_MEM_MemToReg = DUT.riscv_datapath.EX_MEM_MemToReg;
wire EX_MEM_PCSrcCont = DUT.riscv_datapath.EX_MEM_PCSrcCont;



wire [31:0] MEM_WB_ALUOut = DUT.riscv_datapath.MEM_WB_ALUOut;
wire [31:0] MEM_WB_ReadData = DUT.riscv_datapath.MEM_WB_ReadData;
wire [4:0] MEM_WB_rs1_loc = DUT.riscv_datapath.MEM_WB_rs1_loc;
wire [4:0] MEM_WB_rs2_loc = DUT.riscv_datapath.MEM_WB_rs2_loc;
wire [4:0] MEM_WB_rd_loc = DUT.riscv_datapath.MEM_WB_rd_loc;
wire MEM_WB_RegWrite = DUT.riscv_datapath.MEM_WB_RegWrite;
wire MEM_WB_MemToReg = DUT.riscv_datapath.MEM_WB_MemToReg;

wire [31:0] out = DUT.riscv_datapath.Data_Mem[1];

initial
begin
    clk = 1'b0;
    forever #1 clk = ~clk;
end

initial
begin
    DUT.riscv_datapath.Inst_Mem[0] = 8'h00;
    DUT.riscv_datapath.Inst_Mem[1] = 8'h00;
    DUT.riscv_datapath.Inst_Mem[2] = 8'h81;
    DUT.riscv_datapath.Inst_Mem[3] = 8'h33;
    DUT.riscv_datapath.Inst_Mem[4] = 8'h00;
    DUT.riscv_datapath.Inst_Mem[5] = 8'h00;
    DUT.riscv_datapath.Inst_Mem[6] = 8'ha1;
    DUT.riscv_datapath.Inst_Mem[7] = 8'h83;
    DUT.riscv_datapath.Inst_Mem[8] = 8'h00;
    DUT.riscv_datapath.Inst_Mem[9] = 8'h21;
    DUT.riscv_datapath.Inst_Mem[10] = 8'h84;
    DUT.riscv_datapath.Inst_Mem[11] = 8'h63;
    DUT.riscv_datapath.Inst_Mem[24] = 8'h00;
    DUT.riscv_datapath.Inst_Mem[25] = 8'h21;
    DUT.riscv_datapath.Inst_Mem[26] = 8'h84;
    DUT.riscv_datapath.Inst_Mem[27] = 8'h63;
    DUT.riscv_datapath.Inst_Mem[40] = 8'h00;
    DUT.riscv_datapath.Inst_Mem[41] = 8'h21;
    DUT.riscv_datapath.Inst_Mem[42] = 8'h84;
    DUT.riscv_datapath.Inst_Mem[43] = 8'h63;
    DUT.riscv_datapath.Inst_Mem[56] = 8'h00;
    DUT.riscv_datapath.Inst_Mem[57] = 8'h21;
    DUT.riscv_datapath.Inst_Mem[58] = 8'h84;
    DUT.riscv_datapath.Inst_Mem[59] = 8'h63;
    
    DUT.riscv_datapath.reg_file[0] = 32'h00000001;
    DUT.riscv_datapath.reg_file[1] = 32'h00000001;
    
    DUT.riscv_datapath.Data_Mem[1] = 32'h00000002;
    
    #5.5 start = 1;
    #50 $finish;
end
endmodule
