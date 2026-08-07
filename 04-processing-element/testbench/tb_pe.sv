
module tb_pe;

localparam DATA_WIDTH = 8;
localparam ACC_WIDTH = 20;

logic clk = 0;
logic rst;
logic valid_in;
logic weight_load;
logic signed [DATA_WIDTH-1:0] a_in, weight_in;
logic signed [ACC_WIDTH-1:0]   psum_in;

logic valid_out;
logic signed [ACC_WIDTH-1:0] psum_out;
logic signed [DATA_WIDTH-1:0]  a_out;

always #5 clk = ~clk; // 100 MHz

pe #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) dut (
    .clk(clk), .rst(rst),
    .weight_load(weight_load), .weight_in(weight_in),
    .valid_in(valid_in), .a_in(a_in), .psum_in(psum_in),
    .valid_out(valid_out), .a_out(a_out), .psum_out(psum_out)
);

int expected_psum_q[$];
int expected_a_q[$];
int check_count = 0;
localparam int NUM_EXPECTED = 5;

task automatic single_step();
    @(negedge clk) a_in = 5; psum_in = 100; valid_in = 1; weight_load = 0;
    expected_psum_q.push_back(150); expected_a_q.push_back(5);
    @(negedge clk) valid_in = 0; 
endtask

task automatic bubble();
    @(negedge clk) a_in = 4; psum_in = 20; valid_in = 1;
    expected_psum_q.push_back(60); expected_a_q.push_back(4);
    @(negedge clk) valid_in = 0; 
    @(negedge clk) a_in = 6; psum_in = 100; valid_in = 1;
    expected_psum_q.push_back(160); expected_a_q.push_back(6);
    @(negedge clk) valid_in = 0; 
endtask

task automatic overflow_positive();
    @(negedge clk) weight_in = -128; weight_load = 1; valid_in = 0;
    @(negedge clk) weight_load = 0; a_in = -128; psum_in=520000; valid_in = 1;
    expected_psum_q.push_back(524287); expected_a_q.push_back(-128);
    @(negedge clk) valid_in = 0;
endtask

task automatic overflow_negative();
    @(negedge clk) weight_in = 127; weight_load = 1; valid_in = 0;
    @(negedge clk) weight_load = 0; a_in = -128; psum_in=-520000; valid_in = 1;
    expected_psum_q.push_back(-524288); expected_a_q.push_back(-128);
    @(negedge clk) valid_in = 0;
endtask

initial begin
    rst = 1; repeat(2) @(negedge clk); rst = 0;
    @(negedge clk) weight_in = 10; weight_load = 1;
    single_step();
    bubble();
    overflow_positive();
    overflow_negative();
end

always @(posedge clk) begin
    #1;
    if (valid_out) begin
        int exp_psum, exp_a;
        exp_psum = expected_psum_q.pop_front();
        exp_a = expected_a_q.pop_front();
        if(psum_out != exp_psum || a_out != exp_a)
            $error("FAIL @ %0t: expected psum=%0d a=%0d actual psum=%0d a=%0d", $time, exp_psum, exp_a, psum_out, a_out);
        else
            $display("PASS @ %0t: psum_out=%0d a_out=%0d", $time, psum_out, a_out);
        check_count++;
        if(check_count == NUM_EXPECTED) begin
            $display("All %0d checks complete.", NUM_EXPECTED);
            $finish;
        end
    end
end

endmodule