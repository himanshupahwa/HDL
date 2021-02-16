module full_adder
(
    input a,
    input b,
    input cin,
    output reg sum,
    output reg cout
);

    wire ha1_sum, ha1_carry;
    wire ha2_sum, ha2_carry;
    half_adder ha1
                (
                    .a(a),
                    .b(b),
                    .sum(ha1_sum),
                    .cout(ha1_carry)
                );
    
    half_adder ha2_carry
                (
                    .a(cin),
                    .b(ha1_sum),
                    .sum(ha2_sum),
                    .cout(ha2_carry)
                );

    assign sum = ha2_sum;
    assign cout = ha1_carry1 | ha2_carry;
endmodule