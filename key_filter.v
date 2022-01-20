`timescale  1ns/1ns

module  keyfilter
#(
    parameter CNT_MAX = 20'd999_999 //�������������ֵ
)
(
    input   wire    sys_clk     ,   //ϵͳʱ��50Mhz
    input   wire    sys_rst_n   ,   //ȫ�ָ�λ
    input   wire    key_in      ,   //���������ź�
    output  reg     key_flag        //key_flagΪ1ʱ��ʾ�������⵽����������
                                    //key_flagΪ0ʱ��ʾû�м�⵽����������
);
reg     [19:0]  cnt_20ms    ;   //������
//***************************** Main Code ****************************//
//cnt_20ms:���ʱ�ӵ������ؼ�⵽�ⲿ���������ֵΪ�͵�ƽʱ����������ʼ����
always@(posedge sys_clk or posedge sys_rst_n)begin
    if(sys_rst_n == 1'b1)
        cnt_20ms <= 20'b0;
    else    if(key_in == 1'b1)
        cnt_20ms <= 20'b0;
    else    if(cnt_20ms == CNT_MAX && key_in == 1'b0)
        cnt_20ms <= cnt_20ms;
    else
        cnt_20ms <= cnt_20ms + 1'b1;
end
//key_flag:��������20ms�����������Ч��־λ
//��key_flag��999_999ʱ����,ά��һ��ʱ�ӵĸߵ�ƽ
always@(posedge sys_clk or posedge sys_rst_n)begin
    if(sys_rst_n == 1'b1)
        key_flag <= 1'b0;
    else    if(cnt_20ms == CNT_MAX - 1'b1)
        key_flag <= 1'b1;
    else
        key_flag <= 1'b0;
end
endmodule
