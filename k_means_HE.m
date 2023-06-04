clear;
clear;
clc;
%pic:图片，histograph:直方图，gap:最初划分子图的阈值
%注意：对于循环的i用uint16是为了求256，图像矩阵uint8是因为图像double不好输出

%读图片,画出原始灰度直方图
path = 'D:\专业书\数字图像处理\dipum_images_ch03\pic1.tif';
pic_raw = imread(path);
pic_shape = size(pic_raw,3);
if pic_shape == 3
    pic_raw = rgb2gray(pic_raw);
end
imhist(pic_raw),title('histograph\_raw'),xlabel('灰度值'),ylabel('数量');

%计算分割图像的阈值
[row_num,col_num]= size(pic_raw);
gap = uint8(sum(pic_raw(:))/(row_num*col_num)+0.5);

%分割图像并且统计直方图,统计子图像素个数
pic_left = uint8(zeros(row_num,col_num));
pic_right = uint8(zeros(row_num,col_num));
histograph_left = zeros(1,256);
histograph_right = zeros(1,256);
pic_left_num = 0;
pic_right_num = 0;


%聚类
%初始聚类中心计算(设计两个图像矩阵，聚到哪一类，哪一类上对应位置赋值，完后求和求均值即可)
cluster_kernal = zeros(1,2);
pic_cluster = uint8(zeros(row_num,col_num));
for i=1:row_num
    for j = 1:col_num
        if pic_raw(i,j) <= gap
            pic_left(i,j) = uint32(pic_raw(i,j));
            pic_left_num = uint32(pic_left_num)+1;
            pic_cluster(i,j) = 0;
        else
            pic_right(i,j) = uint32(pic_raw(i,j));
            pic_right_num = uint32(pic_right_num)+1;
            pic_cluster(i,j) = 1;
        end
    end
end
%求均值，获得聚类中心
cluster_kernal(1) = round(sum(pic_left(:))/pic_left_num);
cluster_kernal(2) = round(sum(pic_right(:))/pic_right_num);

%第一次聚类(用第三个矩阵作布尔矩阵0，1来标记类别)
 pic_cluster = uint8(zeros(row_num,col_num));

 for i=1:row_num
     for j = 1:col_num
         dist1 = abs((int32(pic_raw(i,j))-cluster_kernal(1)));
         dist2 = abs((int32(pic_raw(i,j))-cluster_kernal(2)));
         if  dist1 <= dist2
             pic_cluster(i,j) = 0;
         else
             pic_cluster(i,j) = 1;
         end
     end
 end

%迭代聚类（更新-》聚类），这里用true因为内部有聚类到局部最优就停止
while true
    %已经聚类后的更新    
    pic_left = uint8(zeros(row_num,col_num));
    pic_right = uint8(zeros(row_num,col_num));
    pic_left_num = 0;
    pic_right_num = 0;
    for i=1:row_num
        for j = 1:col_num
            if pic_cluster(i,j) == 0
                pic_left(i,j) = uint32(pic_raw(i,j));
                pic_left_num = uint32(pic_left_num)+1;
            else
                pic_right(i,j) = uint32(pic_raw(i,j));
                pic_right_num = uint32(pic_right_num)+1;
            end
        end
    end
    
    %更新到聚类点局部最优后退出
    if cluster_kernal(1) == round(sum(pic_left(:))/pic_left_num)
        if cluster_kernal(2) == round(sum(pic_right(:))/pic_right_num)
            break
        end
    end
    
    %没有最优就接着更新
    cluster_kernal(1) = round(sum(pic_left(:))/pic_left_num);
    cluster_kernal(2) = round(sum(pic_right(:))/pic_right_num);
    
    %每次更新后重新聚类
    pic_cluster = uint8(zeros(row_num,col_num));
    
    for i=1:row_num
        for j = 1:col_num
            dist1 = abs((int32(pic_raw(i,j))-cluster_kernal(1)));
            dist2 = abs((int32(pic_raw(i,j))-cluster_kernal(2)));
            if  dist1 <= dist2
                pic_cluster(i,j) = 0;
            else
                pic_cluster(i,j) = 1;
            end
        end
    end
