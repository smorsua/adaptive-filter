module adaptive_filter #(
    parameter WIDTH = 16,
    parameter TAPS = 16
) (
    input clk,
    input rstn,
    input [WIDTH-1:0] din,
    input [WIDTH-1:0] desired,
    input [WIDTH-1:0] step_size,
    output [WIDTH-1:0] dout,
    output [WIDTH-1:0] error,
    output reg [TAPS-1:0][WIDTH-1:0] weights
);

    reg [TAPS-1:0][WIDTH-1:0] next_weights;

    tapped_delay_line #(
        .WIDTH(WIDTH),
        .DEPTH(TAPS)
    ) delay_line (
        .clk(clk),
        .rstn(rstn),
        .din(din),
        .tapped_delay()
    );

    transposed_fir #(
        .DIN_WIDTH(DIN_WIDTH),
        .DOUT_WIDTH(DOUT_WIDTH),
        .TAPS(TAPS)
    ) filter (
        .clk(clk),
        .rstn(rstn),
        .din(din),
        .coeffs(weights),
        .dout(dout)
    );

    assign error = desired - dout;

    lms #(
        .WIDTH(WIDTH),
        .TAPS(TAPS)
    ) my_lms (
        .din(tapped_delay),
        .error(error),
        .step_size(step_size),
        .curr_weights(weights),
        .next_weights(next_weights)
    );

endmodule