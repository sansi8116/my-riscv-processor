
module dmem (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a,
    input  logic [31:0] wd,
    output logic [31:0] rd
);

    logic [31:0] RAM [0:63];

    // Write on the rising edge of the clock
    always_ff @(posedge clk) begin
        if (we)
            RAM[a[7:2]] <= wd;
    end

    // Combinational read
    always_comb begin
        rd = RAM[a[7:2]];
    end

endmodule
