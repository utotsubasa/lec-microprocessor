/* verilator lint_off WIDTH */
/* verilator lint_off CASEINCOMPLETE */
`timescale 1ns / 1ps

module alu(
    input wire [5:0] alucode,       // 演算種別
    input wire [31:0] op1,          // 入力データ1
    input wire [31:0] op2,          // 入力データ2
    output reg [31:0] alu_result,   // 演算結果
    output reg br_taken             // 分岐の有無
    );
    `include "define.vh"

    always @(*) begin
        case(alucode)
            `ALU_LUI:
                begin
                    alu_result = op2;
                    br_taken = 0;
                end
            `ALU_JAL:
                begin
                    alu_result = op2 + 4;
                    br_taken = 1;
                end
            `ALU_JALR:
                begin
                    alu_result = op2 + 4;
                    br_taken = 1;    
                end
            `ALU_BEQ:
                begin
                    alu_result = 32'd0;
                    br_taken = (op1 == op2) ? 1 : 0;
                end
            `ALU_BNE:
                begin
                    alu_result = 32'd0;
                    br_taken = (op1 != op2) ? 1 : 0;
                end
            `ALU_BLT:
                begin
                    alu_result = 32'd0;
                    br_taken = ($signed(op1) < $signed(op2)) ? 1 : 0;
                end
            `ALU_BGE:
                begin
                    alu_result = 32'd0;
                    br_taken = ($signed(op1) >= $signed(op2)) ? 1 : 0;
                end
            `ALU_BLTU:
                begin
                    alu_result = 32'd0;
                    br_taken = ($unsigned(op1) < $unsigned(op2)) ? 1 : 0;
                end
            `ALU_BGEU:
                begin
                    alu_result = 32'd0;
                    br_taken = ($unsigned(op1) >= $unsigned(op2)) ? 1 : 0;
                end
            `ALU_LB:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;      
                end
            `ALU_LH:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;      
                end
            `ALU_LW:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;      
                end
            `ALU_LBU:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;      
                end
            `ALU_LHU:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;      
                end
            `ALU_SB:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;      
                end
            `ALU_SH:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;          
                end
            `ALU_SW:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;
                end
            `ALU_ADD:
                begin
                    alu_result = op1 + op2;
                    br_taken = 0;
                end
            `ALU_SUB:
                begin
                    alu_result = op1 - op2;
                    br_taken = 0;      
                end
            `ALU_SLT:
                begin
                    alu_result = {4'b0,($signed(op1) < $signed(op2))};
                    br_taken = 0;      
                end
            `ALU_SLTU:
                begin
                    alu_result = {4'b0,($unsigned(op1) < $unsigned(op2))};
                    br_taken = 0;      
                end
            `ALU_XOR:
                begin
                    alu_result = op1 ^ op2;
                    br_taken = 0;
                end
            `ALU_OR:
                begin
                    alu_result = op1 | op2;
                    br_taken = 0;      
                end
            `ALU_AND:
                begin
                    alu_result = op1 & op2;
                    br_taken = 0;      
                end
            `ALU_SLL:
                begin
                    alu_result = op1 << op2[4:0];
                    br_taken = 0;
                end
            `ALU_SRL:
                begin
                    alu_result = op1 >> op2[4:0];
                    br_taken = 0;
                end
            `ALU_SRA:
                begin
                    alu_result = $signed(op1) >>> op2[4:0];
                end
            `ALU_NOP:;
            default: ;
        endcase
    end
    // always begin
    //    alu_result <= res;
    // end
endmodule
