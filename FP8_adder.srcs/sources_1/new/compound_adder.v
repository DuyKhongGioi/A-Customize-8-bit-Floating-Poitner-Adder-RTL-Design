module compound_adder (
    input wire [3:0] x,
    input wire [3:0] y,
    output wire [4:0] w,
    output wire [4:0] wp1
);
    // Tính toán đồng thời tổng w và w+1 (Dùng cho cả Far path và Close path)
    assign w = x + y;
    assign wp1 = x + y + 1;
endmodule