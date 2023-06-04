%������ͼƬ�͹�������
clear ;
clear ;
clc;
%��ͼƬ,����ԭʼ�Ҷ�ֱ��ͼ
path = 'D:\רҵ��\����ͼ����\dipum_images_ch02\pic00.tif';
pic_raw = imread(path);
if size(pic_raw,3) == 3
    pic_raw = rgb2gray(pic_raw);
end
subplot(121),imhist(pic_raw),title('histograph\_raw'),xlabel('�Ҷ�ֵ'),ylabel('����');
%ͳ�Ƹ���ֱ��ͼ
histograph = zeros(1,256);
[row_num,col_num]= size(pic_raw);
% ̫�������
% for i= 1:row_num*col_num
%     %ÿ�����ؼ�����ֵ��ܸ���
%     temp = pic_raw == i;
%     histo_i_numerator = sum(temp(:));
%     histo_i_denominator = 256;
%     histograph(i+1) = histo_i_numerator/histo_i_denominator;
% end

%����Ƶ�ʷֲ�ֱ��ͼ
for i = 1:row_num
    for j = 1:col_num
        %ѭ�����ͼ�����أ��鵽x����Ӧ�ĻҶ�ֵx�ĸ���+1
        pixel_now = pic_raw(i,j);
        histograph(pixel_now+1) = histograph(pixel_now+1) + 1;
    end
end
for i = 0:255
    %������ת��Ϊ����
    histograph(uint16(i)+1) = histograph(uint16(i)+1)/(row_num*col_num);
end

%���ۻ��ֲ�
histograph_acc = zeros(1,256);
for i=0:255
    if i == 0
        %��һ���������⴦��ֱ����ԭ���������ۻ��ֲ�
        histograph_acc(i+1) = histograph(i+1);
    else   
        %���������ۼƷֲ���ǰһ���ۻ��ֲ����ϵ�ǰ���صĸ��ʼ���
        histograph_acc(uint16(i)+1) = histograph_acc(i)+histograph(uint16(i)+1);
    end
end
%��255��þɵĻҶȵ��µĻҶȵ�ӳ�亯��
graymap = round(histograph_acc*255);
%ӳ�������µ�ͼƬ
pic_new1 = zeros(row_num,col_num);
for i = 1:row_num
    for j = 1:col_num
        pixel_raw = pic_raw(i,j);
        pic_new1(i,j) = graymap(pixel_raw+1);
    end
end
subplot(122),imhist(uint8(pic_new1)),title('histograph\_new'),xlabel('�Ҷ�ֵ'),ylabel('����');
%����¾�ͼƬ���жԱ�
figure;
subplot(121),imshow(pic_raw),title('pic\_raw');
subplot(122),imshow(uint8(pic_new1)),title('pic\_new');

%��CLAHE��ʽ����û��̫��������Ҳû����ɫ������
pic_new2 = adapthisteq(pic_raw,'NumTiles',[5 5],'ClipLimit',0.005);
figure,subplot(122),imshow(uint8(pic_new2)),title('histograph\_new'),xlabel('�Ҷ�ֵ'),ylabel('����');

