`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2021 04:36:41 PM
// Design Name: 
// Module Name: bcd_to_bin
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


module bcd2bin
   (
    //input wire [3:0] bcd3, 
    //input wire [3:0] bcd2, 
    input wire [3:0] bcd1, 
    input wire [3:0] bcd0, 
    output wire [7:0] bin
   );

   //assign bin = (bcd3 * 10'd1000) + (bcd2*7'd100) + (bcd1*4'd10) + bcd0;
   
   assign bin = (bcd1*4'd10) + bcd0;

endmodule
