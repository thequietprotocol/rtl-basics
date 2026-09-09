// Positive Edge Detection

module edge_detect (
    input clk, 
    input rst,
    input level,
    output edge
);

typedef enum logic [1:0] {low, edge, high} state_t;
state_t curr_state, next_state;

always_ff @(posedge clk) begin
    if(rst) curr_state <= low;
    else curr_state <= next_state;
end

always_comb begin
    case(curr_state)
        low: next_state = level? edge: low;
        edge: next_state = level? high: low;
        high: next_state = level? high: low;
        default: next_state = low;
    endcase
end

assign edge = (curr_state == edge);

endmodule
