module float_adder_8bit_top (
    input wire clk,
    input wire rst_n,
    input wire [7:0] opa,
    input wire [7:0] opb,
    output reg [7:0] add,
    output reg overflow,
    output reg underflow
);
    reg [7:0] opa_r, opb_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            opa_r <= 8'b0;
            opb_r <= 8'b0;
        end else begin
            opa_r <= opa;
            opb_r <= opb;
        end
    end
    
    wire sign_a = opa_r[7];
    wire sign_b = opb_r[7];
    wire [3:0] exp_a = opa_r[6:3];
    wire [3:0] exp_b = opb_r[6:3];
    
    wire is_a_zero = (exp_a == 4'b0000);
    wire is_b_zero = (exp_b == 4'b0000);
    wire exp_a_nonzero = (exp_a != 4'b0000);
    wire exp_b_nonzero = (exp_b != 4'b0000);
    
    wire [3:0] frac_a = {exp_a_nonzero, opa_r[2:0]};
    wire [3:0] frac_b = {exp_b_nonzero, opb_r[2:0]};
    wire swap;
    wire [3:0] d_raw;
    
    ediff_module u_ediff (
        .e1(exp_a),
        .e2(exp_b),
        .sign(swap),
        .ab_diff(d_raw)
    );
    
    wire effective_swap = is_a_zero ? 1'b1 : (is_b_zero ? 1'b0 : swap);
    wire [3:0] exp_large = (effective_swap == 1'b1) ? exp_b : exp_a;
    wire [3:0] fraca_c = (effective_swap == 1'b1) ? frac_b : frac_a;
    wire [3:0] fracb_c = (effective_swap == 1'b1) ? frac_a : frac_b;
    wire sign_large = (effective_swap == 1'b1) ? sign_b : sign_a;
    wire sub = sign_a ^ sign_b;
    wire is_close = (sub == 1'b1) && (d_raw <= 4'd1);
    
    wire [3:0] frac_far, frac_close;
    wire [3:0] exp_far, exp_close;
    
    far_path_4bit u_far (
        .fraca_c(fraca_c),
        .fracb_c(fracb_c),
        .exp_large(exp_large),
        .d(d_raw),
        .sub(sub),
        .frac_ans_far(frac_far),
        .exp_ans_far(exp_far)
    );
    
    close_path_4bit u_close (
        .fraca_c(fraca_c),
        .fracb_c(fracb_c),
        .exp_large(exp_large),
        .one_d(d_raw[0]),
        .frac_ans_close(frac_close),
        .exp_ans_close(exp_close)
    );
    
    wire [3:0] m_fin = (is_close == 1'b1) ? frac_close : frac_far;
    wire [3:0] e_fin = (is_close == 1'b1) ? exp_close : exp_far;
    wire result_is_zero = (e_fin == 4'b0000) && (m_fin == 4'b0000);
    
    // --- ĐÃ SỬA LỖI TẠI ĐÂY ---
    // Fix lỗi ngược dấu khi 2 số cùng E nhưng phần Frac của số A lại nhỏ hơn B
    wire true_sign = (is_close && d_raw == 4'd0 && fraca_c < fracb_c) ? ~sign_large : sign_large;
    wire final_sign;
    
    assign final_sign = result_is_zero ? 1'b0 :
                        (is_a_zero ? sign_b :
                        (is_b_zero ? sign_a : true_sign));
    // --------------------------
                        
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            add <= 8'b0;
            overflow <= 1'b0;
            underflow <= 1'b0;
        end else begin
            if (is_a_zero && is_b_zero) begin
                add <= 8'b0;
                underflow <= 1'b1;
            end else if (is_a_zero) begin
                add <= opb_r;
                overflow <= (exp_b == 4'b1111);
                underflow <= (exp_b == 4'b0000);
            end else if (is_b_zero) begin
                add <= opa_r;
                overflow <= (exp_a == 4'b1111);
                underflow <= (exp_a == 4'b0000);
            end else begin
                add <= {final_sign, e_fin, m_fin[2:0]};
                overflow <= (e_fin == 4'b1111);
                underflow <= (e_fin == 4'b0000);
            end
        end
    end
endmodule