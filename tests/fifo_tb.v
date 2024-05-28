module fifo_tb();
    localparam WIDTH = 16;
    localparam DEPTH = 4;

    reg clk;
    reg rstn;
    reg [WIDTH-1:0] din;
    wire [WIDTH-1:0] dout;

    fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) my_fifo(
        .clk(clk),
        .rstn(rstn),
        .din(din),
        .dout(dout)
    );

    initial begin
        $dumpfile("test.vcd");
        $dumpvars();
    end

    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        clk = 0;
        rstn = 1;
        din = 0;

        reset_fifo();
        fifo_push(1);
        $display(dout);
        fifo_push(2);
        $display(dout);
        fifo_push(3);
        $display(dout);
        
        $finish();
    end

    task reset_fifo();
        begin
            rstn = 0;
            @(posedge clk);
            rstn = 1;
        end
    endtask

    task fifo_push(input [WIDTH-1:0] data_in);
        begin 
            din = data_in;
            @(posedge clk);
        end
    endtask
endmodule