// oneHertz.sv

// ########## One Hertz Counter ##########

module oneHz#(
    parameter int PERIOD = 100_000_000  // 1 Hz @ 100 MHz; override for simulation
)(
    input logic clk,
    input logic reset, 
    output logic oneSec
);

// For a clock of 100 MHz
logic [$clog2(PERIOD)-1: 0] counter;

always_ff @(posedge clk) begin
    if(reset | counter == PERIOD-1) counter <= 'd0;
    else counter <= counter + 1;
end

always_ff @(posedge clk) begin
    if(reset) oneSec <= 0;
    else if(counter == PERIOD-1) oneSec <= 1;
    else oneSec <= 0;
end

endmodule

// ########## End of One Hertz Counter ##########
