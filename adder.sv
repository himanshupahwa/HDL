module adder
#(parameter WORD_WIDTH = 64)
(
    input clk, 
    input reset,
    input [WORD+WIDTH-1:0] a,
    input [WORD+WIDTH-1:0] b,
    output reg [*WORD_WIDTH -1 : 0] result
);

assign result = a + b;

endmodule