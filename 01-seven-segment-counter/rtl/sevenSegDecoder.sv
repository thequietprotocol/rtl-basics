// seven_seg.sv

// ########## 4-to-7 decoder for 7-Segment Display ##########

module hex_to_7seg(
    input logic [3:0] hex,
    input logic dp,
    output logic [7:0] led_pattern
);

// LED Patterns: 01(0), 4f(1), 12(2), 06(3), 4f(4), 24(5), 20(6), 0f(7), 00(8), 04(9), 02(a), 60(b), 31(c), 42(d), 10(e), 38(f)

always_comb begin
    case(hex)
        'h0: led_pattern = 'b000_0001;
        'h1: led_pattern = 'b100_1111;
        'h2: led_pattern = 'b001_0010;
        'h3: led_pattern = 'b000_0110;
        'h4: led_pattern = 'b100_1100;
        'h5: led_pattern = 'b010_0100;
        'h6: led_pattern = 'b010_0000;
        'h7: led_pattern = 'b000_1111;
        'h8: led_pattern = 'b000_0000;
        'h9: led_pattern = 'b000_0100;
        'ha: led_pattern = 'b000_0010;
        'hb: led_pattern = 'b110_0000;
        'hc: led_pattern = 'b011_0001;
        'hd: led_pattern = 'b100_0010;
        'he: led_pattern = 'b001_0000;
        'hf: led_pattern = 'b011_1000;
        default: led_pattern = 'b001_1000; // default(P)
    endcase

    led_pattern[7] = dp;

end

endmodule

// ########## End of 4-to-7 decoder for 7-Segment Display ##########