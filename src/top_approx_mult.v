`timescale 1ns / 1ps

module top_approx_mult_urbana (
    input  wire        CLK_100MHZ,
    input  wire [15:0] SW,
    output reg  [15:0] LED
);

    wire [7:0] a;
    wire [7:0] b;
    wire [15:0] product_approx;

    assign a = SW[7:0];
    assign b = SW[15:8];

    approx_mult_8bit u_approx (
        .a      (a),
        .b      (b),
        .product(product_approx)
    );

    always @(posedge CLK_100MHZ) begin
        LED <= product_approx;
    end

endmodule
