module transposed_fir_tb();
    localparam WIDTH = 16;
    localparam FRAC = 7;
    localparam TAPS = 4;

    reg clk;
    reg rstn;
    reg [WIDTH-1:0] din;
    reg [TAPS-1:0][WIDTH-1:0] coeffs;
    wire [WIDTH-1:0] dout;

    transposed_fir #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .TAPS(TAPS)
    ) my_fir(
        .clk(clk),
        .rstn(rstn),
        .din(din),
        .coeffs(coeffs),
        .dout(dout)
    );

    // Clock
    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        integer fin, fout, fcoeff;
        string coeff_file;
        clk = 0;
        rstn = 1;
        din = 0;

        // void'($value$plusargs("coeffs=%s", coeff_file));
        coeff_file = "../matlab/data/coeffs.txt";
        fcoeff = $fopen(coeff_file, "r");
        for(integer i = 0; i < TAPS; i++) begin
            reg [WIDTH-1:0] coeff;
            void'($fscanf(fcoeff, "%d", coeff));
            coeffs[i] = coeff; 
        end

        for(integer i = 0; i < TAPS; i++) begin
            $display("%d", coeffs[i]);    
        end

        reset_fir();

        fin = $fopen("../matlab/data/input.txt", "r");
        fout = $fopen("../matlab/data/output.txt", "w");
        
        fork
            // Input signal
            for(integer i = 0; i < 2000; i++) begin
                reg [WIDTH-1:0] sample;
                void'($fscanf(fin, "%d", sample));
                next_sample(sample);
            end

            // Monitor
            for(integer i = 0; i < 2000; i++) begin
                @(posedge clk);
                $fwrite(fout, $sformatf("%0d\n", $signed(dout)));
            end
        join

        $stop();
    end

    task reset_fir();
        begin
            rstn = 0;
            @(posedge clk);
            rstn = 1;
        end
    endtask

    task next_sample(input [WIDTH-1:0] data_in);
        begin 
            din = data_in;
            @(posedge clk);
        end
    endtask
endmodule