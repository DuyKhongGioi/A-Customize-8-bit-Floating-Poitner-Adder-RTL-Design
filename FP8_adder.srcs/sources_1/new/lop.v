module lop (
    input wire [3:0] a,
    input wire [3:0] b,
    output wire [1:0] d,
    output wire y
);
    wire [3:0] f;
    wire [3:0] np, pp, zp;
    wire [3:0] nn, pn, zn;
    
    preencoder_float8 u_preencoder (
        .a(a), .b(b), .f(f),
        .np(np), .pp(pp), .zp(zp),
        .nn(nn), .pn(pn), .zn(zn)
    );
    
    wire [1:0] p1;
    wire [1:0] v1;
    
    lod2 u_lod2_high (.a(f[3]), .b(f[2]), .p(p1[1]), .v(v1[1]));
    lod2 u_lod2_low  (.a(f[1]), .b(f[0]), .p(p1[0]), .v(v1[0]));
    
    assign d[1] = ~v1[1];
    assign d[0] = v1[1] ? p1[1] : p1[0];
    
    wire z_p1_h, p_p1_h, n_p1_h, y_p1_h;
    wire z_p1_l, p_p1_l, n_p1_l, y_p1_l;
    wire z_p2, p_p2, n_p2, yp_final;
    
    poss u_poss_high (
        .zl(zp[3]), .pl(pp[3]), .nl(np[3]), .yl(1'b0),
        .zr(zp[2]), .pr(pp[2]), .nr(np[2]), .yr(1'b0),
        .z(z_p1_h), .p(p_p1_h), .n(n_p1_h), .y(y_p1_h)
    );
    
    poss u_poss_low (
        .zl(zp[1]), .pl(pp[1]), .nl(np[1]), .yl(1'b0),
        .zr(zp[0]), .pr(pp[0]), .nr(np[0]), .yr(1'b0),
        .z(z_p1_l), .p(p_p1_l), .n(n_p1_l), .y(y_p1_l)
    );
    
    poss u_poss_root (
        .zl(z_p1_h), .pl(p_p1_h), .nl(n_p1_h), .yl(y_p1_h),
        .zr(z_p1_l), .pr(p_p1_l), .nr(n_p1_l), .yr(y_p1_l),
        .z(z_p2), .p(p_p2), .n(n_p2), .y(yp_final)
    );
    
    wire z_n1_h, p_n1_h, n_n1_h, y_n1_h;
    wire z_n1_l, p_n1_l, n_n1_l, y_n1_l;
    wire z_n2, p_n2, n_n2, yn_final;
    
    neg u_neg_high (
        .zl(zn[3]), .pl(pn[3]), .nl(nn[3]), .yl(1'b0),
        .zr(zn[2]), .pr(pn[2]), .nr(nn[2]), .yr(1'b0),
        .z(z_n1_h), .p(p_n1_h), .n(n_n1_h), .y(y_n1_h)
    );
    
    neg u_neg_low (
        .zl(zn[1]), .pl(pn[1]), .nl(nn[1]), .yl(1'b0),
        .zr(zn[0]), .pr(pn[0]), .nr(nn[0]), .yr(1'b0),
        .z(z_n1_l), .p(p_n1_l), .n(n_n1_l), .y(y_n1_l)
    );
    
    neg u_neg_root (
        .zl(z_n1_h), .pl(p_n1_h), .nl(n_n1_h), .yl(y_n1_h),
        .zr(z_n1_l), .pr(p_n1_l), .nr(n_n1_l), .yr(y_n1_l),
        .z(z_n2), .p(p_n2), .n(n_n2), .y(yn_final)
    );
    
    assign y = yp_final | yn_final;
endmodule