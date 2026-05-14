module ediff_module (
    input wire [3:0] e1,
    input wire [3:0] e2,
    output reg sign,
    output reg [3:0] ab_diff
);
    always @(*) begin
        if (e1 > e2) begin
            ab_diff = e1 - e2;
            sign = 1'b0;
        end else begin
            ab_diff = e2 - e1;
            sign = 1'b1;
        end
    end
endmodule