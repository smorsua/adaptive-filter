/*
    It supports signed fixed point.
    The rounding algorithm is truncation.
*/
module fixed_point_coverter #(
    parameter DIN_WIDTH = 16,
    parameter DIN_FRAC = 15,
    parameter DOUT_WIDTH = 16,
    parameter DOUT_FRAC = 15
) (
    input [DIN_WIDTH-1:0] din,
    output [DOUT_WIDTH-1:0] dout
);
    localparam din_frac_start = DIN_FRAC - 1;     
    localparam dout_frac_start = DOUT_FRAC - 1;     

    localparam din_integer = DIN_WIDTH - DIN_FRAC - 1;
    localparam dout_integer = DOUT_WIDTH - DOUT_FRAC - 1;

    // Integer part includes sign
    localparam dout_integer_start = DOUT_WIDTH - 1;
    localparam dout_integer_end = dout_integer_start - dout_integer + 1;
    localparam din_integer_start = DIN_WIDTH - 1;
    localparam din_integer_end = din_integer_start - din_integer + 1;

    always_comb begin
        dout = 0;

        // Convert fractional part
        if(DIN_FRAC > 0 && DOUT_FRAC > 0) begin
            if(DIN_FRAC < DOUT_FRAC) begin
                dout[dout_frac_start:dout_frac_start-DIN_FRAC+1] = din[din_frac_start:0];
            end else begin
                dout[dout_frac_start:0] = din[din_frac_start:din_frac_start-DOUT_FRAC+1];
            end
        end

        // Convert integer part
        if(din_integer > 0 && dout_integer > 0) begin
            if(din_integer < dout_integer) begin
                dout[dout_integer_start:dout_integer_end] = $signed(din[din_integer_start:din_integer_end]);
            end
        end 
    end
endmodule