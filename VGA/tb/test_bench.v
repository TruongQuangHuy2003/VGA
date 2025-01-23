`timescale 1ns/1ps
module test_bench;
	parameter H_RES = 640;
	parameter V_RES = 480;
	parameter H_FP = 16;
	parameter H_SYNC = 96;
	parameter H_BP = 48;
	parameter V_FP = 10;
	parameter V_SYNC = 2;
	parameter V_BP = 33;

	parameter CLK_PERIOD = 10;	//100mhz clock

	reg clk;
	reg rst_n;
	wire hsync;
	wire vsync;
	wire [10:0] pixel_x;
	wire [9:0] pixel_y;
	wire video_active;
	wire [7:0] rgb_r;
	wire [7:0] rgb_g;
	wire [7:0] rgb_b;

	// Instance of DUT
	vga_generator #(
		.H_RES(H_RES),
		.V_RES(V_RES),
		.H_FP(H_FP),
		.H_SYNC(H_SYNC),
		.H_BP(H_BP),
		.V_FP(V_FP),
		.V_SYNC(V_SYNC),
		.V_BP(V_BP)
	) dut (
		.clk(clk),
		.rst_n(rst_n),
		.hsync(hsync),
		.vsync(vsync),
		.pixel_x(pixel_x),
		.pixel_y(pixel_y),
		.video_active(video_active),
		.rgb_r(rgb_r),
		.rgb_g(rgb_g),
		.rgb_b(rgb_b)
	);

	localparam H_TOTAL = H_RES + H_FP + H_SYNC + H_BP;
	localparam V_TOTAL = V_RES + V_FP + V_SYNC + V_BP;

	initial begin
		clk = 0;
		forever #(CLK_PERIOD/2) clk = ~clk;
	end
	
	task verify;
		input exp_hsync;
		input exp_vsync;
		input [10:0] exp_pixel_x;
		input [9:0] exp_pixel_y;
		input exp_video_active;
		input [7:0] exp_rgb_r;
		input [7:0] exp_rgb_g;
		input [7:0] exp_rgb_b;
		begin
			$display("At time: %t", $time);
			if(hsync == exp_hsync && vsync == exp_vsync && pixel_x == exp_pixel_x && pixel_y == exp_pixel_y && rgb_r == exp_rgb_r && rgb_g == exp_rgb_g && rgb_b == exp_rgb_b) begin
			     $display("-----------------------------------TESTCASE PASSED-------------------------------------------------------");
			     $display("Expected hsync: 1'b%b, Got hsync: 1'b%b, Expected vsync: 1'b%b, Got vsync: 1'b%b",exp_hsync, hsync, exp_vsync, vsync);
			     $display("Expected pixel x: 11'h%h, Got pixel x: 11'h%h, Expected pixel y: 10'h%h, Got pixel y: 10'h%h", exp_pixel_x, pixel_x, exp_pixel_y, pixel_y);
			     $display("Expected rgb_r: 8'h%h, Got rgb_r: 8'h%h, Expected rgb_g: 8'h%h, Got rgb_g: 8'h%h, Expected rgb_b: 8'h%h, Got rgb_b: 8'h%h", exp_rgb_r, rgb_r, exp_rgb_g, rgb_g, exp_rgb_b, rgb_b);
			     $display("---------------------------------------------------------------------------------------------------------");
		     end else begin
			     $display("-----------------------------------TESTCASE FAILED-------------------------------------------------------");
			     $display("Expected hsync: 1'b%b, Got hsync: 1'b%b, Expected vsync: 1'b%b, Got vsync: 1'b%b",exp_hsync, hsync, exp_vsync, vsync);
			     $display("Expected pixel x: 11'h%h, Got pixel x: 11'h%h, Expected pixel y: 10'h%h, Got pixel y: 10'h%h", exp_pixel_x, pixel_x, exp_pixel_y, pixel_y);
			     $display("Expected rgb_r: 8'h%h, Got rgb_r: 8'h%h, Expected rgb_g: 8'h%h, Got rgb_g: 8'h%h, Expected rgb_b: 8'h%h, Got rgb_b: 8'h%h", exp_rgb_r, rgb_r, exp_rgb_g, rgb_g, exp_rgb_b, rgb_b);
			     $display("---------------------------------------------------------------------------------------------------------");
		     end
	     end
     endtask

	initial begin
		$dumpfile("test_bench.vcd");
		$dumpvars(0, test_bench);

		$display("-----------------------------------------------------------------------------------------------------------------------------------------");
		$display("---------------------------------- TESTBENCH FOR VGA SIGNAL GENERATOR -------------------------------------------------------------------");
		$display("-----------------------------------------------------------------------------------------------------------------------------------------");

		rst_n = 0;
		@(posedge clk);
		verify(1'b1, 1'b1,11'h000, 10'h000, 1'b0,8'h00, 8'h00, 8'h00);

		rst_n = 1;
		@(posedge clk);
		verify(1'b1, 1'b1,11'h000, 10'h000, 1'b0,8'h00, 8'h00, 8'h00);

		repeat(H_RES + H_FP) @(posedge clk);
		verify(1'b0, 1'b1,11'h000, 10'h000, 1'b0,8'h00, 8'h00, 8'h00);
		
		repeat(H_TOTAL - H_RES - H_FP) @(posedge clk);
		verify(1'b1, 1'b1,11'h000, 10'h000, 1'b1,8'h00, 8'h00, 8'h00);
		
		repeat(50) @(posedge clk);
		verify(1'b1, 1'b1,11'd50, 10'h001, 1'b1,8'd49, 8'h01, 8'd50);
		
		repeat(600) @(posedge clk);
		verify(1'b1, 1'b1, 11'h000, 10'h000, 1'b0, 8'h00, 8'h00, 8'h00);
		
		repeat(6) @(posedge clk);
		verify(1'b0, 1'b1,11'h000, 10'h000, 1'b0, 8'h00, 8'h00, 8'h00);
		
		rst_n = 0;
		@(posedge clk);

		rst_n = 1;
		repeat(V_RES) @(posedge clk);
		verify(1'b1, 1'b1, V_RES - 1, 10'h000, 1'b1,V_RES - 2, 8'h00, V_RES - 2);

		#100;
		$finish;

	end
endmodule

