module far_path_4bit (
    input wire [3:0] fraca_c,
    input wire [3:0] fracb_c,
    input wire [3:0] exp_large,
    input wire [3:0] d,
    input wire sub,
    output wire [3:0] frac_ans_far,
    output wire [3:0] exp_ans_far
);
    wire [3:0] a, b;
    wire gb, rb, sb;
    wire [3:0] x, y;
    wire gy, ry, sy;
    wire g, r, s;
    wire [4:0] w, wp1;
    wire cout, msb, l, l_1;
    wire sel_add, sel_sub, sel_spl;
    wire bshin;
    wire sft_rt, sft_left;
    wire [4:0] rounded;
    reg [3:0] final_frac;
    reg [3:0] final_exp;
    
    assign a = fraca_c;
    wire [6:0] shifter_out;
    
    barrel_shifter_4bit u_shifter (
        .i(fracb_c),
        .sftamt(d),
        .o(shifter_out)
    );
    
    assign b = shifter_out[6:3];
    assign gb = shifter_out[2];
    assign rb = shifter_out[1];
    assign sb = shifter_out[0];
    
    assign x = a;
    assign y = sub ? ~b : b;
    assign gy = sub ? ~gb : gb;
    assign ry = sub ? ~rb : rb;
    assign sy = sub ? ~sb : sb;
    
    assign g = sub ? (gy | (ry & sy)) : gy;
    assign r = sub ? (ry | sy) : ry;
    assign s = sub ? (~sy) : sy;
    
    compound_adder u_compound (
        .x(x), .y(y), .w(w), .wp1(wp1)
    );
    
    assign cout = w[4];
    assign msb = w[3];
    assign l_1 = w[1];
    assign l = w[0];
    
    assign sel_add = (~sub) & (
        ((~cout) & (g & (l | r | s))) |
        (cout & (l & (l_1 | g | r | s)))
    );
    
    assign sel_sub = cout & (
        sub & (
            ((~g) & (~r) & (~s)) |
            (g & r) |
            (msb & (g & (l | s)))
        )
    );
    
    assign sel_spl = sel_add | sel_sub;
    assign bshin = cout & (((~g) & r & s) | (g & (~r)));
    wire [4:0] raw_sum = sel_spl ? wp1 : w;
    assign rounded = raw_sum;
    
    assign sft_rt = cout & (~sub);
    assign sft_left = (~msb) & sub;
    
    always @(*) begin
        if (sft_rt) begin
            final_frac = rounded[4:1];
            final_exp = exp_large + 1;
        end else if (sft_left) begin
            final_frac = {rounded[2:0], bshin};
            final_exp = exp_large - 1;
        end else begin
            final_frac = rounded[3:0];
            final_exp = exp_large;
        end
    end
    
    assign frac_ans_far = final_frac;
    assign exp_ans_far = final_exp;
endmodule