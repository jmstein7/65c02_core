`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2021 12:59:03 PM
// Design Name: 
// Module Name: clocking_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Additional Comments: Copyright (C) 2021 Jonathan Stein (New York, USA)
//
//                              "MIT License"
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software with full atribution, i.e.,
//  clearly identifying the author such that the average, ordinary person using 
//  this work would be on notice as to the author of this work, as well as understanding
//  the terms of this license, as set forth herein.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Feel free to contact the author through the 6502 user forum: 
//  http://forum.6502.org/memberlist.php?mode=viewprofile&u=3597
//
// 
//////////////////////////////////////////////////////////////////////////////////


module clocking_unit(
    input logic clk,
    output logic clock_running,
    input logic reset,
    output logic phi1o,
    output logic phi2o,
    output logic phi2_out,
    output logic mem_clk,
    output logic fclk //4x phi2
    );
    
    logic locked;
    logic at_speed = 0; 
    logic [1:0] start_clock = 0;
    
    assign phi2o = phi2_out;
    assign phi1o = ~phi2_out;
    assign clock_running = at_speed;
    
    always @(posedge phi2o) begin
        if (start_clock < 2'b10) begin
            at_speed <= 0;
            start_clock <= start_clock +1;
        end
        else if (start_clock == 2'b10) begin
            start_clock <= start_clock +1;
            at_speed <= 1;
        end
        else if (start_clock == 2'b11)
            start_clock <= 2'b11;
    end
    
      clk_wiz_0 main_clock
   (
    // Clock out ports
    .phi2(phi2_out),     // output phi2
    .fclk(fclk),     // output fclk
    .mem_clk(mem_clk),
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk(clk));      // input clk
    
endmodule
