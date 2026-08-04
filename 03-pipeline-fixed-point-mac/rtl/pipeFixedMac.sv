
module pipeFixedMac #(
    parameter DATA_WIDTH = 8, // Q1.7
    parameter ACC_WIDTH  = 20
)(
    input logic clk, 
    input logic rst, 
    input logic valid_in,
    input logic clear_acc,
    input logic signed [DATA_WIDTH-1:0] a_in,
    input logic signed [DATA_WIDTH-1:0] b_in,
    
    output logic valid_out,
    output logic signed [ACC_WIDTH-1:0] acc_out

);

logic signed [DATA_WIDTH-1:0] a_reg;
logic signed [DATA_WIDTH-1:0] b_reg;
logic valid_reg1, clear_reg1;

always_ff @(posedge clk) begin
    if(rst) begin
        a_reg <= '0;
        b_reg <= '0;
        valid_reg1 <= 'b0;
        clear_reg1 <= 'b0;
    end else begin
        a_reg <= a_in; // unconditional input capture, check valid_reg
        b_reg <= b_in;
        valid_reg1 <= valid_in;
        clear_reg1 <= clear_acc;
    end
end

logic signed [2*DATA_WIDTH-1:0] prod;
logic valid_reg2, clear_reg2;

always_ff @(posedge clk) begin
    if(rst) begin
        prod <= '0;
        valid_reg2 <= 'b0;
        clear_reg2 <= 'b0;
    end else begin
        prod <= a_reg * b_reg;
        valid_reg2 <= valid_reg1;
        clear_reg2 <= clear_reg1;
    end
end

logic signed [ACC_WIDTH-1:0] sum;
logic ovf;
assign sum = acc_out + prod;
assign ovf = (acc_out[ACC_WIDTH-1] == prod[2*DATA_WIDTH-1]) && (sum[ACC_WIDTH-1] != acc_out[ACC_WIDTH-1]);

localparam logic signed [ACC_WIDTH-1:0] MAX_ACC = {1'b0, {(ACC_WIDTH-1){1'b1}}};
localparam logic signed [ACC_WIDTH-1:0] MIN_ACC = {1'b1, {(ACC_WIDTH-1){1'b0}}};

always_ff @(posedge clk) begin
    if(rst) begin
        acc_out <= '0;
        valid_out <= 'b0;
    end else begin
        valid_out <= valid_reg2;
        if(valid_reg2) begin
            if(clear_reg2) acc_out <= prod;
            else if(ovf) acc_out <= acc_out[ACC_WIDTH-1]? MIN_ACC: MAX_ACC;
            else acc_out <= sum;
        end
    end
end

endmodule