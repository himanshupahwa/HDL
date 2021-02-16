module carry_select_adder
(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output reg [3:0] sum,
    output reg[3:0] carry
);

wire [3:0] temp1, temp2, carry_temp1, carry_temp2;

full_adder full_adder_00(a[0], b[0], 1'b0, temp1[0], carry_temp1[0]);
full_adder full_adder_01(a[1], b[1], carry_temp1[0], temp1[1], carry_temp1[1]);
full_adder full_adder_02(a[2], b[2], carry_temp1[0], temp1[2], carry_temp1[2]);
full_adder full_adder_03(a[3], b[3], carry_temp1[0], temp1[3], carry_temp1[3]);


full_adder full_adder_10(a[0], b[0], 1'b1, temp2[0], carry_temp2[0]);
full_adder full_adder_11(a[1], b[1], carry_temp2[0], temp2[1], carry_temp2[1]);
full_adder full_adder_12(a[2], b[2], carry_temp2[0], temp2[2], carry_temp2[2]);
full_adder full_adder_13(a[3], b[3], carry_temp2[0], temp2[3], carry_temp2[3]);


multiplexer_2 mux_sum[3] ( temp1, temp2, cin, sum  );
multiplexer_2 mux_carry ( carry_temp1[3], carry_temp2[3], cin, cout  );

endmodule