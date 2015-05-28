create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

create_clock -period 10000.000 -name comm_clk -waveform {0.000 5000.000} [get_ports comm_clk]
