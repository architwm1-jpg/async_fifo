`timescale 1ns / 1ps

module fifomem #(parameter DSIZE = 8, ASIZE = 4)(
    input  wire [DSIZE - 1:0] wdata,
    input  wire [ASIZE - 1:0] waddr, raddr,
    input  wire wclken, wclk,
    output wire [DSIZE - 1:0] rdata
    );
    
    localparam DEPTH = 1 << ASIZE;
    reg [DSIZE-1:0] mem [0:DEPTH-1];
    
    // Asynchronous read
    assign rdata = mem[raddr];
    
    // Synchronous write
    always @(posedge wclk) begin
        if (wclken) mem[waddr] <= wdata;
    end
endmodule