

module pe #(
    parameter int DATA_WIDTH = 8,  // Q 1.7
    parameter int ACC_WIDTH  = 20  // Q 6.14
)(
    input  logic clk, rst,

    input  logic                          weight_load,
    input  logic signed [DATA_WIDTH-1:0]  weight_in,

    input  logic                          valid_in,
    input  logic signed [DATA_WIDTH-1:0]  a_in,
    input  logic signed [ACC_WIDTH-1:0]   psum_in,

    output logic                          valid_out,
    output logic signed [DATA_WIDTH-1:0]  a_out,
    output logic signed [ACC_WIDTH-1:0]   psum_out
);

logic signed [DATA_WIDTH-1:0] weight_in_reg;
logic signed [ACC_WIDTH-1:0] psum_in_reg; 
logic signed [DATA_WIDTH-1:0] a_in_reg;
logic valid_reg;
logic signed [DATA_WIDTH-1:0] a_out_reg; // 2nd reg to align with psum_out

always_ff @(posedge clk) begin
    if(rst) begin 
        a_in_reg <= '0;
        valid_reg <= '0;
        psum_in_reg <= '0;
    end else begin
        valid_reg <= valid_in;
        if(valid_in) begin
            a_in_reg <= a_in;
            psum_in_reg <= psum_in;
        end
    end
end

always_ff @(posedge clk) begin
    if(rst) weight_in_reg <= '0;
    else if(weight_load) weight_in_reg <= weight_in;
end

logic valid_reg2;
logic signed [ACC_WIDTH-1:0] psum_in_reg2;
logic signed [2*DATA_WIDTH-1:0] prod_reg;

always_ff @(posedge clk) begin
    if(rst) begin
        psum_in_reg2 <= '0;
        valid_reg2 <= '0;
        prod_reg <= '0;
    end else begin
        valid_reg2 <= valid_reg;
        if(valid_reg) begin
            psum_in_reg2 <= psum_in_reg;
            prod_reg <= weight_in_reg * a_in_reg;
        end
    end
end

logic signed [ACC_WIDTH-1:0] sum;
logic ovf;

assign sum  = psum_in_reg2 + prod_reg;
assign ovf  = (psum_in_reg2[ACC_WIDTH-1] == prod_reg[2*DATA_WIDTH-1]) && (sum[ACC_WIDTH-1] != psum_in_reg2[ACC_WIDTH-1]);

localparam logic signed [ACC_WIDTH-1:0] MAX_ACC = {1'b0, {(ACC_WIDTH-1){1'b1}}};
localparam logic signed [ACC_WIDTH-1:0] MIN_ACC = {1'b1, {(ACC_WIDTH-1){1'b0}}};

always_ff @(posedge clk) begin
    if(rst) begin
        psum_out <= '0;
        a_out_reg <= '0;
        valid_out <= '0;
    end else begin
        valid_out <= valid_reg2;
        if(valid_reg2) begin
            psum_out <= ovf ? (psum_in_reg2[ACC_WIDTH-1] ? MIN_ACC : MAX_ACC) : sum;
            a_out_reg <= a_in_reg;
        end
    end
end

assign a_out = a_out_reg;

endmodule