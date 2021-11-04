`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2021 12:59:03 PM
// Design Name: 
// Module Name: instruction_decode
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


module instruction_decode(
    input logic resb,
    input logic irqb,
    input logic nmib,
    input logic [1:0] q,
    input logic p,
    input logic fclk,
    input logic mem_clk,
    input logic clock_running,
    
    output logic [3:0] read,
    output logic [3:0] write,
    output logic [2:0] hmode_select,
    output logic [2:0] lmode_select,
    input logic rdy,
    output logic vpb,
    output logic sync,
    output logic mlb,
    output logic id_phi2_out,
    output logic id_rwb_out,
    
    input logic timing_control,
    input logic phi2,
    output logic ir_signal,
    output logic id_flag,
    output logic y,
    output logic x,
    output logic s,
    output logic alu,
    output logic accumulator,
    output logic pcl,
    output logic pch,
    output logic input_DL,
    output logic data_bus_buffer,
    output logic psr_xfer,
    
    output logic increment_pc,
    output logic a_increment,
    output logic a_decrement,
    output logic x_increment,
    output logic x_decrement,
    output logic y_increment,
    output logic y_decrement,
    output logic sp_increment,
    output logic sp_decrement,
    output logic alu_to_accumulator_xfer,
    output logic acc_to_alu_xfer,
    output logic addr_to_alu_xfer,

    output logic idl_clear,
    
    input logic [7:0] processor_stat_in,
    output logic [7:0] processor_stat_out,
    input logic [7:0] instruction_reg_in
    );
    
    /* Reset wires and regs */
    logic [1:0] reset_active;
    logic [2:0] reset_seven;
    logic begin_reset; /*  <= when this is equal to one, start reset sequence */

    
    //////////////////////////////////////////////////////////////////////////////////
    //          RESET COUNTS / two cycles down to start reset sequence
    //////////////////////////////////////////////////////////////////////////////////
    //Reset Logic and counters
    
    always @(negedge phi2) begin
        if (~resb) begin
            if ((reset_active == 2'b00)) begin
                reset_active <= reset_active + 2'b01;
                begin_reset <= 0; 
                reset_seven <= 0;
            end
            else if (reset_active == 2'b01) begin
                reset_active <= reset_active + 2'b01;
            end
            else if (reset_active == 2'b10) begin
                reset_active <= 2'b10;
            end
            else if (reset_active == 2'b11) begin
                reset_active <= 0;
                begin_reset <= 0;
                reset_seven <= 0;
            end
        end
        else if (resb) begin
            if ((reset_active == 2'b00) || (reset_active == 2'b01))
                reset_active <= 0;  
            else if (reset_active == 2'b10) begin
                begin_reset <= 1;
                reset_active <= reset_active + 2'b01;
            end
            else if (reset_active == 2'b11) begin
                begin_reset <= 0;
                reset_active <= 0;
            end
            //count seven cycles
            if (reset_seven == 0 && ~begin_reset)
                reset_seven <= 0;
            else if (reset_seven == 0 && begin_reset)
                reset_seven <= reset_seven + 3'b001;
            else if (reset_seven > 0 && resb)
                reset_seven <= reset_seven + 3'b001;
        end
    end
    /* END OF RESET COUNTERS */
    //////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////
    
endmodule
