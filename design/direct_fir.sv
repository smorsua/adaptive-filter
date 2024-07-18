module direct_fir #(
    parameter WIDTH,
    parameter FRAC,
    parameter TAPS
) (
    input i_clk,
    input i_rstn,
    input [WIDTH-1:0] i_din,
    input [TAPS-1:0][WIDTH-1:0] i_coeffs,
    input i_ovr,
    output [WIDTH-1:0] o_dout,
    output o_ovr
);

    wire [TAPS-2:0][WIDTH-1:0] din_tapped_delay;
    wire [TAPS-1:0][WIDTH-1:0] mult_res;
    wire [TAPS-1:0] mult_ovr;
    wire [TAPS-1:0][WIDTH-1:0] sum_res; // There are only TAPS-1 sums. sum_res[0] will be result of first multiplication
    wire [TAPS-2:0] sum_ovr;

    tapped_delay_line #(
        .WIDTH(WIDTH),
        .DEPTH(TAPS-1)
    ) din_delay_line (
        .clk(i_clk),
        .rstn(i_rstn),
        .din(i_din),
        .tapped_delay(din_tapped_delay)
    );

    fmult #(
        .DIN_WIDTH(WIDTH),
        .DIN_FRAC(FRAC),
        .DOUT_WIDTH(WIDTH),
        .DOUT_FRAC(FRAC)
    ) din_times_coeff (
        .i_multiplicand(i_din),
        .i_multiplier(i_coeffs[0]),
        .o_result(mult_res[0]),
        .i_ovr(i_ovr),
        .o_ovr(mult_ovr[0])
    );

    assign sum_res[0] = mult_res[0];

    generate
        for(genvar i = 1; i < TAPS; i++) begin
            fmult #(
                .DIN_WIDTH(WIDTH),
                .DIN_FRAC(FRAC),
                .DOUT_WIDTH(WIDTH),
                .DOUT_FRAC(FRAC)
            ) din_times_coeff (
                .i_multiplicand(din_tapped_delay[i-1]),
                .i_multiplier(i_coeffs[i]),
                .o_result(mult_res[i]),
                .i_ovr(i_ovr),
                .o_ovr(mult_ovr[i])
            );
        end

        for(genvar i = 0; i < TAPS-1; i++) begin
            fadd #(
                .WIDTH(WIDTH),
                .FRAC(FRAC)
            ) mult_res_sum (
                .i_a(mult_res[i+1]),
                .i_b(sum_res[i]),
                .o_res(sum_res[i+1]),
                .o_ovr(sum_ovr[i])           
            );
        end
    endgenerate

    assign o_dout = sum_res[TAPS-1];
    assign o_ovr = sum_ovr[TAPS-2];
endmodule