`timescale 1ns / 1ps

module tb_float_adder_8bit();

    // Inputs
    reg clk;
    reg rst_n;
    reg [7:0] opa;
    reg [7:0] opb;

    // Outputs
    wire [7:0] add;
    wire overflow;
    wire underflow;

    // Instantiate the Unit Under Test (UUT)
    float_adder_8bit_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .opa(opa),
        .opb(opb),
        .add(add),
        .overflow(overflow),
        .underflow(underflow)
    );

    // Tạo xung Clock (Chu kỳ 10ns -> Tần số 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Task hỗ trợ tự động bơm test case và kiểm tra kết quả
    task test_add;
        input [7:0] a;
        input [7:0] b;
        input [7:0] expected;
        begin
            opa = a;
            opb = b;
            
            // Bộ cộng có pipeline 2 tầng, cần đợi 2-3 nhịp clock để kết quả xuất ra
            @(posedge clk); // Đưa dữ liệu vào thanh ghi đầu vào (opa_r, opb_r)
            @(posedge clk); // Thực hiện phép cộng, lưu vào thanh ghi đầu ra (add)
            @(posedge clk); // Lấy mẫu kết quả ngõ ra để so sánh
            
            if (add === expected) begin
                $display("[PASS] %h + %h = %h", a, b, add);
            end else begin
                $display("[FAIL] %h + %h = %h (Kỳ vọng: %h)", a, b, add, expected);
            end
        end
    endtask

    // Kịch bản mô phỏng chính
    initial begin
        // Khởi tạo trạng thái ban đầu
        rst_n = 0;
        opa = 8'h00;
        opb = 8'h00;

        // Giữ reset trong 100ns
        #100;
        rst_n = 1;
        @(posedge clk);

        $display("=== BAT DAU MO PHONG BO CONG FP8 ===");
        $display("Dinh dang: 1 bit Sign, 4 bit Exp (Bias=7), 3 bit Frac");
        $display("-----------------------------------------------------");

        // Test 1: 0.0 + 0.0 = 0.0
        // 0.0 = 8'h00
        test_add(8'h00, 8'h00, 8'h00);

        // Test 2: 1.0 + 1.0 = 2.0 (Kiểm tra Normalize và tăng Exponent)
        // 1.0 = 0_0111_000 = 8'h38
        // 2.0 = 0_1000_000 = 8'h40
        test_add(8'h38, 8'h38, 8'h40);

        // Test 3: 1.5 + 1.5 = 3.0 
        // 1.5 = 0_0111_100 = 8'h3C
        // 3.0 = 0_1000_100 = 8'h44
        test_add(8'h3C, 8'h3C, 8'h44);

        // Test 4: -1.0 + 1.0 = 0.0 (Kiểm tra Close path triệt tiêu nhau hoàn toàn)
        // -1.0 = 1_0111_000 = 8'hB8
        test_add(8'hB8, 8'h38, 8'h00);

        // Test 5: KIỂM TRA LỖI SAI DẤU VỪA FIX
        // A = 1.0  (8'h38)
        // B = -1.5 (8'hBC) -> Cùng số mũ Exp=7, nhưng Frac khác nhau, trái dấu.
        // A + B = 1.0 + (-1.5) = -0.5
        // -0.5 = 1_0110_000 = 8'hB0
        test_add(8'h38, 8'hBC, 8'hB0);

        // Test 6: Đảo vị trí A và B của Test 5
        // -1.5 + 1.0 = -0.5
        test_add(8'hBC, 8'h38, 8'hB0);

        // Test 7: 2.0 + 1.0 = 3.0 (Kiểm tra Far path: hai số lệch nhau số mũ)
        // 2.0 = 0_1000_000 = 8'h40
        // 1.0 = 0_0111_000 = 8'h38
        test_add(8'h40, 8'h38, 8'h44);

        $display("-----------------------------------------------------");
        $display("=== KET THUC MO PHONG ===");
        
        #50;
        $finish; // Kết thúc mô phỏng
    end

endmodule