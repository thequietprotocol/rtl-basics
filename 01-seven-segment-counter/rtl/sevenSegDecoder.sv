// seven_seg.sv

// ########## 4-to-7 decoder for 7-Segment Display ##########

module hex_to_7seg(
    input logic [3:0] hex,
    input logic dp,
    output logic [7:0] led_pattern
);

// LED Patterns: 40(0), 79(1), 24(2), 30(3), 19(4), 12(5), 02(6), 78(7), 00(8), 10(9), 20(a), 03(b), 46(c), 21(d), 04(e), 0e(f)
// seg[6:0] = {g, f, e, d, c, b, a}

always_comb begin
    case (hex)
        4'h0: led_pattern = 7'h40;
        4'h1: led_pattern = 7'h79;
        4'h2: led_pattern = 7'h24;
        4'h3: led_pattern = 7'h30;
        4'h4: led_pattern = 7'h19;
        4'h5: led_pattern = 7'h12;
        4'h6: led_pattern = 7'h02;
        4'h7: led_pattern = 7'h78;
        4'h8: led_pattern = 7'h00;
        4'h9: led_pattern = 7'h10;
        4'ha: led_pattern = 7'h20; // a
        4'hb: led_pattern = 7'h03; // b
        4'hc: led_pattern = 7'h46; // c/C
        4'hd: led_pattern = 7'h21; // d
        4'he: led_pattern = 7'h04; // e
        4'hf: led_pattern = 7'h0e; // f
        default: led_pattern = 7'h0c; // p/P
    endcase
    
    led_pattern[7] = dp;
    
end

endmodule

// ########## End of 4-to-7 decoder for 7-Segment Display ##########