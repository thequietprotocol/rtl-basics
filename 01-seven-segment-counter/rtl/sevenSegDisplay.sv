// sevenSegDisplay.sv

// ########## Counting, Display Refresh and Multiplexing ##########

module display_7seg#(
    parameter int TICK_PERIOD    = 100_000_000,  // count tick (1 Hz @ 100 MHz)
    parameter int REFRESH_BIT_HI = 18,           // mux uses [HI:HI-1]
    parameter int REFRESH_BIT_LO = 17
)(
    input logic clk, 
    input logic reset, 
    output logic [3:0] anode,
    output logic [7:0] cathode 
);

// Counters
logic [3:0] count0, count1, count2, count3, curr_digit;
logic [3:0] en;

oneHz #(.PERIOD(TICK_PERIOD)) tick(.clk(clk), .reset(reset), .oneSec(en[0]));

//hexUpCounter c0(.clk(clk), .reset(reset), .enable(en[0]), .count(count0));
//hexUpCounter c1(.clk(clk), .reset(reset), .enable(en[1]), .count(count1));
//hexUpCounter c2(.clk(clk), .reset(reset), .enable(en[2]), .count(count2));
//hexUpCounter c3(.clk(clk), .reset(reset), .enable(en[3]), .count(count3));
//assign en[1] = (count0 == 'hf) && en[0];
//assign en[2] = (count1 == 'hf) && en[1];
//assign en[3] = (count2 == 'hf) && en[2];

bcdUpCounter c0(.clk(clk), .reset(reset), .enable(en[0]), .count(count0));
bcdUpCounter c1(.clk(clk), .reset(reset), .enable(en[1]), .count(count1));
bcdUpCounter c2(.clk(clk), .reset(reset), .enable(en[2]), .count(count2));
bcdUpCounter c3(.clk(clk), .reset(reset), .enable(en[3]), .count(count3));
assign en[1] = (count0 == 'd9) && en[0];
assign en[2] = (count1 == 'd9) && en[1];
assign en[3] = (count2 == 'd9) && en[2];

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
