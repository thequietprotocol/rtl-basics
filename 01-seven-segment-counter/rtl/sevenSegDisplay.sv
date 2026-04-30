// sevenSegDisplay.sv

// ########## Counting, Display Refresh and Multiplexing ##########

module display_7seg#(
    parameter int TICK_PERIOD    = 100_000_000,  // count tick (1 Hz @ 100 MHz)
    parameter int REFRESH_BIT_HI = 18,           // mux uses [HI:HI-1]
    parameter int REFRESH_BIT_LO = 17
)(
    input logic clk, 
    input logic reset, 
    input logic upDown,
    output logic [3:0] anode,
    output logic [7:0] cathode 
);

// Counters
logic [3:0] count0, count1, count2, count3, curr_digit;
logic [3:0] en;
logic [2:0] wrap_around;

oneHz #(.PERIOD(TICK_PERIOD)) tick(.clk(clk), .reset(reset), .oneSec(en[0]));

hexUpDownCounter c0(.clk(clk), .reset(reset), .enable(en[0]), .upDown(upDown), .count(count0));
hexUpDownCounter c1(.clk(clk), .reset(reset), .enable(en[1]), .upDown(upDown), .count(count1));
hexUpDownCounter c2(.clk(clk), .reset(reset), .enable(en[2]), .upDown(upDown), .count(count2));
hexUpDownCounter c3(.clk(clk), .reset(reset), .enable(en[3]), .upDown(upDown), .count(count3));
assign wrap_around[0] = ((upDown && count0 == 4'hf) || (!upDown && count0 == 4'd0));
assign wrap_around[1] = ((upDown && count1 == 4'hf) || (!upDown && count1 == 4'd0));
assign wrap_around[2] = ((upDown && count2 == 4'hf) || (!upDown && count2 == 4'd0));

//bcdUpDownCounter c0(.clk(clk), .reset(reset), .enable(en[0]), .upDown(upDown), .count(count0));
//bcdUpDownCounter c1(.clk(clk), .reset(reset), .enable(en[1]), .upDown(upDown), .count(count1));
//bcdUpDownCounter c2(.clk(clk), .reset(reset), .enable(en[2]), .upDown(upDown), .count(count2));
//bcdUpDownCounter c3(.clk(clk), .reset(reset), .enable(en[3]), .upDown(upDown), .count(count3));
//assign wrap_around[0] = ((upDown && count0 == 4'd9) || (!upDown && count0 == 4'd0));
//assign wrap_around[1] = ((upDown && count1 == 4'd9) || (!upDown && count1 == 4'd0));
//assign wrap_around[2] = ((upDown && count2 == 4'd9) || (!upDown && count2 == 4'd0));

assign en[1] = wrap_around[0] && en[0];
assign en[2] = wrap_around[1] && en[1];
assign en[3] = wrap_around[2] && en[2];

// Display
logic [REFRESH_BIT_HI:0] led_refresh_counter;

always_ff @(posedge clk) begin
    if(reset) led_refresh_counter <= 0;
    else led_refresh_counter <= led_refresh_counter + 1;
end

// Refresh rate > 60 Hz
// Using last 2 bits of 19-bit counter -> 100 MHz / 2^18 ~= 95 Hz

always_comb begin
  case(led_refresh_counter[REFRESH_BIT_HI:REFRESH_BIT_LO])
        'd0: begin anode = 'b1110; curr_digit = count0; end
        'd1: begin anode = 'b1101; curr_digit = count1; end
        'd2: begin anode = 'b1011; curr_digit = count2; end
        'd3: begin anode = 'b0111; curr_digit = count3; end
    endcase
end

hex_to_7seg hss(.hex(curr_digit), .dp('b0), .led_pattern(cathode));

// synthesis translate off
assert property (@(posedge clk) disable iff(reset)
  anode inside {4'b1110, 4'b1101, 4'b1011, 4'b0111});
//synthesis translate on


endmodule

// ########## End of Counting, Display Refresh and Multiplexing ##########
