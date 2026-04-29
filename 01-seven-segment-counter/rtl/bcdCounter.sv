// bcd_counter.sv

// ########## Counter ##########

module bcdUpCounter(
    input logic clk,
    input logic reset,
    input logic enable,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin
        if(reset) count <= 'd0;
        else if(enable) begin
          if(count == 'd9) count <= 'd0;
          else count <= count + 'd1; 
        end
    end

    // synthesis translate_off
    assert property (@(posedge clk) disable iff(reset) 
        count inside {[0:9]}
    ) else $error("BCD out of range: %0d", count);

    assert property (@(posedge clk) disable iff(reset)
        (enable && count == 'd9) |=> (count == 'd0)
    ) else $error("BCD counter did not wrap around 9 -> 0, got 0%d", count);
    // synthesis translate_on

endmodule

// ########## End of Counter ##########