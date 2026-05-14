![](https://s3.hedgedoc.org/hd1-demo/uploads/0f524f26-8ae0-4a82-ac62-816dd10dcc4f.png)

The `float_adder_8bit_top` module implements a pipelined, dual-path floating-point addition/subtraction algorithm. The execution flow is broken down into the following sequential stages:

### 1. Input Registration (Clock Cycle 1)

* **Synchronization:** The 8-bit operands (`opa` and `opb`) are registered into internal flip-flops (`opa_r` and `opb_r`) on the rising edge of the clock or reset asynchronously. This isolates the combinational logic from external timing variations.

### 2. Unpacking & Exception Detection

* **Component Extraction:** The module splits both registered inputs into their respective Sign (1 bit), Exponent (4 bits), and Fraction (3 bits) fields.
* **Implicit Bit Restoration:** A hidden leading bit is appended to the fraction. It is set to `1` if the exponent is non-zero (normalized), and `0` if the exponent is zero (subnormal/zero).
* **Zero Checking:** Flags (`is_a_zero`, `is_b_zero`) are generated to identify if either operand is strictly zero, which bypasses complex arithmetic later.

### 3. Exponent Comparison & Operand Swapping

* **Difference Calculation:** The `ediff_module` computes the absolute difference between the two exponents (`d_raw`) and determines which operand is larger.
* **Data Routing (Swap):** To simplify addition/subtraction, the logic forces the larger number into a standard position (`exp_large`, `fraca_c`). If `opa` is smaller than `opb`, their data paths are internally swapped.
* **Operation Decoding:** The module checks if the operation is an effective subtraction by XORing the sign bits (`sub = sign_a ^ sign_b`).

### 4. Dual-Path Arithmetic Execution

To optimize hardware and reduce latency, the module calculates the result using two parallel datapaths:

* **Far Path (`far_path_4bit`):** Handles all additions, as well as subtractions where the exponent difference is strictly greater than 1. It performs standard alignment (shifting the smaller fraction), addition/subtraction, and basic normalization.
* **Close Path (`close_path_4bit`):** Handles subtractions where the exponent difference is either 0 or 1 (`is_close = 1`). This path is highly optimized for "massive cancellation" scenarios, ensuring rapid normalization when leading bits cancel each other out.

### 5. Path Selection & Sign Correction

* **Multiplexing:** Based on the `is_close` condition, the logic selects the final fraction (`m_fin`) and exponent (`e_fin`) from either the Far Path or the Close Path.
* **Edge-Case Sign Correction:** Calculates the final sign bit. It includes a specific hardware fix (`true_sign`) for a subtraction edge case where both exponents are equal, but Operand A's fraction is smaller than Operand B's, ensuring the sign doesn't flip incorrectly.

### 6. Packing & Output Registration (Clock Cycle 2)

* **Exception Handling:** If both inputs are zero, the output is forced to zero. If only one input is zero, the module directly passes the other operand to the output.
* **Packing:** The final Sign, Exponent, and truncated Fraction (removing the hidden bit) are concatenated into the 8-bit `add` result.
* **Flag Generation:** * `overflow` is triggered if the resulting exponent maxes out (`4'b1111`).
* `underflow` is triggered if the resulting exponent drops to zero (`4'b0000`).


* **Output Sync:** The final data and flags are latched into output registers on the next clock edge.
