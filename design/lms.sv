module lms #(
    parameter WIDTH, // Used for all net but weights
    parameter FRAC, // Used for all net but weights
    parameter TAPS
) (
    input signed [TAPS-1:0][WIDTH-1:0] din,
    input signed [WIDTH-1:0] error,
    input signed [WIDTH-1:0] step_size,
    input signed [TAPS-1:0][WIDTH-1:0] curr_weights,
    input i_ovr,
    output signed [TAPS-1:0][WIDTH-1:0] next_weights,
    output signed [TAPS-1:0] next_weights_ovr
);

    localparam LMS_CALC_WIDTH = WIDTH * 3 + 2; // Times three because step * error * din. +2 because we multiply by two.
    localparam LMS_CALC_FRAC = FRAC * 3;

    wire signed [LMS_CALC_WIDTH-1:0] step_size_fw;
    wire step_size_ovr;

    fixed_point_converter #(
        .DIN_WIDTH(WIDTH),
        .DIN_FRAC(FRAC),
        .DOUT_WIDTH(LMS_CALC_WIDTH),
        .DOUT_FRAC(LMS_CALC_FRAC)
    ) step_size_conv (
        .din(step_size),
        .i_ovr(1'b0),
        .dout(step_size_fw),
        .o_ovr(step_size_ovr)
    );

    generate
        for(genvar i = 0; i < TAPS; i++) begin
            wire signed [LMS_CALC_WIDTH-1:0] error_times_din_res;
            wire error_times_din_res_ovr;

            fmult #(
                .DIN_WIDTH(WIDTH),
                .DIN_FRAC(FRAC),
                .DOUT_WIDTH(LMS_CALC_WIDTH),
                .DOUT_FRAC(LMS_CALC_FRAC)
            ) error_times_din (
                .i_multiplicand(error),
                .i_multiplier(din[i]),
                .o_result(error_times_din_res),
                .i_ovr(i_ovr),
                .o_ovr(error_times_din_res_ovr)
            );

            wire signed [LMS_CALC_WIDTH-1:0] error_times_din_times_step_size_res;
            wire error_times_din_times_step_size_res_ovr;

            fmult #(
                .DIN_WIDTH(LMS_CALC_WIDTH),
                .DIN_FRAC(LMS_CALC_FRAC),
                .DOUT_WIDTH(LMS_CALC_WIDTH),
                .DOUT_FRAC(LMS_CALC_FRAC)
            ) error_din_times_step_size (
                .i_multiplicand(error_times_din_res),
                .i_multiplier(step_size_fw),
                .o_result(error_times_din_times_step_size_res),
                .i_ovr(error_times_din_res_ovr | step_size_ovr),
                .o_ovr(error_times_din_times_step_size_res_ovr)
            );

            wire signed [LMS_CALC_WIDTH-1:0] curr_weights_fw;
            wire curr_weights_ovr;

            fixed_point_converter #(
                .DIN_WIDTH(WIDTH),
                .DIN_FRAC(FRAC),
                .DOUT_WIDTH(LMS_CALC_WIDTH),
                .DOUT_FRAC(LMS_CALC_FRAC)
            ) curr_weight_conv (
                .din(curr_weights[i]),
                .i_ovr(1'b0),
                .dout(curr_weights_fw),
                .o_ovr(curr_weights_ovr)
            );

            wire signed [LMS_CALC_WIDTH-1:0] weight_offset = error_times_din_times_step_size_res <<< 1; // Times two FIXME: doesnt detect overflow. Need integer bits to multiply by two in fixed point. 
            wire signed [LMS_CALC_WIDTH-1:0] next_weights_fw = curr_weights_fw + weight_offset;

            fixed_point_converter #(
                .DIN_WIDTH(LMS_CALC_WIDTH),
                .DIN_FRAC(LMS_CALC_FRAC),
                .DOUT_WIDTH(WIDTH),
                .DOUT_FRAC(FRAC)
            ) next_weight_conv (
                .din(next_weights_fw),
                .i_ovr(error_times_din_times_step_size_res_ovr | curr_weights_ovr), //FIXME: doesnt take left shift overflow into account, although there should never be overflow because width is big enough.
                .dout(next_weights[i]),
                .o_ovr(next_weights_ovr[i])
            );
        end
    endgenerate
endmodule