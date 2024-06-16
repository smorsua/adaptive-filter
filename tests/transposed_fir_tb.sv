module transposed_fir_tb();
    localparam DIN_WIDTH = 16;
    localparam DOUT_WIDTH = 16;
    localparam TAPS = 8;

    reg clk;
    reg rstn;
    reg [DIN_WIDTH-1:0] din;
    reg [TAPS-1:0][DIN_WIDTH-1:0] coeffs;
    wire [DOUT_WIDTH-1:0] dout;

    transposed_fir #(
        .DIN_WIDTH(DIN_WIDTH),
        .DOUT_WIDTH(DOUT_WIDTH),
        .TAPS(TAPS)
    ) my_fir(
        .clk(clk),
        .rstn(rstn),
        .din(din),
        .coeffs(coeffs),
        .dout(dout)
    );

    // Dump waves
    initial begin
        $dumpfile("dump.fst");
        $dumpvars();
    end

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

        $value$plusargs("coeffs=%s", coeff_file);
        fcoeff = $fopen(coeff_file, "r");
        for(integer i = 0; i < TAPS; i++) begin
            reg [DIN_WIDTH-1:0] coeff;
            $fscanf(fcoeff, "%x", coeff);
            coeffs[i] = coeff; 
        end

        for(integer i = 0; i < TAPS; i++) begin
            $display("%x", coeffs[i]);    
        end

        reset_fir();

        fin = $fopen("./matlab/input.txt", "r");
        fout = $fopen("./output.txt", "w");
        fork
            // Input signal
            for(integer i = 0; i < 1000; i++) begin
                reg [DIN_WIDTH-1:0] sample;
                $fscanf(fin, "%d", sample);
                next_sample(sample);
            end

            // Monitor
            for(integer i = 0; i < 1000; i++) begin
                @(posedge clk);
                $fwrite(fout, $sformatf("%0d\n", $signed(dout)));
            end
        join

        $finish();
    end

    task reset_fir();
        begin
            rstn = 0;
            @(posedge clk);
            rstn = 1;
        end
    endtask

    task next_sample(input [DIN_WIDTH-1:0] data_in);
        begin 
            din = data_in;
            @(posedge clk);
        end
    endtask
endmodule