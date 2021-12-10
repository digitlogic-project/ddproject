`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/27 21:20:26
// Design Name: 
// Module Name: design1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module design1(
input short,
input long,
output reg [2:0] length,
input decode,
input clearALL,
input back,

input clk,
input rst,

output reg [7:0] Y_r,
output reg [2:0] th,
output reg [4:0] code,
output reg [4:0] leds,
output reg [7:0] seg_out,
output reg [7:0] out,
output reg [7:0] seg_en,
output reg [63:0] totout
    );
parameter en0 = 8'b1111_1111,en1 = 8'b0111_1111,en2 = 8'b0011_1111,en3 = 8'b0001_1111,
en4 = 8'b0000_1111,en5 = 8'b0000_0111,en6 = 8'b0000_0011,en7 = 8'b000_0001,en8 = 8'b0000_0000;

parameter out0 = 8'b00000000, out1 = 8'b00000000, out2 = 8'b00000000, out3 = 8'b00000000, out4 = 8'b00000000, 
out5 = 8'b00000000, out6 = 8'b00000000, out7 = 8'b00000000, out8 = 8'b00000000;

reg [7:0] next_state;
reg [7:0] outnext_state;
reg [2:0] tot;

reg [31:0]cnt;
reg [3:0]scan_cnt;

parameter  period= 100000;
reg clkout;

always @(posedge clk or negedge rst)
begin
    if(!rst)
      begin
        tot <= 0;
//      seg_out <= out0;
      end
    else if(decode == 1'b1)begin
        tot <= tot + 1'b1;
//        seg_en <= next_state;
//        seg_out <= outnext_state;
        begin
        case(length)
          3'o1:begin
            case(code)
              5'bxxxx0: out<=8'b0000_0110;//e
              5'bxxxx1: out<=8'b0000_0111;//t
            endcase
            end
          3'o2:begin
            case(code)
              5'bxxx10: out<=8'b0000_1000;//a
              5'bxxx00: out<=8'b0111_0000;//i
              5'bxxx11: out<=8'b0100_1000;//m
              5'bxxx01: out<=8'b0010_1011;//n   
            endcase
            end       
          3'o3:begin
            case(code)
              5'bxx001: out<=8'b0010_0001;//d
              5'bxx011: out<=8'b0100_0010;//g
              5'bxx101: out<=8'b0000_1010;//k
              5'bxx111: out<=8'b0010_0011;//o
              5'bxx010: out<=8'b0100_1110;//r
              5'bxx000: out<=8'b0011_0110;//s
              5'bxx100: out<=8'b0100_0001;//u
              5'bxx110: out<=8'b0000_0001;//w
            endcase
            end
          3'o4:begin
            case(code)
              5'bx0001: out<=8'b0000_0011;//b
              5'bx0101: out<=8'b0100_0110;//c
              5'bx0100: out<=8'b0000_1110;//f
              5'bx0000: out<=8'b0000_1001;//h
              5'bx1110: out<=8'b0111_0001;//j
              5'bx0010: out<=8'b0100_0111;//l
              5'bx0110: out<=8'b0000_1100;//p
              5'bx1011: out<=8'b0001_1000;//q
              5'bx1000: out<=8'b0110_0011;//v
              5'bx1001: out<=8'b0001_1011;//x
              5'bx1101: out<=8'b0001_0001;//y
              5'bx0011: out<=8'b0010_0101;//z
            endcase
            end
          3'o5:begin
            case(code)
              5'b11110: out<=8'b0111_1001;//1
              5'b11100: out<=8'b0010_0100;//2
              5'b11000: out<=8'b0011_0000;//3
              5'b10000: out<=8'b0001_1001;//4
              5'b00000: out<=8'b0001_0010;//5
              5'b00001: out<=8'b0000_0010;//6
              5'b00011: out<=8'b0111_1000;//7
              5'b00111: out<=8'b0000_0000;//8
              5'b01111: out<=8'b0001_0000;//9
              5'b11111: out<=8'b0100_0000;//0
           endcase
           end
         default : out <= 8'b1111_1111;//ÎÞ
        endcase
        end
        
      begin
      case(tot)
        1: totout[7:0] <= out;
        2: totout[15:8] <= out;
        3: totout[23:16] <= out;
        4: totout[31:24] <= out;
        5: totout[39:32] <= out;
        6: totout[47:40] <= out;
        7: totout[55:48] <= out;
        8: totout[63:56] <= out;
      endcase
      end
    end
    end

always @(posedge clk or negedge rst)
  begin
  if(!rst)
    begin
    code <= 5'b00000;
    th <= 3'b000;
    length <= 3'b000;
    leds <= 5'b00000;
    end
  else if(short == 1'b0)
     begin
       code[th] <= 0;
       th <= th + 1'b1;
       leds[length] <= 1'b0;
       length <= length + 1'b1;
     end
  else if(long == 1'b0)
     begin
       code[th] <= 1;
       th <= th + 1'b1;
       leds[length] <= 1'b1;
       length <= length + 1'b1;
     end
  end

always @(posedge clk or negedge rst)
begin
  if (clearALL == 1'b1)
    begin
      length <= 3'b0;
      code <= 5'b0;
      seg_en <= en0;
      seg_out <= out0;
    end
end

always@(posedge clk, negedge rst) begin
		if(~rst) begin
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

always@(posedge clkout or negedge rst) begin
  if(!rst) begin
    scan_cnt <= 0;
  end
  else begin
    scan_cnt <= scan_cnt + 1;
    case(tot)
    1: if(scan_cnt == 4'd1) scan_cnt <= 0;
    2: if(scan_cnt == 4'd2) scan_cnt <= 0;
    3: if(scan_cnt == 4'd3) scan_cnt <= 0;
    4: if(scan_cnt == 4'd4) scan_cnt <= 0;
    5: if(scan_cnt == 4'd5) scan_cnt <= 0;
    6: if(scan_cnt == 4'd6) scan_cnt <= 0;
    7: if(scan_cnt == 4'd7) scan_cnt <= 0;
    8: if(scan_cnt == 4'd8) scan_cnt <= 0;
    endcase
  end
end

always @( scan_cnt)
          begin 
          case ( scan_cnt )    
              4'b0001 : seg_en = 8'b1111_1110;    
              4'b0010 : seg_en = 8'b1111_1101;    
              4'b0011 : seg_en = 8'b1111_1011;    
              4'b0100 : seg_en = 8'b1111_0111;    
              4'b0101 : seg_en = 8'b1110_1111;    
              4'b0110 : seg_en = 8'b1101_1111;    
              4'b0111 : seg_en = 8'b1011_1111;     
              4'b1000 : seg_en = 8'b0111_1111;    
              default : seg_en = 8'b1111_1111;    
          endcase
          end

always @ (scan_cnt )
     begin 
     case (scan_cnt)
         1: Y_r = totout[7:0]; 
         2: Y_r = totout[15:8]; 
         3: Y_r = totout[23:16]; 
         4: Y_r = totout[31:24]; 
         5: Y_r = totout[39:32]; 
         6: Y_r = totout[47:40]; 
         7: Y_r = totout[55:48]; 
         8: Y_r = totout[63:56]; 
         default: Y_r = 8'b11111111;
     endcase
     end
endmodule
//always @ (*)
//  begin
//  case (seg_en)
//    en0 : next_state = en1;
//    en1 : next_state = en2;
//    en2 : next_state = en3;
//    en3 : next_state = en4;
//    en4 : next_state = en5;
//    en5 : next_state = en6;
//    en6 : next_state = en7;
//    en7 : next_state = en8;                    
//  endcase
//  end

//always @ (*)
//  begin
//  case (seg_out)
//    out0 : outnext_state = out1;
//    out1 : outnext_state = out2;
//    out2 : outnext_state = out3;
//    out3 : outnext_state = out4;
//    out4 : outnext_state = out5;
//    out5 : outnext_state = out6;
//    out6 : outnext_state = out7;
//    out7 : outnext_state = out8;                    
//  endcase
//  end

//led±äÆµ
//always @( posedge clk or negedge rst)      
//     begin 
//     if (!rst)
//         cnt <= 0 ;
//     else  begin  
//             cnt<= cnt+1;
//         if (cnt    == (period >> 1) - 1)               
//                 clkout <= #1 1'b1;
//         else if (cnt == period - 1)                    
//             begin 
//                 clkout <= #1 1'b0;
//                  cnt <= #1 'b0;      
//             end          
//         end
//     end



//              4'h0: seg_out=8'b0100_0000;  // 0
//              4'h1: seg_out=8'b0111_1001;  // 1
//              4'h2: seg_out=8'b0010_0100;  // 2
//              4'h3: seg_out=8'b0011_0000;  // 3
//              4'h4: seg_out=8'b0001_1001;  // 4
//              4'h5: seg_out=8'b0001_0010;  // 5
//              4'h6: seg_out=8'b0000_0010;  // 6
//              4'h7: seg_out=8'b0111_1000;  // 7
//              4'h8: seg_out=8'b0000_0000;  // 8
//              4'h9: seg_out=8'b0001_0000;  // 9
//              4'ha: seg_out=8'b0000_1000;  // A
//              4'hb: seg_out=8'b0000_0011;  // b
//              4'hc: seg_out=8'b0100_0110;  // c
//              4'hd: seg_out=8'b0010_0001;  // d
//              4'he: seg_out=8'b0000_0110;  // E
//              4'hf: seg_out=8'b0000_1110;  // F
//              4'h0: seg_out=8'b0100_0010;  // G
//              4'h1: seg_out=8'b0000_1001;  // H
//              4'h2: seg_out=8'b0111_0000;  // I
//              4'h3: seg_out=8'b0111_0001;  // J
//              4'h4: seg_out=8'b0000_1010;  // K
//              4'h5: seg_out=8'b0100_0111;  // L
//              4'h6: seg_out=8'b0100_1000;  // M
//              4'h7: seg_out=8'b0010_1011;  // N
//              4'h8: seg_out=8'b0010_0011;  // o
//              4'h9: seg_out=8'b0000_1100;  // P
//              4'ha: seg_out=8'b0001_1000;  // Q
//              4'hb: seg_out=8'b0100_1110;  // R
//              4'hc: seg_out=8'b0011_0110;  // S
//              4'hd: seg_out=8'b0000_0111;  // T
//              4'he: seg_out=8'b0100_0001;  // U
//              4'hf: seg_out=8'b0110_0011;  // V
//              4'hc: seg_out=8'b0000_0001;  // W
//              4'hd: seg_out=8'b0001_1011;  // X
//              4'he: seg_out=8'b0001_0001;  // Y
//              4'hf: seg_out=8'b0010_0101;  // Z