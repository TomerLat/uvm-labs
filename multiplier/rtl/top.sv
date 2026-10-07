`timescale 1ns / 1ps

///////////////////////////

module top(mul_if.dut m);

    assign m.y = m.a + m.b;
endmodule

///////////////////////////

interface mul_if;

    logic [3:0] a, b;
    logic [4:0] y;
    
    modport dut (input a, b, output y);

endinterface
