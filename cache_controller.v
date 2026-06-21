// cpu interface

module cache_controller(

    input clk,
    input rst,
    input cpu_read,
    input cpu_write,

    input [7:0] cpu_addr,
    input [31:0] cpu_wdata,

    output reg [31:0] cpu_rdata,
    output reg stall_cpu
);

// cache array design
// 2-way set associative cache

reg valid [0:3][0:1];
reg dirty [0:3][0:1];

reg [3:0] tag_array [0:3][0:1];
reg [31:0] data_array [0:3][0:1];

// main memory

reg [31:0] memory [0:255];


// address breakdown

wire [1:0] index;
wire [3:0] tag;

assign index = cpu_addr[3:2];
assign tag   = cpu_addr[7:4];

// hit logic

wire hit_way0;
wire hit_way1;

assign hit_way0 =
    valid[index][0] &&
    (tag_array[index][0] == tag);

assign hit_way1 =
    valid[index][1] &&
    (tag_array[index][1] == tag);

// FSM states
parameter IDLE        = 2'b00;
parameter COMPARE_TAG = 2'b01;
parameter WRITE_BACK  = 2'b10;
parameter ALLOCATE    = 2'b11;

reg [1:0] state;

// LRU logic

reg lru [0:3];

reg replace_way;

always @(*) begin

    if(lru[index] == 0)
        replace_way = 1;
    else
        replace_way = 0;

end

// initialize memory

initial begin

    memory[8'h24] = 32'd999; // placing decimal 999 at hexadecimal address 24

end

// main FSM

integer i;
integer j;

always @(posedge clk or posedge rst) begin

    if(rst) begin

        state <= IDLE;

        stall_cpu <= 0;

        // clear cache

        for(i=0; i<4; i=i+1) begin

            for(j=0; j<2; j=j+1) begin

                valid[i][j] <= 0;
                dirty[i][j] <= 0;

            end
        end
    end

    else begin

        case(state)
        IDLE:
        begin

            if(cpu_read || cpu_write) begin

                stall_cpu <= 1;

                state <= COMPARE_TAG;

            end

        end
        COMPARE_TAG:
        begin

            // CACHE HIT WAY0

            if(hit_way0) begin

                cpu_rdata <= data_array[index][0];

                lru[index] <= 0;

                stall_cpu <= 0;

                state <= IDLE;

            end

            // CACHE HIT WAY1

            else if(hit_way1) begin

                cpu_rdata <= data_array[index][1];

                lru[index] <= 1;

                stall_cpu <= 0;

                state <= IDLE;

            end

            // CACHE MISS

            else begin

                if(dirty[index][replace_way])
                    state <= WRITE_BACK;

                else
                    state <= ALLOCATE;

            end

        end

        WRITE_BACK:
        begin

            memory[cpu_addr]
                <= data_array[index][replace_way];

            dirty[index][replace_way]
                <= 0;

            state <= ALLOCATE;

        end

        ALLOCATE:
        begin

            data_array[index][replace_way]
                <= memory[cpu_addr];

            tag_array[index][replace_way]
                <= tag;

            valid[index][replace_way]
                <= 1;

            cpu_rdata <= memory[cpu_addr];

            lru[index] <= replace_way;

            stall_cpu <= 0;

            state <= IDLE;

        end
        endcase

    end

end

endmodule

