module transposed_fir #(
    parameter DIN_WIDTH = 16,
    parameter DOUT_WIDTH = 16,
    parameter TAPS = 16
) (
    input clk,
    input rstn,
    input [DIN_WIDTH-1:0] din,
    input [TAPS-1:0][DIN_WIDTH-1:0] coeffs,
    output reg [DOUT_WIDTH-1:0] dout,
);

    reg [TAPS-2:0][DOUT_WIDTH-1:0] partial_sums; // One delay less than taps

    always @(negedge rstn) begin
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            partial_sums <= 0;
            dout <= 0;
        else begin
            // Multiply coeffs by input sample
            reg [TAPS-1:0][DOUT_WIDTH-1:0] mult_res;
            reg [TAPS-2:0][DOUT_WIDTH-1:0] sums; // One sum less than taps

            for(integer i = 0; i < TAPS; i++) begin
                mult_res[i] <= $signed(din) * $signed(coeffs[TAPS-1-i]); // Coeffs are reversed in transposed FIR 
            end

            // Calculate cummulative sums and store them, starting from the end
            for(integer i = TAPS-2; i >= 1; i--) begin
                sums[i] <= mult_res[i+1] + partial_sums[i-1];
            end

            sums[0] <= mult_res[0];
            dout <= sums[TAPS-2];
        end
    end

endmodule