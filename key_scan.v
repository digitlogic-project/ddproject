module  key_scan(
                 clk    ,
                 rst_n  ,
                 key_col,
                 key_row,
                 key_out,
                 key_vld   
               );


    parameter      KEY_W    =   4 ;
    parameter      COL      =   0 ;
    parameter      ROW      =   1 ;
    parameter      DLY      =   2 ;
    parameter      FIN      =   3 ;
    parameter      COL_CNT  =   160;
    parameter      TIME_20MS=   10_000_000;

    //�����źŶ���
    input               clk    ;
    input               rst_n  ;
    input  [3:0]        key_col;

    //����źŶ���
    output              key_vld;
    output[3:0]         key_out;
    output[KEY_W-1:0]   key_row;

    //����ź�reg����
    reg   [3:0]         key_out;
    reg   [KEY_W-1:0]   key_row;
    reg                 key_vld;


    reg [3:0]           key_col_ff0;
    reg [3:0]           key_col_ff1;
    reg [1:0]           key_col_get;
    reg                 shake_flag ;
    reg                 shake_flag_ff0;
    reg[3:0]            state_c;
    reg [23:0]          shake_cnt;
    reg[3:0]            state_n;
    reg [1:0]           row_index;
    reg[ 9:0]           row_cnt;
    //reg[ 2:0]           x      ;


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_col_ff0 <= 4'b1111;
        key_col_ff1 <= 4'b1111;
    end
    else begin
        key_col_ff0 <= key_col    ;
        key_col_ff1 <= key_col_ff0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        shake_cnt <= 0;
    end
    else if(add_shake_cnt)begin
        if(end_shake_cnt)
            shake_cnt <= 0;
        else
            shake_cnt <= shake_cnt + 1;
    end
    else begin
        shake_cnt <= 0;
    end
end

assign  add_shake_cnt = key_col_ff1!=4'hf && shake_flag==0;
assign  end_shake_cnt = add_shake_cnt && shake_cnt==TIME_20MS-1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        shake_flag <= 0;
    end
    else if(end_shake_cnt) begin
        shake_flag <= 1'b1;
    end
    else if(key_col_ff1==4'hf) begin
        shake_flag <= 1'b0;
    end
end



always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        state_c <= COL;
    end
    else begin
        state_c <= state_n;
    end
end



always  @(*)begin
    case(state_c)
        COL: begin
                     if(col2row_start)begin
                         state_n = ROW;
                     end
                     else begin
                         state_n = state_c;
                     end
                 end
        ROW: begin
                     if(row2dly_start)begin
                         state_n = DLY;
                     end
                     else begin
                         state_n = state_c;
                     end
                 end
        DLY :  begin
                     if(dly2fin_start)begin
                         state_n = FIN;
                     end
                     else begin
                         state_n = state_c;
                     end
                 end
        FIN: begin
                     if(fin2col_start)begin
                         state_n = COL;
                     end
                     else begin
                         state_n = state_c;
                     end
                  end
       default: state_n = COL;
    endcase
end

assign  col2row_start = state_c==COL && end_shake_cnt;
assign  row2dly_start = state_c==ROW && end_row_index; 
assign  dly2fin_start = state_c==DLY && end_row_index; 
assign  fin2col_start = state_c==FIN && key_col_ff1==4'hf;





always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_row <= 4'b0;
    end
    else if(state_c==ROW)begin
        key_row <= ~(1'b1 << row_index);
    end
    else begin
        key_row <= 4'b0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        row_cnt <= 0;
    end
    else if(add_row_cnt) begin
        if(end_row_cnt)
            row_cnt <= 0;
        else
            row_cnt <= row_cnt + 1;
    end
end
assign add_row_cnt = state_c==ROW || state_c==DLY;
assign end_row_cnt = add_row_cnt && row_cnt==COL_CNT-1;


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        row_index <= 0;
    end
    else if(add_row_index) begin
        if(end_row_index)
            row_index <= 0;
        else
            row_index <= row_index + 1;
    end
end
assign add_row_index = end_row_cnt;
assign end_row_index = add_row_index && row_index==16-1;

//always  @(*)begin
//    if(state_c==ROW)
//        x = 4;
//    else
//        x = 1;
//end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_col_get <= 0;
    end
    else if(col2row_start) begin
        if(key_col_ff1==4'b1110)
            key_col_get <= 0;
        else if(key_col_ff1==4'b1101)
            key_col_get <= 1;
        else if(key_col_ff1==4'b1011)
            key_col_get <= 2;
        else 
            key_col_get <= 3;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_out <= 0;
    end
    else if(state_c==ROW && end_row_cnt)begin
        key_out <= {row_index,key_col_get};
    end
    else begin
        key_out <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_vld <= 1'b0;
    end
    else if(state_c==ROW && end_row_cnt && key_col_ff1[key_col_get]==1'b0)begin
        key_vld <= 1'b1;
    end
    else begin
        key_vld <= 1'b0;
    end
end

endmodule

