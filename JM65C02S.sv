`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer: Jonathan Stein
// 
// Create Date: 10/30/2021 05:58:46 PM
// Design Name: 
// Module Name: JM65C02S
// Project Name: A 65c02 ISA-compatible processor implementation
// Revision: v1.0
// Revision 0.01 - File Created
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
//////////////////////////////////////////////////////////////////////////////////


module JM65C02S(
    input logic clk,
    output logic vpb,
    input logic rdy, 
    output logic phi1o, 
    input logic irqb, 
    output logic mlb, 
    input logic nmib, 
    output logic sync, 
    input logic resb, 
    output logic phi2o,
    input logic sob,  
    input logic be, 
    output logic rwb,
    
    output logic [15:0] a,
    inout logic  [7:0] data_io
    
    );

    logic  [7:0] data_io_in;
    logic [7:0] data_io_out;
    logic [15:0] address; 
    logic clock_running;
    logic mem_clk;
    logic [3:0] r_count;
    logic id_phi2_out;
    logic id_rwb_out;
    logic acc_to_alu_xfer;
    logic addr_to_alu_xfer;
    logic psr_xfer;
    logic [2:0] hmode_select;
    logic [2:0] lmode_select;
    logic c_carry;
    logic d_decimal;
    logic pc_carry_done;
    logic compute_step;
    logic psr_update_request;
    logic ack_update_request;
    logic n_result; 
    logic v_result;
    logic z_result;
    logic c_result;
    logic swap_a_b;
    logic swap_b_c;
    logic [3:0] operation_select;
    logic phi2_to_tc;
    logic fclk;
    logic sfclk;
    logic [1:0] q;
    /*--------------------------*/
    /* MASTER ADDRESS BUS SETUP */
    /*--------------------------*/
    //Internal Signals
    assign a = address;
    assign rwb = id_rwb_out;
    
    logic [2:0] mode_select;
    logic [7:0] y_to_abus;
    logic [7:0] x_to_abus;
    logic [7:0] sp_to_abus;
    logic [7:0] alu_to_abus;
    logic [7:0] abus_to_alu;
    logic [7:0] pcl_to_abus;
    logic [7:0] abus_to_pcl;
    logic [7:0] pch_to_abus;
    logic [7:0] abus_to_pch;
    logic [7:0] IDLA_to_abus;
    logic [7:0] IDLB_to_abus;
    
    address_bus address_bus_a(
    .full_address_output(address),
    .fclk(fclk),
    .phi2(id_phi2_out),
    .q(q),
    .rwb(id_rwb_out),
    .be(be),
    .hmode_select(hmode_select),
    .lmode_select(lmode_select),
    .index_y_in(y_to_abus),
    
    .index_x_in(x_to_abus),
    
    .stack_p_reg_in(sp_to_abus),
    
    .alu_in(alu_to_abus),
    .alu_out(abus_to_alu),
    
    .PCL_in(pcl_to_abus),
    .PCL_out(abus_to_pcl),
    
    .PCH_in(pch_to_abus),
    .PCH_out(abus_to_pch),
    
    .input_data_latch_A(IDLA_to_abus),  //high byte
    .input_data_latch_B(IDLB_to_abus)   //low byte
    );
    
    /*-----------------------*/
    /* MASTER DATA BUS SETUP */
    /*-----------------------*/
    //Internal Signals
    logic [7:0] y_to_dbus;
    logic [7:0] dbus_to_y;
    logic [7:0] x_to_dbus;
    logic [7:0] dbus_to_x;
    logic [7:0] sp_to_dbus;
    logic [7:0] dbus_to_sp;
    logic [7:0] alu_to_dbus;
    logic [7:0] dbus_to_alu;
    logic [7:0] accumulator_to_dbus;
    logic [7:0] dbus_to_accumulator;
    logic [7:0] pcl_to_dbus;
    logic [7:0] dbus_to_pcl;
    logic [7:0] pch_to_dbus;
    logic [7:0] dbus_to_pch;
    logic [7:0] idl_to_dbus;
    logic [7:0] dbus_to_idl;
    logic [7:0] dbuff_to_dbus;
    logic [7:0] dbus_to_dbuff;
    logic [7:0] ir_to_dbus;
    logic [7:0] dbus_to_ir;
    logic [7:0] psr_to_dbus;
    logic [7:0] dbus_to_psr;
    logic [3:0] dbus_read;
    logic [3:0] dbus_write;
    
    data_bus data_bus_a(

    .phi2(id_phi2_out),
    .rwb(id_rwb_out),
    .read(dbus_read),
    .write(dbus_write),
    .index_y_in(y_to_dbus),
    .index_y_out(dbus_to_y),
    
    .index_x_in(x_to_dbus),
    .index_x_out(dbus_to_x),
    
    .stack_p_reg_in(sp_to_dbus),
    .stack_p_reg_out(dbus_to_sp),
    
    .alu_in(alu_to_dbus),
    .alu_out(dbus_to_alu),
    
    .accumulator_in(accumulator_to_dbus),
    .accumulator_out(dbus_to_accumulator),
    
    .PCL_in(pcl_to_dbus),
    .PCL_out(dbus_to_pcl),
    
    .PCH_in(pch_to_dbus),
    .PCH_out(dbus_to_pch),
    
    .input_data_latch_in(idl_to_dbus),
    .input_data_latch_out(dbus_to_idl),
    
    .data_bus_buff_in(dbuff_to_dbus),
    .data_bus_buff_out(dbus_to_dbuff),
    
    .processor_status_reg_in(psr_to_dbus),
    .processor_status_reg_out(dbus_to_psr)
    );
    
    /*-----------------------*/
    /* Instruction Decoder   */
    /*-----------------------*/
    //Internal Signals
    logic int_resb_to_id;
    logic int_irqb_to_id;
    logic int_nmibb_to_id;
    logic tc_phi2_to_id;
    logic id_flag;
    logic ir_signal;
    logic id_to_y;
    logic id_to_x;
    logic id_to_sp;
    logic id_to_alu;
    logic id_to_accum;
    logic id_to_pcl;
    logic id_to_pch;
    logic id_to_idl;
    logic id_to_dbus_buff;
    logic tc_to_id;
    logic [7:0] id_to_psr;
    logic [7:0] psr_to_id;
    logic [7:0] ir_to_id;
    logic increment_pc;
    logic p;
    logic fclk_out;
    logic a_increment;
    logic a_decrement;
    logic x_increment;
    logic x_decrement;
    logic y_increment;
    logic y_decrement;
    logic sp_increment;
    logic sp_decrement;
    logic alu_to_accumulator_xfer; //transfer from ALU to A
    logic idl_clear;
    
    instruction_decode id_a(
    .resb(int_resb_to_id),
    .irqb(int_irqb_to_id),
    .nmib(int_nmib_to_id),
    .p(p),
    .q(q),
    .r(r_count),
    .fclk(fclk_out),
    .mem_clk(mem_clk),
    .increment_pc(increment_pc),
    .read(dbus_read),
    .write(dbus_write),
    .hmode_select(hmode_select),
    .lmode_select(lmode_select),
    .id_phi2_out(id_phi2_out),
    .id_rwb_out(id_rwb_out),
    .idl_clear(idl_clear),
    .compute_step(compute_step),
    .a_increment(a_increment),
    .a_decrement(a_decrement),
    .x_increment(x_increment),
    .x_decrement(x_decrement),
    .y_increment(y_increment),
    .y_decrement(y_decrement),
    .sp_increment(sp_increment),
    .sp_decrement(sp_decrement),
    .alu_to_accumulator_xfer(alu_to_accumulator_xfer),
    .acc_to_alu_xfer(acc_to_alu_xfer),
    .addr_to_alu_xfer(addr_to_alu_xfer),
    .psr_xfer(psr_xfer),
    
    .rdy(rdy),
    .vpb(vpb),
    .sync(sync),
    .mlb(mlb),
    .phi2(tc_phi2_to_id),
    .ir_signal(ir_signal),
    .id_flag(id_flag),
    .y(id_to_y),
    .x(id_to_x),
    .s(id_to_sp),
    .alu(id_to_alu),
    .accumulator(id_to_accum),
    .pcl(id_to_pcl),
    .pch(id_to_pch),
    .input_DL(id_to_idl),
    .data_bus_buffer(id_to_dbus_buff),
    .timing_control(tc_to_id),
    .clock_running(clock_running),
    
    .processor_stat_in(psr_to_id),
    .processor_stat_out(id_to_psr),
    .instruction_reg_in(ir_to_id),
    
    .swap_b_c(swap_b_c),
    .swap_a_b(swap_a_b),
    .operation_select(operation_select)
    );

    /*-----------------------*/
    /* Interrupt Logic       */
    /*-----------------------*/
    //Internal Signals
interrupt_logic int_logic(
    .resb_in(resb),
    .irqb_in(irqb),
    .nmib_in(nmib),
    .resb_out(int_resb_to_id),
    .irqb_out(int_irqb_to_id),
    .nmib_out(int_nmib_to_id)
    );
    
    /*-----------------------------------*/
    /* Clock Generator and oscillator    */
    /*-----------------------------------*/
    //Internal Signals
    
clocking_unit clock_gen_one(
    .clk(clk),
    .clock_running(clock_running),
    .reset(~resb),
    .phi1o(phi1o),
    .phi2o(phi2o),
    .phi2_out(phi2_to_tc),
    .fclk(fclk),
    .sfclk(sfclk),
    .mem_clk(mem_clk)
    );

    /*-----------------------------------*/
    /* Timing Control Unit               */
    /*-----------------------------------*/
    //Internal Signals
    
timing_control tc_unit(
    .reset(~resb),
    .tc_to_id(tc_to_id),
    .cg_to_tc(fclk),
    .phi2_in(phi2_to_tc),
    .phi2_out(tc_phi2_to_id),
    .p(p),
    .q(q),
    .r(r_count),
    .fclk(fclk),
    .sfclk(sfclk),
    .fclk_out(fclk_out)
    );

    /*-----------------------------------*/
    /* Instruction Register              */
    /*-----------------------------------*/
    //Internal Signals
    
instruction_register ir_unit(
    .ir_signal(ir_signal),
    .instruction_decode_out(ir_to_id),
    .data_in(data_io_in),
    .phi2(id_phi2_out)
    );
    
    /*-----------------------------------*/
    /* ALU                               */
    /*-----------------------------------*/
    //Internal Signals
    logic [7:0] accumulator_to_alu;
    logic [7:0] alu_to_accumulator;
    
    ALU ALU_one(
    
    .compute_step(compute_step),
    .fclk(fclk),
    .mem_clk(mem_clk),
    .resb(int_resb_to_id),
    .instruction_decode_in(id_to_alu),
    
    .db_in(dbus_to_alu),
    .db_out(alu_to_dbus),
    
    .c_carry(c_carry),
    .d_decimal(d_decimal),
    
    .address_in(abus_to_alu),
    .address_out(alu_to_abus),
    .acc_to_alu_xfer(acc_to_alu_xfer),
    .addr_to_alu_xfer(addr_to_alu_xfer),
    
    .accumulator_in(accumulator_to_alu),
    .accumulator_out(alu_to_accumulator),
    
    .psr_to_id(psr_to_id),
    .psr_update_request(psr_update_request),
    .ack_update_request(ack_update_request),
    .n_result(n_result), 
    .v_result(v_result),
    .z_result(z_result), 
    .c_result(c_result),
    .swap_b_c(swap_b_c),
    .swap_a_b(swap_a_b),
    .operation_select(operation_select)
    
    );
    /*------------------------------------*/
    /* Accumulator Register File          */
    /*------------------------------------*/
    //Internal Signals    
    
accumulator_A accumulator_one(

    .instruction_decode_in(id_to_accum),
    .fclk(fclk),
    .rwb(id_rwb_out),
    .db_in(dbus_to_accumulator),
    .db_out(accumulator_to_dbus),
    .alu_in(alu_to_accumulator),
    .alu_out(accumulator_to_alu),
    .a_increment(a_increment),
    .a_decrement(a_decrement),
    .alu_to_accumulator_xfer(alu_to_accumulator_xfer)
    );

    /*------------------------------------*/
    /* Processor Status Register          */
    /*------------------------------------*/
    //Internal Signals  

processor_stat_reg PSR_one(
    
    .sob(sob),
    .phi2(id_phi2_out),
    .fclk(fclk),
    .id_flag(id_flag),
    .c_carry(c_carry),
    .d_decimal(d_decimal),
    .psr_xfer(psr_xfer),
    .instruction_decode_in(id_to_psr),
    .instruction_decode_out(psr_to_id),
    .db_in(dbus_to_psr),
    .db_out(psr_to_dbus),
    .psr_update_request(psr_update_request),
    .ack_update_request(ack_update_request),
    .n_result(n_result), 
    .v_result(v_result),
    .z_result(z_result), 
    .c_result(c_result)
    );
    /*--------------------------*/
    /* PCL and PCH              */
    /*--------------------------*/
    //Internal Signals  
    
    logic carry_to_pch;
    
PCL pcl_one(
    
    .fclk(fclk),
    .instruction_decode_in(id_to_pcl),
    .increment_pc(increment_pc),
    .carry_to_pch(carry_to_pch),
    .db_in(dbus_to_pcl),
    .db_out(pcl_to_dbus),
    .address_low_in(abus_to_pcl),
    .address_low_out(pcl_to_abus),
    .carry_done(pc_carry_done)
    );

PCH pch_one(
    
    .fclk(fclk),
    .instruction_decode_in(id_to_pch),
    .carry_to_pch(carry_to_pch),
    .db_in(dbus_to_pch),
    .db_out(pch_to_dbus),
    .address_high_in(abus_to_pch),
    .address_high_out(pch_to_abus),
    .carry_done(pc_carry_done)
    );
    
    /*----------------------------*/
    /*                            */
    /*  X and Y Index Registers   */
    /*                            */
    /*----------------------------*/
    //Internal Signals 
 index_register_X x_reg(
    
    .fclk(fclk),
    .instruction_decode_in(id_to_x),
    .rwb(id_rwb_out),
    .db_in(dbus_to_x),
    .db_out(x_to_dbus),
    .address_out(x_to_abus),
    .x_increment(x_increment),
    .x_decrement(x_decrement)
    );
 
 index_register_Y y_reg(
    
    .fclk(fclk),
    .instruction_decode_in(id_to_y),
    .rwb(id_rwb_out),
    .db_in(dbus_to_y),
    .db_out(y_to_dbus),
    .address_out(y_to_abus),
    .y_increment(y_increment),
    .y_decrement(y_decrement)
    );

    /*----------------------------*/
    /*                            */
    /*    Input Data Latch        */
    /*                            */
    /*----------------------------*/
    //Internal Signals 
Input_Data_Latch input_d_latch(

    .fclk(fclk),
    .instruction_decode_in(id_to_idl),
    .clear(idl_clear),
    .rwb(id_rwb_out),
    .db_in(dbus_to_idl),
    .db_out(idl_to_dbus),
    .address_high_out(IDLA_to_abus), // eight high bytes
    .address_low_out(IDLB_to_abus)   // eight low bytes
    );
    
    /*----------------------------*/
    /*                            */
    /*    Data Bus Buffer         */
    /*                            */
    /*----------------------------*/
    //Internal Signals 
data_bus_buffer dbus_buffer(
    
    .instruction_decode_in(id_to_dbus_buff),
    
    .fclk(fclk),
    .be(be),
    .phi2(id_phi2_out),
    .rwb(rwb),
    
    .db_in(dbus_to_dbuff),
    .db_out(dbuff_to_dbus),
    
    .data_in(data_io_in),
    .data_out(data_io_out)
    ); 

    assign data_io = (rwb) ? 'bZ : data_io_out;
    assign data_io_in = (rwb) ? data_io : 'bZ; 

    /*----------------------------*/
    /*                            */
    /*    Stack Pointer           */
    /*                            */
    /*----------------------------*/
    //Internal Signals  
stack_point_register stack_pointer(

    .fclk(fclk),
    .instruction_decode_in(id_to_sp),
    .db_in(dbus_to_sp),
    .db_out(sp_to_dbus),
    .address_out(sp_to_abus),
    .sp_increment(sp_increment),
    .sp_decrement(sp_decrement)
    );
    
endmodule
