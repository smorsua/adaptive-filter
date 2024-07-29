module fadd #(
    parameter WIDTH=16,
    parameter FRAC=15
) (
    input [WIDTH-1:0] i_a,
    input [WIDTH-1:0] i_b,
    output [WIDTH-1:0] o_res,
    output reg o_ovr
);
    assign o_res = i_a + i_b;

    always_comb begin
        if(!i_a[WIDTH-1] && !i_b[WIDTH-1] && o_res[WIDTH-1]) begin // Both numbers positive and result negative
            o_ovr = 1'b1;
        end else if(i_a[WIDTH-1] && i_b[WIDTH-1] && !o_res[WIDTH-1]) begin // Both numbers negative and result positive
            o_ovr = 1'b1;
        end else begin
            o_ovr = 1'b0;
        end
    end
endmodule