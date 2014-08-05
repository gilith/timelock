`include "../montgomery/test_timelock_3.v"
`include "../uart/uart_receiver.v"
`include "../uart/uart_transmitter.v"

module controller (
    input clk,
    input comm_clk,

    output tx_serial,
    input rx_serial
);

    wire tx_ready;
    reg new_putbyte = 0;
    reg [7:0] putbyte;

    uart_transmitter uart_tx (
        .clk (comm_clk),
        .uart_tx (tx_serial),
        .rx_new_byte (new_putbyte),
        .rx_byte (putbyte),
        .tx_ready (tx_ready)
    );

    wire new_getbyte;
    wire [7:0] getbyte;

    uart_receiver uart_rx (
        .clk (comm_clk),
        .uart_rx (rx_serial),
        .tx_new_byte (new_getbyte),
        .tx_byte (getbyte)
    );

    reg [367:0] x = 0;
    wire [183:0] ys;
    wire [183:0] yc;
    wire dn;
    reg ld = 1;

    test_timelock_3 timelock (
        .clk (clk),
        .ld (ld),
        .xs (x[183:0]),
        .xc (x[367:184]),
        .dn (dn),
        .ys (ys),
        .yc (yc)
    );

    parameter
        LOAD = 4'd0,
        ACKLOAD = 4'd1,
        COMPUTE = 4'd2,
        ACKCOMPUTE = 4'd3;

    parameter
        IDLE = 2'd0,
        WAIT = 2'd1,
        WRITE = 2'd2;

    reg [1:0] state = IDLE;
    reg [1:0] state_next = IDLE;
    reg [367:0] x_next = 0;
    reg [7:0] outbyte = 0;

    always @(posedge comm_clk) begin
        state <= state_next;
        x <= x_next;
        new_putbyte <= 0;
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (new_getbyte) begin
                    case (getbyte[3:0])
                        LOAD: begin
                            outbyte = {x[3:0], ACKLOAD};
                            x_next = {getbyte[7:4], x[367:4]};
                            state_next = WRITE;
                        end

                        COMPUTE: begin
                            ld = 0;
                            state_next = WAIT;
                        end
                    endcase
                end
            end

            WAIT: begin
                if (dn) begin
                    x_next[183:0] = ys;
                    x_next[367:184] = yc;
                    outbyte = {4'b0, ACKCOMPUTE};
                    state_next = WRITE;
                end
            end

            WRITE: begin
                if (tx_ready) begin
                    putbyte = outbyte;
                    new_putbyte = 1;
                    state_next = IDLE;
                end
            end
        endcase
    end

endmodule
