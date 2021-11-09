`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2021 12:59:03 PM
// Design Name: 
// Module Name: processor_stat_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Processor Status Register
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


module processor_stat_reg(

    input logic id_flag,
    input logic psr_xfer,
    input logic sob,
    input logic phi2,
    input logic fclk,
    
    output logic c_carry,
    output logic d_decimal,
    
    input logic [7:0] instruction_decode_in,
    output logic [7:0] instruction_decode_out,
    input logic [7:0] db_in,
    output logic [7:0] db_out,
    
    input logic psr_update_request,
    output logic ack_update_request,
    input logic n_result, 
    input logic v_result,
    input logic z_result, 
    input logic c_result
    
    );
    
    //negative, overflow, don't care, break, decimal,
    //interrupt, zero, carry 
    logic n, v, X, b, d, i, z, c;
    logic [7:0] p_status_register;
    logic [7:0] reg_breakout;
    
    assign {n, v, X, b, d, i, z, c} = reg_breakout; 
    
    //assign p_status_register = {n,v,x,b,d,i,z,c};
    
    always_latch begin
    
    if (sob && ~fclk)
            p_status_register <= {n,1'b1,X,b,d,i,z,c};
            
    if (fclk) begin
            
        if (id_flag)
            p_status_register <= db_in;
            
        else if (psr_xfer)
            p_status_register <= instruction_decode_in;
            
        else if (psr_update_request) begin
            p_status_register <= {n_result, v_result, X, b, d, i, z_result, c_result};
            ack_update_request <= 1;
        end
        
        else if (~psr_update_request)
            ack_update_request <= 0;
            
    end
    
    end
    
    assign c_carry = c; 
    assign d_decimal = d;
    assign reg_breakout = p_status_register;
    assign db_out = p_status_register;
    assign instruction_decode_out = p_status_register;
    
endmodule
