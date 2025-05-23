`timescale 1us/1ns

module NWCC(
    input i_clk_1mhz, i_pulse_signal, i_reset,
    output [12:0] o_r_plus_a_count, o_a_count, o_total_count
);
    wire [12:0] w_cnt1, w_cnt2, w_sub, w_add1, w_add2;
    wire w_a, w_b, w_c;                                                   		//a-->8us delay    b-->128us delay   c-->1024us delay
    
    assign o_total_count = w_cnt1; 
     
    delay8 d1(i_clk_1mhz, i_reset, i_pulse_signal, w_a);
    delay128 d2(i_clk_1mhz, i_reset, w_a, w_b);
    delay1024 d3(i_clk_1mhz, i_reset, i_pulse_signal, w_c);
         
    counter_13bit c1(w_a, i_reset, w_cnt1);
    counter_13bit c2(w_b, i_reset, w_cnt2);
    w_subtractor_13bit w_sub1(w_cnt1, w_cnt2, w_sub);
    adder_13bit w_add1(w_sub, o_r_plus_a_count, w_add1);                     	// R+A adder
    adder_13bit w_add2(w_sub, o_a_count, w_add2);                      			// A adder
    register_13bit reg1(i_pulse_signal, i_reset, w_add1, o_r_plus_a_count);     // R+A register
    register_13bit reg2(w_c, i_reset, w_add2, o_a_count);  						//A register   
	
endmodule

////////////////////////////////////////////////////////////// Counter Unit

module counter_13bit(
    input clk, reset,
    output reg [12:0] count
);
    always @(posedge clk, posedge reset) begin
    if (reset)
        count <= 13'd0;
    else
        count <= count + 1'b1;
    end 
endmodule

///////////////////////////////////////////////////////////// Subtractor Unit

module w_subtractor_13bit(
    input [12:0] num1, num2,
    output [12:0] result
);
    assign result = num1 - num2;   
endmodule

///////////////////////////////////////////////////////////// Adder Unit

module adder_13bit(
    input [12:0] num1, num2,
    output [12:0] result
);
    assign result = num1 + num2;   
endmodule

//////////////////////////////////////////////////////////// Register Unit

module register_13bit(
    input clk, reset,
    input [12:0] inp,
    output reg [12:0] out
);
    always @(posedge clk or posedge reset) begin
        if(reset)
            out <= 13'd0;
        else
            out <= inp;
    end 
endmodule

//////////////////////////////////////////////////////////// Delayers

//////////////////// 8us delay
module delay8 (
input clk, reset, inp, 
output out
);
    reg [7:0] shifter;
    assign out = shifter[7];
    always @(posedge clk or posedge reset) begin
        if(reset)
            shifter <= 8'd0;
        else
            shifter <= {shifter[6:0], inp};
    end
endmodule       
/////////////////// 128us delay 
module delay128 (
input clk, reset, inp, 
output out
);
    reg [127:0] shifter;
    assign out = shifter[127];
    always @(posedge clk or posedge reset) begin
        if(reset)
            shifter <= 128'd0;
        else
            shifter <= {shifter[126:0], inp};
    end
endmodule                   
///////////////// 1024us delay 
module delay1024 (
input clk, reset, inp, 
output out
);
    reg [1023:0] shifter;
    assign out = shifter[1023];
    always @(posedge clk or posedge reset) begin
        if(reset)
            shifter <= 1024'd0;
        else
            shifter <= {shifter[1022:0], inp};
    end
endmodule



