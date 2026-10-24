/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_switcherCpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);


  GP_REG reg(
    .clk(clk),
    .rst(~rst_n),
    .a(uio_out),
    .b(uio_out),
    .c(uio_out),
    .d(uio_out),
    .ien(ui_in[0]),
    .isel(ui_in[2:1]),

    .q(uio_out),
  );

  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in ^ uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  //assign uio_out = 0;
  assign uio_oe  = 1;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule


module GP_REG #(parameter W=8) (
  input wire [W-1:0]a,
  input wire [W-1:0]b,
  input wire [W-1:0]c,
  input wire [W-1:0]d,

  input wire [1:0]isel,
  input wire clk,
  input wire rst,
  input wire ien,

  output reg [W-1:0]q
);


always @(negedge clk) begin
  if (rst) begin
    q <= 0;
  end else if (ien) begin
    case (isel)
      0: q <= a;
      1: q <= b;
      2: q <= c;
      3: q <= d;
      default: q <= q;
    endcase
  end
end


endmodule;