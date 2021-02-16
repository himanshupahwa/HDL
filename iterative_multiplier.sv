module iterative_multiplier
#(parameter MULTSIZE = 64)
(product,ready,multiplier,multiplicand,start,clk); //P
   input [MULTSIZE-1:0]  multiplier, multiplicand;
   input         start, clk;
   output        product;
   output        ready;

   localparam LEVEL = clog2(MULTSIZE) - 1;
   reg [2*MULTSIZE-1:0]    product;

   reg [MULTSIZE-1:0]    multiplier_copy;
   reg [2*MULTSIZE-1:0]    multiplicand_copy;
   
   reg [LEVEL:0]     bit; 
   wire          ready = !bit;
   
   initial bit = 0;

   always @( posedge clk )
   begin
     if( ready && start ) begin

        bit               = MULTSIZE;
        product           = 0;
        multiplicand_copy = { MULTSIZE'd0, multiplicand };
        multiplier_copy   = multiplier;
        
     end else if( bit ) begin

        if( multiplier_copy[0] == 1'b1 ) product = product + multiplicand_copy;

        multiplier_copy = multiplier_copy >> 1;
        multiplicand_copy = multiplicand_copy << 1;
        bit = bit - 1;

     end
   end

endmodule