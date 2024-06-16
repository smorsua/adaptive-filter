module transposed_fir #(
    parameter WIDTH,
    parameter FRAC,
    parameter TAPS
) (
    input clk,
    input rstn,
    input [WIDTH-1:0] din,
    input [TAPS-1:0][WIDTH-1:0] coeffs,
    output [WIDTH-1:0] dout
);

    localparam MULT_RES_WIDTH = WIDTH + WIDTH;
    localparam MULT_RES_FRAC = FRAC + FRAC;

    reg [TAPS-1:0][MULT_RES_WIDTH-1:0] mult_res;
    reg [TAPS-2:0][MULT_RES_WIDTH-1:0] partial_sums; // One delay less than taps
    reg [MULT_RES_WIDTH-1:0] dout_full_width;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            partial_sums <= 0;
            mult_res <= 0;
            dout_full_width <= 0;
        end else begin
            // Multiply coeffs by input sample
            for(integer i = 0; i < TAPS; i++) begin
                mult_res[i] <= $signed(din) * $signed(coeffs[TAPS-1-i]); // Coeffs are reversed in transposed FIR 
            end

            // Calculate cummulative sums and store them, starting from the end
            for(integer i = TAPS-2; i >= 1; i--) begin
                partial_sums[i] <= mult_res[i+1] + partial_sums[i-1];
            end

            partial_sums[0] <= mult_res[0];
            dout_full_width <= partial_sums[TAPS-2];
        end
    end

    fixed_point_coverter #(
        .DIN_WIDTH(MULT_RES_WIDTH),
        .DIN_FRAC(MULT_RES_FRAC),
        .DOUT_WIDTH(WIDTH),
        .DOUT_FRAC(FRAC)
    ) dout_conv(
        .din(dout_full_width),
        .dout(dout)
    );

endmodule