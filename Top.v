`timescale 1ns / 1ps

module Top(
    input clk,
    input rst,
    input en,
    //////////////////////////////
    input       [7:0]sw,                  //���Ʒ�����
    input speed,
    input       [3:0] row,                 // ������
    output reg [3:0] col,                 // ������ѡ����Ӧ��Ϊ0ʱ�������⵽row��ĳλΪ0��������������λ��
    output reg [7:0] seg_an,
    output reg [7:0] seg_out,
    output reg buzzer,
    //////////////////////////////
    input sshort,
    input llong,
    input decode,
    input clearALL,
    input back,
    output reg light1,
    output reg light2,
    output reg light3,
    //output reg [7:0] Y_r,
    output reg [4:0] code,
    
    //output reg [7:0] seg_en,
    output reg [2:0] length,
    output reg [3:0] tot,
    /////////////////////////////
    output state
    );
assign state=en;
//Decoder/////////////////////////////////////////////////////////////////////////////////////
reg [63:0] totout;
reg [2:0] th;
reg [7:0] out;

reg [31:0]cnt;
reg [3:0]scan_cnt;

parameter  period= 100000;
reg clkout;

wire fshort;
wire flong;
wire fclear;
wire fback;
wire fdecode;

keyfilter ushort(clk,rst,sshort,fshort);
keyfilter ulong(clk,rst,llong,flong);
keyfilter uclear(clk,rst,clearALL,fclear);
keyfilter uback(clk,rst,back,fback);
keyfilter udecode(clk,rst,decode,fdecode);

always @(posedge clk, posedge rst)
begin
    if(en == 1'b1) begin
      if(rst)begin
        tot <= 4'b0;
        code <= 5'b0;
        th <= 3'b0;
        length <= 3'b0;
        totout <= 64'b0;
      end
      else if(fdecode == 1'b1)begin
            tot <= tot + 1'b1;
          case(tot)
            0: 
            totout[7:0] <= out;
            1:
            totout[15:8] <= out;
            2: 
            totout[23:16] <= out;
            3: 
            totout[31:24] <= out;
            4: 
            totout[39:32] <= out;
            5: 
            totout[47:40] <= out;
            6: 
            totout[55:48] <= out;
            7: 
            totout[63:56] <= out;
            8:
            light3 <= 1'b1;
          endcase
          code <= 5'b0;
          th <= 3'b0;
          length <= 3'b0;
          light2 <= 1'b0;
        end
        else if(fshort == 1'b1)begin
             case(length)
                3'b000: out<=8'b0000_0110;//e
                3'b001:begin
                    case(code[0])
                      1'b0: out<=8'b0111_0000;//i
                      1'b1: out<=8'b0010_1011;//n  
                    endcase
                    end       
                3'b010:begin
                    case(code[1:0])
                      2'b10: out<=8'b0100_1110;//r
                      2'b00: out<=8'b0011_0110;//s
                      2'b11: out<=8'b0100_0010;//g
                      2'b01: out<=8'b0010_0001;//d  
                    endcase
                    end
                3'b011:begin
                    case(code[2:0])
                      3'b001: begin
                        out<=8'b0000_0011;//b
                        light2 <= 1'b0;
                      end
                      3'b011: begin
                        out<=8'b0010_0101;//z
                        light2 <= 1'b0;
                      end
                      3'b101: begin
                        out<=8'b0100_0110;//c
                        light2 <= 1'b0;
                      end
                      3'b010: begin
                        out<=8'b0100_0111;//l
                        light2 <= 1'b0;
                      end
                      3'b000: begin
                        out<=8'b0000_1001;//h
                        light2 <= 1'b0;
                      end
                      3'b100: begin
                        out<=8'b0000_1110;//f
                        light2 <= 1'b0;
                      end
                      3'b110: begin
                        out<=8'b0000_1100;//p
                        light2 <= 1'b0;
                      end
                      default: begin
                        out<=8'b1111_1111;
                        light2 <= 1'b1;
                      end
                    endcase
                    end
                3'b100:begin
                    case(code[3:0])
                      4'b0111: begin
                        out<=8'b0000_0000;//8
                        light2 <= 1'b0;
                      end
                      4'b0001: begin
                        out<=8'b0000_0010;//6
                        light2 <= 1'b0;
                      end
                      4'b0000: begin
                        out<=8'b0001_0010;//5
                        light2 <= 1'b0;
                      end
                      4'b0011: begin
                        out<=8'b0111_1000;//7
                        light2 <= 1'b0;
                      end
                      4'b1111: begin
                        out<=8'b0001_0000;//9
                        light2 <= 1'b0;
                      end
                      default: begin
                        out<=8'b1111_1111;
                        light2 <= 1'b1;
                      end
                    endcase
                    end
               default : out <= 8'b11111111;//��
               endcase
             th <= th + 1'b1;
             length <= length + 1'b1;
        end
        else if(flong == 1'b1)begin
             case(length) 
             3'b000: out<=8'b0000_0111;//t
             3'b001: begin
                 case(code[0])
                   1'b0: out<=8'b0000_1000;//a
                   1'b1: out<=8'b0100_1000;//m
                 endcase
                 end
             3'b010: begin
                 case(code[1:0])
                   2'b10: out<=8'b0000_0001;//w
                   2'b00: out<=8'b0100_0001;//u
                   2'b11: out<=8'b0010_0011;//o
                   2'b01: out<=8'b0000_1010;//k
                 endcase
                 end
             3'b011: begin
                 case(code[2:0])
                   3'b001: begin
                     out<=8'b0001_1011;//x
                     light2 <= 1'b0;
                   end
                   3'b011: begin
                     out<=8'b0001_1000;//q
                     light2 <= 1'b0;
                   end
                   3'b101: begin
                     out<=8'b0001_0001;//y
                     light2 <= 1'b0;
                   end
                   3'b000: begin
                     out<=8'b0110_0011;//v
                     light2 <= 1'b0;
                   end
                   3'b110: begin
                     out<=8'b0111_0001;//j
                     light2 <= 1'b0;
                   end
                   default: begin
                     out<=8'b1111_1111;
                     light2 <= 1'b1;
                   end
                 endcase
                 end
             3'b100: begin
                 case(code[3:0])
                   4'b0000: begin
                     out<=8'b0001_1001;//4
                     light2 <= 1'b0;
                   end
                   4'b1110: begin
                     out<=8'b0111_1001;//1
                     light2 <= 1'b0;
                   end
                   4'b1100: begin
                     out<=8'b0010_0100;//2
                     light2 <= 1'b0;
                   end
                   4'b1000: begin
                     out<=8'b0011_0000;//3
                     light2 <= 1'b0;
                   end
                   4'b1111: begin
                     out<=8'b0100_0000;//0
                     light2 <= 1'b0;
                   end
                   default: begin
                     out<=8'b1111_1111;
                     light2 <= 1'b1;
                   end
                 endcase
                 end
                 default : out <= 8'b11111111;//��
             endcase
             code[th] <= 1'b1;
             th <= th + 1'b1;
             length <= length + 1'b1;
        end
        else if (fclear == 1'b1)begin
             length <= 3'b0;
             code <= 5'b0;
             tot <= 4'b0;
             th <= 3'b0;
             totout <= 64'b0;
             out <= 8'b0;
             light1 <= 1'b0;
             light2 <= 1'b0;
             light3 <= 1'b0;
        end
        else if(fback == 1'b1)begin
             if(th != 0)begin
               light1 <= 1'b0;
               case(length)
               3'b001:begin
                 out <= 8'b11111111;
               end
               3'b010:begin
                 case(code[0])
                 1'b0:out<=8'b0000_0110;//e
                 1'b1:out<=8'b0000_0111;//t
                 endcase
               end
               3'b011:begin
                 case(code[1:0])
                 2'b00:out<=8'b0111_0000;//i
                 2'b01:out<=8'b0010_1011;//n  
                 2'b10:out<=8'b0000_1000;//a 
                 2'b11:out<=8'b0100_1000;//m
                 endcase
               end
               3'b100:begin
                 case(code[2:0])
                 3'b000:begin
                   out<=8'b0011_0110;//s
                   light2 <= 1'b0;
                 end
                 3'b001:begin
                   out<=8'b0010_0001;//d
                   light2 <= 1'b0;
                 end 
                 3'b010:begin
                   out<=8'b0100_1110;//r
                   light2 <= 1'b0;
                 end
                 3'b011:begin
                   out<=8'b0100_0010;//g
                   light2 <= 1'b0;
                 end
                 3'b100:begin
                   out<=8'b0100_0001;//u
                   light2 <= 1'b0;
                 end
                 3'b101:begin
                   out<=8'b0000_1010;//k
                   light2 <= 1'b0;
                 end
                 3'b110:begin
                   out<=8'b0000_0001;//w
                   light2 <= 1'b0;
                 end
                 3'b111:begin
                   out<=8'b0010_0011;//o
                   light2 <= 1'b0;
                 end
                 endcase
               end
               3'b110:begin
                 case(code[3:0])
                 4'b0000:begin
                   out<=8'b0000_1001;//h
                   light2 <= 1'b0;
                 end
                 4'b0001:begin
                   out<=8'b0000_0011;//b
                   light2 <= 1'b0;
                 end
                 4'b0010:begin
                   out<=8'b0100_0111;//l
                   light2 <= 1'b0;
                 end
                 4'b0011:begin
                   out<=8'b0010_0101;//z
                   light2 <= 1'b0;
                 end
                 4'b0100:begin
                   out<=8'b0000_1110;//f
                   light2 <= 1'b0;
                 end
                 4'b0101:begin
                   out<=8'b0100_0110;//c
                   light2 <= 1'b0;
                 end
                 4'b0110:begin
                   out<=8'b0000_1100;//p
                   light2 <= 1'b0;
                 end
                 4'b1000:begin
                   out<=8'b0110_0011;//v
                   light2 <= 1'b0;
                 end
                 4'b1001:begin
                   out<=8'b0001_1011;//x
                   light2 <= 1'b0;
                 end
                 4'b1011:begin
                   out<=8'b0001_1000;//q
                   light2 <= 1'b0;
                 end
                 4'b1101:begin
                   out<=8'b0001_0001;//y
                   light2 <= 1'b0;
                 end
                 4'b1110:begin
                   out<=8'b0111_0001;//j
                   light2 <= 1'b0;
                 end
                 default: begin
                   out<= 8'b1111_1111;
                   light2 <= 1'b1;
                 end
                 endcase
               end
               endcase
               code[th - 1'b1] <= 1'b0;
               th <= th - 1'b1;
               length <= length - 1'b1;
             end
             else begin
               light1 <= 1'b1;
             end
        end
    end
end

always@(posedge clk, posedge rst) begin
    if(en==1'b1) begin
    if(rst) begin
		cnt <= 0;
		clkout <= 0;
	end
	else begin
		if(cnt == (period>>1)-1) begin
			clkout <= ~clkout;
			cnt <= 0;
		end
		else begin
			cnt <= cnt + 1;
		end
  end
  end
end

always@(posedge clkout, posedge rst) begin
  if(en==1'b1) begin
  if(rst) begin
    scan_cnt <= 4'b0000;
  end
  else begin
    scan_cnt <= scan_cnt + 1'b1;
    case(tot)
    0: scan_cnt <= 4'b0000;
    1: if(scan_cnt == 4'd1) scan_cnt <= 4'b0000;
    2: if(scan_cnt == 4'd2) scan_cnt <= 4'b0000;
    3: if(scan_cnt == 4'd3) scan_cnt <= 4'b0000;
    4: if(scan_cnt == 4'd4) scan_cnt <= 4'b0000;
    5: if(scan_cnt == 4'd5) scan_cnt <= 4'b0000;
    6: if(scan_cnt == 4'd6) scan_cnt <= 4'b0000;
    7: if(scan_cnt == 4'd7) scan_cnt <= 4'b0000;
    8: if(scan_cnt == 4'd8) scan_cnt <= 4'b0000;
    endcase
  end
  end
end

//always @( scan_cnt)
//      begin 
//      case ( scan_cnt )    
//          4'b0001 : seg_an = 8'b1111_1110;    
//          4'b0010 : seg_an = 8'b1111_1101;    
//          4'b0011 : seg_an = 8'b1111_1011;    
//          4'b0100 : seg_an = 8'b1111_0111;    
//          4'b0101 : seg_an = 8'b1110_1111;    
//          4'b0110 : seg_an = 8'b1101_1111;    
//          4'b0111 : seg_an = 8'b1011_1111;     
//          4'b1000 : seg_an = 8'b0111_1111;    
//          default : seg_an = 8'b1111_1111;    
//      endcase
//      end

//always @ (scan_cnt )
//     begin 
//     case (scan_cnt)
//         1: seg_out = totout[7:0]; 
//         2: seg_out = totout[15:8]; 
//         3: seg_out = totout[23:16]; 
//         4: seg_out = totout[31:24]; 
//         5: seg_out = totout[39:32]; 
//         6: seg_out = totout[47:40]; 
//         7: seg_out = totout[55:48]; 
//         8: seg_out = totout[63:56]; 
//         default: seg_out = 8'b11111111;
//     endcase
//     end
/////////////////////////////////////////////////////////////////////////////////////////////

//++++++++++++++++++++++++++++++++++++++
// ��Ƶʱ�ӣ���100mʱ�ӷ�Ƶ��1khz�����ھ��󰴼�������ܶ�̬��ʾ
//++++++++++++++++++++++++++++++++++++++
reg [15:0] kcnt;                         // ��Ƶ������
reg clk1k_reg;
wire clk1k;
//��Ƶ��������������49999��0 
always @ (posedge clk or posedge rst)
  if (rst)
    kcnt <= 0;
  else
	if(kcnt==49999)
		kcnt <= 0;
	else
		kcnt <= kcnt + 1'b1;
//clk1k,1kʱ�ӣ�ռ�ձ�Ϊ50%��������49999��ת��100m/((49999+1)*2)=1k
always @ (posedge clk or posedge rst)
  if (rst)
    clk1k_reg <= 0;
  else if(en==1'b0)
	if(kcnt==49999)
		clk1k_reg <= ~clk1k_reg;
//�ϰ���		
assign clk1k=clk1k_reg;
//������
//assign clk1k=clk;
//--------------------------------------
// �������
//--------------------------------------
//++++++++++++++++++++++++++++++++++++++
// ��ʼʱ����4��ȫ����Ϊ0�������ʱrow��Ϊȫf�������а������£���ʱȥ���μ��ÿһ�У��Ӷ��ó����������λ��
// ע�⵱�õ���Ӧ������λ��ʱ����Ҫ����10ms
//++++++++++++++++++++++++++++++++++++++
parameter NO_KEY_PRESSED = 6'b000_001;  
parameter SCAN_COL0      = 6'b000_010;  
parameter SCAN_COL1      = 6'b000_100;  
parameter SCAN_COL2      = 6'b001_000;  
parameter SCAN_COL3      = 6'b010_000;  
parameter KEY_PRESSED    = 6'b100_000;  

reg [5:0] current_state, next_state;    
reg [3:0] key_filter_cnt;
 
always @ (posedge clk1k or posedge rst)
  if (rst)
    current_state <= NO_KEY_PRESSED;
  else if(en==0)
    current_state <= next_state;
 
// ?????????????
always @ (*)
  case (current_state)
    NO_KEY_PRESSED :                    // ��ʼ̬��������ѡ��0���ȴ��������º��Ƚ���col0
        if (row != 4'hF)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
    SCAN_COL0 :                         // ���������col0������з���10ms���ɹ�����KEY_PRESSED���������col1
        if (row != 4'hF)
			if (key_filter_cnt==9)
				next_state = KEY_PRESSED;
			else
				next_state = SCAN_COL0;
        else 
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // ���������col1������з���10ms���ɹ�����KEY_PRESSED���������col2
        if (row != 4'hF)
			if (key_filter_cnt==9)
				next_state = KEY_PRESSED;
			else
				next_state = SCAN_COL1;
        else 
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // ���������col2������з���10ms���ɹ�����KEY_PRESSED���������col3
        if (row != 4'hF)
			if (key_filter_cnt==9)
				next_state = KEY_PRESSED;
			else
				next_state = SCAN_COL2;
        else 
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // ���������col3������з���10ms���ɹ�����KEY_PRESSED���������NO_KEY_PRESSED
        if (row != 4'hF)
			if (key_filter_cnt==9)
				next_state = KEY_PRESSED;
			else
				next_state = SCAN_COL3;
        else 
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // ����ȫΪf�󣬴������ɿ�������NO_KEY_PRESSED
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED; 
	default : next_state = NO_KEY_PRESSED; 
  endcase

//key_filter_cnt,��������������  
always @ (posedge clk1k or posedge rst)
  if (rst)
    key_filter_cnt <= 0;
  else
    case (next_state)
      NO_KEY_PRESSED :                  // key_filter_cnt=0
		key_filter_cnt <= 0;
      SCAN_COL0 :                       // ���������col0�ģ������ʱ��+1�������0
        if(row != 4'hF)
			key_filter_cnt <= key_filter_cnt+1;
		else
			key_filter_cnt <= 0;
      SCAN_COL1 :                       // ���������col1�ģ������ʱ��+1�������0
        if(row != 4'hF)
			key_filter_cnt <= key_filter_cnt+1;
		else
			key_filter_cnt <= 0;
      SCAN_COL2 :                       // ���������col2�ģ������ʱ��+1�������0
        if(row != 4'hF)
			key_filter_cnt <= key_filter_cnt+1;
		else
			key_filter_cnt <= 0;
      SCAN_COL3 :                       // ���������col3�ģ������ʱ��+1�������0
        if(row != 4'hF)
			key_filter_cnt <= key_filter_cnt+1;
		else
			key_filter_cnt <= 0;
      KEY_PRESSED :                     // key_filter_cnt=0
		key_filter_cnt <= 0;
    endcase
 
reg  key_pressed_flag,key_pressed_flag_dly1,key_pressed_flag_dly2;             // ??????��??
wire key_pressed_flag_plus,key_pressed_flag_plus_dly1;
reg [3:0] col_val, row_val;             // ????????
 
// ?????????????????????
always @ (posedge clk1k or posedge rst)
  if (rst)
  begin
    col              <= 4'h0;
	col_val			 <= 4'hf;
	row_val			 <= 4'hf;
    key_pressed_flag <=    0;
  end
  else if(en==0)
    case (next_state)
      NO_KEY_PRESSED :                  // ??��???????
      begin
        col              <= 4'h0;
        key_pressed_flag <=    0;       // ???????��???
      end
      SCAN_COL0 :                       // ?????0??
        col <= 4'b1110;
      SCAN_COL1 :                       // ?????1??
        col <= 4'b1101;
      SCAN_COL2 :                       // ?????2??
        col <= 4'b1011;
      SCAN_COL3 :                       // ?????3??
        col <= 4'b0111;
      KEY_PRESSED :                     // ?��???????
      begin
        col_val          <= col;        // ???????
        row_val          <= row;        // ???????
        key_pressed_flag <= 1;          // ?��?????��??  
      end
    endcase

//��key_pressed_flag�ӳ�һ�ģ����ڼ��������	
always @ (posedge clk1k or posedge rst)
  if (rst)
  begin
    key_pressed_flag_dly1 <= 0;
	key_pressed_flag_dly2 <= 0;
  end
  else if(en==0)
  begin
    key_pressed_flag_dly1 <= key_pressed_flag;
	key_pressed_flag_dly2 <= key_pressed_flag_dly1;
  end
	
//key_pressed_flag_plusΪkey_pressed_flag�������أ���key_pressed_flag=1��key_pressed_flag_dly1=0	
assign key_pressed_flag_plus=key_pressed_flag & (~key_pressed_flag_dly1);

//key_pressed_flag_plus_dly1Ϊkey_pressed_flag_plus����һ�ģ���key_pressed_flag_dly1=1��key_pressed_flag_dly2=0
assign key_pressed_flag_plus_dly1=key_pressed_flag_dly1 & (~key_pressed_flag_dly2);
//--------------------------------------
// ???????? ????
//--------------------------------------
 
 
//++++++++++++++++++++++++++++++++++++++
// �������棬ֻ��Ҫ1��clk���弴�ɣ�������ʾ8����ͬ�����������
//++++++++++++++++++++++++++++++++++++++
reg [3:0] keyboard_val;

always @ (posedge clk1k or posedge rst)
  if (rst)
    keyboard_val <= 4'h0;
  else if(en==0)
    if (key_pressed_flag_plus)
      case ({col_val, row_val})
        8'b1110_1110 : keyboard_val <= 4'h1;
        8'b1110_1101 : keyboard_val <= 4'h4;
        8'b1110_1011 : keyboard_val <= 4'h7;
        8'b1110_0111 : keyboard_val <= 4'hE;
        8'b1101_1110 : keyboard_val <= 4'h2;
        8'b1101_1101 : keyboard_val <= 4'h5;
        8'b1101_1011 : keyboard_val <= 4'h8;
        8'b1101_0111 : keyboard_val <= 4'h0;
        8'b1011_1110 : keyboard_val <= 4'h3;
        8'b1011_1101 : keyboard_val <= 4'h6;
        8'b1011_1011 : keyboard_val <= 4'h9;
        8'b1011_0111 : keyboard_val <= 4'hF;
        8'b0111_1110 : keyboard_val <= 4'hA; 
        8'b0111_1101 : keyboard_val <= 4'hB;
        8'b0111_1011 : keyboard_val <= 4'hC;
        8'b0111_0111 : keyboard_val <= 4'hD;        
      endcase

reg[3:0] key_in_cnt;
reg[4:0] seg_data0,seg_data1,seg_data2,seg_data3,seg_data4,seg_data5,seg_data6,seg_data7;




	  
//����������ÿ����1��0-C��1�������Ǻ�-1������#����0������D��0	
always @ (posedge clk1k or posedge rst)
  if (rst)
    key_in_cnt <= 0;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF || keyboard_val==4'hD)
			key_in_cnt <= 0;
	  else if(keyboard_val==4'hE)
		if (key_in_cnt!=0)
			key_in_cnt <= key_in_cnt-1;
		else
			key_in_cnt <= key_in_cnt;
	  else
		if (key_in_cnt!=8)
			key_in_cnt <= key_in_cnt+1;
		
//�����0ֵ����ÿ����1��0-Cʱ��ʾ����ֵ�������Ǻ���ʾ�����1ֵ������#����0����ʾ������D���䣬�ٴΰ���0-Cʱ����Ȼ��ʾ����ֵ  
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_data0 <= 5'h1f;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF)
			seg_data0 <= 5'h1f;
	  else if (keyboard_val==4'hE)
			seg_data0 <= seg_data1;
	  else if (keyboard_val==4'hD)
			seg_data0 <= seg_data0;
	  else
		   if(key_in_cnt!=8)
			seg_data0 <= {1'b0,keyboard_val};

//�����1ֵ����ÿ����1��0-Cʱ��ʾ�����0ֵ�������Ǻ���ʾ�����2ֵ������#����0����ʾ������D���䣬�ٴΰ���0-Cʱ,����ʾ  
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_data1 <= 5'h1f;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF)
			seg_data1 <= 5'h1f;
	  else if (keyboard_val==4'hE)
			seg_data1 <= seg_data2;
	  else if (keyboard_val==4'hD)
			seg_data1 <= seg_data1;
	  else
			if(key_in_cnt==0)
				seg_data1 <= 5'h1f;
			else if(key_in_cnt!=8)
				seg_data1 <= seg_data0;

//�����2ֵ����ÿ����1��0-Cʱ��ʾ�����1ֵ�������Ǻ���ʾ�����3ֵ������#����0����ʾ������D���䣬�ٴΰ���0-Cʱ,����ʾ  
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_data2 <= 5'h1f;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF)
			seg_data2 <= 5'h1f;
	  else if (keyboard_val==4'hE)
			seg_data2 <= seg_data3;
	  else if (keyboard_val==4'hD)
			seg_data2 <= seg_data2;
	  else
			if(key_in_cnt==0)
				seg_data2 <= 5'h1f;
			else if(key_in_cnt!=8)
				seg_data2 <= seg_data1;
				
//�����3ֵ����ÿ����1��0-Cʱ��ʾ�����2ֵ�������Ǻ���ʾ�����4ֵ������#����0����ʾ������D���䣬�ٴΰ���0-Cʱ,����ʾ  
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_data3 <= 5'h1f;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF)
			seg_data3 <= 5'h1f;
	  else if (keyboard_val==4'hE)
			seg_data3 <= seg_data4;
	  else if (keyboard_val==4'hD)
			seg_data3 <= seg_data3;
	  else
			if(key_in_cnt==0)
				seg_data3 <= 5'h1f;
			else if(key_in_cnt!=8)
				seg_data3 <= seg_data2;

//�����4ֵ����ÿ����1��0-Cʱ��ʾ�����3ֵ�������Ǻ���ʾ�����5ֵ������#����0����ʾ������D���䣬�ٴΰ���0-Cʱ,����ʾ  
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_data4 <= 5'h1f;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF)
			seg_data4 <= 5'h1f;
	  else if (keyboard_val==4'hE)
			seg_data4 <= seg_data5;
	  else if (keyboard_val==4'hD)
			seg_data4 <= seg_data4;
	  else
			if(key_in_cnt==0)
				seg_data4 <= 5'h1f;
			else if(key_in_cnt!=8)
				seg_data4 <= seg_data3;	

//�����5ֵ����ÿ����1��0-Cʱ��ʾ�����4ֵ�������Ǻ���ʾ�����6ֵ������#����0����ʾ������D���䣬�ٴΰ���0-Cʱ,����ʾ  
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_data5 <= 5'h1f;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF)
			seg_data5 <= 5'h1f;
	  else if (keyboard_val==4'hE)
			seg_data5 <= seg_data6;
	  else if (keyboard_val==4'hD)
			seg_data5 <= seg_data5;
	  else
			if(key_in_cnt==0)
				seg_data5 <= 5'h1f;
			else if(key_in_cnt!=8)
				seg_data5 <= seg_data4;

//�����6ֵ����ÿ����1��0-Cʱ��ʾ�����5ֵ�������Ǻ���ʾ�����7ֵ������#����0����ʾ������D���䣬�ٴΰ���0-Cʱ,����ʾ  
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_data6 <= 5'h1f;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF)
			seg_data6 <= 5'h1f;
	  else if (keyboard_val==4'hE)
			seg_data6 <= seg_data7;
	  else if (keyboard_val==4'hD)
			seg_data6 <= seg_data6;
	  else
			if(key_in_cnt==0)
				seg_data6 <= 5'h1f;
			else if(key_in_cnt!=8)
				seg_data6 <= seg_data5;	

//�����7ֵ����ÿ����1��0-Cʱ��ʾ�����6ֵ�������ǺŲ���ʾ������#����0����ʾ������D���䣬�ٴΰ���0-Cʱ,����ʾ  
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_data7 <= 5'h1f;
  else if(en==0)
    if (key_pressed_flag_plus_dly1)
      if (keyboard_val==4'hF)
			seg_data7 <= 5'h1f;
	  else if (keyboard_val==4'hE)
			seg_data7 <= 5'h1f;
	  else if (keyboard_val==4'hD)
			seg_data7 <= seg_data7;
	  else
			if(key_in_cnt==0)
				seg_data7 <= 5'h1f;
			else if(key_in_cnt!=8)
				seg_data7 <= seg_data6;					
			
//--------------------------------------
//  ��̬�����ɨ��
//--------------------------------------
reg[2:0] seg_sel;
reg[3:0] seg_data;

//�����ɨ�裬ÿ��Ƭѡ����1ms��8msһ��ѭ�����൱��125HZ�����۲��ɼ��������
always @ (posedge clk1k or posedge rst)
  if (rst)
    seg_sel <= 0;
  else if(en==0)
	if (seg_sel==7)
		seg_sel <= 0;
	else
		seg_sel <= seg_sel+1;

//��ӦƬѡʹ�ܵ�ʱ�������Ӧ�����������
always @(seg_sel,seg_data0,seg_data1,seg_data2,seg_data3,seg_data4,seg_data5,seg_data6,seg_data7)
begin
	case(seg_sel)
	0	:	seg_data<=seg_data0;
	1	:	seg_data<=seg_data1;
	2	:	seg_data<=seg_data2;
	3	:	seg_data<=seg_data3;
	4	:	seg_data<=seg_data4;
	5	:	seg_data<=seg_data5;
	6	:	seg_data<=seg_data6;
	7	:	seg_data<=seg_data7;
	endcase
end 

//seg_an
always @(seg_sel,scan_cnt)
begin
if(en==0)begin
	case(seg_sel)
	0	:	seg_an<=8'b11111110;
	1	:	seg_an<=8'b11111101;
	2	:	seg_an<=8'b11111011;
	3	:	seg_an<=8'b11110111;
	4	:	seg_an<=8'b11101111;
	5	:	seg_an<=8'b11011111;
	6	:	seg_an<=8'b10111111;
	7	:	seg_an<=8'b01111111;
	endcase
end
else begin	
	case ( scan_cnt )    
          4'b0001 : seg_an = 8'b1111_1110;    
          4'b0010 : seg_an = 8'b1111_1101;    
          4'b0011 : seg_an = 8'b1111_1011;    
          4'b0100 : seg_an = 8'b1111_0111;    
          4'b0101 : seg_an = 8'b1110_1111;    
          4'b0110 : seg_an = 8'b1101_1111;    
          4'b0111 : seg_an = 8'b1011_1111;     
          4'b1000 : seg_an = 8'b0111_1111;    
          default : seg_an = 8'b1111_1111;    
      endcase
end
end


always @ (seg_data,scan_cnt)
     begin 
     if(en==0)begin
     case (seg_data)
         5'h0: seg_out = 8'b11000000; // 0
         5'h1: seg_out = 8'b11111001; // 1
         5'h2: seg_out = 8'b10100100; // 2
         5'h3: seg_out = 8'b10110000; // 3
         5'h4: seg_out = 8'b10011001; // 4
         5'h5: seg_out = 8'b10010010; // 5
         5'h6: seg_out = 8'b10000010; // 6
         5'h7: seg_out = 8'b11111000; // 7
         5'h8: seg_out = 8'b10000000; // 8
         5'h9: seg_out = 8'b10010000; // 9
         5'ha: seg_out = 8'b10001000; // A
         5'hb: seg_out = 8'b10000011; // b
         5'hc: seg_out = 8'b11000110; // c
         default: seg_out = 8'b11111111;
     endcase
     end
     else begin
          case (scan_cnt)
         1: seg_out = totout[7:0]; 
         2: seg_out = totout[15:8]; 
         3: seg_out = totout[23:16]; 
         4: seg_out = totout[31:24]; 
         5: seg_out = totout[39:32]; 
         6: seg_out = totout[47:40]; 
         7: seg_out = totout[55:48]; 
         8: seg_out = totout[63:56]; 
         default: seg_out = 8'b11111111;
     endcase
     end
     end    

//--------------------------------------
// buzzer,�������������ʱ�����߰���Dʱ����2s��
//--------------------------------------
reg[17:0] buzzer_en_cnt;
reg buzzer_en;
wire [17:0]total;
assign total=(speed)?15000:7500;
wire [17:0]sum=(speed)?15000*key_in_cnt:7500*key_in_cnt;
//buzzer_en_cnt,�����ʱ�����߰���Dʱ������Ϊ2000,2s�ӣ�����ÿ��clk-1������0���ټ�
always @ (posedge clk1k or posedge rst)
  if (rst)begin
    buzzer_en_cnt <= 0;
    //buzzer_en<=0;
  end
  else if(en==0)
    if (key_pressed_flag_plus_dly1)begin
          if (keyboard_val==4'hD)begin
                buzzer_en_cnt <= total;
          end
          else if (keyboard_val<4'hD && key_in_cnt==8)begin//λ������󱨾�
                buzzer_en_cnt <= 2000;
          end
          else begin
                buzzer_en_cnt <= buzzer_en_cnt;
          end
    end
	else if (buzzer_en_cnt!=0)begin
			buzzer_en_cnt <= buzzer_en_cnt-1;
	end
			
//buzzer_en,2s�ڿ����죬������
wire [17:0]long,short,mid;
assign long =(speed)?14'd2000:14'd1000;
assign short=(speed)?14'd1000:14'd500;
assign mid=(speed)?14'd1000:14'd500;
reg [4:0]tmp_seg_data;
always@(sw)begin
    if(keyboard_val==4'hD)begin
        case(sw)
            8'b0000_0001:tmp_seg_data=seg_data7;
            8'b0000_0010:tmp_seg_data=seg_data6;
            8'b0000_0100:tmp_seg_data=seg_data5;
            8'b0000_1000:tmp_seg_data=seg_data4;
            8'b0001_0000:tmp_seg_data=seg_data3;
            8'b0010_0000:tmp_seg_data=seg_data2;
            8'b0100_0000:tmp_seg_data=seg_data1;
            8'b1000_0000:tmp_seg_data=seg_data0;
            default:tmp_seg_data=5'b1_1111;
        endcase
    end
end

always@(buzzer_en_cnt)begin
     if(keyboard_val==4'hD)begin
       case(tmp_seg_data)
           5'd0:begin
               if(buzzer_en_cnt>=total-long)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long -mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-long-mid-long)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-long)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-long-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-long-mid-long) 
                   buzzer_en=1'b1;
               else                        
                   buzzer_en=1'b0;
           end
           5'd1:begin 
               if(buzzer_en_cnt>=total-short)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-short-mid-long)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-long-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-short-mid-long-mid-long)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-long-mid-long-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-short-mid-long-mid-long-mid-long)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-long-mid-long-mid-long-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-short-mid-long-mid-long-mid-long-mid-long)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0;   
                                                         
           end
           5'd2:begin
               if(buzzer_en_cnt>=total-short)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-short-mid-short)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-short-mid-short-mid-long)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid-long-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-short-mid-short-mid-long-mid-long)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid-long-mid-long-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-short-mid-short-mid-long-mid-long-mid-long)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0; 
           end
           5'd3:begin
               if(buzzer_en_cnt>=total-short)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-short-mid-short)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-long)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-long-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-long-mid-long)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0; 
           end
           5'd4:begin
               if(buzzer_en_cnt>=total-short)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-short-mid-short)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-short-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-short-mid-long)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0; 
           end
           5'd5:begin
               if(buzzer_en_cnt>=total-short)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-short-mid-short)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-short-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-short-mid-short-mid-short-mid-short-mid-short)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0; 
           end
           5'd6:begin
               if(buzzer_en_cnt>=total-long)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-long-mid-short)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-short-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-long-mid-short-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-short-mid-short-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-long-mid-short-mid-short-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-short-mid-short-mid-short-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-long-mid-short-mid-short-mid-short-mid-short)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0; 
           end
           5'd7:begin
               if(buzzer_en_cnt>=total-long)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-long-mid-long)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-long-mid-long-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-short-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-long-mid-long-mid-short-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-short-mid-short-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-long-mid-long-mid-short-mid-short-mid-short)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0; 
           end
           5'd8:begin
               if(buzzer_en_cnt>=total-long)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-long-mid-long)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-short)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-short-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-short-mid-short)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0; 
           end
           5'd9:begin
               if(buzzer_en_cnt>=total-long)     
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid)
                   buzzer_en=1'b0;
               else if(buzzer_en_cnt>=total-long-mid-long)
                   buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid)
                   buzzer_en=1'b0; 
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid)
                       buzzer_en=1'b0;      
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-long)
                       buzzer_en=1'b1;
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-long-mid)
                       buzzer_en=1'b0;  
               else if(buzzer_en_cnt>=total-long-mid-long-mid-long-mid-long-mid-short)
                       buzzer_en=1'b1;    
               else                        
                       buzzer_en=1'b0; 
           end
           default:buzzer_en=1'b0; 
       endcase
   end
    else begin
           buzzer_en=((buzzer_en_cnt==0) ? 0 : 1);
    end
end




//buzzer,��buzzer_enΪ1ʱ����500hz��ת�����������
always @ (posedge clk1k or posedge rst)
  if (rst)
    buzzer <= 0;
  else if(en==0)
    if (buzzer_en)
		buzzer <= ~ buzzer;
	else
		buzzer <= 0;  
    
    /////////////////////////////////////////////////////////////////////////////////////////////
endmodule
