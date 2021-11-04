`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jonathan Stein
// 
// Create Date: 10/30/2021 05:21:22 PM
// Module Name: processor_wrapper
// Project Name: JM65C02S 8-bit processor
// Target Devices: Xilinx Artix-7 
// Tool Versions: 
// Description: Wrapper for JM65C02S Processor, akin to the
//              Western Digital 65C02 Processor 
//              aka A 65c02 compatible processor implementation
// 
// Revision: v1.0
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
//  LIABLITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Feel free to contact the author through the 6502 user forum: 
//  http://forum.6502.org/memberlist.php?mode=viewprofile&u=3597
//
//////////////////////////////////////////////////////////////////////////////////


module processor_wrapper(
    input clk,
    input reset
    );
    
    wire vpb, rdy, phi1o, irqb, mlb, nmib, sync, resb, phi2o,
    sob, phi2, be, rwb;
    
    wire [7:0] data_io;
    wire [15:0] a;
     
    assign resb = ~reset;
    
    /* System Verilog Processor Instance */
    JM65C02S processor_one(
    
    /* Processor Signals */
    .vpb(vpb),
    .rdy(rdy), 
    .phi1o(phi1o), 
    .irqb(irqb), 
    .mlb(mlb), 
    .nmib(nmib), 
    .sync(sync), 
    .resb(resb), 
    .phi2o(phi2o),
    .sob(sob), 
    .clk(clk), 
    .be(be), 
    .rwb(rwb),
    
    /* Data and Address Busses */
    .a(a),
    .data_io(data_io) 
    
    );
    
endmodule
