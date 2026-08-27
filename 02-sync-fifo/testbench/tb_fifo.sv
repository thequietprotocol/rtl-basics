`timescale 1ns/1ps

module tb_sync_fifo;

localparam DATA_WIDTH = 8;
localparam DEPTH = 5;

logic clk, reset;
logic read_en, write_en;
logic [DATA_WIDTH-1:0] data_in;
logic [DATA_WIDTH-1:0] data_out;
logic full, empty;

sync_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) dut(
    .clk(clk), .reset(reset),
    .read_en(read_en), .write_en(write_en),
    .data_in(data_in), .data_out(data_out),
    .full(full), .empty(empty)
);

always #5 clk = ~clk;

initial begin
    // Initialization
    clk = 0; reset = 1; read_en = 0; write_en = 0; data_in = '0;
    #15; reset = 0;
    
    // Back-to-back Burst Write
    $display("Writing Data...");
    @(negedge clk);
    write_en = 1;
    repeat(DEPTH) begin
        data_in = $random;
        $display("Wrote Data: %0h", data_in);
        @(negedge clk);
    end
    write_en = 0; // Clear write enable

    #20; // Idle gap

    // Back-to-back Burst Read
    $display("Reading Data...");
    @(negedge clk);
    read_en = 1;
    repeat(DEPTH) begin
        @(negedge clk); // Wait for posedge to execute and update data_out
        $display("Read Data: %0h", data_out);
    end
    read_en = 0; // Clear read enable

    #20;
    $finish;
end

endmodule