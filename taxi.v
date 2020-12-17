//taxi.v, 顶层模块, 该代码可从https://github.com/LYRbbding/taximeter直接下载运行
module taxi (
  clk, rst, mile_v, onride, double, night, subtotal, waiting, stopped,
  seg_cat, seg_AX, speed_led, night_led, double_led, ride_led, clk_sound,
  lattice_row, lattice_Rcol, lattice_Gcol, lcd_en, lcd_rs, lcd_data
);
  /************************ 输入变量 ************************/
  input             clk;                //内部时钟信号, 50MHz
  input             rst;                //全局复位按钮, btn0
  input       [2:0] mile_v;             //里程计数速度, sw2 1 0
  input             onride;             //空驶状态, sw5, 1行驶, 0空载
  input             double;             //合乘模式, sw6, 1双人, 0单人
  input             night;              //夜间模式, sw7, 1夜间, 0白天
  input             subtotal;           //合乘结束按钮, btn1
  input             waiting;            //等待按钮, btn3
  input             stopped;            //结束按钮, btn5
  /*********************************************************/
  
  /************************ 输出变量 ************************/
  output reg  [7:0] seg_cat;            //数码管阴极
  output      [7:0] seg_AX;             //数码管阳极
  output      [7:0] speed_led;          //行使速度, led7-0
  output            night_led;          //夜间状态, led13, 1夜间, 0日间
  output            double_led;         //合乘状态, led14, 1合乘, 0单人
  output            ride_led;           //空驶状态, led15, 1空载, 0行驶
  output            clk_sound;          //输出音频信号
  output reg  [7:0] lattice_row;        //点阵阴极
  output      [7:0] lattice_Rcol;       //点阵阳极, R, 空车
  output      [7:0] lattice_Gcol;       //点阵阳极, G, 载客
  output            lcd_en;             //1602LCD使能端
  output            lcd_rs;             //1602LCD数据选择端
  output      [7:0] lcd_data;           //1602LCD数据端
  /*********************************************************/
  
  /************************ 其它变量 ************************/
  //------------   音频变量  ------------
  reg         [3:0] snd_status;         //声音控制状态码
  reg               sound_on;           //声音控制变量
  reg         [8:0] sound_cnt;          //音频节拍控制
  wire              sound_out;          //从音频模块获得音频输出信号
  assign clk_sound = sound_out;         //将获得的音频输出至外部
  
  //------------  数码管变量  ------------
  reg         [3:0] seg_data [7:0];     //数码管数据
  reg         [2:0] seg_cnt;            //数码管扫描位置
  
  //------------   点阵变量  ------------
  reg         [2:0] lat_Vcnt;           //点阵纵向扫描位置
  reg         [3:0] lat_Hcnt;           //点阵横向滚动位置
  reg         [8:0] lat_Htimer;         //点阵横向计时
  wire        [7:0] lattice_Rcol_data;  //点阵阳极, R, 空车
  wire        [7:0] lattice_Gcol_data;  //点阵阳极, G, 载客
  //判断当前载客状态, 并输出相应颜色和图案的点阵
  assign lattice_Rcol = {onride ? 8'b0 : lattice_Rcol_data};
  assign lattice_Gcol = {onride ? lattice_Gcol_data : 8'b0};
  
  //------------   内部计数变量  ------------
  reg         [9:0] mile_mcnt;          //里程计数器, ms
  reg         [2:0] mile_speed;         //速度计数器, v
  reg         [6:0] mile_cnt;           //里程计数器, km
  reg         [9:0] wait_mcnt;          //等待计数器, ms
  reg         [3:0] wait_cnt;           //等待计数器, s
  reg               wait_status;        //等待状态, 1等待, 0行驶
  reg               stop_cnt;           //旅程结束状态标志
  reg         [3:0] night_cnt;          //夜间模式小数计数
  reg         [7:0] people1_price [2:0];//合乘乘客1价格计数
  reg         [7:0] people2_price [2:0];//合乘乘客2价格计数
  reg         [1:0] sub_cnt;            //合乘状态
  
  //------------   价格控制变量  ------------
  reg         [3:0] Myuan;              //里程价格控制变量, 元
  reg         [3:0] Mjiao;              //里程价格控制变量, 角
  reg         [3:0] Wyuan;              //等待价格控制变量, 元
  reg         [3:0] Wjiao;              //等待价格控制变量, 角
  
  wire              clk1k;              //千分频信号
  wire              wait_dbs;           //等待按钮, 除抖信号
  wire              stop_dbs;           //旅程结束, 除抖信号
  wire              sub_dbs;            //合乘结束, 除抖信号
  
  assign double_led = double;
  assign night_led  = night;
  assign ride_led   = ~onride;
    
  initial begin          //初始化
    //音频初始化
    snd_status  =  4'b0;  sound_on    =  1'b0;
    sound_cnt   =  9'b0;  sub_cnt     =  2'b0;
    //计数初始化, 计费用相关变量置0
    mile_mcnt   = 10'b0;  mile_speed  =  3'b0;
    mile_cnt    =  7'b0;  wait_status =  1'b0;
    wait_mcnt   = 10'b0;  wait_cnt    =  4'b0;
    stop_cnt    =  1'b0;  night_cnt   =  4'b0;
    //数码管初始化, 点亮瞬间值为99900013, 检测数码管是否正常工作
    seg_cnt[0]  =  3'b0;
    seg_data[0] =  4'd3;  seg_data[1] =  4'd1;
    seg_data[2] =  4'd0;  seg_data[3] =  4'd0;
    seg_data[4] =  4'd0;  seg_data[5] =  4'd9;
    seg_data[6] =  4'd9;  seg_data[7] =  4'd9;
    //点阵初始化, 扫描位置归0
    lat_Vcnt    =  3'b0;  lat_Hcnt    =  4'b0;
    lat_Htimer  =  9'b0;
    //计费初始化
    Myuan       =  4'd2;  Mjiao       =  4'd0;    //正常模式2元每1公里里程
    Wyuan       =  4'd1;  Wjiao       =  4'd0;    //正常模式1元每3秒计时
  end
    
  always @(double or night or sub_cnt) begin
    //拨码开关变化, 改变计费单位价格
    if(sub_cnt == 0)        //合乘阶段值为0时计价(仅在合乘时值生效)
      case({double,night})  //都进行判断是为了简化代码逻辑
        2'b00:    begin  Myuan = 2;  Mjiao = 0;  Wyuan = 1;  Wjiao = 0;  end
        2'b01:    begin  Myuan = 2;  Mjiao = 4;  Wyuan = 1;  Wjiao = 2;  end
        2'b10:    begin  Myuan = 1;  Mjiao = 2;  Wyuan = 0;  Wjiao = 6;  end
        2'b11:    begin  Myuan = 1;  Mjiao = 4;  Wyuan = 0;  Wjiao = 7;  end
        default:  begin  Myuan = 2;  Mjiao = 0;  Wyuan = 1;  Wjiao = 0;  end
      endcase
    else                    //合乘阶段值非0时计价
      case({double,night})
        2'b00:    begin  Myuan = 2;  Mjiao = 0;  Wyuan = 1;  Wjiao = 0;  end
        2'b01:    begin  Myuan = 2;  Mjiao = 4;  Wyuan = 1;  Wjiao = 2;  end
        2'b10:    begin  Myuan = 2;  Mjiao = 0;  Wyuan = 1;  Wjiao = 0;  end
        2'b11:    begin  Myuan = 2;  Mjiao = 4;  Wyuan = 1;  Wjiao = 2;  end
        default:  begin  Myuan = 2;  Mjiao = 0;  Wyuan = 1;  Wjiao = 0;  end
      endcase
  end
  
  always @(posedge clk1k or posedge rst) begin
    if(rst) begin     //扫描强制归0
      seg_cnt <= 0;
      lat_Vcnt <= 0;
    end
    //正常工作状态
    else begin
      //数码管扫描
      if(onride) begin
        seg_cnt <= seg_cnt + 1;             //扫描位置计数, 低电平有效
        seg_cat[seg_cnt] <= 1'b1;           //前一扫描位阴极置1, 即关闭显示
        seg_cat[seg_cnt+3'b001] <= 1'b0;    //当前扫描位阴极置0, 即开启显示
      end
      
      //点阵扫描
      lat_Vcnt <= lat_Vcnt + 1;             //逻辑同数码管扫描
      lattice_row[lat_Vcnt] <= 1'b1;
      lattice_row[lat_Vcnt+3'b001] <= 1'b0;
      lat_Htimer <= lat_Htimer + 1;
      if(lat_Htimer == 9'd511)
        lat_Hcnt <= lat_Hcnt + 1;
      
      //LCD1602价格显示控制
      if(onride && (!stop_cnt && sub_cnt != 1)) begin
        if(sub_cnt == 0)  begin             //合乘状态
          people1_price[2] <= seg_data[2];
          people1_price[1] <= seg_data[1];
          people1_price[0] <= seg_data[0];
          people2_price[2] <= seg_data[2];
          people2_price[1] <= seg_data[1];
          people2_price[0] <= seg_data[0];
        end
        else begin                          //单人状态
          people1_price[2] <= seg_data[2];
          people1_price[1] <= seg_data[1];
          people1_price[0] <= seg_data[0];
        end
        
        //欢迎音乐
        if(snd_status < 4'd15) begin
          if(sound_cnt == 9'b0_0000_1111)     sound_on <= 1;
          else if(sound_cnt == 9'b1_1111_1111) begin
            snd_status <= snd_status + 1;
            sound_on <= 0;
          end
          sound_cnt <= sound_cnt + 1;
        end
        else  sound_on <= 0;
        
        //不同模式初始化数值
        if (double && night && seg_data[0] == 4'd3 && seg_data[1] == 4'd1 &&
            seg_data[2] == 4'd0 && seg_data[3] == 4'd0 &&
            seg_data[4] == 4'd0 && seg_data[5] == 4'd0 &&
            seg_data[6] == 4'd0 && seg_data[7] == 4'd0) begin
          seg_data[0] <= 0;
          night_cnt <= 4'd6;
        end     //夜间合乘
        else if(night && seg_data[0] == 4'd3 && seg_data[1] == 4'd1 &&
                seg_data[2] == 4'd0 && seg_data[3] == 4'd0 &&
                seg_data[4] == 4'd0 && seg_data[5] == 4'd0 &&
                seg_data[6] == 4'd0 && seg_data[7] == 4'd0) begin
          seg_data[0] <= 6;
          night_cnt <= 4'd6;
        end     //夜间
        else if(double && seg_data[0] == 4'd3 && seg_data[1] == 4'd1 &&
                seg_data[2] == 4'd0 && seg_data[3] == 4'd0 &&
                seg_data[4] == 4'd0 && seg_data[5] == 4'd0 &&
                seg_data[6] == 4'd0 && seg_data[7] == 4'd0) begin
          seg_data[1] <= 0;
          seg_data[0] <= 8;
          night_cnt <= 4'd8;
        end     //合乘
        
        //等待状态操作
        if (wait_status) begin
          //到达计时节点
          if(wait_mcnt == 10'd999) begin
            wait_mcnt <= 10'd0;
            
            /************处理等待计时数码管************/
            //计数到达上限时, 停止计数
            if(seg_data[5]==4'd9 && seg_data[4]==4'd0 && seg_data[3]==4'd0);
            //计数如果发生进位, 判断进位情况
            else if (seg_data[3] == 4'd9) begin
              seg_data[3] <= 0;
              if (seg_data[4] == 4'd9) begin
                seg_data[4] <= 0;
                seg_data[5] <= seg_data[5] + 1;
              end
              else
                seg_data[4] <= seg_data[4] + 1;
            end
            //计数未发生进位, 直接改变
            else
              seg_data[3] <= seg_data[3] + 1;
            
            /************处理等待计费数码管************/
            //到达计费节点, 开始计费
            if(wait_cnt == 3'h5) begin
              if(seg_data[5]==4'd9&&seg_data[4]==4'd0&&seg_data[3]==4'd0);
              else begin
                //判断是否会由于四舍五入产生进位
                //情况1: 加和后大于4, 加和前小于5
                //情况2: 加和后发生溢出, 加和修正后大于4
                if (seg_data[0] + Wyuan + ((night_cnt + Wjiao > 4'd4 &&
                    night_cnt < 4'd5 || night_cnt + Wjiao < night_cnt &&
                    night_cnt + Wjiao + 4'd6 > 4'd4)?4'd1:4'd0) > 4'd9) begin
                  seg_data[0] <= seg_data[0] + Wyuan +
                          ((night_cnt + Wjiao > 4'd4 && night_cnt < 4'd5 ||
                          night_cnt + Wjiao < night_cnt &&
                          night_cnt + Wjiao + 4'd6 > 4'd4) ? 4'd7 : 4'd6);
                  if (seg_data[1] == 4'd9) begin
                    seg_data[1] <= 0;
                    seg_data[2] <= seg_data[2] + 1;
                  end
                  else
                    seg_data[1] <= seg_data[1] + 1;
                end
                else
                  seg_data[0] <= seg_data[0] + Wyuan +
                          ((night_cnt + Wjiao > 4'd4 && night_cnt < 4'd5 ||
                          night_cnt + Wjiao < night_cnt &&
                          night_cnt + Wjiao + 4'd6 > 4'd4) ? 4'd1 : 4'd0);
                night_cnt <= night_cnt + Wjiao +
                          ((night_cnt + Wjiao > 4'd9 ||
                          night_cnt + Wjiao < night_cnt) ? 4'd6 : 4'd0);
              end
              wait_cnt <= wait_cnt + 1;
            end
            //即将溢出, 重新置位
            else if (wait_cnt == 3'h7) begin
              wait_cnt <= 3'h5;
            end
            //完成计数加
            else
              wait_cnt <= wait_cnt + 1;
          end
          else
            wait_mcnt <= wait_mcnt + 1;
        end
        //正常行驶状态操作
        else begin
          if(mile_mcnt == 10'd999) begin
            mile_mcnt <= 10'd0;
            if(mile_speed >= mile_v) begin
              mile_speed <= 3'b0;
              
              /************处理行驶里程数码管************/
              //计数到达上限时, 停止计数
              if (seg_data[7] == 4'd9 && seg_data[6] == 4'd9);
              //计数如果发生进位, 判断进位情况
              else if (seg_data[6] == 4'd9) begin
                seg_data[6] <= 0;
                seg_data[7] <= seg_data[7] + 1;
              end
              //计数未发生进位, 直接改变
              else
                seg_data[6] <= seg_data[6] + 1;
              
              /************处理行驶计费数码管************/
              //到达计费节点, 开始计费
              if(mile_cnt > 6'd2) begin
                if (seg_data[7] == 4'd9 && seg_data[6] == 4'd9);
                else begin
                  //判断是否会由于四舍五入产生进位
                  //情况1: 加和后大于4, 加和前小于5
                  //情况2: 加和后发生溢出, 加和修正后大于4
                  if(seg_data[0] + Myuan + ((night_cnt + Mjiao > 4'd4 &&
                    night_cnt < 4'd5 || night_cnt + Mjiao < night_cnt &&
                    night_cnt + Mjiao + 4'd6 > 4'd4)?4'd1:4'd0) > 4'd9) begin
                    seg_data[0] <= seg_data[0] + Myuan +
                            ((night_cnt + Mjiao > 4'd4 && night_cnt < 4'd5 ||
                            night_cnt + Mjiao < night_cnt &&
                            night_cnt + Mjiao + 4'd6 > 4'd4) ? 4'd7 : 4'd6);
                    if (seg_data[1] == 4'd9) begin
                      seg_data[1] <= 0;
                      seg_data[2] <= seg_data[2] + 1;
                    end
                    else
                      seg_data[1] <= seg_data[1] + 1;
                  end
                  else
                    seg_data[0] <= seg_data[0] + Myuan +
                            ((night_cnt + Mjiao > 4'd4 && night_cnt < 4'd5 ||
                            night_cnt + Mjiao < night_cnt &&
                            night_cnt + Mjiao + 4'd6 > 4'd4) ? 4'd1 : 4'd0);
                  night_cnt <= night_cnt + Mjiao +
                            ((night_cnt + Mjiao > 4'd9 ||
                            night_cnt + Mjiao < night_cnt) ? 4'd6 : 4'd0);
                end
              end
              mile_cnt <= mile_cnt + 1;       //里程计数++
            end
            else
              mile_speed <= mile_speed + 1;   //一公里未计满, 只在公里内增加
          end
          else
            mile_mcnt <= mile_mcnt + 1;
        end
      end
      else if(onride && stop_cnt) begin
        //欢送音乐
        if(snd_status > 4'd0) begin
          if(sound_cnt == 9'b0_0000_1111)     sound_on <= 1;
          else if(sound_cnt == 9'b1_1111_1111) begin
            snd_status <= snd_status - 1;
            sound_on <= 0;
          end
          sound_cnt <= sound_cnt + 1;
        end
        else  sound_on <= 0;
      end
      //空载状态，重新初始化
      else if(~onride) begin
        mile_mcnt   <= 10'd0;       mile_speed  <= 3'd0;
        mile_cnt    <= 6'd0;        wait_mcnt   <= 10'd0;
        wait_cnt    <= 3'd0;        night_cnt   <= 4'b0;
        snd_status  <= 9'b0;
        //数码管初始化
        seg_cnt     <= 0;           seg_cat     <= 8'hff;
        seg_data[0] <= 4'd3;        seg_data[1] <= 4'd1;
        seg_data[2] <= 4'd0;        seg_data[3] <= 4'd0;
        seg_data[4] <= 4'd0;        seg_data[5] <= 4'd0;
        seg_data[6] <= 4'd0;        seg_data[7] <= 4'd0;
      end
    end
  end
  
  //点阵字幕显示
  lattice EMPTY (onride,lat_Vcnt,lat_Hcnt,lattice_Rcol_data);
  lattice WELCOME (onride,lat_Vcnt,lat_Hcnt,lattice_Gcol_data);
  
  //1602LCD, row_1 row_2通过拼接方式传递字符串
  lcd_1602_driver LCD1602 (
    .CLK(clk),
    .BTN_TRCK(rst),
    .row_1(onride?{4'h3,seg_data[7],4'h3,seg_data[6],"km ",4'h3,seg_data[5],
           4'h3,seg_data[4],4'h3,seg_data[3],"s ",8'h31+mile_v,"s/km "}
           :" TAXI - WELCOME "),  //第一行, 显示里程 等待时长 速度
                                  //未载客时显示欢迎
    .row_2(onride?(double?{"RMB 1:",8'h30+people1_price[2],
           8'h30+people1_price[1],8'h30+people1_price[0],", 2:",
           8'h30+people2_price[2],8'h30+people2_price[1],
           8'h30+people2_price[0]}:{"RMB:",4'h3,seg_data[2],
           4'h3,seg_data[1],4'h3,seg_data[0],"         "})
           :" Powered by LYR "),  //第二行, 显示费用
                                  //未载客时显示版权
    .LCD_E(lcd_en),
    .LCD_RS(lcd_rs),
    .LCD_DATA(lcd_data)
  );
  
  //等待按钮操作
  always @(posedge clk or posedge rst) begin
    if(rst)              wait_status <= 1'b0;
    else if(!onride || stop_cnt)  wait_status <= 1'b0;
    else if(wait_dbs)        wait_status <= ~wait_status;
  end
  debounce waitingKEY (clk,rst,waiting,wait_dbs);        //等待按键信号消抖
  
  //停止按钮操作
  always @(posedge clk or posedge rst) begin
    if(rst)              stop_cnt <= 1'b0;
    else if(!onride)        stop_cnt <= 1'b0;
    else if(stop_dbs)        stop_cnt <= 1'b1;
  end
  debounce stoppedKEY (clk,rst,stopped,stop_dbs);        //停止按键信号消抖
  
  //合乘按钮操作
  always @(posedge clk or posedge rst) begin
    if(rst)              sub_cnt <= 2'b0;
    else if(!onride)        sub_cnt <= 2'b0;
    else if(double&&sub_dbs&&sub_cnt < 2'd2)  sub_cnt <= sub_cnt + 1;
  end
  debounce subKEY (clk,rst,subtotal,sub_dbs);          //合乘按键信号消抖
  
  buzzer soundBUZ (clk,sound_on,rst,snd_status,sound_out);  //产生音频信号
  
  //扫描信号分频
  divide #(.WIDTH(32),.N(50000)) divide1000 (
    .clk(clk),
    .rst_n(rst),
    .clkout(clk1k)
  );
  segment seg_high(seg_data[seg_cnt],seg_AX);          //数码管信号实例化
  counter38 speedLED (onride,mile_speed,speed_led);      //行驶速度3-8计数
  
endmodule
