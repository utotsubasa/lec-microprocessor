module instruction_memory(
        input wire [31:0] r_addr,
        output wire [31:0] r_data
    );
    reg [31:0] mem [0:30000];
    initial $readmemh("/home/denjo/デスクトップ/後期実験/マイクロプロセッサ/b3exp-master/benchmarks/Coremark/code.hex", mem);
    assign r_data = mem[r_addr>>2];
endmodule
