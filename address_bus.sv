`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2021 12:59:03 PM
// Design Name: 
// Module Name: address_bus
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

module address_bus(
    input logic phi2,
    input logic [1:0] q,
    input logic fclk,
    input logic rwb,
    input logic be,
    input logic [2:0] hmode_select,
    input logic [2:0] lmode_select,
    
    input logic [7:0] index_y_in, //0
    
    input logic [7:0] index_x_in, //1
    
    input logic [7:0] stack_p_reg_in, //2 so, 3'b010 for example
    
    input logic [7:0] alu_in, //3
    output logic [7:0] alu_out,
    
    input logic [7:0] PCL_in, //4
    output logic [7:0] PCL_out,
    
    input logic [7:0] PCH_in, //5
    output logic [7:0] PCH_out,
    
    input logic [7:0] input_data_latch_A, //6 A is the high byte
    input logic [7:0] input_data_latch_B,   //B is the low byte
    
    output logic [15:0] full_address_output

    );
    
    logic [7:0] high_byte;
    logic [7:0] low_byte;
    
    always_latch begin
    if (fclk && (q == 0)) begin
        if (~be)
            full_address_output <= 'bZ;
        else if (be)
            full_address_output <= {high_byte, low_byte};
    end
    end
    
    assign high_byte = (hmode_select == 3'b010) ? 8'h01 : 
    (hmode_select == 3'b110) ? input_data_latch_A :
    (hmode_select == 3'b101) ? PCH_in : 'bZ;
    
    assign low_byte = (lmode_select == 3'b010) ? stack_p_reg_in : 
    (lmode_select == 3'b000) ? index_y_in :
    (lmode_select == 3'b001) ? index_x_in :
    (lmode_select == 3'b110) ? input_data_latch_B :
    (lmode_select == 3'b011) ? alu_in :
    (lmode_select == 3'b101) ? PCL_in : 'bZ;
    
    /* send values to units that can read these bytes */
    assign alu_out = low_byte;
    assign PCL_out = low_byte;
    assign PCH_out = high_byte;
    
endmodule
