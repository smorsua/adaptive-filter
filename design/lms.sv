module lms #(
    parameter WIDTH = 16,
    parameter TAPS = 16
) (
    input [TAPS-1:0][WIDTH-1:0] din,
    input [WIDTH-1:0] error,
    input [WIDTH-1:0] step_size,
    input [TAPS-1:0][WIDTH-1:0] curr_weights,
    output reg [TAPS-1:0][WIDTH-1:0] next_weights
);

    always_comb begin
        for(int i = 0; i < TAPS; i++) begin
            next_weights[i] <= curr_weights[i] + 2 * step_size * error * din[i];
        end
    end

    fixed_point_coverter output_coverter

endmodule