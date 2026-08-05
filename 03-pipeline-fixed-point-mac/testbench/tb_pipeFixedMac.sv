
module tb_pipeFixedMac;

localparam DATA_WIDTH = 8;
localparam ACC_WIDTH = 20;

logic clk = 0;
logic rst;
logic valid_in;
logic clear_acc;
logic signed [DATA_WIDTH-1:0] a_in, b_in;
logic valid_out;
logic signed [ACC_WIDTH-1:0] acc_out;

always #5 clk = ~clk; // 100 MHz

pipeFixedMac #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) dut (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .clear_acc(clear_acc),
    .a_in(a_in), .b_in(b_in),
    .valid_out(valid_out), .acc_out(acc_out)
);

int expected_q[$];
int check_count = 0;
localparam int NUM_EXPECTED = 13;

task automatic basic_accumulate();
    @(negedge clk) a_in = 5; b_in = 10; clear_acc = 1; valid_in = 1;
    expected_q.push_back(50);
    @(negedge clk) a_in = 10; clear_acc = 0;
    expected_q.push_back(150);
    @(negedge clk) a_in = -5;
    expected_q.push_back(100);
    @(negedge clk) a_in = 20;
    expected_q.push_back(300);
    @(negedge clk) a_in = -15;
    expected_q.push_back(150);
    @(negedge clk) a_in = 8;
    expected_q.push_back(230);
endtask

task automatic back_to_back();
    @(negedge clk) a_in = 9; b_in = 2; clear_acc = 1; valid_in = 1;
    expected_q.push_back(18);
    @(negedge clk) b_in = 3; clear_acc = 0;
    expected_q.push_back(45);
    @(negedge clk) b_in = -4;
    expected_q.push_back(9);
    @(negedge clk) b_in = -5;
    expected_q.push_back(-36);
    @(negedge clk) valid_in = 0;  
endtask

task automatic pipe_bubble();
    @(negedge clk) a_in = 4; b_in = 5; clear_acc = 1; valid_in = 1;
    expected_q.push_back(20);
    @(negedge clk) a_in = 7; valid_in = 0; 
    @(negedge clk) a_in = 5; clear_acc = 0; valid_in = 1;
    expected_q.push_back(45);
    @(negedge clk) a_in = -7;
    expected_q.push_back(10);
    @(negedge clk) valid_in = 0;  
endtask

initial begin
    rst = 1; repeat(2) @(negedge clk); rst = 0;
    basic_accumulate();
    back_to_back();
    pipe_bubble();
end

always @(posedge clk) begin
    #1;
    if (valid_out) begin
        int exp_val;
        exp_val = expected_q.pop_front();
        if(acc_out != exp_val)
            $error("FAIL @ %0t: expected=%0d actual=%0d", $time, exp_val, acc_out);
        else
            $display("PASS @ %0t: acc_out=%0d", $time, acc_out);
        check_count++;
        if(check_count == NUM_EXPECTED) begin
            $display("All %0d checks complete.", NUM_EXPECTED);
            $finish;
        end
    end
end

endmodule