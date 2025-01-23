### VGA Signal Generator 
This document explains the theoretical background and functionality of the `vga_generator` module, which generates VGA signals. Below are detailed explanations of the core concepts, parameters, and functionality implemented in the code:

---

### **1. VGA Signal Basics**
VGA (Video Graphics Array) is a standard for displaying graphics. A VGA display requires the generation of synchronization signals and pixel data in accordance with specific timing requirements:
- **Horizontal Synchronization (hsync):** Controls the timing for horizontal lines.
- **Vertical Synchronization (vsync):** Controls the timing for vertical frame refresh.
- **Video Active:** Defines the active display area where pixels are drawn.
- **RGB Signals:** Carry color data for each pixel.

---

### **2. Module Parameters**
The `vga_generator` module uses parameters to configure the resolution and timing for VGA signals:
- **H_RES:** Horizontal resolution (e.g., 640 pixels for standard VGA).
- **V_RES:** Vertical resolution (e.g., 480 pixels for standard VGA).
- **H_FP, H_SYNC, H_BP:** Horizontal front porch, sync pulse, and back porch timings.
- **V_FP, V_SYNC, V_BP:** Vertical front porch, sync pulse, and back porch timings.

The total horizontal and vertical pixels include the resolution and porch/sync areas:
- `H_TOTAL = H_RES + H_FP + H_SYNC + H_BP`
- `V_TOTAL = V_RES + V_FP + V_SYNC + V_BP`

---

### **3. Pixel Counters**
The module includes counters to track the current horizontal and vertical pixel positions:
- **h_counter:** Tracks the horizontal position within a line.
- **v_counter:** Tracks the vertical position within a frame.

The counters are incremented with every clock cycle:
- When `h_counter` reaches `H_TOTAL`, it resets, and `v_counter` increments.
- When `v_counter` reaches `V_TOTAL`, it resets, starting a new frame.

---

### **4. Synchronization Signal Generation**
Synchronization signals are generated based on the counters:
- **Horizontal Sync (hsync):** Active low during the horizontal sync pulse period.
- **Vertical Sync (vsync):** Active low during the vertical sync pulse period.
  
The code uses conditional logic to determine whether the counters are within the sync pulse range.

---

### **5. Active Display Area**
The `video_active` signal indicates whether the current pixel is within the active display area:
- `video_active` is high when `h_counter` is less than `H_RES` and `v_counter` is less than `V_RES`.

Additionally:
- **pixel_x:** Tracks the x-coordinate of the current pixel in the active area.
- **pixel_y:** Tracks the y-coordinate of the current pixel in the active area.

---

### **6. RGB Signal Generation**
The module outputs RGB signals during the active display period. The color for each pixel is generated based on its position:
- `rgb_r` (Red): Uses the 8 least significant bits of `pixel_x`.
- `rgb_g` (Green): Uses the 8 least significant bits of `pixel_y`.
- `rgb_b` (Blue): A combination of `pixel_x` and `pixel_y` values.

Outside the active display area, RGB signals are set to zero.

---

### **7. Reset Behavior**
The module supports an asynchronous active-low reset (`rst_n`):
- When `rst_n` is low:
  - Counters reset to zero.
  - Synchronization signals (`hsync`, `vsync`) default to inactive states.
  - RGB signals are cleared.

---

### **8. Timing Configuration**
The timing parameters must be carefully selected to meet the VGA standard. For example, a standard 640x480 VGA display uses:
- Horizontal: 
  - Resolution = 640 pixels
  - Front Porch = 16 pixels
  - Sync Pulse = 96 pixels
  - Back Porch = 48 pixels
  - Total = 800 pixels
- Vertical:
  - Resolution = 480 lines
  - Front Porch = 10 lines
  - Sync Pulse = 2 lines
  - Back Porch = 33 lines
  - Total = 525 lines

---

### **9. Output Signals**
- **hsync:** Horizontal sync pulse, active low.
- **vsync:** Vertical sync pulse, active low.
- **pixel_x:** Current x-coordinate in the active display area.
- **pixel_y:** Current y-coordinate in the active display area.
- **video_active:** Indicates whether the current position is within the visible area.
- **rgb_r, rgb_g, rgb_b:** RGB color signals for the current pixel.

---

### **10. Summary**
This module is a fully parameterized VGA signal generator that can be customized for different resolutions and timings. It provides:
- Precise control of synchronization signals.
- Generation of video signals with RGB color gradients based on pixel position.
- Compatibility with various display resolutions through parameter configuration.
