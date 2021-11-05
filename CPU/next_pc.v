module next_pc(
        input wire [31:0] pc,
        input wire [5:0] alucode,
        input wire br_taken,
        input wire [31:0] imm,
        input wire [31:0] reg_data,
        output wire [31:0] npc
    );
    function [31:0] funcpc(
        input [5:0] alucode,
        input [31:0] pc,
        input [31:0] imm,
        input [31:0] reg_data,
        input br_taken
    );
        case(alucode)
            `ALU_LUI: funcpc = pc + 4;
            `ALU_JAL: funcpc = pc + imm;
            `ALU_JALR: funcpc = reg_data + imm;
            `ALU_BEQ: funcpc = br_taken ? pc + imm : pc + 4;
            `ALU_BNE: funcpc= br_taken ? pc + imm : pc + 4;
            `ALU_BLT: funcpc = br_taken ? pc + imm : pc + 4;
            `ALU_BGE: funcpc = br_taken ? pc + imm : pc + 4;
            `ALU_BLTU: funcpc = br_taken ? pc + imm : pc + 4;
            `ALU_BGEU: funcpc = br_taken ? pc + imm : pc + 4;
            `ALU_LB: funcpc = pc + 4;
            `ALU_LH: funcpc = pc + 4;
            `ALU_LW: funcpc = pc + 4;
            `ALU_LBU: funcpc = pc + 4;
            `ALU_LHU: funcpc = pc + 4;
            `ALU_SB: funcpc = pc + 4;
            `ALU_SH: funcpc = pc + 4;
            `ALU_SW: funcpc = pc + 4;
            `ALU_ADD: funcpc = pc + 4;
            `ALU_SUB: funcpc = pc + 4;
            `ALU_SLT: funcpc = pc + 4;
            `ALU_SLTU: funcpc = pc + 4;
            `ALU_XOR: funcpc = pc + 4;
            `ALU_OR: funcpc = pc + 4;
            `ALU_AND: funcpc = pc + 4;
            `ALU_SLL: funcpc = pc + 4;
            `ALU_SRL: funcpc = pc + 4;
            `ALU_SRA: funcpc = pc + 4;
            `ALU_NOP: funcpc = pc + 4;
        endcase
    endfunction
    assign npc = funcpc(alucode,pc,imm,reg_data,br_taken);
endmodule
