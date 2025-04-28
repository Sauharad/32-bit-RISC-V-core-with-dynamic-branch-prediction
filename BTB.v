`timescale 1ns / 1ps

module BTB(input wire clk,
           input wire [31:0] PC_predict,
           input wire [31:0] PC_update,
           input wire update,
           input wire [31:0] target_address_update,
           input wire start,
           output reg [31:0] target_address_predict,
           output reg hit);

reg [0:56] BTBuffer [0:31][0:3];

reg [11:0] priority_halving_counter;


integer i,j;
always @(posedge start)
    begin
        for (i=0;i<32;i=i+1)
            for (j=0;j<4;j=j+1)
                BTBuffer[i][j] = 56'h00000000000000;
        priority_halving_counter = 12'h000;
        hit = 1'b0;
    end

always @(posedge clk)
    priority_halving_counter <= priority_halving_counter + 1;
    
wire halve_now = (priority_halving_counter == 12'hfff);

always @(posedge halve_now)
    for (i=0;i<32;i=i+1)
        for (j=0;j<4;j=j+1)
            BTBuffer[i][j][49:56] = BTBuffer[i][j][49:56] >>> 1;

reg [1:0] hit_loc;

 
wire a_lowest =  ((BTBuffer[PC_update[4:0]][0][49:56] < BTBuffer[PC_update[4:0]][1][49:56]) &&
                  (BTBuffer[PC_update[4:0]][0][49:56] < BTBuffer[PC_update[4:0]][2][49:56]) &&
                  (BTBuffer[PC_update[4:0]][0][49:56] < BTBuffer[PC_update[4:0]][3][49:56]));
wire b_lowest =  ((BTBuffer[PC_update[4:0]][1][49:56] < BTBuffer[PC_update[4:0]][0][49:56]) &&
                  (BTBuffer[PC_update[4:0]][1][49:56] < BTBuffer[PC_update[4:0]][2][49:56]) &&
                  (BTBuffer[PC_update[4:0]][1][49:56] < BTBuffer[PC_update[4:0]][3][49:56]));

wire c_lowest =  ((BTBuffer[PC_update[4:0]][2][49:56] < BTBuffer[PC_update[4:0]][1][49:56]) &&
                  (BTBuffer[PC_update[4:0]][2][49:56] < BTBuffer[PC_update[4:0]][0][49:56]) &&
                  (BTBuffer[PC_update[4:0]][2][49:56] < BTBuffer[PC_update[4:0]][3][49:56]));

wire d_lowest =  ((BTBuffer[PC_update[4:0]][3][49:56] < BTBuffer[PC_update[4:0]][1][49:56]) &&
                  (BTBuffer[PC_update[4:0]][3][49:56] < BTBuffer[PC_update[4:0]][2][49:56]) &&
                  (BTBuffer[PC_update[4:0]][3][49:56] < BTBuffer[PC_update[4:0]][0][49:56]));

wire ab_equal = (BTBuffer[PC_update[4:0]][0][49:56] == BTBuffer[PC_update[4:0]][1][49:56]);
wire ac_equal = (BTBuffer[PC_update[4:0]][0][49:56] == BTBuffer[PC_update[4:0]][2][49:56]);
wire ad_equal = (BTBuffer[PC_update[4:0]][0][49:56] == BTBuffer[PC_update[4:0]][3][49:56]);
wire bc_equal = (BTBuffer[PC_update[4:0]][1][49:56] == BTBuffer[PC_update[4:0]][2][49:56]);
wire bd_equal = (BTBuffer[PC_update[4:0]][1][49:56] == BTBuffer[PC_update[4:0]][3][49:56]);
wire cd_equal = (BTBuffer[PC_update[4:0]][2][49:56] == BTBuffer[PC_update[4:0]][3][49:56]);

always @(*)
    begin
        if (PC_predict != PC_update)
            begin
                for (i=0;i<4;i=i+1)
                    begin
                        if ({BTBuffer[PC_predict[4:0]][i][0:15],BTBuffer[PC_predict[4:0]][i][48]} == {PC_predict[20:5],1'b1})
                            begin
                                hit = 1'b1;
                                target_address_predict = BTBuffer[PC_predict[4:0]][i][16:47];
                                if (BTBuffer[PC_predict[4:0]][i][49:56] != 8'hff)
                                    BTBuffer[PC_predict[4:0]][i][49:56] = BTBuffer[PC_predict[4:0]][i][49:56] + 1;
                            end 
                    end
                if ({BTBuffer[PC_predict[4:0]][0][0:15],BTBuffer[PC_predict[4:0]][0][48]} == {PC_predict[20:5],1'b1} &&
                    {BTBuffer[PC_predict[4:0]][1][0:15],BTBuffer[PC_predict[4:0]][1][48]} == {PC_predict[20:5],1'b1} &&
                    {BTBuffer[PC_predict[4:0]][2][0:15],BTBuffer[PC_predict[4:0]][2][48]} == {PC_predict[20:5],1'b1} &&
                    {BTBuffer[PC_predict[4:0]][3][0:15],BTBuffer[PC_predict[4:0]][3][48]} == {PC_predict[20:5],1'b1})
                    hit = 1'b0;
                    
                if (update)
                    begin
                        for (j=0;j<4;j=j+1)
                            begin
                                if (BTBuffer[PC_update[4:0]][j][0:15] == PC_update[20:5])
                                    begin
                                        BTBuffer[PC_update[4:0]][j][48] = 1'b1;
                                        if (BTBuffer[PC_update[4:0]][j][49:56] != 8'hff)
                                            BTBuffer[PC_update[4:0]][j][49:56] = BTBuffer[PC_update[4:0]][j][49:56] + 1;
                                    end
                            end
                        if (BTBuffer[PC_update[4:0]][0][0:15] != PC_update[20:5] &&
                            BTBuffer[PC_update[4:0]][1][0:15] != PC_update[20:5] &&
                            BTBuffer[PC_update[4:0]][2][0:15] != PC_update[20:5] &&
                            BTBuffer[PC_update[4:0]][3][0:15] != PC_update[20:5])
                            begin
                                if (a_lowest)
                                    BTBuffer[PC_update[4:0]][0] = {PC_update[20:5],target_address_update,1'b1,8'h01};
                                else if (b_lowest)
                                    BTBuffer[PC_update[4:0]][1] = {PC_update[20:5],target_address_update,1'b1,8'h01};
                                else if (c_lowest)
                                    BTBuffer[PC_update[4:0]][2] = {PC_update[20:5],target_address_update,1'b1,8'h01};
                                else if (d_lowest)
                                    BTBuffer[PC_update[4:0]][3] = {PC_update[20:5],target_address_update,1'b1,8'h01};
                                else
                                    begin
                                        if (ab_equal || ac_equal || ad_equal)
                                            BTBuffer[PC_update[4:0]][0] = {PC_update[20:5],target_address_update,1'b1,8'h01};
                                        if (bc_equal || bd_equal)
                                            BTBuffer[PC_update[4:0]][1] = {PC_update[20:5],target_address_update,1'b1,8'h01};
                                        if (cd_equal)
                                            BTBuffer[PC_update[4:0]][2] = {PC_update[20:5],target_address_update,1'b1,8'h01};
                                    end
                            end
                    end  
            end
        if (PC_predict == PC_update)
            begin
            end             
    end

    
endmodule
