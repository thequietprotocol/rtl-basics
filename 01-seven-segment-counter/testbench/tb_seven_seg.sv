// tb_seven_seg.sv

module tb_display_7seg;
  logic clk = 0;
  logic reset = 1;
  logic upDown = 1;
  logic bcdHex = 1;
  logic [3:0] anode;
  logic [7:0] cathode;
  
  // With count0 incrementing every 16 cycles, choosing [3:2] refresh bits means each digit is held for 4 cycles at cathode output
  display_7seg #(.TICK_PERIOD(16), .REFRESH_BIT_HI(3), .REFRESH_BIT_LO(2)) dut0 (.clk(clk), .reset(reset), .upDown(upDown), .bcdHex(bcdHex), .anode(anode), .cathode(cathode));
  
  
  always #5 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_display_7seg);
  end
  
  initial begin
    #20 reset = 0;
    #500_000; bcdHex = 0;
    #500_000; upDown = 0;
    #500_000; bcdHex = 1;
    #500_000; $finish;
  end
  
  function automatic string cath_to_hex(input logic [7:0] cath);
    // Compare only the segment bits [6:0]; ignore [7] which is dp
    case (cath[6:0])
        7'h01: return "0";
        7'h4F: return "1";
        7'h12: return "2";
        7'h06: return "3";
        7'h4C: return "4";
        7'h24: return "5";
        7'h20: return "6";
        7'h0F: return "7";
        7'h00: return "8";
        7'h04: return "9";
        7'h02: return "A";
        7'h60: return "B";
        7'h31: return "C";
        7'h42: return "D";
        7'h10: return "E";
        7'h38: return "F";
        7'h18: return "P";  // your default
        default: return "?";
    endcase
endfunction

logic [3:0] c0, c1, c2, c3;
assign c0 = bcdHex ? dut0.bcd_count0 : dut0.hex_count0;
assign c1 = bcdHex ? dut0.bcd_count1 : dut0.hex_count1;
assign c2 = bcdHex ? dut0.bcd_count2 : dut0.hex_count2;
assign c3 = bcdHex ? dut0.bcd_count3 : dut0.hex_count3;

// then in $display use c0..c3
  
  initial begin
    $display("  time | c3 c2 c1 c0 anode cathode");
    forever begin
      @(anode);
        $display("bcdHex=%b dir=%b %h %h %h %h anode=%b cathode=%h (%s)", bcdHex, upDown, c3, c2, c1, c0, dut0.anode, dut0.cathode, cath_to_hex(dut0.cathode));
    end  
  end
  
endmodule