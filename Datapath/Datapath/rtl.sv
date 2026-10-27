
module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  ResultSrc,
    input  logic        PCSrc,
    input  logic        ALUSrc,
    input  logic        RegWrite,
    input  logic [1:0]  ImmSrc,
    input  logic [2:0]  ALUControl,
    output logic        Zero,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData
);

    logic [31:0] PCNext;
    logic [31:0] PCPlus4;
    logic [31:0] PCTarget;
    logic [31:0] ImmExt;
    logic [31:0] SrcA;
    logic [31:0] SrcB;
    logic [31:0] Result;
    logic [31:0] RD1;
    logic [31:0] RD2;

    // Program counter register
    flopr #(32) pcreg (
        .clk(clk),
        .reset(reset),
        .d(PCNext),
        .q(PC)
    );

    // PC + 4
    adder pcadd4 (
        .a(PC),
        .b(32'd4),
        .y(PCPlus4)
    );

    // Sign-extend the instruction immediate
    extend ext (
        .instr(Instr[31:7]),
        .immsrc(ImmSrc),
        .immext(ImmExt)
    );

    // Branch/jump target = PC + (ImmExt << 1)
    adder pctargetadd (
        .a(PC),
        .b(ImmExt << 1),
        .y(PCTarget)
    );

    // Select the next PC
    mux2 #(32) pcmux (
        .d0(PCPlus4),
        .d1(PCTarget),
        .s(PCSrc),
        .y(PCNext)
    );

    // Register file
    regfile rf (
        .clk(clk),
        .we3(RegWrite),
        .a1(Instr[19:15]),
        .a2(Instr[24:20]),
        .a3(Instr[11:7]),
        .wd3(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    // Select ALU second operand
    mux2 #(32) srcbmux (
        .d0(RD2),
        .d1(ImmExt),
        .s(ALUSrc),
        .y(SrcB)
    );

    assign SrcA = RD1;
    assign WriteData = RD2;

    // ALU
    alu mainalu (
        .a(SrcA),
        .b(SrcB),
        .alucontrol(ALUControl),
        .result(ALUResult)
    );

    assign Zero = (ALUResult == 32'd0);

    // Select value written back to register file
    mux3 #(32) resultmux (
        .d0(ALUResult),
        .d1(ReadData),
        .d2(PCPlus4),
        .s(ResultSrc),
        .y(Result)
    );

endmodule
