`include "./utils/monitor.sv"

module adaptive_filter_tb();
    localparam WIDTH = 32;
    localparam FRAC = 20;
    localparam TAPS = 2;

    reg clk;
    reg rstn;
    reg signed [WIDTH-1:0] din;
    reg signed [WIDTH-1:0] desired;
    reg signed [WIDTH-1:0] error;
    wire signed [WIDTH-1:0] dout;
    reg [WIDTH-1:0] step_size;
    wire [TAPS-1:0][WIDTH-1:0] weights;
    wire o_ovr;

    adaptive_filter #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .TAPS(TAPS)
    ) my_filter (
        .clk(clk),
        .rstn(rstn),
        .i_din(din),
        .i_desired(desired),
        .i_step_size(step_size),
        .i_ovr(1'b0),
        .o_dout(dout),
        .o_error(error),
        .o_weights(weights),
        .o_ovr(o_ovr)
    );

    // Clock
    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        integer fin, fdes, fout, ferr, fweights, fstep, fweights_evolution;
        string coeff_file;

        clk = 0;
        rstn = 1;
        din = 0;
        desired = 0;

        fin = $fopen("../matlab/data/input.txt", "r");
        fdes = $fopen("../matlab/data/desired.txt", "r");
        fout = $fopen("../matlab/data/output.txt", "w");
        ferr = $fopen("../matlab/data/error.txt", "w");
        fweights = $fopen("../matlab/data/weights.txt", "w");
        fweights_evolution = $fopen("../matlab/data/weights_evolution.txt", "w");
        fstep = $fopen("../matlab/data/step_size.txt", "r");

        void'($fscanf(fstep, "%d", step_size));
        void'($fclose(fstep));

        reset_filter();

        fork
            // Input signal
            for(integer i = 0; i < 1000; i++) begin
                reg [WIDTH-1:0] din_sample;
                reg [WIDTH-1:0] desired_sample;
                void'($fscanf(fin, "%d", din_sample));
                void'($fscanf(fdes, "%d", desired_sample));
                next_sample(din_sample, desired_sample);
            end

            for(integer i = 0; i < 1000; i++) begin
                @(posedge clk);
                void'($fdisplay(fout, "%0d", dout));
                void'($fdisplay(ferr, "%0d", error));
                void'($fdisplay(fweights_evolution, "%0d %0d", weights[0], weights[1]));
            end
        join

        for(int j = 0; j < TAPS; j++) begin
            void'($fdisplay(fweights, "%0d", weights[j]));
        end

        void'($fclose(fin));
        void'($fclose(fdes));
        void'($fclose(fout));
        void'($fclose(ferr));
        void'($fclose(fweights));
        void'($fclose(fweights_evolution));

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