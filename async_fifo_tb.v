`timescale 1ns / 1ps

module async_fifo_tb;
    parameter DSIZE = 8;
    parameter ASIZE = 4;
    parameter WCLK_PERIOD = 10;
    parameter RCLK_PERIOD = 25;
    
    reg [DSIZE - 1:0] wdata;
    reg winc, wclk, wrst_n;
    reg rinc, rclk, rrst_n; // Corrected 'inc' to 'rinc'
    
    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;
    
    async_fifo #( 
        .DSIZE(DSIZE),
        .ASIZE(ASIZE)
    ) uut (
        .wdata(wdata), .winc(winc), .wclk(wclk), .wrst_n(wrst_n),
        .rinc(rinc),   .rclk(rclk), .rrst_n(rrst_n),
        .rdata(rdata), .wfull(wfull), .rempty(rempty)
    );

    // Clock Generation
    initial wclk = 0;
    always #(WCLK_PERIOD/2) wclk = ~wclk;
       
    initial rclk = 0;
    always #(RCLK_PERIOD/2) rclk = ~rclk;
       
    initial begin 
        // Initial States
        winc = 0; rinc = 0; wdata = 0;
        wrst_n = 0; rrst_n = 0;
        
        // Reset
        #(WCLK_PERIOD * 3);
        wrst_n = 1; rrst_n = 1;
        $display("[%0t] Reset De-asserted", $time);
        
        // --- Write Data ---
        repeat (17) begin 
            @(posedge wclk);
            if (!wfull) begin
                winc = 1;
                wdata = wdata + 1;
            end else begin 
                winc = 0;
                $display("[%0t] FIFO is FULL", $time);
            end 
        end 
        @(posedge wclk) winc = 0;
          
        #(RCLK_PERIOD * 5); // Wait for synchronization
          
        // --- Read Data ---
        while(!rempty) begin
            @(posedge rclk);
            rinc = 1;
            #1; // Wait a tiny bit to see data settle in wave
            $display("[%0t] Reading Data: %h", $time, rdata);
        end
          
        @(posedge rclk) rinc = 0;
        $display("[%0t] FIFO is Empty", $time);
          
        #(WCLK_PERIOD * 10);
        $display("Simulation Finished");
        $finish;
    end
endmodule