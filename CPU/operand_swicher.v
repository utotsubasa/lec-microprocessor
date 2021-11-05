module operand_swicher(
        input wire [31:0] pc,
        input wire [31:0] reg_data1,
        input wire [31:0] reg_data2,
        input wire [31:0] imm,
        input wire [1:0] aluop1_type,
        input wire [1:0] aluop2_type,
        output wire [31:0] data1,
        output wire [31:0] data2
    );
    `include "define.vh"
    function [31:0] os(
        input [31:0] pc,
        input [31:0] reg_data,
        input [31:0] imm,
        input [1:0] aluop_type
    );
        case(aluop_type)
            `OP_TYPE_REG: os = reg_data;
            `OP_TYPE_IMM: os = imm;
            `OP_TYPE_PC: os = pc;
            `OP_TYPE_NONE: os = 0;
        endcase
    endfunction
    assign data1 = os(pc,reg_data1,imm,aluop1_type);
    assign data2 = os(pc,reg_data2,imm,aluop2_type);
endmodule
