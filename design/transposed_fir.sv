module transposed_fir #(
    parameter WIDTH=16,
    parameter FRAC=15,
    parameter TAPS=2
) (
    input clk,
    input rstn,
    input [WIDTH-1:0] din,
    input [TAPS-1:0][WIDTH-1:0] coeffs,
    input i_ovr,
    output reg [WIDTH-1:0] dout,
    output o_ovr
);

    localparam CALC_WIDTH = WIDTH + WIDTH + TAPS-1;
    localparam CALC_FRAC = FRAC + FRAC;

    reg [TAPS-1:0][CALC_WIDTH-1:0] mult_res;
    reg [TAPS-2:0][CALC_WIDTH-1:0] partial_sums; // One delay less than taps
    wire [CALC_WIDTH-1:0] dout_fw;

    wire [TAPS-1:0] mult_ovr;
    generate
        // Multiply coeffs by input sample
        for(genvar i = 0; i < TAPS; i++) begin
            fmult #(
                .DIN_WIDTH(WIDTH),
                .DIN_FRAC(FRAC),
                .DOUT_WIDTH(CALC_WIDTH),
                .DOUT_FRAC(CALC_FRAC)
            ) din_times_coeff (
                .i_multiplicand(din),
                .i_multiplier(coeffs[TAPS-1-i]), // Coeffs are reversed in transposed FIR 
                .o_result(mult_res[i]),
                .i_ovr(i_ovr),
                .o_ovr(mult_ovr[i])
            );
        end

        // Calculate cummulative sums and store them, starting from the end
        for(genvar i = TAPS-2; i >= 1; i--) begin
            always @(posedge clk or negedge rstn) begin
                if(rstn) begin // Not a reset
                    partial_sums[i] <= mult_res[i] + partial_sums[i-1]; // FIXME: take sum ovr into account
                end
            end
        end
    endgenerate


    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            partial_sums <= 0;
        end else begin
            partial_sums[0] <= mult_res[0];
        end
    end


    assign dout_fw = mult_res[TAPS-1] + partial_sums[TAPS-2];

    wire dout_ovr;
    fixed_point_converter #(
        .DIN_WIDTH(CALC_WIDTH),
        .DIN_FRAC(CALC_FRAC),
        .DOUT_WIDTH(WIDTH),
        .DOUT_FRAC(FRAC)
    ) dout_conv (
        .din(dout_fw),
        .i_ovr(|(mult_ovr)),
        .dout(dout),
        .o_ovr(dout_ovr)
    );

    assign o_ovr = i_ovr | dout_ovr;

endmodule