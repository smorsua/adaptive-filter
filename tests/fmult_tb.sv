`timescale 1ns/1ps

module fmult_tb();

    localparam WIDTH = 16;
    localparam FRAC = 7;

    reg [WIDTH-1:0] i_multiplicand;
    reg [WIDTH-1:0] i_multiplier;
    reg i_ovr;
    reg [WIDTH-1:0] o_result;
    reg o_ovr;

    fmult #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) dut (
        .i_multiplicand(i_multiplicand),
        .i_multiplier(i_multiplier),
        .i_ovr(i_ovr),
        .o_result(o_result),
        .o_ovr(o_ovr)
    );

    initial begin
        // Load input vector
        static int fvector = $fopen("../matlab/data/test_vector.txt", "r");
        int code;
        
        bit [WIDTH-1:0] a[$], b[$], res[$];
        bit [WIDTH-1:0] a_temp, b_temp, res_temp;

        if(!fvector) begin
            $display("Error opening file");
            $stop();
        end

        while(1) begin
            code = $fscanf(fvector, "%d %d %d", a_temp, b_temp, res_temp);
            if(code == 0 || code == -1) begin
                break;    
            end

            a.push_back(a_temp);
            b.push_back(b_temp);
            res.push_back(res_temp);
        end

        $fclose(fvector);
        
        i_ovr = 0;

        for(int i = 0; i < a.size(); i++) begin
            i_multiplicand = a[i];
            i_multiplier = b[i];
            #10;

            if(o_result == res[i]) begin
                $display("Success row %d", i);
            end else begin
                $display("Failure: model %b sim %b", res[i], o_result);
            end
        end

        $stop();
    end

endmodule