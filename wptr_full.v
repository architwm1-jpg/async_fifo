`timescale 1ns / 1ps

module wptr_full #(parameter ASIZE = 4)(
    input  wire winc, wclk, wrst_n,
    input  wire [ASIZE:0] wq2_rptr,
    output reg  wfull,
    output wire [ASIZE-1:0] waddr,
    output reg  [ASIZE:0] wptr
    );
    
    reg  [ASIZE:0] wbin;
    wire [ASIZE:0] wgraynext, wbinnext;
    wire wfull_val; // Added declaration

    assign waddr = wbin[ASIZE-1:0];
    assign wbinnext = wbin + (winc & ~wfull);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin <= 0;
            wptr <= 0;
        end else begin
            wbin <= wbinnext;
            wptr <= wgraynext;
        end
    end

    // Full logic for Gray Code pointers
    assign wfull_val = (wgraynext == {~wq2_rptr[ASIZE:ASIZE-1], wq2_rptr[ASIZE-2:0]});
       
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) wfull <= 1'b0;
        else         wfull <= wfull_val;
    end     
endmodule