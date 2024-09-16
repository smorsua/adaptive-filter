module adaptive_filter #(
    parameter WIDTH=32,
    parameter FRAC=20,
    parameter TAPS=2
) (
    input clk,
    input rstn,
    input signed [WIDTH-1:0] i_din,
    input signed [WIDTH-1:0] i_desired,
    input [WIDTH-1:0] i_step_size,
    input i_ovr,
    output signed [WIDTH-1:0] o_dout,
    output signed [WIDTH-1:0] o_error,
    output reg signed [WIDTH-1:0] o_weights[TAPS-1:0],
    output o_ovr
);

    wire [TAPS-1:0][WIDTH-1:0] next_weights;
    reg [TAPS-1:0][WIDTH-1:0] weights;
    wire [TAPS-2:0][WIDTH-1:0] din_tapped_delay;

    always_comb begin
        for(int i = 0; i < TAPS; i++) begin
            o_weights[i] = weights[i];
        end
    end

    // Update weights 
    always @(posedge clk or rstn) begin
        if(!rstn) begin
            weights <= 0;
        end else begin
            weights <= next_weights;
        end
    end

    tapped_delay_line #(
        .WIDTH(WIDTH),
        .DEPTH(TAPS-1)
    ) delay_line (
        .clk(clk),
        .rstn(rstn),
        .din(i_din),
        .tapped_delay(din_tapped_delay)
    );

    wire dout_ovr;
    // transposed_fir #(
    //     .WIDTH(WIDTH),
    //     .FRAC(FRAC),
    //     .TAPS(TAPS)
    // ) filter (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .din(i_din),
    //     .i_ovr(i_ovr),
    //     .coeffs(o_weights),
    //     .dout(o_dout),
    //     .o_ovr(dout_ovr)
    // );

    direct_fir #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .TAPS(TAPS)
    ) my_fir(
        .i_clk(clk),
        .i_rstn(rstn),
        .i_din(i_din),
        .i_coeffs(weights),
        .i_ovr(i_ovr),
        .o_dout(o_dout),
        .o_ovr(dout_ovr)
    );

    assign o_error = i_desired - o_dout; // FIXME: take subtraction overflow into account
    assign error_ovr = dout_ovr; //FIXME: use right formula, this is temporary
    wire [TAPS-1:0] next_weights_ovr;

    lms #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .TAPS(TAPS)
    ) my_lms (
        .din({din_tapped_delay, i_din}),
        .error(o_error),
        .step_size(i_step_size),
        .curr_weights(weights),
        .i_ovr(i_ovr | error_ovr),
        .next_weights(next_weights),
        .next_weights_ovr(next_weights_ovr)
    );

    assign o_ovr = i_ovr | |(next_weights_ovr) | dout_ovr;

endmodule