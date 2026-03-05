`timescale 1ns / 1ps

module rptr_empty #(parameter ASIZE = 4) (
    input  wire rinc, rclk, rrst_n,
    input  wire [ASIZE:0] rq2_wptr,
    output reg  rempty,
    output wire [ASIZE-1:0] raddr,
    output reg  [ASIZE:0] rptr
);
    reg  [ASIZE:0] rbin;
    wire [ASIZE:0] rgraynext, rbinnext;
    wire rempty_val; // Added declaration

    assign raddr = rbin[ASIZE-1:0];
    assign rbinnext = rbin + (rinc & ~rempty);
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin <= 0;
            rptr <= 0;
        end else begin
            rbin <= rbinnext;
            rptr <= rgraynext;
        end
    end

    // Empty when Gray-code read pointer matches synchronized write pointer
    assign rempty_val = (rgraynext == rq2_wptr);
    
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) rempty <= 1'b1;
        else         rempty <= rempty_val;
    end
endmodule