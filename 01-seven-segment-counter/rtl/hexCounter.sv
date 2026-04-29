// hexCounter.sv

// ########## Counter ##########

module hexUpCounter(
    input logic clk,
    input logic reset,
    input logic enable,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin
        if(reset) count <= 0;
        else if(enable) count <= count + 1;  // Wraps after 0xF
    end

endmodule

// ########## End of Counter ##########