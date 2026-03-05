`timescale 1ns / 1ps

module sync_ptr #(parameter ASIZE = 4)(
    input  wire clk, rst_n,
    input  wire [ASIZE:0] ptr_in,
    output reg  [ASIZE:0] ptr_out
    );
    
    reg [ASIZE:0] sync_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) {ptr_out, sync_reg} <= 0;
        else         {ptr_out, sync_reg} <= {sync_reg, ptr_in};
    end
endmodule