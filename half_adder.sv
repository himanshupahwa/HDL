module half_adder
(
    input a,
    input b,
    output reg sum,
    output reg cout

);

    assign sum = a ^ b ;
    assign cout = a & b;
endmodule