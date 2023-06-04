clear;
clear;
clc;
%这一部分是用来进行聚类个数估计，采用手肘法
%保留每次聚类的聚类中心数值
%！！！！！！eval()一般写好表达式在使用，或者用来途中解开变量变字符串，绝对不能放在左边解开字符串变量后赋值
%这样会破坏eval功能，严禁 eval(expr) = xxx;

%修改为n个进行聚类的结果

%TODO:可以考虑将之改进为函数，

%pic:图片，histograph:直方图，gap:最初划分子图的阈值
%注意：对于循环的i用uint16是为了求256，图像矩阵uint8是因为图像double不好输出

%读图片,画出原始灰度直方图
path = 'D:\专业书\数字图像处理\dipum_images_ch02\pic00.tif';
pic_raw = imread(path);
pic_shape = size(pic_raw,3);
if pic_shape == 3
    pic_raw = rgb2gray(pic_raw);
end
[row_num,col_num]= size(pic_raw);
imhist(pic_raw),title('histograph\_raw'),xlabel('灰度值'),ylabel('数量');

%定聚类簇最大数值,sse用可能的最大簇个数，后面用不到的循环范围限制即可
cluster_max = 8;
sse_group = zeros(1,cluster_max);

%提前为不同数量聚类中心指定数组并且随机初始化和排序
    %如何选择初始聚类点
%随机初始化
% for cluster_num = 1:cluster_max
%     rng(0);
%     expr_cluster_kernal_init = ['cluster_kernal_',int2str(cluster_num),'=round(rand(1,cluster_num)*255);'];
%     eval(expr_cluster_kernal_init);
%     expr_cluster_kernal_sort = ['cluster_kernal_',int2str(cluster_num),'=sort(cluster_kernal_',int2str(cluster_num),');'];
%     eval(expr_cluster_kernal_sort);
% end

%k-means++初始化
for cluster_num = 1:cluster_max
     expr_cluster_kernal_init = ['cluster_kernal_',int2str(cluster_num),'=zeros(1,cluster_num);'];
     eval(expr_cluster_kernal_init);
end
kernal_v = uint8(sum(pic_raw(:))/(row_num*col_num));
for cluster_index = 1:cluster_max
    %这里利用了不同聚类中心个数和对应的轮次数一致
    %更新第cluster_index个位置的初始化聚类中心值（不同个数的kernal都更新）
    for cluster_num = cluster_index:cluster_max
        expr_cluster_kernal_update = ['cluster_kernal_',int2str(cluster_num),'(cluster_index)=kernal_v;'];
        eval(expr_cluster_kernal_update);
    end
    %算下一个要更新的核心数
    pic_dist_init = zeros(row_num,col_num);
    for i=1:row_num
        for j=1:col_num
            dist = zeros(1,cluster_index);
            for k=1:cluster_index
                expr_dist = ['dist(k) = abs((int16(pic_raw(i,j))-cluster_kernal_',int2str(cluster_index),'(k)));'];
                eval(expr_dist);
            end
            pic_dist_init(i,j) = min(dist);
        end
    end
    [kernal_v_gap,kernal_v_index] = max(pic_dist_init(:));
    pic_dist_tmp = pic_raw(:);
    kernal_v = pic_dist_tmp(kernal_v_index);
end

for cluster_num = 1:cluster_max
    expr_cluster_kernal_sort = ['cluster_kernal_',int2str(cluster_num),'=sort(cluster_kernal_',int2str(cluster_num),');'];
    eval(expr_cluster_kernal_sort);
end

%找最优聚类个数
for cluster_num = 1:cluster_max

    %这里的所有循环工作目标都是为了获得最优的聚类点个数
    %随机生成聚类点，若切分为cluster_num个类,每一次循环得到一个sse来画手肘图
    %判断最优秀的聚类点个数选择,排序聚类点方便后面顺序操作子图
    %下面注释操作由上面的取代，这里只是为了方便理解不删除
    %cluster_kernal = round(rand(1,cluster_num)*255);
    %cluster_kernal = sort(cluster_kernal);

    %根据聚类点个数生成子图，此时为空，后面聚类
    for i =1:cluster_num
        expr1 = ['pic_',int2str(i),'=uint8(zeros(row_num,col_num));'];
        eval(expr1);

        expr2 = ['histograph_',int2str(i),'=zeros(1,256);'];
        eval(expr2);
    end

    %聚类
    %迭代聚类（聚类-》更新），这里用true因为内部有聚类到局部最优就停止
    while true
        %聚类(用第三个矩阵作为标记矩阵来标记类别)
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
        %已经聚类后的更新
        %为了循环计算，只能先造表达式再eval解开运行
        for i =1:cluster_num
            %建立每个子图的空白图像矩阵
            expr1 = ['pic_',int2str(i),'=uint8(zeros(row_num,col_num));'];
            eval(expr1);
            %建立每个字图对应的空白直方图
            expr2 = ['histograph_',int2str(i),'=zeros(1,256);'];
            eval(expr2);
            %统计每个子图拥有的像素个数，方便后面均值更新聚类中心
            expr3 = ['pic_',int2str(i),'_num = 0;'];
            eval(expr3);
        end

        %根据聚类结果获得对应聚类后的子图和数目
        for i=1:row_num
            for j = 1:col_num
                for k =1:cluster_num
                    if pic_cluster(i,j) == k
                        expr4 = ['pic_',int2str(k),'(i,j)=pic_raw(i,j);'];
                        eval(expr4);
                        expr5 = ['pic_',int2str(k),'_num =uint32(','pic_',int2str(k),'_num',')+1;'];
                        eval(expr5);
                    end
                end
            end
        end
        %更新到聚类点局部最优后退出，flag代表有无局部最优
        flag = 1;
        for k=1:cluster_num
            if eval(['pic_',int2str(k),'_num']) == 0
                continue
            end
            if eval(['cluster_kernal_',int2str(cluster_num),'(k)']) ~= round(sum(eval(['pic_',int2str(k),'(:)']))/eval(['pic_',int2str(k),'_num']));
                flag = 0;
            end
        end
        if flag == 1
            break
        end

        %没有最优就接着更新,TOTEST
        for k = 1:cluster_num%这里没什么用，还是寄希望于k-means++
            if eval(['pic_',int2str(k),'_num']) == 0
                new_kernal_value = eval(['cluster_kernal_',int2str(cluster_num),'(k+1)-1']);
            else
                new_kernal_value = uint64(round(double(sum(eval(['pic_',int2str(k),'(:)'])))/double(eval(['pic_',int2str(k),'_num']))));
            end
                eval(['cluster_kernal_',int2str(cluster_num),'(k) = new_kernal_value;']);
        end
    end
    %计算每次最优聚类点的sse，使用公式，但不完全按照其计算顺序，这里顺序扫描聚类矩阵，根据对应哪个类来求误差平方相加，
    %扫完一遍计算完一遍
    for m = 1:row_num
        for n = 1:col_num
            sse_group(cluster_num) = sse_group(cluster_num) + (eval(['cluster_kernal_',int2str(cluster_num),'(pic_cluster(m,n))']) - int32(pic_raw(m,n)))^2;
        end
    end
end
%手肘法确定最优点数目，确定后直接用对应数目训练一次
axis_x = 1:cluster_max;
axis_y = sse_group;
figure,plot(axis_x,axis_y,'-*'),xlabel('聚类簇个数'),ylabel('SSE');
