module lms #(
    parameter WIDTH, // Used for all net but weights
    parameter FRAC, // Used for all net but weights
    parameter COEFF_WIDTH,
    parameter COEFF_FRAC,
    parameter TAPS
) (
    input [TAPS-1:0][WIDTH-1:0] din,
    input [WIDTH-1:0] error,
    input [WIDTH-1:0] step_size,
    input [TAPS-1:0][COEFF_WIDTH-1:0] curr_weights,
    output [TAPS-1:0][COEFF_WIDTH-1:0] next_weights,
);
    // Multiplication result width
    localparam MULT_RES_WIDTH = ($clog2(2) + 1) + WIDTH + WIDTH + WIDTH;
    localparam MULT_RES_FRAC = FRAC + FRAC + FRAC;

    generate
        for(genvar i = 0; i < TAPS; i++) begin
            wire [WIDTH-1:0] error_times_din_res;
            wire error_times_din_res_ovr;

            fmult #(
                .WIDTH(WIDTH),
                .FRAC(FRAC)
            ) error_times_din (
                .i_multiplicand(error),
                .i_multiplier(din[i]),
                .o_result(error_times_din_res),
                .i_ovr(0),
                .o_ovr(error_times_din_res_ovr)
            );

            wire [WIDTH-1:0] error_times_din_times_step_size_res;
            wire [WIDTH-1:0] error_times_din_times_step_size_res_ovr;

            fmult #(
                .WIDTH(WIDTH),
                .FRAC(FRAC)
            ) error_din_times_step_size (
                .i_multiplicand(error_times_din_res),
                .i_multiplier(step_size),
                .o_result(error_times_din_times_step_size_res),
                .i_ovr(error_times_din_times_step_size_res_ovr),
                .o_ovr()
            );

            wire [width-1:0] weight_offset = error_din_times_step_size_res <<< 1; // Times two FIXME: doesnt detect overflow. Need integer bits to multiply by two in fixed point. 
            assign next_weights[i] = curr_weights[i] + weight_offset;
        end
    endgenerate
endmodule