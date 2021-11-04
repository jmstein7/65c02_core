`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2021 12:59:03 PM
// Design Name: 
// Module Name: data_bus
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


module data_bus(

    input logic phi2,
    input logic rwb,
    
    logic [3:0] read,
    logic [3:0] write,
    
    //0
    input logic [7:0] index_y_in,
    output logic [7:0] index_y_out,
    //1
    input logic [7:0] index_x_in,
    output logic [7:0] index_x_out,
    //2
    input logic [7:0] stack_p_reg_in,
    output logic [7:0] stack_p_reg_out,
    //3
    input logic [7:0] alu_in,
    output logic [7:0] alu_out,
    //4
    input logic [7:0] accumulator_in,
    output logic [7:0] accumulator_out,
    //5
    input logic [7:0] PCL_in,
    output logic [7:0] PCL_out,
    //6
    input logic [7:0] PCH_in,
    output logic [7:0] PCH_out,
    //7
    input logic [7:0] input_data_latch_in,
    output logic [7:0] input_data_latch_out,
    //8
    input logic [7:0] data_bus_buff_in,
    output logic [7:0] data_bus_buff_out,
    //9
    input logic [7:0] processor_status_reg_in,
    output logic [7:0] processor_status_reg_out
    );
    
    logic [7:0] data_bus;
    
    assign data_bus = (read == 0) ? index_y_out : 
    (read == 1) ? index_x_in : 
    (read == 2) ? stack_p_reg_in :
    (read == 3) ? alu_in :
    (read == 4) ? accumulator_in :
    (read == 5) ? PCL_in :
    (read == 6) ? PCH_in :
    (read == 7) ? input_data_latch_in :
    (read == 8) ? data_bus_buff_in :
    (read == 9) ? processor_status_reg_in : 'bZ;
    //use 10 if you want high impedence
    
    assign  index_y_out = (write == 0) ? data_bus : 'bZ;
    assign  index_x_out = (write == 1) ? data_bus : 'bZ;
    assign  stack_p_reg_out = (write == 2) ? data_bus : 'bZ;
    assign  alu_out = (write == 3) ? data_bus : 'bZ;
    assign  accumulator_out = (write == 4) ? data_bus : 'bZ;
    assign  PCL_out = (write == 5) ? data_bus : 'bZ;
    assign  PCH_out = (write == 6) ? data_bus : 'bZ;
    assign  input_data_latch_out = (write == 7) ? data_bus : 'bZ;
    assign  data_bus_buff_out = (write == 8) ? data_bus : 'bZ;
    assign  processor_status_reg_out = (write == 9) ? data_bus : 'bZ;
    
    
endmodule
