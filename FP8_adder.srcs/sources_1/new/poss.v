module poss (
    input zl, pl, nl, yl, zr, pr, nr, yr, 
    output z, p, n, y
);
    assign z = zl & zr;
    assign p = (zl & pr) | (pl & zr);
    assign n = nl | (zl & nr);
    assign y = yl | (zl & yr) | (pl & nr);
endmodule