`timescale 1ns / 1ps

module async_fifo #(parameter DSIZE=8, ASIZE=4)(
    input  wire [DSIZE-1:0] wdata,
    input  wire winc, wclk, wrst_n,
    input  wire rinc, rclk, rrst_n,
    output wire [DSIZE-1:0] rdata,
    output wire wfull,
    output wire rempty
    );

    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;

    // 1. Dual-Port RAM storage
    fifomem #(DSIZE, ASIZE) storage (
        .wdata(wdata), .waddr(waddr), .raddr(raddr),
        .wclken(winc && !wfull), .wclk(wclk), .rdata(rdata)
    );

    // 2. Sync Read Pointer into Write Domain
    sync_ptr #(ASIZE) sync_r2w (
        .clk(wclk), .rst_n(wrst_n), .ptr_in(rptr), .ptr_out(wq2_rptr)
    );

    // 3. Sync Write Pointer into Read Domain
    sync_ptr #(ASIZE) sync_w2r (
        .clk(rclk), .rst_n(rrst_n), .ptr_in(wptr), .ptr_out(rq2_wptr)
    );

    // 4. Read Logic (Empty Flag)
    rptr_empty #(ASIZE) read_logic (
        .rinc(rinc), .rclk(rclk), .rrst_n(rrst_n),
        .rq2_wptr(rq2_wptr), .rempty(rempty), .raddr(raddr), .rptr(rptr)
    );

    // 5. Write Logic (Full Flag)
    wptr_full #(ASIZE) write_logic (
        .winc(winc), .wclk(wclk), .wrst_n(wrst_n),
        .wq2_rptr(wq2_rptr), .wfull(wfull), .waddr(waddr), .wptr(wptr)
    );
endmodule