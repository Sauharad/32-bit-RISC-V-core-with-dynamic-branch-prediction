`timescale 1ns / 1ps

module BHT(input wire clk,
           input wire [4:0] PC_lower_predict,
           input wire [4:0] PC_lower_update,
           input wire update,
           input wire update_direction,
           input wire start,
           output wire take_branch);
           
reg [0:31] BHTable [1:0];

assign take_branch = (BHTable[PC_lower_predict] == 2'b10 || BHTable[PC_lower_predict] == 2'b11);

integer i;
always @(posedge start)
    for (i=0;i<256;i=i+1)
        begin
            BHTable[i] = 2'b01;
        end
    
always @(*)
    begin
        if (update == 1'b1)
            begin
                if (update_direction == 1'b1 && BHTable[PC_lower_update] != 2'b11)
                    BHTable[PC_lower_update] = BHTable[PC_lower_update] + 1;
                if (update_direction == 1'b0 && BHTable[PC_lower_update] != 2'b00)
                    BHTable[PC_lower_update] = BHTable[PC_lower_update] - 1;    
            end
    end   
    
endmodule
