`timescale 1ns / 1ps

module BR_Test_Unit(input wire A,
               input wire B,
               output wire BR_TAKE);
               
assign BR_TAKE = (A==B);

endmodule
