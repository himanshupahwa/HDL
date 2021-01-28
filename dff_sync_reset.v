module dff_sync_reset (
data   , // Data Input
clk    , // Clock Input
reset  , // Reset input
q        // Q output
);
//-----------Input Ports---------------
input data, clk, reset ; 

//-----------Output Ports---------------
output q;

//------------Internal Variables--------
reg q;

//-------------Code Starts Here---------
reg sync_reset;
reg sync_reset_pipe;
always @ ( posedge clk)
begin
    sync_reset <= reset;
    sync_reset_pipe <= sync_reset;
end

always @ ( posedge clk)
if (~sync_reset_pipe) begin
  q <= 1'b0;
end  else begin
  q <= data;
end

endmodule