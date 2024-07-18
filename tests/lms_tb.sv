virtual class load_file #(parameter WIDTH, parameter TAPS=1);
    typedef bit [WIDTH-1:0] sampleQueue[$]; 
    typedef bit [TAPS-1:0][WIDTH-1:0] matrixQueue[$];

    static function automatic sampleQueue load_vector(string filepath);
        int fvector = $fopen(filepath, "r");
        bit [WIDTH-1:0] q[$];

        if(fvector == 0) begin
            $fatal();
        end

        while(1) begin
            bit [WIDTH-1:0] val;
            int code = $fscanf(fvector, "%d", val);
            if(code == 0 || code == -1) begin
                break;    
            end

            q.push_back(val);
        end
        $fclose(fvector);
        return q;
    endfunction

    //FIXME: hardcoded 2 taps
    static function automatic matrixQueue load_matrix(string filepath);
        int fmatrix = $fopen(filepath, "r");
        bit [TAPS-1:0][WIDTH-1:0] q1[$];

        if(fmatrix == 0) begin
            $fatal();
        end

        while(1) begin
            bit [WIDTH-1:0] val1, val2;
            int code = $fscanf(fmatrix, "%d %d", val1, val2);
            if(code == 0 || code == -1) begin
                break;    
            end

            q1.push_back({val2, val1});
        end

        $fclose(fmatrix);
        return q1;
    endfunction
endclass

module lms_tb;
    localparam WIDTH = 32;
    localparam FRAC = 25;
    localparam TAPS = 2;

    reg [TAPS-1:0][WIDTH-1:0] din;
    reg [WIDTH-1:0] error;
    reg [WIDTH-1:0] step_size;
    reg [TAPS-1:0][WIDTH-1:0] weights;
    wire [TAPS-1:0][WIDTH-1:0] next_weights;

    lms #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .TAPS(TAPS)
    ) my_lms (
        .din(din),
        .error(error),
        .step_size(step_size),
        .curr_weights(weights),
        .next_weights(next_weights),
        .next_weights_ovr()
    );

    initial begin
        static int fvector = $fopen("../matlab/data/test_vector.txt", "r");
        bit [TAPS-1:0][WIDTH-1:0] din_q[$], weights_q[$], next_weights_q[$];
        bit [WIDTH-1:0] error_q[$], step_size_q[$];

        error_q = load_file#(WIDTH)::load_vector("../matlab/data/error_vector.txt");
        step_size_q = load_file#(WIDTH)::load_vector("../matlab/data/step_size_vector.txt");

        din_q = load_file#(WIDTH,TAPS)::load_matrix("../matlab/data/din_vector.txt");
        weights_q = load_file#(WIDTH,TAPS)::load_matrix("../matlab/data/weights_vector.txt");
        next_weights_q = load_file#(WIDTH,TAPS)::load_matrix("../matlab/data/next_weights_vector.txt");

        for(int i = 0; i < din_q.size(); i++) begin
            din = din_q[i];
            error = error_q[i];
            step_size = step_size_q[i];
            weights = weights_q[i];

            #10;

            if(next_weights == next_weights_q[i]) begin
                $display("Success row %d", i);
            end else begin
                $display("Failure: model %b sim %b", next_weights_q[i], next_weights);
            end
        end

        $stop();

    end
endmodule