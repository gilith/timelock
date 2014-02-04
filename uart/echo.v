// Simple top-level module to test the uart modules.
module echo (
    input clk,

    output tx_serial,
    input rx_serial
);

    wire tx_ready;
    reg new_putbyte = 0;
    reg [7:0] putbyte;

	uart_transmitter uart_tx (
		.clk (clk),
		.uart_tx (tx_serial),
		.rx_new_byte (new_putbyte),
		.rx_byte (putbyte),
		.tx_ready (tx_ready)
	);

    wire new_getbyte;
    wire [7:0] getbyte;

    uart_receiver uart_rx (
        .clk (clk),
        .uart_rx (rx_serial),
        .tx_new_byte (new_getbyte),
        .tx_byte (getbyte)
    );

    always @(posedge clk)
    begin
        new_putbyte <= 0;
        if (new_getbyte)
        begin
            if (tx_ready)
            begin
                new_putbyte <= 1;
                putbyte <= getbyte;
            end
        end
    end

endmodule
