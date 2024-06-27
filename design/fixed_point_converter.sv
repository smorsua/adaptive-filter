/*
    It supports signed fixed point.
    The rounding algorithm is truncation.
    We assume input signals are not overflowed
*/
module fixed_point_converter #(
    parameter DIN_WIDTH,
    parameter DIN_FRAC,
    parameter DOUT_WIDTH,
    parameter DOUT_FRAC
) (
    input [DIN_WIDTH-1:0] din,
    input i_ovr,
    output [DOUT_WIDTH-1:0] dout,
    output o_ovr
);
    localparam din_frac_end = DIN_FRAC - 1;     
    localparam dout_frac_end = DOUT_FRAC - 1;     

    // Integer part includes sign
    localparam din_integer = DIN_WIDTH - DIN_FRAC;
    localparam dout_integer = DOUT_WIDTH - DOUT_FRAC;

    localparam dout_integer_end = DOUT_WIDTH - 1;
    localparam dout_integer_start = dout_integer_end - dout_integer + 1;
    localparam din_integer_end = DIN_WIDTH - 1;
    localparam din_integer_start = din_integer_end - din_integer + 1;

    generate
        
    // Convert fractional part if present in both source and destination
    if(DIN_FRAC > 0 && DOUT_FRAC > 0) begin
        if(DIN_FRAC < DOUT_FRAC) begin
            assign dout[dout_frac_end:dout_frac_end-DIN_FRAC+1] = din[din_frac_end:0];
        end else begin
            assign dout[dout_frac_end:0] = din[din_frac_end:din_frac_end-DOUT_FRAC+1];
        end
    end

    // Convert integer part. There is always at least one bit (sign)
    if(din_integer < dout_integer) begin
        assign dout[dout_integer_end:dout_integer_start] = $signed(din[din_integer_end:din_integer_start]); // Automatic sign extension
    end else begin
        assign dout[dout_integer_end:dout_integer_start] = $signed(din[din_integer_start + dout_integer - 1:din_integer_start]); // We don't subtract 1 on the MSB of din because we use the additional bit as the sign bit.
    end
    endgenerate

    assign o_ovr = (dout[DOUT_WIDTH-1] != din[DIN_WIDTH-1]) | i_ovr; // Overflow if sign isn't equal
endmodule