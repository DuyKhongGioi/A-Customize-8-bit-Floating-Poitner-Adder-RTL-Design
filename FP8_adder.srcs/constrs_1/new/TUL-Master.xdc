# Định nghĩa Clock 100MHz (Chu kỳ = 10.000 ns)
# Tham số -waveform {0.000 5.000} nghĩa là duty cycle 50% (mức cao 5ns, mức thấp 5ns)
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]