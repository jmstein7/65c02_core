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
    input logic [3:0] r,
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
    output logic vpb, //3
    output logic sync, //2
    output logic mlb, //1
    output logic id_phi2_out,
    output logic id_rwb_out, //0
    
    input logic timing_control,
    input logic phi2,
    /* Execute Signals */
    output logic compute_step, //ALU Run 0
    output logic ir_signal, //1
    output logic id_flag, //2
    output logic y, //3
    output logic x, //4
    output logic s, //5
    output logic alu,  //6
    output logic accumulator,  //7
    output logic pcl, //8
    output logic pch, //9
    output logic input_DL,  //10
    output logic data_bus_buffer,  //11
    output logic psr_xfer, //12
    output logic alu_to_accumulator_xfer, //13
    output logic acc_to_alu_xfer,  //14
    output logic addr_to_alu_xfer, //15
    
    output logic increment_pc, //0
    output logic a_increment,  //1
    output logic a_decrement, //2
    output logic x_increment, //3
    output logic x_decrement, //4
    output logic y_increment, //5
    output logic y_decrement, //6
    output logic sp_increment, //7
    output logic sp_decrement, //8
    output logic idl_clear,  //9
    
    input logic [7:0] processor_stat_in,
    output logic [7:0] processor_stat_out,
    input logic [7:0] instruction_reg_in,
    
    //ALU Operations
    output logic swap_a_b,
    output logic swap_b_c,
    output logic [3:0] operation_select
    );
    
    /* Reset wires and regs */
    logic [1:0] reset_active;
    logic [2:0] reset_seven;
    logic begin_reset; /*  <= when this is equal to one, start reset sequence */
    logic [7:0] instruction;
    logic load_count;
    logic dbb; 
    logic fetch_byte, place_byte;
    
    /* Status Flags */
    logic [7:0] status_flags;
    logic [7:0] n_flag = 8'b10000000;
    logic [7:0] v_flag = 8'b01000000;
    logic [7:0] X_flag = 8'b00100000;
    logic [7:0] b_flag = 8'b00010000;
    logic [7:0] d_flag = 8'b00001000;
    logic [7:0] i_flag = 8'b00000100;
    logic [7:0] z_flag = 8'b00000010;
    logic [7:0] c_flag = 8'b00000001;
    logic [7:0] null_flag = 8'b00000000;
    /*-------------------------------*/
    /* Data Bus Multiplexing */
    /* Read Source */
    logic [7:0] data_bus_set;
    logic [3:0] read_y = 4'b0000;
    logic [3:0] read_x = 4'b0001;
    logic [3:0] read_sp = 4'b0010;
    logic [3:0] read_alu = 4'b0011;
    logic [3:0] read_a = 4'b0100;
    logic [3:0] read_pcl = 4'b0101;
    logic [3:0] read_pch = 4'b0110;
    logic [3:0] read_idl = 4'b0111;
    logic [3:0] read_dbuff = 4'b1000;
    logic [3:0] read_psr = 4'b1001;
    logic [3:0] read_bz = 4'b1010;
    /* Write to Source */
    logic [3:0] write_y = 4'b0000;
    logic [3:0] write_x = 4'b0001;
    logic [3:0] write_sp = 4'b0010;
    logic [3:0] write_alu = 4'b0011;
    logic [3:0] write_a = 4'b0100;
    logic [3:0] write_pcl = 4'b0101;
    logic [3:0] write_pch = 4'b0110;
    logic [3:0] write_idl = 4'b0111;
    logic [3:0] write_dbuff = 4'b1000;
    logic [3:0] write_psr = 4'b1001;
    logic [3:0] write_bz = 4'b1010;
    /*-------------------------------*/
    /*-------------------------------*/
    /* Address Bus Multiplexing */
    /* High Byte Select */
    logic [5:0] address_bus_set; 
    logic [2:0] addh_stack = 3'b010;
    logic [2:0] addh_idlA = 3'b110;
    logic [2:0] addh_pcH = 3'b101;
    logic [2:0] addh_bz = 3'b111;
    /* Low Byte Select */
    logic [2:0] addl_stack = 3'b010;
    logic [2:0] addl_idlB = 3'b110;
    logic [2:0] addl_pcL = 3'b101;
    logic [2:0] addl_y = 3'b000;
    logic [2:0] addl_x = 3'b001;
    logic [2:0] addl_alu = 3'b011;
    logic [2:0] addl_bz = 3'b111;
    /*-------------------------------*/
    /*-------------------------------*/
    /* ALU Register Operations       */
    logic [5:0] alu_operations_regs; 
    logic [1:0] alu_swap_a_b = 2'b01; // swap
    logic [1:0] alu_swap_b_c = 2'b10; // registers
    logic [1:0] alu_reg_hold = 2'b00; // registers
    
    /* ALU Operation Select          */
    logic [3:0] and_a_b =       8'b0000;   //0
    logic [3:0] or_a_b =        8'b0001;   //1
    logic [3:0] xor_a_b =       8'b0010;   //2
    logic [3:0] add_a_b_cr =    8'b0011;   //3
    logic [3:0] sub_a_b_ncr =   8'b0100;   //4
    logic [3:0] asl_b_cr =      8'b0101;   //5
    logic [3:0] lsr_b_cr =      8'b0110;   //6
    logic [3:0] rol_b_cr =      8'b0111;   //7
    logic [3:0] ror_b_cr =      8'b1000;   //8
    logic [3:0] bit_a_b =       8'b1001;   //9
    logic [3:0] cmp_a_b =       8'b1010;   //a 10
    logic [3:0] tsb_a_b =       8'b1011;   //b 11
    logic [3:0] trb_a_b =       8'b1100;   //c 12
    logic [3:0] dtb_a_b =       8'b1101;   //d 13
    logic [3:0] btd_a_b =       8'b1110;   //e 14
    logic [3:0] null_a_b =      8'b1111;   //no-op
    
    /*-------------------------------*/
    /*-------------------------------*/
    logic [15:0] load_store_execute;
    logic [15:0] alu_compute = 16'b1000000000000000;
    logic [15:0] load_ireg = 16'b0100000000000000;
    logic [15:0] load_psr = 16'b0010000000000000;
    logic [15:0] load_y = 16'b0001000000000000;
    logic [15:0] load_x = 16'b0000100000000000;
    logic [15:0] load_sp = 16'b0000010000000000;
    logic [15:0] load_alu = 16'b0000001000000000;
    logic [15:0] load_a = 16'b0000000100000000;
    logic [15:0] load_pcl = 16'b0000000010000000;
    logic [15:0] load_pch = 16'b0000000001000000;
    logic [15:0] load_data_latch = 16'b0000000000100000;
    logic [15:0] load_bus_buffer = 16'b0000000000010000;
    logic [15:0] update_status = 16'b0000000000001000;
    logic [15:0] mov_alu_to_acc = 16'b0000000000000100;
    logic [15:0] mov_acc_to_alu = 16'b0000000000000010;
    logic [15:0] mov_low_byte_to_alu = 16'b0000000000000001; //low address byte
    logic [15:0] no_op_hold = 16'b0000000000000000;
    /*-------------------------------*/
    /* Increment, Decrement, Clear   */
    /*-------------------------------*/
     logic [9:0] inc_dec_clr; 
     logic [9:0] inc_pc = 10'b1000000000; //0
     logic [9:0] inc_a = 10'b0100000000;  //1
     logic [9:0] dec_a = 10'b0010000000; //2
     logic [9:0] inc_x = 10'b0001000000; //3
     logic [9:0] dec_x = 10'b0000100000; //4
     logic [9:0] inc_y = 10'b0000010000; //5
     logic [9:0] dec_y = 10'b0000001000; //6
     logic [9:0] inc_sp = 10'b0000000100; //7
     logic [9:0] dec_sp = 10'b0000000010; //8
     logic [9:0] clear_idl = 10'b0000000001;  //9
     logic [9:0] no_change = 10'b0000000000;  //9
    
    logic rwb;
    /* External Signals Out */
    logic [3:0] signal_set; 
    logic [3:0] set_vpb = 4'b1000; //3
    logic [3:0] set_sync = 4'b0100; //2
    logic [3:0] set_mlb = 4'b0010; //1
    logic [3:0] set_rwb = 4'b0001; //0
    logic [3:0] set_none = 4'b0001; //Null
    
    
    /* Data Bus Buffer */
    assign id_rwb_out = rwb; //<= RWB SIGNAL <=
    assign dbb = data_bus_buffer;
    assign fetch_byte = id_rwb_out;
    assign place_byte = ~id_rwb_out; 
    assign id_phi2_out = phi2;

    /*  MAIN SEQUENCE  */
    always @(posedge fclk) begin
    
        {vpb, sync, mlb, rwb} <= signal_set; //4-bits
        
        {read, write} <= data_bus_set; //8-bits
        
        {hmode_select, lmode_select} <= address_bus_set; //6-bits
        
        {compute_step, ir_signal, id_flag, y, x, s, alu, accumulator, pcl, pch, input_DL,
        data_bus_buffer, psr_xfer, alu_to_accumulator_xfer, acc_to_alu_xfer,
        addr_to_alu_xfer} <= load_store_execute; //16-bits
                
        {swap_a_b, swap_b_c, operation_select} <= alu_operations_regs;
    
        {increment_pc, a_increment, a_decrement, x_increment, x_decrement,
        y_increment, y_decrement, sp_increment, sp_decrement, 
        idl_clear} <= inc_dec_clr; //10-bits
    
        processor_stat_out <= status_flags; //8-bits
        
    end
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
