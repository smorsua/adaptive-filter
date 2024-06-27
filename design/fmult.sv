
module fmult #(
    parameter DIN_WIDTH,
    parameter DIN_FRAC,
    parameter DOUT_WIDTH,
    parameter DOUT_FRAC
) (
    input signed [DIN_WIDTH-1:0] i_multiplicand,
    input signed [DIN_WIDTH-1:0] i_multiplier,
    input i_ovr,
    output signed [DOUT_WIDTH-1:0] o_result,
    output o_ovr
);
    localparam result_width = 2*DIN_WIDTH;
    localparam result_frac = 2*DIN_FRAC;

    wire signed [result_width-1:0] result_fw; // Result full width
    wire conv_ovr;
    
    assign result_fw = i_multiplicand * i_multiplier;

    //TODO: can delete this block if output size is equal to maximum needed size (both width and frac have to be equal);
    fixed_point_converter #(
        .DIN_WIDTH(result_width),
        .DIN_FRAC(result_frac),
        .DOUT_WIDTH(DOUT_WIDTH),
        .DOUT_FRAC(DOUT_FRAC)
    ) result_conv(
        .din(result_fw),
        .i_ovr(i_ovr),
        .dout(o_result),
        .o_ovr(conv_ovr)
    );

    assign o_ovr = i_ovr | conv_ovr;

endmodule