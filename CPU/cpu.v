module cpu(
        input wire sysclk,
        input wire cpu_resetn
    );

    wire [31:0] pc;
    wire [31:0] ir;
    wire  [4:0]	srcreg1_num;  // ソースレジスタ1番号
    wire  [4:0]	srcreg2_num;  // ソースレジスタ2番号
    wire  [4:0]	dstreg_num;   // デスティネーションレジスタ番号
    wire [31:0]	imm;          // 即値
    wire   [5:0]	alucode;      // ALUの演算種別
    wire   [1:0] aluop1_type;  // ALUの入力タイプ
    wire   [1:0] 	aluop2_type;  // ALUの入力タイプ
    wire	reg_we;       // レジスタ書き込みの有無
    wire is_load;      // ロード命令判定フラグ
    wire is_store;     // ストア命令判定フラグ
    wire is_halt;
    wire [31:0] r_data1;
    wire [31:0] r_data2;
    wire [31:0] alu_result;
    wire br_taken;
    wire [31:0] npc;
    wire [31:0] write_value;
    wire [31:0] load_value;
    wire [31:0] op1_data;
    wire [31:0] op2_data;
    wire [7:0] r_data_byte;
    wire [15:0] r_data_half;
    wire [31:0] r_data_word;
    wire [7:0] w_data_byte;
    wire [15:0] w_data_half;
    wire [31:0] w_data_word;
    wire [31:0] r_store_addr;
    wire [31:0] w_store_addr;
    integer fd;
    initial begin
        fd = $fopen("/home/denjo/デスクトップ/後期実験/マイクロプロセッサ/work/file.trace","w");
    end
    always @(posedge sysclk) begin
        if(alucode >= 14 && alucode <= 16) begin // store
            if(alucode == 14) $fdisplay(fd,"0x%4'h: 0x%8'h # (no destination); mem[0x%8'h] <- 0x%2'h", pc,ir,w_store_addr,w_data_byte);
            if(alucode == 15) $fdisplay(fd,"0x%4'h: 0x%8'h # (no destination); mem[0x%8'h] <- 0x%4'h", pc,ir,w_store_addr,w_data_half);
            if(alucode == 16) $fdisplay(fd,"0x%4'h: 0x%8'h # (no destination); mem[0x%8'h] <- 0x%8'h", pc,ir,w_store_addr,w_data_word);
        end else if(alucode >= 9 && alucode <= 13 ) begin // load
            if(alucode == 9 || alucode == 12) begin
                if(dstreg_num == 0) begin $fdisplay(fd,"0x%4'h: 0x%8'h # (no destination);            0x%02'h <- mem[0x%8'h]", pc,ir,load_value[7:0],r_store_addr);
                end else begin $fdisplay(fd,"0x%4'h: 0x%8'h # x%02'd = 0x%8'h;            0x%02'h <- mem[0x%8'h]", pc,ir,dstreg_num,write_value,load_value[7:0],r_store_addr); end
            end else if(alucode == 10 || alucode == 13) begin
                if(dstreg_num == 0) begin $fdisplay(fd,"0x%4'h: 0x%8'h # (no destination);          0x%04'h <- mem[0x%8'h]", pc,ir,load_value[15:0],r_store_addr);
                end else begin $fdisplay(fd,"0x%4'h: 0x%8'h # x%02'd = 0x%8'h;          0x%04'h <- mem[0x%8'h]", pc,ir,dstreg_num,write_value,load_value[15:0],r_store_addr); end
            end else begin
                if(dstreg_num == 0) begin $fdisplay(fd,"0x%4'h: 0x%8'h # (no destination);      0x%08'h <- mem[0x%8'h]", pc,ir,load_value,r_store_addr);
                end else begin $fdisplay(fd,"0x%4'h: 0x%8'h # x%02'd = 0x%8'h;      0x%08'h <- mem[0x%8'h]", pc,ir,dstreg_num,write_value,load_value,r_store_addr); end
            end
        end else if(alucode >= 2 && alucode <= 8) begin
            $fdisplay(fd,"0x%4'h: 0x%8'h # (no destination)", pc,ir);
        end else begin
            if(dstreg_num != 0) begin $fdisplay(fd,"0x%4'h: 0x%8'h # x%02'd = 0x%8'h", pc,ir,dstreg_num,write_value);
            end else begin $fdisplay(fd,"0x%4'h: 0x%8'h # (no destination)", pc,ir); end
        end
    end
    assign write_value = is_load ? load_value : alu_result; 
    pc pc0( // 済
        .clk(sysclk),
        .reset(cpu_resetn),
        .npc(npc),
        .pc(pc)
    );
    instruction_memory instruction_memory0( // 済
        .r_addr(pc),
        .r_data(ir)
    );
    decoder decoder0( // 済
        .ir(ir),
        .srcreg1_num(srcreg1_num),
        .srcreg2_num(srcreg2_num),
        .dstreg_num(dstreg_num),
        .imm(imm),
        .alucode(alucode),
        .aluop1_type(aluop1_type),
        .aluop2_type(aluop2_type),
        .reg_we(reg_we),
        .is_load(is_load),
        .is_store(is_store),
        .is_halt(is_halt)
    );
    register_file register_file0( // 済
        .clk(sysclk), 
        .we(reg_we), 
        .r_addr1(srcreg1_num), 
        .r_addr2(srcreg2_num), 
        .r_data1(r_data1), 
        .r_data2(r_data2), 
        .w_addr(dstreg_num), 
        .w_data(write_value)
    );
    operand_swicher operand_swicher0( // 済
        .pc(pc),
        .reg_data1(r_data1),
        .reg_data2(r_data2),
        .imm(imm),
        .aluop1_type(aluop1_type),
        .aluop2_type(aluop2_type),
        .data1(op1_data),
        .data2(op2_data)
    );
    alu alu0( // 済
        .alucode(alucode),
        .op1(op1_data),
        .op2(op2_data),
        .alu_result(alu_result),
        .br_taken(br_taken)
    );
    lsu lsu0( // 済
        .alucode(alucode),
        .addr(alu_result),
        .w_data(r_data2),
        .r_data_byte(r_data_byte),
        .r_data_half(r_data_half),
        .r_data_word(r_data_word),
        .load_data(load_value),
        .r_addr(r_store_addr),
        .w_addr(w_store_addr),
        .store_data_byte(w_data_byte),
        .store_data_half(w_data_half),
        .store_data_word(w_data_word)
    );
    data_memory data_memory0( // 済
        .clk(sysclk),
        .alucode(alucode),
        .is_store(is_store),
        .w_addr(w_store_addr),
        .w_data_byte(w_data_byte),
        .w_data_half(w_data_half),
        .w_data_word(w_data_word),
        .r_addr(r_store_addr),
        .r_data_byte(r_data_byte),
        .r_data_half(r_data_half),
        .r_data_word(r_data_word)
    );
    next_pc next_pc0( // ?
        .pc(pc),
        .alucode(alucode),
        .br_taken(br_taken),
        .imm(imm),
        .reg_data(r_data1),
        .npc(npc)
    );
endmodule
