Specialized hardware to open the crypto timelock puzzle described at

http://people.csail.mit.edu/rivest/lcs35-puzzle-description.txt

The repo is organized into the following directories:

_______________________________________________________________________________
doc/

This directory contains a description of the crypto timelock puzzle,
and copies of the GPL and MIT licenses. The repo is distributed under
the MIT license with the exception of the uart directory, which is
distributed under the GPL license.

_______________________________________________________________________________
montgomery/

This directory contains a Verilog module called timelock_9 that
computes x^(2^(10^9)) mod np, where n is the 2,046-bit modulus used in
the crypto timelock puzzle and p is a 58-bit checksum prime number.
The computation uses Montgomery multiplication, so each modular
squaring takes only 2,136 cycles. This directory also contains a
Verilog module test_timelock_3 that computes x^(2^(10^3)) mod mp,
where m is a 127-bit number, which can be used for testing.

_______________________________________________________________________________
uart/

This directory contains Verilog modules implementing a universal
asynchronous receiver/transmitter (UART), which allows the hardware to
communicate with the user over USB.

_______________________________________________________________________________
controller/

This directory contains a Verilog main controller module that
instantiates the montgomery and uart modules. The controller receives
single byte commands from the user to load an input number into the
circuit, perform the computation, and return the result number. To
support this operation the controller maintains an internal state and
a register.

Commands:

LOAD a: Rotate the register right, inserting the argument a into the
leftmost 4 bits and returning the rightmost 4 bits b in the byte
ACKLOAD b.

COMPUTE: Start the computation using the value in the register, wait
for it to signal completion, and copy the result back into the
register. At this point return the byte ACKCOMPUTE.

_______________________________________________________________________________
