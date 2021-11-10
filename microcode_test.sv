`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2021 06:30:52 PM
// Design Name: 
// Module Name: microcode_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module microcode_test(
    input logic fclk,
    input logic clock_running,
    output logic [3:0] signal_set,
    output logic [7:0] data_bus_set,
    output logic [5:0] address_bus_set,
    output logic [15:0] load_store_execute,
    output logic [5:0] alu_operations_regs,
    output logic [9:0] inc_dec_clr,
    output logic [7:0] status_flags,
    output logic [4:0] vector_operations
    );
    
    logic [2:0] step_count = 0;
    
    logic [4:0] start_reset = 5'b11000;
    logic [4:0] start_nmib = 5'b10100;
    logic [4:0] start_irqb = 5'b10010;
    logic [4:0] start_stack = 5'b00001;
    logic [4:0] start_null = 5'b00000;
    
    /* Status Flags */
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
    logic [3:0] set_vpb = 4'b1000; //3
    logic [3:0] set_sync = 4'b0100; //2
    logic [3:0] set_mlb = 4'b0010; //1
    logic [3:0] set_rwb = 4'b0001; //0
    logic [3:0] set_none = 4'b0001; //Null
    
    always @(posedge fclk) begin
    if (clock_running) begin
        
        if (step_count == 0) begin
        signal_set <= set_rwb;
        data_bus_set <= {read_bz, write_bz};
        address_bus_set <= {addh_pcH, addl_pcL};
        load_store_execute <= no_op_hold;
        alu_operations_regs <= {alu_reg_hold, null_a_b};
        inc_dec_clr <= clear_idl;
        status_flags <= null_flag;
        vector_operations <= start_null;
        end
        else if (step_count == 1) begin
        signal_set <= set_rwb;
        data_bus_set <= {read_dbuff, write_a};
        address_bus_set <= {addh_pcH, addl_pcL};
        load_store_execute <= (load_bus_buffer | load_a | update_status);
        alu_operations_regs <= {alu_reg_hold, null_a_b};
        inc_dec_clr <= no_change;
        status_flags <= null_flag;
        vector_operations <= start_null;
        end
        
        step_count <= step_count + 1;
    end
    end
    
endmodule