end
sse_group = zeros(1,4);
for m = 1:row_num
    for j = 1:col_num
        sse_group(1) = sse_group(1) + (cluster_kernal(pic_cluster(i,j)+1) - int32(pic_raw(i,j)))^2;
    end
end



%找到局部最优聚类点后同时也划分了不同的子图，接下来直接找到每个子图的最大值gap
gap = max(pic_left(:));

%TODO 上面通过局部最优找到了gap
%下面还要接着修改来求合并，不能直接用gap粗暴划分，论文实际上是对于大的部分的
%可以粗暴划分，工作基本完成。
%如果继续改进可以研究选择最优聚类点情况下的聚类和结果


%注意映射关系，矩阵下标gap+2位置有值代表对应的灰度gap+1有值
for i=1:row_num
    for j = 1:col_num
        if pic_raw(i,j) <= gap
            pic_left(i,j) = pic_raw(i,j);
            histograph_left(pic_left(i,j)+1) = histograph_left(pic_left(i,j)+1)+1;
        else
            pic_right(i,j) = pic_raw(i,j);
            histograph_right(pic_right(i,j)+1) = histograph_right(pic_right(i,j)+1)+1;
        end
    end
end

%打印分割后的直方图
figure;
subplot(121),imhist(uint8(pic_left)),title('histograph\_left'),xlabel('灰度值'),ylabel('数目');
subplot(122),imhist(uint8(pic_right)),title('histograph\_right'),xlabel('灰度值'),ylabel('数目');

%分割图像统计直方图

for i = 0:gap
    %左子图个数转概率图  %%!这里用double ，因为int除去int会归0
    histograph_left(i+1) = histograph_left(i+1)/double(pic_left_num);
end
for i = gap+1:255
    %右子图个数转概率图
    histograph_right(i+1) = histograph_right(i+1)/double(pic_right_num);
end

%计算累积分布
histograph_left_acc = zeros(1,256);
histograph_right_acc = zeros(1,256);

for i=0:gap
    if i == 0
        %第一个像素特殊处理，直接用原来的来算累积分布
        histograph_left_acc(i+1) = histograph_left(i+1);
    else   
        %其余像素累计map分布用前一个累积分布加上当前像素的概率即可
        histograph_left_acc(i+1) = histograph_left_acc(i)+histograph_left(i+1);
    end
end
%这里有个问题，生成的右子图像素的第256个，累积分布归0了,发现是i位uint8时最大255，不管怎么加都是255
%需要用uint16来修改再加
for i= (gap+1):255
    if i == gap+1
        %第一个像素特殊处理，直接用原来的来算累积分布
        histograph_right_acc(i+1) = histograph_right(i+1);
    else   
        %其余像素累计分布用前一个累积分布加上当前像素的概率即可
        histograph_right_acc(uint16(i)+1) = histograph_right_acc(i)+histograph_right(i+1);
    end
end

%映射函数计算和合并
graymap = zeros(1,256);
for i=0:gap
    graymap(uint16(i)+1) = round(histograph_left_acc(uint16(i)+1)*gap);
end
for i=gap+1:255
    graymap(uint16(i)+1) = round((gap+1)+histograph_right_acc(uint16(i)+1)*(255-(gap+1)));
end

%映射生成新的图片
pic_new = zeros(row_num,col_num);
for i = 1:row_num
    for j = 1:col_num
        pixel_raw = pic_raw(i,j);
        pic_new(i,j) = graymap(pixel_raw+1);
    end
end
%打印原图和新图的直方图
figure;
subplot(121),imhist(uint8(pic_raw)),title('histograph\_raw'),xlabel('灰度值'),ylabel('数量');
subplot(122),imhist(uint8(pic_new)),title('histograph\_new'),xlabel('灰度值'),ylabel('数量');
%打印原图和新图
figure;
subplot(121),imshow(uint8(pic_raw)),title('pic\_raw'),xlabel('灰度值'),ylabel('数量');
subplot(122),imshow(uint8(pic_new)),title('pic\_new'),xlabel('灰度值'),ylabel('数量');

