// bcd_counter.sv

// ########## Counter ##########

module bcdUpDownCounter(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic upDown,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin
        if(reset) count <= 4'd0;
        else if(enable) begin
          if(upDown) count <= (count == 4'd9)? 4'd0: count + 4'd1; 
          else count <= (count == 4'd0)? 4'd9: count - 4'd1;
        end
    end

    // synthesis translate_off
    assert property (@(posedge clk) disable iff(reset) 
        count inside {[0:9]}
    ) else $error("BCD out of range: %0d", count);

    assert property (@(posedge clk) disable iff(reset)
        (enable && upDown && count == 4'd9) |=> (count == 4'd0)
    ) else $error("BCD counter did not wrap around 9 -> 0, got 0%d", count);

    assert property (@(posedge clk) disable iff(reset)
        (enable && !upDown && count == 4'd0) |=> (count == 4'd9)
    ) else $error("BCD down: did not wrap 0->9, got %0d", count);
    // synthesis translate_on

endmodule

// ########## End of Counter ##########