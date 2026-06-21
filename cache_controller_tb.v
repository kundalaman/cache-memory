module tb;

    reg clk;
    reg rst;

    reg cpu_read;
    reg cpu_write;

    reg [7:0] cpu_addr;
    reg [31:0] cpu_wdata;

    wire [31:0] cpu_rdata;
    wire stall_cpu;

    // DUT

    cache_controller uut (

        .clk(clk),
        .rst(rst),

        .cpu_read(cpu_read),
        .cpu_write(cpu_write),

        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),

        .cpu_rdata(cpu_rdata),
        .stall_cpu(stall_cpu)

    );
    // clock generation

    always #5 clk = ~clk;

    // simulation

    initial begin

        // waveform dump

        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        // initialize

        clk = 0;
        rst = 1;

        cpu_read = 0;
        cpu_write = 0;
        cpu_addr = 0;
        cpu_wdata = 0;

        // release reset

        #10;
        rst = 0;

        // CPU read request
        #10;
        cpu_read = 1;

        cpu_addr = 8'h24;

        // wait

        #10;

        cpu_read = 0;

        // finish simulation

        #100;

        $finish;

    end

endmodule
