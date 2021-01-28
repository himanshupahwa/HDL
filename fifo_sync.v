module fifo_sync
#(
	parameter FIFO_WIDTH = 8, 
	parameter FIFO_DEPTH = 32,
    parameter INIT_VAL = 1'b0,
    parameter ALMOST_FULL_THRESHOLD   =  4,
    parameter ALMOST_EMPTY_THRESHOLD   =  1
)
(
	input 			rst,
	input	 		wr_clk,
	input 			wr_enable,
	input 			rd_clk,
	input 			rd_enable,
	input [FIFO_WIDTH-1:0]	wr_data,
	output reg[FIFO_WIDTH-1:0]	rd_data,
	output reg			fifo_full,
        output reg 			fifo_empty,
	output 	reg		fifo_almost_full,
        output reg			fifo_almost_empty
	
);
localparam addr_bits = $clog2(DEPTH); 

(* ramstyle = "M20K" *) reg [0:FIFO_WIDTH-1] ram[0:FIFO_DEPTH]; 

/** reset sync **/
reg rd_rst_pre = INIT_VAL; /* synthesis dont_merge */
reg rd_rst_reg = INIT_VAL; /* synthesis dont_merge */
reg wr_rst_pre = INIT_VAL; /* synthesis dont_merge */
reg wr_rst_reg = INIT_VAL; /* synthesis dont_merge */

always@(posedge rd_clk)
begin
	rd_rst_pre <= rst;
    rd_rst_reg <= rd_rst_pre;
end

always@(posedge wr_clk)
begin
	wr_rst_pre <= rst;
    wr_rst_reg <= wr_rst_pre;
end

/** Read and write pointer sum **/
reg load = 1'b0;
reg invert_b = 1'b0;

(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] read_ptr_sum = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] write_ptr_sum = 0;
(* syn_preserve=1, must_keep= 1*) reg  read_ptr_cout = 0;
(* syn_preserve=1, must_keep= 1*) reg  write_ptr_cout = 0;

// Based on read and write Enable setup read ptr and write ptr sum
always@(*)
    begin
    	{read_ptr_cout, read_ptr_sum} = read_ptr_sum + rd_enable;
        {write_ptr_cout, write_ptr_sum} = write_ptr_sum + wr_enable;
	end

/** Setup write counter **/
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] write_ptr = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] read_ptr = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] read_ptr_not_fwft = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] rd_ptr_wr_clk = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] rd_ptr_static = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] wr_ptr_rd_clk = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] wr_ptr_static = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] rd_level = 0;
(* syn_preserve=1, must_keep= 1*) reg [addr_bits:0] wr_level = 0;
(* syn_preserve=1, must_keep= 1*) reg [5:0] rd_reset_p1 = 0;


always@(posedge wr_clk)
begin
    //  This evaluates write ptr value. It further captures rd ptr on the write clock value.
    // Why is rd ptr on write clock value relevant? this allows us to use rd ptr in evaluating
    // if we can write to fifo or not. We can write to fifo only if full is signal is not high.
    // full means no of elements in fifo = FIFO_DEPTH. Now number of elements can be computed to be 
    // NO OF ELEMENTS IN FIFO = WRITE_LEVEL = {WRITE_PTR - READ_PTR(WR_CLK) + WR_ENABLE} == FIFO_DEPTH
    if(rst)
        begin
            wr_ptr_static <= 0;
            rd_ptr_wr_clk <= 0;
        end
    else //if(wr_token)
        begin
            wr_ptr_static <= write_ptr_sum;
            rd_ptr_wr_clk <= rd_ptr_static;
        end
    
    // This control signal for almost full or full signal
    if(rst)
        begin
            wr_level <= 0;
        end
    else
        begin
            wr_level <= write_ptr - rd_ptr_wr_clk + wr_enable;
        end

    // This snippet maintains the write ptr value
    if(rst)
        begin
            write_ptr <= 0;
        end
    else
        begin
            write_ptr <= write_ptr_sum;
        end
end

    wire [addr_bits:0] almost_full_alu;
    
        assign almost_full_alu = wr_level + ALMOST_FULL_THRESHOLD + 1'b1;

        always@(posedge wr_clk)
            begin  
                if(rst)
                    begin
                        fifo_almost_full <= 0;
                    end
                else
                    begin
                        fifo_almost_full <= almost_full_alu[addr_bits];
                    end
            end

    wire [addr_bits:0] full_alu;
            
    assign full_alu = wr_level + wr_enable;
        
    always@(posedge wr_clk)
        begin  
                    if(rst)
                        begin
                            fifo_full <= 0;
                        end
                    else
                        begin
                            fifo_full <= full_alu[addr_bits];
                        end
                end
                
always@(posedge rd_clk)
begin
    rd_reset_p1 <= {6{rd_rst_reg}};
    
    if(rd_reset_p1[0])
        begin
            rd_ptr_static <= 0;
            wr_ptr_rd_clk <= 0;
        end
    else //if(rd_token)
        begin
            rd_ptr_static <= read_ptr_sum;
            wr_ptr_rd_clk <= wr_ptr_static;
        end
        
    if(rd_reset_p1[1])
        begin
            rd_level <= 0;
        end
    else 
        begin
            rd_level <= wr_ptr_rd_clk - read_ptr_sum - rd_enable;
        end


    if(rd_reset_p1[2])
        begin
            read_ptr <= 0;//1'b0 -1;
            read_ptr_sum <= 0;
        end
    else
        begin
            read_ptr_sum <= read_ptr_sum;
        end
end

localparam ALMOST_EMPTY_THRESHOLD_MINUS1 = ALMOST_EMPTY_THRESHOLD + 1;
wire [addr_bits:0] almost_empty_alu;
    
        assign almost_empty_alu = rd_level - rd_enable - ALMOST_EMPTY_THRESHOLD_MINUS1;
    
        always@(posedge rd_clk)
            begin  
                if(rd_reset_p1[5])
                    begin
                        fifo_almost_empty <= 1;
                    end
                else
                    begin
                        fifo_almost_empty <= almost_empty_alu[addr_bits];
                    end
            end

wire [addr_bits:0] empty_alu;
            
            assign empty_alu = rd_level - rd_enable - 1'b1;
            
            always@(posedge rd_clk)
                begin  
                    if(rd_reset_p1[4])
                        begin
                            fifo_empty <= 1;
                        end
                    else
                        begin
                            fifo_empty <= empty_alu[addr_bits];
                        end
                end

/** Write to FIFO **/
always @ (posedge wr_clk)
	begin
		if (wr_enable)
			begin
				ram[write_ptr_sum] <= wr_data;
			end
	end


always @ (posedge rd_clk)
        begin
            
            // Port B is for reading only
                rd_data <= ram[read_ptr_sum];
        end
endmodule