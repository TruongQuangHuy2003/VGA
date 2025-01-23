module vga_generator #(
	parameter H_RES = 640,	// Do phan giai ngang
	parameter V_RES = 480,	// Do phan giai doc
	parameter H_FP = 16,	// Front porch ngang
	parameter H_SYNC = 96,	// Sync pulse ngang
	parameter H_BP = 48,	// Back porch ngang
	parameter V_FP = 10,	// Front porch doc
	parameter V_SYNC = 2,	// Sync pulse doc
	parameter V_BP = 33	// Back porch doc
)(
	input wire clk,		// Tin hieu xung clock
	input wire rst_n,	// Tin hieu reset (active low)
	output reg hsync,	// Tin hieu dong bo ngang
	output reg vsync,	// Tin hieu dong bo doc
	output reg [10:0] pixel_x,	// Vi tri pixel ngang
	output reg [9:0] pixel_y,	// Vi tri pixel doc
	output reg video_active,	// Tin hieu hien thi hop le
	output reg [7:0] rgb_r,		// Thanh phan mau do,
	output reg [7:0] rgb_g,		// Thanh phan mau xanh la
	output reg [7:0] rgb_b		// Thanh phan mau xanh duong
);

// Tong so pixel ngang va doc
localparam H_TOTAL = H_RES + H_FP + H_SYNC + H_BP;
localparam V_TOTAL = V_RES + V_FP + V_SYNC + V_BP;

// Bo dem pixel
reg [10:0] h_counter;	// Bo dem ngang
reg [9:0] v_counter;	// Bo dem doc.

// Dem pixel va dong
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		h_counter <= 11'h000;
		v_counter <= 10'h000;
	end else begin
		if(h_counter == H_TOTAL - 1'b1) begin
			h_counter <= 11'h000;
			if(v_counter == V_TOTAL - 1'b1) begin
				v_counter <= 10'h000;
			end else begin
				v_counter <= v_counter + 1'b1;
			end
		end else begin
			h_counter <= h_counter + 1'b1;
		end
	end
end

// Tao tin hieu hsync va vsync 
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		hsync <= 1'b1;
		vsync <= 1'b1;
	end else begin
		hsync <= (h_counter >= H_RES + H_FP && h_counter < H_RES + H_FP + H_SYNC) ? 1'b0 : 1'b1;
		vsync <= (v_counter >= V_RES + V_FP && v_counter < V_RES + V_FP + V_SYNC) ? 1'b0 : 1'b1;
	end
end

// Xac dinh vung dia chi
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		video_active <= 1'b0;
		pixel_x <= 11'h000;
		pixel_y <= 10'h000;
	end else begin
		video_active <= (h_counter < H_RES) && (v_counter < V_RES);
		pixel_x <= (video_active) ? h_counter : 1'b0;
		pixel_y <= (video_active) ? v_counter : 1'b0;
	end
end

// Tao tin hieu RGB
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rgb_r <= 8'h00;
		rgb_g <= 8'h00;
		rgb_b <= 8'h00;
	end else if (video_active) begin
		// Hien thi gradien mau theo vi tri pixel
		rgb_r <= pixel_x[7:0];	// mau do theo toa do x
		rgb_g <= pixel_y[7:0];	// mau xanh theo toa do y
		rgb_b <= pixel_x[7:0] + pixel_y[7:0];   // mau xanh la tong hop toa do x va y
	end else begin
		rgb_r <= 8'h00;
		rgb_g <= 8'h00;
		rgb_b <= 8'h00;
	end
end

endmodule

