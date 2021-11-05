module pc(
        input wire clk,
        input wire reset,
        input wire [31:0] npc,
        output wire [31:0] pc
    );
    reg [31:0] pc_reg;
    assign pc = pc_reg;
    always @(posedge clk or negedge reset) begin
        if(reset == 0) begin
            pc_reg <= 32'h8000;
        end else begin
            pc_reg <= npc;
        end
    end
endmodule
