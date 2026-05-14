module lod2 (
    input wire a,
    input wire b,
    output wire p,
    output wire v
);
    assign p = ~a & b;
    assign v = a | b;
endmodule