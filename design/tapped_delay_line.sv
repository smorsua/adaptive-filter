module tapped_delay_line #(
    parameter WIDTH=16,
    parameter DEPTH=2
) (
    input clk,
    input rstn,
    input [WIDTH-1:0] din,
    output reg [DEPTH-1:0][WIDTH-1:0] tapped_delay);

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            tapped_delay <= 0;
        else begin
            // Update in reverse to avoid overwriting values
            for(int i = DEPTH-1; i > 0; i--) begin
                tapped_delay[i] <= tapped_delay[i-1];
            end
            tapped_delay[0] <= din;
        end
    end
    
endmodule