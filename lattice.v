//lattice.v 点阵控制模块
module lattice (onride,lat_Vcnt,lat_Hcnt,lat_led);
  input onride;
  input [2:0] lat_Vcnt;
  input [3:0] lat_Hcnt;
  output reg [7:0] lat_led;
  
  reg [31:0] lat_data_R [7:0];		//点阵数据, R, 空车
  reg [31:0] lat_data_G [7:0];		//点阵数据, G, 载客
  
  //点阵数据初始化
  initial begin
    lat_data_R[0] = 32'h0808_0808;    lat_data_R[1] = 32'h3E7F_3E7F;
    lat_data_R[2] = 32'h0455_0455;    lat_data_R[3] = 32'h0A22_0A22;
    lat_data_R[4] = 32'h3F3E_3F3E;    lat_data_R[5] = 32'h0808_0808;
    lat_data_R[6] = 32'h7F08_7F08;    lat_data_R[7] = 32'h087F_087F;
    
    lat_data_G[0] = 32'h1320_1320;    lat_data_G[1] = 32'h6A70_6A70;
    lat_data_G[2] = 32'h6B4F_6B4F;    lat_data_G[3] = 32'h6A09_6A09;
    lat_data_G[4] = 32'h3A26_3A26;    lat_data_G[5] = 32'h2A26_2A26;
    lat_data_G[6] = 32'h0229_0229;    lat_data_G[7] = 32'h7D50_7D50;
  end
  
  //点阵内容滚动显示
  always @(lat_Hcnt) begin
    if(onride)
      case(lat_Hcnt)
        4'h0:	lat_led = lat_data_G[lat_Vcnt][7:0];
        4'h1:	lat_led = lat_data_G[lat_Vcnt][8:1];
        4'h2:	lat_led = lat_data_G[lat_Vcnt][9:2];
        4'h3:	lat_led = lat_data_G[lat_Vcnt][10:3];
        4'h4:	lat_led = lat_data_G[lat_Vcnt][11:4];
        4'h5:	lat_led = lat_data_G[lat_Vcnt][12:5];
        4'h6:	lat_led = lat_data_G[lat_Vcnt][13:6];
        4'h7:	lat_led = lat_data_G[lat_Vcnt][14:7];
        4'h8:	lat_led = lat_data_G[lat_Vcnt][15:8];
        4'h9:	lat_led = lat_data_G[lat_Vcnt][16:9];
        4'ha:	lat_led = lat_data_G[lat_Vcnt][17:10];
        4'hb:	lat_led = lat_data_G[lat_Vcnt][18:11];
        4'hc:	lat_led = lat_data_G[lat_Vcnt][19:12];
        4'hd:	lat_led = lat_data_G[lat_Vcnt][20:13];
        4'he:	lat_led = lat_data_G[lat_Vcnt][21:14];
        4'hf:	lat_led = lat_data_G[lat_Vcnt][22:15];
        default:	lat_led = 8'b0;
      endcase
    else
      case(lat_Hcnt)
        4'h0:	lat_led = lat_data_R[lat_Vcnt][7:0];
        4'h1:	lat_led = lat_data_R[lat_Vcnt][8:1];
        4'h2:	lat_led = lat_data_R[lat_Vcnt][9:2];
        4'h3:	lat_led = lat_data_R[lat_Vcnt][10:3];
        4'h4:	lat_led = lat_data_R[lat_Vcnt][11:4];
        4'h5:	lat_led = lat_data_R[lat_Vcnt][12:5];
        4'h6:	lat_led = lat_data_R[lat_Vcnt][13:6];
        4'h7:	lat_led = lat_data_R[lat_Vcnt][14:7];
        4'h8:	lat_led = lat_data_R[lat_Vcnt][15:8];
        4'h9:	lat_led = lat_data_R[lat_Vcnt][16:9];
        4'ha:	lat_led = lat_data_R[lat_Vcnt][17:10];
        4'hb:	lat_led = lat_data_R[lat_Vcnt][18:11];
        4'hc:	lat_led = lat_data_R[lat_Vcnt][19:12];
        4'hd:	lat_led = lat_data_R[lat_Vcnt][20:13];
        4'he:	lat_led = lat_data_R[lat_Vcnt][21:14];
        4'hf:	lat_led = lat_data_R[lat_Vcnt][22:15];
        default:	lat_led = 8'b0;
      endcase
  end

endmodule
