`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2021 12:38:59 PM
// Design Name: 
// Module Name: PCH
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
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


module PCH(
    
    input logic fclk,
    input logic instruction_decode_in,
    input logic carry_to_pch,
    
    input logic [7:0] db_in,
    output logic [7:0] db_out,
    
    input logic [7:0] address_high_in,
    output logic [7:0] address_high_out,
    
    output logic carry_done
    
    );
    
    logic [7:0] pc_high_byte;
    
    always_latch begin
    if (fclk) begin
        if (instruction_decode_in)
            pc_high_byte <= db_in;
        else if (carry_to_pch) begin
            pc_high_byte <= pc_high_byte + 1;
            carry_done <= 1; 
        end
        else if (~carry_to_pch)
            carry_done <= 0; 
    end
    end
    
    assign address_out = pc_high_byte;
    assign db_out = pc_high_byte;
    
endmodule
