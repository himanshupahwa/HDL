module ripple_carry_adder
(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output reg [3:0] sum,
    output reg cout
);


reg [3:0] carry_array = {1'b0,1'b0,1'b0,cin}

full_adder full_adder_0
                (
                    .a(a[0]),
                    .b(b[0]),
                    .cin(cin),
                    .sum(sum[0]),
                    .cout(carry_out[0])
                );

full_adder full_adder_1
                (
                    .a(a[1]),
                    .b(b[1]),
                    .cin(carry_out[0]),
                    .sum(sum[1]),
                    .cout(carry_array[1]
                );
                       

full_adder full_adder_2
                (
                    .a(a[2]),
                    .b(b[2]),
                    .cin(carry_out[1]),
                    .sum(sum[2]),
                    .cout(carry_out[2])
                );

full_adder full_adder_3
                (
                    .a(a[3]),
                    .b(b[3]),
                    .cin(carry_out[2]),
                    .sum(sum[3]),
                    .cout(carry_array[3]
                );

endmodule