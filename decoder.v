module decoder(
    input  wire [31:0]  ir,           // 機械語命令列
    output wire  [4:0]	srcreg1_num,  // ソースレジスタ1番号
    output wire  [4:0]	srcreg2_num,  // ソースレジスタ2番号
    output wire  [4:0]	dstreg_num,   // デスティネーションレジスタ番号
    output wire [31:0]	imm,          // 即値
    output reg   [5:0]	alucode,      // ALUの演算種別
    output reg   [1:0]	aluop1_type,  // ALUの入力タイプ
    output reg   [1:0]	aluop2_type,  // ALUの入力タイプ
    output reg	     	reg_we,       // レジスタ書き込みの有無
    output reg		is_load,      // ロード命令判定フラグ
    output reg		is_store,     // ストア命令判定フラグ
    output reg          is_halt
    );
    `include "define.vh"

    wire [6:0] opcode;
    wire [2:0] op_type;
    wire [6:0] op_type_type;
    reg [31:0] imm_reg;
    reg [4:0] rd;
    reg [4:0] rs1;
    reg [4:0] rs2;

    assign opcode = ir[6:0];
    assign op_type  = ir[14:12];
    assign op_type_type = ir[31:25];

    always @(*) begin
        is_halt <= 0;
        imm_reg <= 32'd0;
        rs1 <= 5'd0;
        rs2 <= 5'd0;
        rd <= 5'd0;
        case(opcode)
            `LUI:    // 7'b0110111
                begin
                    imm_reg[31:12] <= ir[31:12];
                    rd <= ir[11:7];
                    alucode <= `ALU_LUI;
                    aluop1_type <= `OP_TYPE_NONE;
                    aluop2_type <= `OP_TYPE_IMM;
                    reg_we <= 1;
                    is_load <= 0;
                    is_store <= 0; 
                end   
            `AUIPC:  // 7'b0010111
                begin
                    imm_reg[31:12] <= ir[31:12];
                    rd <= ir[11:7];
                    alucode <= `ALU_ADD;
                    aluop1_type <= `OP_TYPE_IMM;
                    aluop2_type <= `OP_TYPE_PC;
                    reg_we <= 1;     
                    is_load <= 0;
                    is_store <= 0;     
                end    
            `JAL:    // 7'b1101111
                begin
                    imm_reg[31:1] <= {{11{ir[31]}}, ir[31],ir[19: 12],ir[20],ir[30:21] };
                    rd <= ir[11:7];
                    alucode <= `ALU_JAL;
                    aluop1_type <= `OP_TYPE_NONE;
                    aluop2_type <= `OP_TYPE_PC; 
                    reg_we <= ir[11:7] == 5'd0 ? 0:1;    
                    is_load <= 0; 
                    is_store <= 0;    
                end
            `JALR:   // 7'b1100111
                begin
                    imm_reg <= {{20{ir[31]}},ir[31:20]};
                    rd <= ir[11:7];
                    rs1 <= ir[19:15];
                    alucode <= `ALU_JALR;
                    aluop1_type <= `OP_TYPE_REG;
                    aluop2_type <= `OP_TYPE_PC;
                    reg_we <= ir[11:7] == 5'd0 ? 0 :1;
                    is_load <= 0;
                    is_store <= 0;
                end
            `BRANCH: // 7'b1100011
                begin
                    rs1 <= ir[19:15];
                    rs2 <= ir[24:20];
                    // imm_reg <= {{19{ir[31]}},ir[31],ir[7],ir[30:25],ir[11:8],0}; 
                    imm_reg[32:1] <= {{19{ir[31]}},ir[31],ir[7],ir[30:25],ir[11:8]}; 
                    case(op_type)
                        3'd0: alucode <= `ALU_BEQ;
                        3'd1: alucode <= `ALU_BNE;
                        3'd4: alucode <= `ALU_BLT;
                        3'd5: alucode <= `ALU_BGE;
                        3'd6: alucode <= `ALU_BLTU;
                        3'd7: alucode <= `ALU_BGEU;
                    endcase
                    aluop1_type <= `OP_TYPE_REG;
                    aluop2_type <= `OP_TYPE_REG;
                    reg_we <= 0;
                    is_load <= 0;
                    is_store <= 0;
                end
            `LOAD:    // 7'b0000011
                begin
                    rs1 <= ir[19:15];
                    rd <= ir[11:7];
                    imm_reg[11:0] <= ir[31:20];
                    case(op_type)
                        3'd0: alucode <= `ALU_LB;
                        3'd1: alucode <= `ALU_LH;
                        3'd2: alucode <= `ALU_LW;
                        3'd4: alucode <= `ALU_LBU;
                        3'd5: alucode <= `ALU_LHU;
                    endcase
                    aluop1_type <= `OP_TYPE_REG;
                    aluop2_type <= `OP_TYPE_IMM;
                    reg_we <= 1;
                    is_load <= 1;
                    is_store <= 0;
                end
            `STORE:   // 7'b0100011
                begin
                    rs1 <= ir[19:15];
                    rs2 <= ir[24:20];
                    imm_reg[11:0] <= {ir[31:25],ir[11:7]};
                    case(op_type)
                        3'd0: alucode <= `ALU_SB;
                        3'd1: alucode <= `ALU_SH;
                        3'd2: alucode <= `ALU_SW;
                    endcase
                    aluop1_type <= `OP_TYPE_REG;
                    aluop2_type <= `OP_TYPE_IMM;
                    reg_we <= 0;
                    is_load <= 0;
                    is_store <= 1;
                end
            `OPIMM:   // 7'b0010011
                begin
                    if(op_type == 3'd1 || op_type == 3'd5) begin
                        rs1 <= ir[19:15];
                        rd <= ir[11:7];
                        imm_reg[4:0] <= ir[24:20];
                        if(op_type == 3'd1) begin
                            alucode <= `ALU_SLL;
                        end else begin
                           if(op_type_type == 7'd0) begin
                               alucode <= `ALU_SRL;
                           end else begin
                               alucode <= `ALU_SRA;
                           end
                        end
                        aluop1_type <= `OP_TYPE_REG;
                        aluop2_type <= `OP_TYPE_IMM;
                        reg_we <= 1;
                        is_load <= 0;
                        is_store <= 0;
                    end else begin
                        rs1 <= ir[19:15];
                        rd <= ir[11:7];
                        imm_reg <= {{20{ir[31]}},ir[31:20] };
                        case(op_type)
                            3'd0: alucode <= `ALU_ADD;
                            3'd2: alucode <= `ALU_SLT;
                            3'd3: alucode <= `ALU_SLTU;
                            3'd4: alucode <= `ALU_XOR;
                            3'd6: alucode <= `ALU_OR;
                            3'd7: alucode <= `ALU_AND;
                        endcase
                        aluop1_type <= `OP_TYPE_REG;
                        aluop2_type <= `OP_TYPE_IMM;
                        reg_we <= 1;
                        is_load <= 0;
                        is_store <= 0;
                    end
                end
            `OP:      // 7'b0110011
                begin
                    rs1 <= ir[19:15];
                    rs2 <= ir[24:20];
                    rd <= ir[11:7];
                    case(op_type)
                        3'd0: alucode <= op_type_type == 7'd0 ? `ALU_ADD : `ALU_SUB;
                        3'd1: alucode <= `ALU_SLL;
                        3'd2: alucode <= `ALU_SLT;
                        3'd3: alucode <= `ALU_SLTU;
                        3'd4: alucode <= `ALU_XOR;
                        3'd5: alucode <= op_type_type == 7'd0 ? `ALU_SRL : `ALU_SRA;
                        3'd6: alucode <= `ALU_OR;
                        3'd7: alucode <= `ALU_AND;
                    endcase
                    aluop1_type <= `OP_TYPE_REG;
                    aluop2_type <= `OP_TYPE_REG;
                    reg_we <= 1;
                    is_load <= 0;
                    is_store <= 0;
                end
        endcase
    end

    assign srcreg1_num = rs1;
    assign srcreg2_num = rs2;
    assign dstreg_num = rd;
    assign imm = imm_reg;
endmodule