clear;
clear;
clc;
%��һ�������������о���������ƣ��������ⷨ
%����ÿ�ξ���ľ���������ֵ
%������������eval()һ��д�ñ��ʽ��ʹ�ã���������;�н⿪�������ַ��������Բ��ܷ�����߽⿪�ַ���������ֵ
%�������ƻ�eval���ܣ��Ͻ� eval(expr) = xxx;

%�޸�Ϊn�����о���Ľ��

%TODO:���Կ��ǽ�֮�Ľ�Ϊ������

%pic:ͼƬ��histograph:ֱ��ͼ��gap:���������ͼ����ֵ
%ע�⣺����ѭ����i��uint16��Ϊ����256��ͼ�����uint8����Ϊͼ��double�������

%��ͼƬ,����ԭʼ�Ҷ�ֱ��ͼ
path = 'D:\רҵ��\����ͼ����\dipum_images_ch02\pic00.tif';
pic_raw = imread(path);
pic_shape = size(pic_raw,3);
if pic_shape == 3
    pic_raw = rgb2gray(pic_raw);
end
[row_num,col_num]= size(pic_raw);
imhist(pic_raw),title('histograph\_raw'),xlabel('�Ҷ�ֵ'),ylabel('����');

%������������ֵ,sse�ÿ��ܵ����ظ����������ò�����ѭ����Χ���Ƽ���
cluster_max = 8;
sse_group = zeros(1,cluster_max);

%��ǰΪ��ͬ������������ָ�����鲢�������ʼ��������
    %���ѡ���ʼ�����
%�����ʼ��
% for cluster_num = 1:cluster_max
%     rng(0);
%     expr_cluster_kernal_init = ['cluster_kernal_',int2str(cluster_num),'=round(rand(1,cluster_num)*255);'];
%     eval(expr_cluster_kernal_init);
%     expr_cluster_kernal_sort = ['cluster_kernal_',int2str(cluster_num),'=sort(cluster_kernal_',int2str(cluster_num),');'];
%     eval(expr_cluster_kernal_sort);
% end

%k-means++��ʼ��
for cluster_num = 1:cluster_max
     expr_cluster_kernal_init = ['cluster_kernal_',int2str(cluster_num),'=zeros(1,cluster_num);'];
     eval(expr_cluster_kernal_init);
end
kernal_v = uint8(sum(pic_raw(:))/(row_num*col_num));
for cluster_index = 1:cluster_max
    %���������˲�ͬ�������ĸ����Ͷ�Ӧ���ִ���һ��
    %���µ�cluster_index��λ�õĳ�ʼ����������ֵ����ͬ������kernal�����£�
    for cluster_num = cluster_index:cluster_max
        expr_cluster_kernal_update = ['cluster_kernal_',int2str(cluster_num),'(cluster_index)=kernal_v;'];
        eval(expr_cluster_kernal_update);
    end
    %����һ��Ҫ���µĺ�����
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

%�����ž������
for cluster_num = 1:cluster_max

    %���������ѭ������Ŀ�궼��Ϊ�˻�����ŵľ�������
    %������ɾ���㣬���з�Ϊcluster_num����,ÿһ��ѭ���õ�һ��sse��������ͼ
    %�ж�������ľ�������ѡ��,�������㷽�����˳�������ͼ
    %����ע�Ͳ����������ȡ��������ֻ��Ϊ�˷�����ⲻɾ��
    %cluster_kernal = round(rand(1,cluster_num)*255);
    %cluster_kernal = sort(cluster_kernal);

    %���ݾ�������������ͼ����ʱΪ�գ��������
    for i =1:cluster_num
        expr1 = ['pic_',int2str(i),'=uint8(zeros(row_num,col_num));'];
        eval(expr1);

        expr2 = ['histograph_',int2str(i),'=zeros(1,256);'];
        eval(expr2);
    end

    %����
    %�������ࣨ����-�����£���������true��Ϊ�ڲ��о��ൽ�ֲ����ž�ֹͣ
    while true
        %����(�õ�����������Ϊ��Ǿ�����������)
        pic_cluster = uint8(zeros(row_num,col_num));
        dist = zeros(1,cluster_num);
        for i=1:row_num
            for j = 1:col_num
                for k = 1:cluster_num
                    expr_dist = ['dist(k) = abs((int32(pic_raw(i,j))-cluster_kernal_',int2str(cluster_num),'(k)));'];
                    eval(expr_dist);
                end
                %min_valueû�ã�Ҫ����λ��,������ൽ�ڼ���
                [min_value,pic_cluster(i,j)] = min(dist);
            end
        end
        %�Ѿ������ĸ���
        %Ϊ��ѭ�����㣬ֻ��������ʽ��eval�⿪����
        for i =1:cluster_num
            %����ÿ����ͼ�Ŀհ�ͼ�����
            expr1 = ['pic_',int2str(i),'=uint8(zeros(row_num,col_num));'];
            eval(expr1);
            %����ÿ����ͼ��Ӧ�Ŀհ�ֱ��ͼ
            expr2 = ['histograph_',int2str(i),'=zeros(1,256);'];
            eval(expr2);
            %ͳ��ÿ����ͼӵ�е����ظ�������������ֵ���¾�������
            expr3 = ['pic_',int2str(i),'_num = 0;'];
            eval(expr3);
        end

        %���ݾ�������ö�Ӧ��������ͼ����Ŀ
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
        %���µ������ֲ����ź��˳���flag�������޾ֲ�����
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

        %û�����žͽ��Ÿ���,TOTEST
        for k = 1:cluster_num%����ûʲô�ã����Ǽ�ϣ����k-means++
            if eval(['pic_',int2str(k),'_num']) == 0
                new_kernal_value = eval(['cluster_kernal_',int2str(cluster_num),'(k+1)-1']);
            else
                new_kernal_value = uint64(round(double(sum(eval(['pic_',int2str(k),'(:)'])))/double(eval(['pic_',int2str(k),'_num']))));
            end
                eval(['cluster_kernal_',int2str(cluster_num),'(k) = new_kernal_value;']);
        end
    end
    %����ÿ�����ž�����sse��ʹ�ù�ʽ��������ȫ���������˳������˳��ɨ�������󣬸��ݶ�Ӧ�ĸ����������ƽ����ӣ�
    %ɨ��һ�������һ��
    for m = 1:row_num
        for n = 1:col_num
            sse_group(cluster_num) = sse_group(cluster_num) + (eval(['cluster_kernal_',int2str(cluster_num),'(pic_cluster(m,n))']) - int32(pic_raw(m,n)))^2;
        end
    end
end
%���ⷨȷ�����ŵ���Ŀ��ȷ����ֱ���ö�Ӧ��Ŀѵ��һ��
axis_x = 1:cluster_max;
axis_y = sse_group;
figure,plot(axis_x,axis_y,'-*'),xlabel('����ظ���'),ylabel('SSE');
