
module early_debounce #(
    parameter TICK_TIME = 10_000_000, // (in ns)
    parameter SYS_CLK = 10 // (ns)
)(
    input logic clk,
    input logic rst,
    input logic btn,
    output logic db
);

localparam CLK_COUNT = TICK_TIME / SYS_CLK;
logic poll_tick;

modulo_count #(.COUNT(CLK_COUNT)) ticker (
    .clk(clk),
    .rst(rst),
    .q_count(),
    .max_tick(poll_tick)
);

typedef enum logic [2:0] {zero, press, wait1_0, wait2_0, one, unpress, wait1_1, wait2_1} state_t;
state_t curr_state, next_state;

always_ff @(posedge clk) begin
    if(rst) curr_state <= zero;
    else curr_state <= next_state;
end

always_comb begin
    next_state = curr_state;
    case(curr_state)
        zero:    if(btn) next_state = press;
        press:   if(poll_tick) next_state = wait1_0; // wait 0 to TICK_TIME
        wait1_0: if(poll_tick) next_state = wait2_0; // wait TICK_TIME
        wait2_0: if(poll_tick) next_state = (btn)? one: zero; // wait TICK_TIME
        
        one:     if(!btn) next_state = unpress;
        unpress: if(poll_tick) next_state = wait1_1;
        wait1_1: if(poll_tick) next_state = wait2_1;
        wait2_1: if(poll_tick) next_state = (!btn)? zero: one;

        default: next_state = zero;
    endcase
end

always_ff @(posedge clk) begin
    if(rst) db <= '0;
    else begin
        case(next_state)
            zero: db <= '0;
            press: db <= 1'b1;
            wait1_0: db <= 1'b1;
            wait2_0: db <= 1'b1;
            one: db <= 1'b1;
            unpress: db <= '0;
            wait1_1: db <= '0;
            wait2_1: db <= '0;
            default: db <= '0;
        endcase
    end
end

endmodule