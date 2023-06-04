%清空输出图片和工作变量
clear ;
clear ;
clc;
%读图片,画出原始灰度直方图
path = 'D:\专业书\数字图像处理\dipum_images_ch02\pic00.tif';
pic_raw = imread(path);
if size(pic_raw,3) == 3
    pic_raw = rgb2gray(pic_raw);
end
subplot(121),imhist(pic_raw),title('histograph\_raw'),xlabel('灰度值'),ylabel('数量');
%统计概率直方图
histograph = zeros(1,256);
[row_num,col_num]= size(pic_raw);
% 太慢了这个
% for i= 1:row_num*col_num
%     %每个像素计算出现的总概率
%     temp = pic_raw == i;
%     histo_i_numerator = sum(temp(:));
%     histo_i_denominator = 256;
%     histograph(i+1) = histo_i_numerator/histo_i_denominator;
% end

%计算频率分布直方图
for i = 1:row_num
    for j = 1:col_num
        %循环检查图像像素，查到x，对应的灰度值x的个数+1
        pixel_now = pic_raw(i,j);
        histograph(pixel_now+1) = histograph(pixel_now+1) + 1;
    end
end
for i = 0:255
    %将个数转化为概率
    histograph(uint16(i)+1) = histograph(uint16(i)+1)/(row_num*col_num);
end

%算累积分布
histograph_acc = zeros(1,256);
for i=0:255
    if i == 0
        %第一个像素特殊处理，直接用原来的来算累积分布
        histograph_acc(i+1) = histograph(i+1);
    else   
        %其余像素累计分布用前一个累积分布加上当前像素的概率即可
        histograph_acc(uint16(i)+1) = histograph_acc(i)+histograph(uint16(i)+1);
    end
end
%乘255获得旧的灰度到新的灰度的映射函数
graymap = round(histograph_acc*255);
%映射生成新的图片
pic_new1 = zeros(row_num,col_num);
for i = 1:row_num
    for j = 1:col_num
        pixel_raw = pic_raw(i,j);
        pic_new1(i,j) = graymap(pixel_raw+1);
    end
end
subplot(122),imhist(uint8(pic_new1)),title('histograph\_new'),xlabel('灰度值'),ylabel('数量');
%输出新旧图片进行对比
figure;
subplot(121),imshow(pic_raw),title('pic\_raw');
subplot(122),imshow(uint8(pic_new1)),title('pic\_new');

%用CLAHE方式，既没有太大噪声，也没有颜色过度亮
pic_new2 = adapthisteq(pic_raw,'NumTiles',[5 5],'ClipLimit',0.005);
figure,subplot(122),imshow(uint8(pic_new2)),title('histograph\_new'),xlabel('灰度值'),ylabel('数量');

