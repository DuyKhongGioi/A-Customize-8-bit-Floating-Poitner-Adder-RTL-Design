module neg (
    input zl, pl, nl, yl, zr, pr, nr, yr, 
    output z, p, n, y
);
    assign z = zl & zr;
    assign n = (zl & nr) | (nl & zr);
    assign p = pl | (zl & pr);
    assign y = yl | (zl & yr) | (nl & pr);
endmodule