// hexCounter.sv

// ########## Counter ##########

module hexUpDownCounter(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic upDown, // 1 - up, 0 - down
    output logic [3:0] count
);

    always_ff @(posedge clk) begin
        if(reset) count <= 0;
        else if(enable) begin
            if(upDown) count <= count + 1;  // Wraps after 0xF
            else count <= count - 1;   // Wraps after 0x0
        end
    end

endmodule

// ########## End of Counter ##########