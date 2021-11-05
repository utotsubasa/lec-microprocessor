module register_file(
    input clk,
    input we,
    input [4:0] r_addr1,
    input [4:0] r_addr2,
    input [4:0] w_addr,
    input [31:0] w_data,
    output [31:0] r_data1,
    output [31:0] r_data2
); 
    reg [31:0] mem [0:31];             //32bitのレジスタが32個(アドレスは5bit)
    always @(posedge clk) begin
        mem[0] <= 32'd0;
        if(we && (w_addr != 5'd0)) mem[w_addr] <= w_data; //クロックと同期して書き込まれる
    end
    assign r_data1 = mem[r_addr1];
    assign r_data2 = mem[r_addr2];
    parameter CYCLE = 100;
    integer i;
    initial begin
        #(CYCLE*10000)
        for(i = 0;i<=31;i=i+1) begin
            $display("%x",mem[i]);
        end
    end
endmodule
