module preencoder_float8 (
    input wire [3:0] a,
    input wire [3:0] b,
    output wire [3:0] f,
    output wire [3:0] np,
    output wire [3:0] pp,
    output wire [3:0] zp,
    output wire [3:0] nn,
    output wire [3:0] pn,
    output wire [3:0] zn
);
    wire [3:0] e, g, s;
    wire [3:0] x, y, u, v;
    
    assign g = a & ~b;
    assign s = ~a & b;
    assign e = ~((a & ~b) | (~a & b));
    
    genvar i;
    generate
        for (i = 3; i >= 1; i = i - 1) begin : gen_xyuv_high
            assign x[i] = g[i] & ~s[i-1];
            assign y[i] = s[i] & ~g[i-1];
            assign u[i] = s[i] & ~s[i-1];
            assign v[i] = g[i] & ~g[i-1];
        end
    endgenerate
    
    assign x[0] = g[0];
    assign y[0] = s[0];
    assign u[0] = s[0];
    assign v[0] = g[0];
    
    generate
        for (i = 2; i >= 0; i = i - 1) begin : gen_f_low
            assign f[i] = (e[i+1]) ? (x[i] | y[i]) : (u[i] | v[i]);
        end
    endgenerate
    
    assign f[3] = x[3] | y[3];
    assign np[3] = s[3];
    assign np[2] = e[3] & s[2];
    assign np[1] = e[2] & s[1];
    assign np[0] = e[1] & s[0];
    
    assign pp = (u | x) & ~np;
    assign zp = ~(np | pp);
    
    assign pn[3] = g[3];
    assign pn[2] = e[3] & g[2];
    assign pn[1] = e[2] & g[1];
    assign pn[0] = e[1] & g[0];
    
    assign nn = (y | v) & ~pn;
    assign zn = ~(nn | pn);
endmodule