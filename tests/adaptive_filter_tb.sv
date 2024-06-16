module adaptive_filter_tb();
    localparam WIDTH = 16;
    localparam FRAC = 15;
    localparam TAPS = 1;

    reg clk;
    reg rstn;
    reg [WIDTH-1:0] din;
    reg [WIDTH-1:0] desired;
    reg [WIDTH-1:0] error;
    wire [WIDTH-1:0] dout;
    reg [WIDTH-1:0] step_size;
    wire [TAPS-1:0][WIDTH-1:0] weights;

    adaptive_filter #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .TAPS(TAPS)
    ) my_filter (
        .clk(clk),
        .rstn(rstn),
        .din(din),
        .desired(desired),
        .step_size(step_size),
        .dout(dout),
        .error(error),
        .weights(weights)
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
        step_size = 'd3276;

        fin = $fopen("C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\input.txt", "r");
        fout = $fopen(".\\output.txt", "w");

        reset_fir();

        fork
            // Input signal
            for(integer i = 0; i < 1000; i++) begin
                reg [WIDTH-1:0] sample;
                void'($fscanf(fin, "%d", sample));
                next_sample(sample);
            end

            // Monitor
            for(integer i = 0; i < 1000; i++) begin
                @(posedge clk);
                void'($fwrite(fout, $sformatf("%0d\n", $signed(dout))));
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