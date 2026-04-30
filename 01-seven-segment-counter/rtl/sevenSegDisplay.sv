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
    input logic bcdHex,
    output logic [3:0] anode,
    output logic [7:0] cathode 
);

// Counters
logic [3:0] bcd_count0, bcd_count1, bcd_count2, bcd_count3;
logic [3:0] hex_count0, hex_count1, hex_count2, hex_count3;
logic [3:0] curr_digit;
logic [3:0] bcd_en, hex_en;
logic [2:0] bcd_wrap_around, hex_wrap_around;
logic oneHz_tick;

oneHz #(.PERIOD(TICK_PERIOD)) tick(.clk(clk), .reset(reset), .oneSec(oneHz_tick));

bcdUpDownCounter bc0(.clk(clk), .reset(reset), .enable(bcd_en[0]), .upDown(upDown), .count(bcd_count0));
bcdUpDownCounter bc1(.clk(clk), .reset(reset), .enable(bcd_en[1]), .upDown(upDown), .count(bcd_count1));
bcdUpDownCounter bc2(.clk(clk), .reset(reset), .enable(bcd_en[2]), .upDown(upDown), .count(bcd_count2));
bcdUpDownCounter bc3(.clk(clk), .reset(reset), .enable(bcd_en[3]), .upDown(upDown), .count(bcd_count3));

assign bcd_wrap_around[0] = ((upDown && bcd_count0 == 4'd9) || (!upDown && bcd_count0 == 4'd0));
assign bcd_wrap_around[1] = ((upDown && bcd_count1 == 4'd9) || (!upDown && bcd_count1 == 4'd0));
assign bcd_wrap_around[2] = ((upDown && bcd_count2 == 4'd9) || (!upDown && bcd_count2 == 4'd0));

assign bcd_en[0] = oneHz_tick && bcdHex;
assign bcd_en[1] = bcd_wrap_around[0] && bcd_en[0];
assign bcd_en[2] = bcd_wrap_around[1] && bcd_en[1];
assign bcd_en[3] = bcd_wrap_around[2] && bcd_en[2];

hexUpDownCounter hc0(.clk(clk), .reset(reset), .enable(hex_en[0]), .upDown(upDown), .count(hex_count0));
hexUpDownCounter hc1(.clk(clk), .reset(reset), .enable(hex_en[1]), .upDown(upDown), .count(hex_count1));
hexUpDownCounter hc2(.clk(clk), .reset(reset), .enable(hex_en[2]), .upDown(upDown), .count(hex_count2));
hexUpDownCounter hc3(.clk(clk), .reset(reset), .enable(hex_en[3]), .upDown(upDown), .count(hex_count3));

assign hex_wrap_around[0] = ((upDown && hex_count0 == 4'hf) || (!upDown && hex_count0 == 4'd0));
assign hex_wrap_around[1] = ((upDown && hex_count1 == 4'hf) || (!upDown && hex_count1 == 4'd0));
assign hex_wrap_around[2] = ((upDown && hex_count2 == 4'hf) || (!upDown && hex_count2 == 4'd0));

assign hex_en[0] = oneHz_tick && !bcdHex;
assign hex_en[1] = hex_wrap_around[0] && hex_en[0];
assign hex_en[2] = hex_wrap_around[1] && hex_en[1];
assign hex_en[3] = hex_wrap_around[2] && hex_en[2];

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
        'd0: begin anode = 'b1110; curr_digit = bcdHex? bcd_count0: hex_count0; end
        'd1: begin anode = 'b1101; curr_digit = bcdHex? bcd_count1: hex_count1; end
        'd2: begin anode = 'b1011; curr_digit = bcdHex? bcd_count2: hex_count2; end
        'd3: begin anode = 'b0111; curr_digit = bcdHex? bcd_count3: hex_count3; end
    endcase
end

hex_to_7seg hss(.hex(curr_digit), .dp('b0), .led_pattern(cathode));

// synthesis translate_off
assert property (@(posedge clk) disable iff(reset)
  anode inside {4'b1110, 4'b1101, 4'b1011, 4'b0111});
//synthesis translate_on

endmodule

// ########## End of Counting, Display Refresh and Multiplexing ##########
