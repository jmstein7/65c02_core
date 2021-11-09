`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2021 12:59:03 PM
// Design Name: 
// Module Name: timing_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
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


module timing_control(
    input logic reset,
    output logic tc_to_id,
    input cg_to_tc,
    input logic phi2_in,
    output logic phi2_out,
    input logic fclk,
    input logic sfclk,
    output logic [3:0] r,
    output logic [1:0] q,
    output logic p,
    output logic fclk_out
    );
    
    logic [1:0] q_step = 0;
    logic p_step = 0; 
    logic [3:0] r_step = 4'b0010;
    
    assign phi2_out = phi2_in;
    assign q = q_step;
    assign p = p_step;
    assign r = r_step;
    assign fclk_out = fclk;
    
    always @(posedge fclk) begin
        if (q_step == 2'b11)
            p_step <= 0;
        else if (q_step == 2'b01)
            p_step <= 1; 
        q_step <= q_step + 2'b01;
        if (reset) begin
            q_step <= 0;
            p_step <= 0; 
        end
    end
    
    always @(posedge sfclk) begin
        r_step <= r_step + 4'b0001;
        if (reset)
            r_step <= 4'b0001;
    end 
    
endmodule
