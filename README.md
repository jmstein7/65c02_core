# 65c02_core
This is a work in progress, hopefully a 65c02 core implementing the 65c02 ISA. This is an early alpha and, while all the connections between the various registers and signals are there, the control logic, and the ISA, has not yet been implemented. My first shot at the ALU is done, and it is ready to test.

Right now, I'm designing for the Xilinx Artix-7 series, with a CMOD A7 stand-in for the moment (because it has SRAM onboard).

If you want to simulate timing and function, make sure to cycle "reset" once before starting. 
