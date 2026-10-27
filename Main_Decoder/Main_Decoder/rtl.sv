
module maindec (
    input  logic [6:0] op,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       Branch,
    output logic       ALUSrc,
    output logic       RegWrite,
    output logic       Jump,
    output logic [1:0] ImmSrc,
    output logic [1:0] ALUOp
);

    always_comb begin
        // Default values
        ResultSrc = 2'b00;
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        ALUSrc    = 1'b0;
        RegWrite  = 1'b0;
        Jump      = 1'b0;
        ImmSrc    = 2'b00;
        ALUOp     = 2'b00;

        case (op)

            // R-type
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end

            // I-type ALU
            7'b0010011: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ImmSrc   = 2'b00;
                ALUOp    = 2'b10;
            end

            // Load word (LW)
            7'b0000011: begin
                ResultSrc = 2'b01;
                ALUSrc    = 1'b1;
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;
                ALUOp     = 2'b00;
            end

            // Store word (SW)
            7'b0100011: begin
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                ImmSrc   = 2'b01;
                ALUOp    = 2'b00;
            end

            // Branch equal (BEQ) only
            7'b1100011: begin
                Branch = 1'b1;
                ImmSrc = 2'b10;
                ALUOp  = 2'b01;
            end

            // Jump and link (JAL) only
            7'b1101111: begin
                ResultSrc = 2'b10;
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                ImmSrc    = 2'b11;
            end

            // Unsupported opcode: retain defaults
            default: begin
            end

        endcase
    end

endmodule
