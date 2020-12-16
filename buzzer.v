//buzzer.v 音频信号控制
module buzzer(clk, enable, rst, buz_data, buz_sound);
  input clk, rst, enable;
  input [3:0] buz_data;
  output buz_sound;
  
  reg [19:0] sounds [15:0];			//声音频率储存
  wire clk_sound;
  
  initial begin
    //音频信号初始化
    sounds[0] = 20'd151686;		sounds[1] = 20'd151686;		//33
    sounds[2] = 20'd143172;		sounds[3] = 20'd127554;		//45
    sounds[4] = 20'd127554;		sounds[5] = 20'd143172;		//54
    sounds[6] = 20'd151686;		sounds[7] = 20'd170260;		//32
    sounds[8] = 20'd191110;		sounds[9] = 20'd191110;		//11
    sounds[10] = 20'd170260;	sounds[11] = 20'd151686;	//23
    sounds[12] = 20'd151686;	sounds[13] = 20'd151686;	//33
    sounds[14] = 20'd170260;	sounds[15] = 20'd170260;	//22
  end
  
  //音频信号分频
  sound_divide divideSOUND(sounds[buz_data],clk,(enable?0:1),clk_sound);
  
  assign buz_sound = (enable ? clk_sound : enable);
  
endmodule
