module tb_debounce;

logic clk;
logic rst;
logic btn;
logic db_delay;
logic db_early;

delay_debounce #(.TICK_TIME(50), .SYS_CLK(10)) delay_dut (.db(db_delay), .*);
early_debounce #(.TICK_TIME(50), .SYS_CLK(10)) early_dut (.db(db_early), .*);

always begin
  clk = 1'b0; #5;
  clk = 1'b1; #5;
end

initial begin
  @(negedge clk) rst = 1'b1; btn = 1'b0;
  @(negedge clk) rst = 1'b0;
  #100;

  // press: bounce burst, then settles high
  btn = 1'b1; #8;
  btn = 1'b0; #7;
  btn = 1'b1; #6;
  btn = 1'b0; #9;
  btn = 1'b1; #7;
  btn = 1'b0; #6;
  btn = 1'b1;          // settles high
  #500;                // sustained press

  // release: bounce burst, then settles low
  btn = 1'b0; #8;
  btn = 1'b1; #7;
  btn = 1'b0; #6;
  btn = 1'b1; #9;
  btn = 1'b0; #7;
  btn = 1'b1; #6;
  btn = 1'b0;          // settles low
  #500;                // sustained release

  $finish;
end

endmodule
