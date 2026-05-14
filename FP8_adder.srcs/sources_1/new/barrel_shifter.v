module barrel_shifter_4bit (
    input wire [3:0] i,
    input wire [3:0] sftamt,
    output wire [6:0] o
);
    wire [6:0] shifted_val;
    wire sticky;
    
    assign shifted_val = {i, 3'b000} >> sftamt;
    assign sticky = shifted_val[0] | ((sftamt > 4'd6) && (i != 0));
    assign o = {shifted_val[6:1], sticky};
endmodule