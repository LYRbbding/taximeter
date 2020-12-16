//counter38.v 速度LED控制
module counter38 (en, sw, led);
  input en;             //计数使能信号
  input [2:0] sw;       //开关输入信号
  output reg [7:0] led; //输出信号控制特定LED
  
  //always过程块，括号中sw为敏感变量，当sw变化一次执行一次always中所有语句，否则保持不变
  always @(sw) begin
    if (en) begin
      case(sw)
        3'b000:	led = 8'b0000_0001;        3'b001:	led = 8'b0000_0011;
        3'b010:	led = 8'b0000_0111;        3'b011:	led = 8'b0000_1111;
        3'b100:	led = 8'b0001_1111;        3'b101:	led = 8'b0011_1111;
        3'b110:	led = 8'b0111_1111;        3'b111:	led = 8'b1111_1111;
        default:	;
      endcase
    end
    else    led = 8'b0;
  end

endmodule
