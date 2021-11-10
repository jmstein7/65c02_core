`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2021 12:38:59 PM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
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
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input logic compute_step,
    input logic fclk,
    input logic mem_clk,
    input logic resb,
    input logic instruction_decode_in,
    input logic acc_to_alu_xfer,
    input logic addr_to_alu_xfer,
    input logic [7:0] db_in,
    output logic [7:0] db_out,
    
    input logic c_carry,
    input logic d_decimal,
    
    input logic [7:0] address_in,
    output logic [7:0] address_out,
    
    input logic [7:0] accumulator_in,
    output logic [7:0] accumulator_out,
    
    input logic [7:0] psr_to_id,
    output logic psr_update_request,
    input logic ack_update_request,
    output logic n_result, 
    output logic v_result,
    output logic z_result, 
    output logic c_result,
    
    input logic swap_a_b,
    input logic swap_b_c,
    input logic [3:0] operation_select
    
    );
    
    logic [7:0] a_register; // in-out accumulator
    logic [7:0] b_register; // in-out data bus a/k/a "memory"
    logic [7:0] c_register; // in-out address bus
    logic [7:0] a_temp, b_temp, a_temp_a, b_temp_b;
    logic signed [8:0] scratch_register;
    logic [7:0] dummy_result;
    logic [9:0] asl_z, lsr_z, rol_z, ror_z;
    logic [6:0] dummy;
    logic dummy_bit, dummy_bit_b, dummy_bit_c;
    logic [1:0] ova, ovb;
    logic ovv, ovf;
    logic n, v, X, b, d, i, z, c;
    
    parameter signed [7:0] underflow = -127;
    
    /* Overflow V */
    assign ova = a_register[7:7] + b_register[7:7];
    assign ovb = a_register[6:6] + b_register[6:6];
    assign ovv = ova[1:1];
    assign ovf = ovb[1:1];
    assign dummy_result = a_register - b_register - ~c_carry;
    assign asl_z = ({c_carry, a_register, 1'b0} << 1);
    assign lsr_z = ({1'b0, a_register, c_carry} >> 1);
    assign rol_z = ({dummy_bit, a_register, c_carry} << 1);
    assign ror_z = ({c_carry, a_register, dummy_bit} >> 1);
    
    assign {n, v, X, b, d, i, z, c} = psr_to_id;
    
     /* Main ALU Sequence */
    always_latch begin
 
    
        if (instruction_decode_in) begin
            b_register <= db_in;
            
        end
        if (acc_to_alu_xfer) begin
            a_register <= accumulator_in;
            
        end
        if (addr_to_alu_xfer) begin
            c_register <= address_in;
            
        end
        
        if (swap_a_b) begin
            a_register <= b_register;
            b_register <= a_register;
        end
        else if (swap_b_c) begin
            c_register <= b_register;
            b_register <= c_register;
        end
        
        if (ack_update_request)
            psr_update_request <= 0;
    /*============================================*/
    /*============================================*/
        if (compute_step) begin
        /* Start Compute Sequences */
        
            if (operation_select == 8'h00) begin // AND
                a_register <= a_register & b_register; 
                {n_result, dummy} <= (a_register & b_register);
                z_result <= ((a_register & b_register) == 0);
                v_result <= v;
                c_result <= c; 
                psr_update_request <= 1;
            end    
            
            else if (operation_select == 8'h01) begin // ORA
                a_register <= a_register | b_register; 
                {n_result, dummy} <= a_register | b_register;
                z_result <= ((a_register | b_register) == 0);
                v_result <= v;
                c_result <= c; 
                psr_update_request <= 1;
            end   
            
            else if (operation_select == 8'h02) begin // EOR
                a_register <= a_register ^ b_register; 
                {n_result, dummy} <= a_register ^ b_register;
                z_result <= ((a_register ^ b_register) == 0);
                v_result <= v;
                c_result <= c; 
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h03) begin // ADC
                {c_result, a_register} <= a_register + b_register + c_carry; 
                {n_result, dummy} <= a_register + b_register + c_carry;
                v_result <= (ovf ^ ovv); 
                z_result <= ((a_register + b_register + c_carry) == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h04) begin // SBC
                a_register <= a_register - b_register - ~c_carry; 
                c_result <= (a_register >= (b_register + ~c_carry));
                {n_result, dummy} <= a_register - b_register - ~c_carry;
                v_result <= scratch_register < underflow; 
                z_result <= ((a_register - b_register - ~c_carry) == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h05) begin // ASL
                {c_result, b_register, dummy_bit} <= ({c_carry, b_register, 1'b0} << 1); 
                n_result <= asl_z[8:8];
                v_result <= v; 
                z_result <= (asl_z[8:1]) == 0;
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h06) begin // LSR
                {dummy_bit, b_register, c_result} <= ({1'b0, b_register, c_carry} >> 1); 
                n_result <= 0;
                v_result <= v; 
                z_result <= ((lsr_z[8:1]) == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h07) begin // ROL
                {c_result, b_register, dummy_bit} <= ({dummy_bit, b_register, c_carry} << 1); 
                n_result <= rol_z[8:8];
                v_result <= v; 
                z_result <= (rol_z[8:1] == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h08) begin // ROR
                {dummy_bit, b_register, c_result} <= ({c_carry, b_register, dummy_bit} >> 1); 
                n_result <= (ror_z[8:8]);
                v_result <= v; 
                z_result <= (ror_z[8:1] == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h09) begin // BIT
                c_result <= c; 
                n_result <= (b_register[7:7]);
                v_result <= (b_register[6:6]); 
                z_result <= ((a_register & b_register) == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h0a) begin // CMP
                c_result <= (a_register >= b_register); 
                {n_result, dummy} <= (a_register - b_register);
                v_result <= v; 
                z_result <= ((a_register - b_register) == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h0b) begin // TSB
                b_register <= a_register | b_register; 
                c_result <= c;
                n_result <= n;
                v_result <= v; 
                z_result <= ((a_register & b_register) == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h0c) begin // TRB
                b_register <= (~a_register) & b_register; 
                c_result <= c;
                n_result <= n;
                v_result <= v; 
                z_result <= ((a_register & b_register) == 0);
                psr_update_request <= 1;
            end
            
            else if (operation_select == 8'h0d) begin // Decimal to Binary
                a_register <= a_temp;
                b_register <= b_temp;
            end
            
            else if (operation_select == 8'h0e) begin // Binary to Decimal
                a_register <= a_temp_a;
                b_register <= b_temp_b;
            end
            
    /* End Compute Sequences */
        end

   end 
   
    assign address_out = c_register;
    assign db_out = b_register;
    assign accumulator_out = a_register;
    
bcd2bin bcdbi_a
   (
    .bcd1(a_register[7:4]), 
    .bcd0(a_register[3:0]), 
    .bin(a_temp)
   );    
   
bcd2bin bcdbi_b
   ( 
    .bcd1(b_register[7:4]), 
    .bcd0(b_register[3:0]),
    .bin(b_temp)
   );  

bin2bcd binbc_a(
   .bin(a_register),
   .bcd(a_temp_a)
   );
    
bin2bcd binbc_b(
   .bin(b_register),
   .bcd(b_temp_b)
   );
   
    c_addsub_0 sbc_overflow (
  .A(a_register),        // input wire [7 : 0] A
  .B(b_register),        // input wire [7 : 0] B
  .CLK(mem_clk),    // input wire CLK
  .C_IN(c_carry),  // input wire C_IN
  .S(scratch_register)        // output wire [8 : 0] S
);
    

    
endmodule
