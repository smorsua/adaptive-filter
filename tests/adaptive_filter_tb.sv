`include "./utils/monitor.sv"

module adaptive_filter_tb();
    localparam WIDTH = 16;
    localparam FRAC = 7;
    localparam TAPS = 2;

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

    monitor_if #(WIDTH) dout_monitor_if(.clk(clk), .signal(dout));
    monitor_if #(WIDTH) error_monitor_if(.clk(clk), .signal(error));

    // Clock
    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        // integer fin, fdes, fout, ferr, fweights;
        integer fin, fdes, fweights;
        string coeff_file;

        Monitor #(WIDTH) dout_mon, error_mon;
        dout_mon = new("../matlab/data/output.txt"); 
        dout_mon.vif = dout_monitor_if;
        error_mon = new("../matlab/data/error.txt");
        error_mon.vif = error_monitor_if;

        clk = 0;
        rstn = 1;
        din = 0;
        desired = 0;
        step_size = 'h003c;

        fin = $fopen("../matlab/data/input.txt", "r");
        fdes = $fopen("../matlab/data/desired.txt", "r");
        // fout = $fopen("../matlab/data/output.txt", "w");
        // ferr = $fopen("../matlab/data/error.txt", "w");
        fweights = $fopen("../matlab/data/weights.txt", "w");

        reset_filter();

        dout_mon.start_monitoring();
        error_mon.start_monitoring();

        // fork
        //     // Input signal
        //     for(integer i = 0; i < 2000; i++) begin
        //         reg [WIDTH-1:0] din_sample;
        //         reg [WIDTH-1:0] desired_sample;
        //         void'($fscanf(fin, "%d", din_sample));
        //         void'($fscanf(fdes, "%d", desired_sample));
        //         next_sample(din_sample, desired_sample);
        //     end

        //     for(integer i = 0; i < 2000; i++) begin
        //         @(posedge clk);
        //         void'($fdisplay(fout, "%0d", dout));
        //         void'($fdisplay(ferr, "%0d", error));
        //     end
        // join

        for(integer i = 0; i < 2000; i++) begin
            reg [WIDTH-1:0] din_sample;
            reg [WIDTH-1:0] desired_sample;
            void'($fscanf(fin, "%d", din_sample));
            void'($fscanf(fdes, "%d", desired_sample));
            next_sample(din_sample, desired_sample);
        end

        dout_mon.stop_monitoring();
        error_mon.stop_monitoring();

        for(int i = 0; i < TAPS; i++) begin
            void'($fdisplay(fweights, "%0d", weights[i]));
        end

        void'($fclose(fin));
        void'($fclose(fdes));
        // void'($fclose(fout));
        // void'($fclose(ferr));
        void'($fclose(fweights));

        $stop();
    end

    task reset_filter();
        begin
            rstn = 0;
            @(posedge clk);
            rstn = 1;
        end
    endtask

    task next_sample(input [WIDTH-1:0] arg_din, input [WIDTH-1:0] arg_desired);
        begin 
            din = arg_din;
            desired = arg_desired;
            @(posedge clk);
        end
    endtask
endmodule