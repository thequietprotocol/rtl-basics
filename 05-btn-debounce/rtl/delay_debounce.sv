
module delay_debounce #(
    parameter TICK_TIME = 10_000_000, // (in ns)
    parameter SYS_CLK = 10 // (in ns)
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

// at least 20 ms depending on how long before a poll_tick button is pressed
typedef enum logic [2:0] {zero, press, wait1_0, wait2_0, one, unpress, wait1_1, wait2_1} state_t;
state_t curr_state, next_state;

always_ff @(posedge clk) begin
    if(rst) curr_state <= zero;
    else curr_state <= next_state;
end

always_comb begin
    next_state = curr_state;
    case(curr_state)
        zero: next_state = btn? press: zero;
        press: begin
            if(btn)
                if(poll_tick) next_state = wait1_0;
                else next_state = press;
            else
                next_state = zero;
        end
        wait1_0: begin
            if(btn)
                if(poll_tick) next_state = wait2_0;
                else next_state = wait1_0;
            else
                next_state = zero;
        end
        wait2_0: begin
            if(btn)
                if(poll_tick) next_state = one;
                else next_state = wait2_0;
            else
                next_state = zero;
        end

        one: next_state = (!btn)? unpress: one;
        unpress: begin
            if(!btn)
                if(poll_tick) next_state = wait1_1;
                else next_state = unpress;
            else
                next_state = one;
        end
        wait1_1: begin
            if(!btn)
                if(poll_tick) next_state = wait2_1;
                else next_state = wait1_1;
            else
                next_state = one;
        end
        wait2_1: begin
            if(!btn)
                if(poll_tick) next_state = zero;
                else next_state = wait2_1;
            else
                next_state = one;
        end

        default: next_state = zero;
    endcase
end

assign db = (curr_state == one) || (curr_state == unpress) || (curr_state == wait1_1) || (curr_state == wait2_1);

endmodule