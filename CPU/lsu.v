module lsu(
    input wire [5:0] alucode,
    input wire [31:0] addr,
    input wire [31:0] w_data,
    input wire [7:0] r_data_byte,
    input wire [15:0] r_data_half,
    input wire [31:0] r_data_word,
    output wire [31:0] load_data,
    output wire [31:0] r_addr,
    output wire [31:0] w_addr,
    output wire [7:0] store_data_byte,
    output wire [15:0] store_data_half,
    output wire [31:0] store_data_word
);
    `include "define.vh"
    assign r_addr = addr;
    assign w_addr = addr;

    function [31:0] load_data_func(
        input [5:0] alucode,
        input [7:0] r_data_byte,
        input [15:0] r_data_half,
        input [31:0] r_data_word
    );
        case(alucode)
        /*
            `ALU_LB: load_data_func = {{24{r_data_byte[7]}},r_data_byte};
            `ALU_LH: load_data_func = {{16{r_data_half[7]}},r_data_half[7:0],r_data_half[15:8]};
            `ALU_LW: load_data_func = {r_data_word[7:0],r_data_word[15:8],r_data_word[23:16],r_data_word[31:24]};
            `ALU_LBU: load_data_func = {24'b0,r_data_byte};
            `ALU_LHU: load_data_func = {16'b0,r_data_half[7:0],r_data_half[15:8]};
            */
            `ALU_LB: load_data_func = {{24{r_data_byte[7]}},r_data_byte};
            `ALU_LH: load_data_func = {{16{r_data_half[15]}},r_data_half};
            `ALU_LW: load_data_func = r_data_word;
            `ALU_LBU: load_data_func = {24'b0,r_data_byte};
            `ALU_LHU: load_data_func = {16'b0,r_data_half};
            default: ;
        endcase
    endfunction
    assign load_data = load_data_func(alucode,r_data_byte,r_data_half,r_data_word);
    assign store_data_byte = w_data[7:0];
    assign store_data_half = w_data[15:0];
    assign store_data_word = w_data[31:0];
endmodule
