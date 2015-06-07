/*----------------------------------------------------------------------------+
| The timelock controller.                                                    |
|                                                                             |
| Copyright (c) 2014 David Lazar and Joe Leslie-Hurd.                         |
| Distributed under the MIT license.                                          |
+----------------------------------------------------------------------------*/

/* `include "../montgomery/test_timelock_3.v" */
/* `include "../uart/uart_receiver.v" */
/* `include "../uart/uart_transmitter.v" */

module controller (
  input clk,
  input comm_clk,
  input rx_serial,
  output tx_serial
);

 wire       tx_ready;
 reg        new_putbyte = 1'b0;
 reg  [7:0] putbyte;

 uart_transmitter uart_tx (
   .clk (comm_clk),
   .uart_tx (tx_serial),
   .rx_new_byte (new_putbyte),
   .rx_byte (putbyte),
   .tx_ready (tx_ready)
 );

 wire       new_getbyte;
 wire [7:0] getbyte;

 uart_receiver uart_rx (
   .clk (comm_clk),
   .uart_rx (rx_serial),
   .tx_new_byte (new_getbyte),
   .tx_byte (getbyte)
 );

 reg          ld = 1'b1;
 reg  [367:0] x;
 wire         dn;
 wire [183:0] ys;
 wire [183:0] yc;

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

always @(posedge comm_clk) begin
   case (state)
     IDLE: begin
        if (new_getbyte) begin
           case (getbyte[3:0])
             LOAD: begin
                ld <= 1'b1;
                x <= {getbyte[7:4], x[367:4]};
                state <= WRITE;
                new_putbyte <= 1'b0;
                putbyte <= {x[3:0], ACKLOAD};
             end

             COMPUTE: begin
                ld <= 1'b0;
                state <= WAIT;
                new_putbyte <= 1'b0;
             end
           endcase
        end
        else begin
           ld <= 1'b1;
           new_putbyte <= 1'b0;
        end
     end

     WAIT: begin
        if (dn) begin
           x[183:0] <= ys;
           x[367:184] <= yc;
           state <= WRITE;
           putbyte <= {4'b0, ACKCOMPUTE};
        end
     end

     WRITE: begin
        if (tx_ready) begin
           state <= IDLE;
           new_putbyte <= 1'b1;
        end
     end
   endcase
end

endmodule
