module adaptive_filter #(
    parameter WIDTH,
    parameter FRAC,
    parameter TAPS
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

    wire [TAPS-1:0][WIDTH-1:0] next_weights;
    wire [TAPS-1:0][WIDTH-1:0] din_tapped_delay;

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
        .DEPTH(TAPS)
    ) delay_line (
        .clk(clk),
        .rstn(rstn),
        .din(din),
        .tapped_delay(din_tapped_delay)
    );

    transposed_fir #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
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
        .FRAC(FRAC),
        .COEFF_WIDTH(WIDTH),
        .COEFF_FRAC(FRAC),
        .TAPS(TAPS)
    ) my_lms (
        .din(din_tapped_delay),
        .error(error),
        .step_size(step_size),
        .curr_weights(weights),
        .next_weights(next_weights)
    );

endmodule