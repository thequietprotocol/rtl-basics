// fifo.sv

// ########## FIFO ##########

module sync_fifo#(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 16 
)(
    input logic clk, 
    input logic reset,
    input logic read_en, 
    input logic write_en, 
    input logic [DATA_WIDTH-1:0] data_in, 
    output logic [DATA_WIDTH-1:0] data_out, 
    output logic full, 
    output logic empty
);

logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

logic [$clog2(DEPTH)-1:0] read_ptr;
logic [$clog2(DEPTH)-1:0] write_ptr;
logic [$clog2(DEPTH):0] count; 
logic write_valid;
logic read_valid;

always_ff @(posedge clk) begin
    if(reset) begin
        read_ptr <= 'h0;
        write_ptr <= 'h0;
        count <= 'h0;
        data_out <= 'h0;
    end else begin
        if(read_valid) begin
            data_out <= fifo_mem[read_ptr];
            read_ptr <= (read_ptr == DEPTH - 1)? '0 : read_ptr + 'd1;
        end
        if(write_valid) begin
            fifo_mem[write_ptr] <= data_in;
            write_ptr <= (write_ptr == DEPTH - 1)? '0 : write_ptr + 'd1;
        end
        case({read_valid, write_valid})
            2'b00: count <= count;  // No operation
            2'b01: count <= count + 'd1;  // Write
            2'b10: count <= count - 'd1;  // Read
            2'b11: count <= count;  // Simultaneous Read and Write
        endcase
    end

end

assign empty = (count == 0);
assign full = (count == DEPTH);
assign read_valid = (!empty && read_en);
assign write_valid = (!full && write_en);

endmodule

// ########## End of FIFO ##########