module data_memory(
    input wire clk,
    input wire [5:0] alucode,
    input wire is_store,
    input wire [31:0] w_addr,
    input wire [7:0] w_data_byte,
    input wire [15:0] w_data_half,
    input wire [31:0] w_data_word,
    input wire [31:0] r_addr, 
    output wire [7:0] r_data_byte,
    output wire [15:0] r_data_half,
    output wire [31:0] r_data_word
); 
    reg [31:0] mem [0:30000];
    always @(posedge clk) begin
        if(is_store) begin
            case(alucode)
                `ALU_SB: mem[w_addr>>2][(3-w_addr%4)*8+7 -: 8] <= w_data_byte;
                `ALU_SH: mem[w_addr>>2][(3-w_addr%4)*8+7 -: 16] <= w_data_half;
                `ALU_SW: mem[w_addr>>2] <= w_data_word;
            endcase
        end
    end
    assign r_data_byte = mem[r_addr>>2][(3-r_addr%4)*8+7 -: 8];
    assign r_data_half = mem[r_addr>>2][(3-r_addr%4)*8+7 -: 16];
    assign r_data_word = mem[r_addr>>2];
endmodule
