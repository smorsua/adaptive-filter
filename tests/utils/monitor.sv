`ifndef MONITOR_GUARD
`define MONITOR_GUARD

interface monitor_if #(parameter WIDTH) (input clk, input [WIDTH-1:0] signal);
    // logic clk;
    // logic [WIDTH-1:0] signal;
endinterface //monitor_if

class Monitor #(parameter WIDTH);
    int fid;
    virtual monitor_if #(WIDTH) vif;
    event stop_monitoring_e;

    function new(string filepath);
        this.fid = $fopen(filepath, "w");
    endfunction

    task start_monitoring();
        fork
            forever begin
                if(this.stop_monitoring_e.triggered())
                    break;
                @(posedge this.vif.clk);
                void'($fdisplay(fid, "%0d", this.vif.signal));
            end
        join
    endtask

    function void stop_monitoring();
        ->stop_monitoring_e;
        $fclose(this.fid);
    endfunction
endclass

`endif