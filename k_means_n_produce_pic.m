%确定最优聚类点数目
cluster_num = 4;
%用对应的最优聚类中心聚类和直方图聚类
pic_cluster = uint8(zeros(row_num,col_num));
dist = zeros(1,cluster_num);
for i=1:row_num
    for j = 1:col_num
        for k = 1:cluster_num
            expr_dist = ['dist(k) = abs((int32(pic_raw(i,j))-cluster_kernal_',int2str(cluster_num),'(k)));'];
            eval(expr_dist);
        end
        %min_value没用，要的是位置,代表聚类到第几类
        [min_value,pic_cluster(i,j)] = min(dist);
    end
end

%重新计算图像矩阵和直方图矩阵
for i =1:cluster_num
    %建立每个子图的空白图像矩阵
    expr1 = ['pic_',int2str(i),'=uint8(zeros(row_num,col_num));'];
    eval(expr1);
    %建立每个字图对应的空白直方图
    expr2 = ['histograph_',int2str(i),'=zeros(1,256);'];
    eval(expr2);
    %统计每个子图拥有的像素个数
    expr3 = ['pic_',int2str(i),'_num = 0;'];
    eval(expr3);
end

%根据聚类结果获得对应聚类后的子图和直方图统计数目
for i=1:row_num
    for j = 1:col_num
        for k =1:cluster_num
            if pic_cluster(i,j) == k
                expr4 = ['pic_',int2str(k),'(i,j)=pic_raw(i,j);'];
                eval(expr4);
                expr5 = ['pic_',int2str(k),'_num =uint32(','pic_',int2str(k),'_num',')+1;'];
                eval(expr5);
                expr6 = ['histograph_',int2str(k),'(uint16(pic_',int2str(k),'(i,j))+1)=','histograph_',int2str(k),'(pic_',int2str(k),'(i,j)+1)+1;'];
                eval(expr6);
            end
        end
    end
end

% % %找到局部最优聚类点后同时也划分了不同的子图，接下来直接找到每个子图的最大值gap,最后一个gap是255
% %注意，关键点：分割gap是在聚类基础上，代表gap分割的每个子图都是聚类已经生成的，不需要额外生成
gap_group = zeros(1,cluster_num);
for k = 1:cluster_num
    gap_group(k) =  max(eval(['pic_',int2str(k),'(:)']));
end

% %划分工作基本完成。
% %如果继续改进可以研究选择最优初始聚类点情况下的聚类和结果

%打印分割后的直方图

for k=1:cluster_num
    subplot(eval([int2str(ceil(cluster_num/4)),'4',int2str(k)]));
    imhist(uint8(eval(['pic_',int2str(k)]))),title(['histograph\_',int2str(k)]),xlabel('灰度值'),ylabel('数目');
    ax = gca;
    ax.YAxis.Exponent = 0;
    ylim([0,5000]);
end
%分割图像统计直方图

for k = 1:cluster_num
    %子图个数转概率
    expr_num2prob = ['histograph_',int2str(k),'= histograph_',int2str(k),'/double(pic_',int2str(k),'_num);'];
    eval(expr_num2prob);

end


%计算累积分布
for k =1:cluster_num
    expr_acc = ['histograph_',int2str(k),'_acc = zeros(1,256);'];
    eval(expr_acc);
end
for k=1:cluster_num
    gap_now = gap_group(k);
    if k==1
        gap_old = 0;
    else
        gap_old = gap_group(k-1)+1;
    end
    expr_first_acc = ['histograph_',int2str(k),'_acc(gap_old+1) = histograph_',int2str(k),'(gap_old+1);'];
    eval(expr_first_acc);
    for d = gap_old+1:gap_now
        expr_other_acc = ['histograph_',int2str(k),'_acc(d+1) = histograph_',int2str(k),'(d+1)+histograph_',int2str(k),'_acc(d);'];
        eval(expr_other_acc);
    end
end

%映射函数计算和合并
graymap = zeros(1,256);
gap_old = 0;

for gap_num =1:cluster_num
    gap_max = gap_group(gap_num);
    gap_now = gap_max;
    for k = gap_old:gap_now
        graymap(uint16(k)+1) = round(gap_old +eval(['histograph_',int2str(gap_num),'_acc(uint16(k)+1)'])*(gap_now - gap_old));
    end
    gap_old = gap_now+1;
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
subplot(121),imshow(uint8(pic_raw)),title('pic\_raw');%xlabel('灰度值'),ylabel('数量');
subplot(122),imshow(uint8(pic_new)),title('pic\_new');%xlabel('灰度值'),ylabel('数量');

% figure,subplot(241),imshow(pic_1),subplot(242),imshow(pic_2),subplot(243),imshow(pic_3),subplot(244),imshow(pic_4);
% subplot(245),imshow(pic_5),subplot(246),imshow(pic_6),subplot(247),imshow(pic_7),subplot(248),imshow(pic_8);
