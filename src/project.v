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

  GP_REG r0(
    .clk(clk),
    .rst(~rst_n),
    .a(uio_in),
    .b(uio_in),
    .c(uio_in),
    .d(uio_in),
    .ien(ui_in[0]),
    .isel(ui_in[2:1]),

    .q(uio_out)
  );

  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in ^ uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  //assign uio_out = 0;
  assign uio_oe = ui_in[3];
  assign uo_out = uio_out;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:4], 1'b0};

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

wire [3:0]enables;
wire [W-1:0]dIn;

Encoder2to4 enc(
  .a(isel),
  .y(enables)
);

Mux4to1 mux1(
  .a(a),
  .b(b),
  .c(c),
  .d(d),
  .isel(enables),

  .y(dIn)
);

always @(negedge clk) begin
  if (rst) begin
    q <= 0;
  end else if (ien) begin
    q <= dIn;
  end else begin
    q <= q;
  end
end

endmodule

module Encoder2to4 (
  input wire [1:0]a,
  output wire [3:0]y
);

assign y[0] = ~a[0] & ~a[1];
assign y[1] =  a[0] & ~a[1];
assign y[2] = ~a[0] &  a[1];
assign y[3] =  a[0] &  a[1];

endmodule

module Mux4to1 #(parameter W=8) (
  input wire [W-1:0]a,
  input wire [W-1:0]b,
  input wire [W-1:0]c,
  input wire [W-1:0]d,
  input wire [3:0]isel,

  output wire [W-1:0]y
);

genvar i;
generate for (i = 0; i < W; i = i + 1) begin
  assign y[i] = (((a[i] & isel[0]) | (b[i] & isel[1])) | ((c[i] & isel[2]) | (d[i] & isel[3])));
end
endgenerate

endmodule