module fmult #(
    parameter WIDTH,
    parameter FRAC
) (
    input signed [WIDTH-1:0] i_multiplicand,
    input signed [WIDTH-1:0] i_multiplier,
    output signed [WIDTH-1:0] o_result,
    input i_ovr,
    output o_ovr
);
    wire signed [WIDTH*2-1:0] result_fw; // Result full width
    wire conv_ovr;
    
    assign result_fw = i_multiplicand * i_multiplier;

    fixed_point_coverter #(
        .DIN_WIDTH(2*WIDTH),
        .DIN_FRAC(2*FRAC),
        .DOUT_WIDTH(WIDTH),
        .DOUT_FRAC(FRAC)
    ) result_conv(
        .din(result_fw),
        .dout(o_result),
        .ovr(conv_ovr)
    );

    assign o_ovr = i_ovr | conv_ovr;

endmodule