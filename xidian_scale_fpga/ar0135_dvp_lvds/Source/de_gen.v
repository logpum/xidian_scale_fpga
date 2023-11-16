module de_gen (
  input wire clk,       // 时钟信号
  input wire rst,       // 复位信号
  input wire hsync,     // 水平同步信号
  input wire vsync,     // 垂直同步信号
  output reg de        // 数据使能信号
);

  // 分辨率参数
  parameter H_DISPLAY = 1024;  // 水平显示区域像素数
  parameter H_FRONT_PORCH = 160; // 水平前肩像素数
  parameter H_SYNC_PULSE = 32;  // 水平同步脉冲像素数
  parameter H_BACK_PORCH = 144; // 水平后肩像素数
  parameter H_TOTAL = 1344;    // 总水平像素数

  parameter V_DISPLAY = 600;   // 垂直显示区域像素数
  parameter V_FRONT_PORCH = 23;  // 垂直前肩像素数
  parameter V_SYNC_PULSE = 3;  // 垂直同步脉冲像素数
  parameter V_BACK_PORCH = 15;  // 垂直后肩像素数
  parameter V_TOTAL = 628;     // 总垂直像素数

  reg [10:0] horizontal_counter;  // 水平计数器
  reg [10:0] vertical_counter;    // 垂直计数器

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      horizontal_counter <= 11'd0;
      vertical_counter <= 11'd0;
      de <= 1'b0;
    end else begin
      // 水平计数器递增
      if (hsync) begin
        if (horizontal_counter < H_TOTAL - 1) begin
          horizontal_counter <= horizontal_counter + 1;
        end else begin
          horizontal_counter <= 11'd0;
          // 垂直计数器递增
          if (vsync) begin
            if (vertical_counter < V_TOTAL - 1) begin
              vertical_counter <= vertical_counter + 1;
            end else begin
              vertical_counter <= 11'd0;
            end
          end
        end
      end

      // 生成 de 信号
      if (hsync && vsync && horizontal_counter >= H_SYNC_PULSE + H_BACK_PORCH && 
                   horizontal_counter < H_SYNC_PULSE + H_BACK_PORCH + H_DISPLAY &&
                   vertical_counter >= V_SYNC_PULSE + V_BACK_PORCH &&
                   vertical_counter < V_SYNC_PULSE + V_BACK_PORCH + V_DISPLAY) begin
        de <= 1'b1;
      end else begin
        de <= 1'b0;
      end
    end
  end
endmodule
