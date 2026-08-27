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
logic full_reg;
logic empty_reg;

// Write
always_ff @(posedge clk) begin
    if(write_en && !full_reg) fifo_mem[write_ptr] <= data_in;
end

// Read
assign data_out = fifo_mem[read_ptr];

logic [$clog2(DEPTH)-1:0] read_ptr_succ, write_ptr_succ;
assign read_ptr_succ  = (read_ptr  == DEPTH-1) ? '0 : read_ptr  + 1;
assign write_ptr_succ = (write_ptr == DEPTH-1) ? '0 : write_ptr + 1;

// Pointers and Status Registers
always_ff @(posedge clk) begin
    if(reset) begin
        write_ptr <= '0;
        read_ptr <= '0;
        full_reg <= '0;
        empty_reg <= 1'b1;
    end else begin
        case({write_en, read_en})
            2'b01: // Read
                if(!empty_reg) begin
                    read_ptr <= read_ptr_succ;
                    full_reg <= '0;
                    if(read_ptr_succ == write_ptr) empty_reg <= 1'b1;
                end
            2'b10: // Write
                if(!full_reg) begin
                    write_ptr <= write_ptr_succ;
                    empty_reg <= '0;
                    if(write_ptr_succ == read_ptr) full_reg <= 1'b1;
                end
            2'b11: begin // Write and Read
                write_ptr <= write_ptr_succ;
                read_ptr <= read_ptr_succ;
            end
        endcase
    end
end

// Status Outputs
assign full = full_reg;
assign empty = empty_reg;

endmodule

// ########## End of FIFO ##########