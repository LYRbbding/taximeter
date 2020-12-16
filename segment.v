//segment.v 数码管显示模块
module segment (seg_data,seg_led);
  input [3:0] seg_data;
  output [7:0] seg_led;
  
  reg [7:0] seg [9:0];
  
  initial begin
    seg[0]=8'h3f; seg[1]=8'h06; seg[2]=8'h5b; seg[3]=8'h4f; seg[4]=8'h66;
    seg[5]=8'h6d; seg[6]=8'h7d; seg[7]=8'h07; seg[8]=8'h7f; seg[9]=8'h6f;
  end
      
  assign seg_led = seg[seg_data];

endmodule
