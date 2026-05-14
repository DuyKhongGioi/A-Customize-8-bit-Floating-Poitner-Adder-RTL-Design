module close_path_4bit (
    input wire [3:0] fraca_c,
    input wire [3:0] fracb_c,
    input wire [3:0] exp_large,
    input wire one_d,
    output wire [3:0] frac_ans_close,
    output wire [3:0] exp_ans_close
);
    wire [3:0] a, b_aligned;
    wire guard;
    wire [3:0] x, y;
    wire [4:0] w, wp1;
    wire cout;
    wire [1:0] dlop;
    wire y_corr;
    wire [2:0] shift_amt;
    wire [4:0] sum_selected;
    wire [3:0] magnitude;
    wire bshin;
    wire [4:0] shift_in_reg;
    wire [4:0] shifted_res;
    wire result_is_zero;
    wire [4:0] normalized;
    wire [2:0] total_shift;
    
    assign a = fraca_c;
    assign b_aligned = (one_d == 1'b1) ? {1'b0, fracb_c[3:1]} : fracb_c;
    assign guard = (one_d == 1'b1) ? fracb_c[0] : 1'b0;
    
    assign x = a;
    assign y = ~b_aligned;
    
    compound_adder u_compound (
        .x(x), .y(y), .w(w), .wp1(wp1)
    );
    
    lop u_lop (
        .a(a), .b(b_aligned), .d(dlop), .y(y_corr)
    );
    
    assign cout = w[4];
    
    // --- ĐÃ SỬA LỖI TẠI ĐÂY ---
    // Chọn wp1 nếu A >= B (cout=1), ngược lại chọn w nếu A < B (cout=0)
    assign sum_selected = cout ? wp1 : w;
    assign magnitude = cout ? sum_selected[3:0] : ~sum_selected[3:0];
    // --------------------------
    
    assign shift_amt = {1'b0, dlop} + {2'b00, y_corr};
    assign bshin = sum_selected[4] & guard;
    assign shift_in_reg = {magnitude, bshin};
    assign shifted_res = shift_in_reg << shift_amt;
    assign result_is_zero = (shifted_res == 5'b00000);
    
    wire [2:0] extra_shift;
    wire [4:0] temp_shift;
    
    assign extra_shift = shifted_res[4] ? 3'd0 :
                         shifted_res[3] ? 3'd1 :
                         shifted_res[2] ? 3'd2 :
                         shifted_res[1] ? 3'd3 :
                         shifted_res[0] ? 3'd4 : 3'd0;
                         
    assign temp_shift = shifted_res << extra_shift;
    assign normalized = result_is_zero ? 5'b00000 : temp_shift;
    assign total_shift = shift_amt + extra_shift;
    assign frac_ans_close = normalized[4:1];
    
    wire [4:0] exp_temp = {1'b0, exp_large} - {2'b00, total_shift};
    assign exp_ans_close = result_is_zero ? 4'b0000 :
                           (exp_temp[4] == 1'b1) ? 4'b0000 : exp_temp[3:0];
endmodule