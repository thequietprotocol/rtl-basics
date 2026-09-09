
module modulo_count #(
    parameter COUNT = 10
)(
    input logic clk, 
    input logic rst, 
    output logic [$clog2(COUNT)-1:0] q_count,
    output logic max_tick
);

always_ff @(posedge clk) begin
    if(rst) begin
        max_tick <= '0;
        q_count <= '0;
    end else if(q_count == COUNT - 1) begin
        max_tick <= 1'b1;
        q_count <= '0;
    end else begin
        max_tick <= '0;
        q_count <= q_count + 1;
    end
end
