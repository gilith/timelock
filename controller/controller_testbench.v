`include "controller.v"

`define N 20108222225304591643804177582210255459222589123951340007
`define RINV 19116105088315915078035382064413323571495285781564373460

module main;
    reg clk;

    wire tx_serial;
    wire rx_serial;

    controller root (
        .clk (clk),
        .comm_clk (clk),
        .tx_serial (rx_serial),
        .rx_serial (tx_serial)
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

    reg [7:0] b;
    reg [367:0] x = 0;
    reg [367:0] y = 0;

    wire [183:0] ys = y[183:0];
    wire [183:0] yc = y[367:184];

    reg [400:0] spec = 0;
    reg [400:0] ckt = 0;

    initial begin
        clk = 0;

        x = 2;
        $display("MSG: loading x values.");
        repeat (92) begin
            wait (tx_ready);
            new_putbyte = 1;
            putbyte = {x[3:0], root.LOAD};
            #10 new_putbyte = 0;

            wait (new_getbyte);
            b = getbyte;
            if (b[3:0] != root.ACKLOAD) begin
                $display("FAIL: expected ACKLOAD, got: %b", b);
                $finish;
            end
            x = {4'b0, x[367:4]};
            #100;
        end

        wait (tx_ready);
        new_putbyte = 1;
        putbyte = {4'd0, root.COMPUTE};
        #10 new_putbyte = 0;
        $display("MSG: waiting for ACKCOMPUTE.");

        wait (new_getbyte);
        b = getbyte;
        if (b[3:0] != root.ACKCOMPUTE) begin
            $display("FAIL: expected ACKCOMPUTE, got: %b", b);
            $finish;
        end
        #100;

        $display("MSG: reading y values.");
        repeat (92) begin
            wait (tx_ready);
            new_putbyte = 1;
            putbyte = {4'd0, root.LOAD};
            #10 new_putbyte = 0;

            wait (new_getbyte);
            b = getbyte;
            if (b[3:0] != root.ACKLOAD) begin
                $display("FAIL: expected ACKLOAD, got: %b", b);
                $finish;
            end
            y = {b[7:4], y[367:4]};
            #100;
        end

        spec = (2 * `RINV) % `N;
        repeat(1000) spec = (spec * spec) % `N;
        ckt = ((ys + 2 * yc) * `RINV) % `N;

        if (ckt == spec) begin
            $display("Test passed.");
        end else begin
            $display("ckt = %d", ckt);
            $display("spec = %d", spec);
        end

        $finish;
    end

    always
        #5 clk = ~clk;

endmodule
