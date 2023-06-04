clear;
clear;
clc;
%pic:ͼƬ��histograph:ֱ��ͼ��gap:���������ͼ����ֵ
%ע�⣺����ѭ����i��uint16��Ϊ����256��ͼ�����uint8����Ϊͼ��double�������

%��ͼƬ,����ԭʼ�Ҷ�ֱ��ͼ
path = 'D:\רҵ��\����ͼ����\dipum_images_ch03\pic1.tif';
pic_raw = imread(path);
pic_shape = size(pic_raw,3);
if pic_shape == 3
    pic_raw = rgb2gray(pic_raw);
end
imhist(pic_raw),title('histograph\_raw'),xlabel('�Ҷ�ֵ'),ylabel('����');

%����ָ�ͼ�����ֵ
[row_num,col_num]= size(pic_raw);
gap = uint8(sum(pic_raw(:))/(row_num*col_num)+0.5);

%�ָ�ͼ����ͳ��ֱ��ͼ,ͳ����ͼ���ظ���
pic_left = uint8(zeros(row_num,col_num));
pic_right = uint8(zeros(row_num,col_num));
histograph_left = zeros(1,256);
histograph_right = zeros(1,256);
pic_left_num = 0;
pic_right_num = 0;


%����
%��ʼ�������ļ���(�������ͼ����󣬾۵���һ�࣬��һ���϶�Ӧλ�ø�ֵ�����������ֵ����)
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
%���ֵ����þ�������
cluster_kernal(1) = round(sum(pic_left(:))/pic_left_num);
cluster_kernal(2) = round(sum(pic_right(:))/pic_right_num);

%��һ�ξ���(�õ�������������������0��1��������)
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

%�������ࣨ����-�����ࣩ��������true��Ϊ�ڲ��о��ൽ�ֲ����ž�ֹͣ
while true
    %�Ѿ������ĸ���    
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
    
    %���µ������ֲ����ź��˳�
    if cluster_kernal(1) == round(sum(pic_left(:))/pic_left_num)
        if cluster_kernal(2) == round(sum(pic_right(:))/pic_right_num)
            break
        end
    end
    
    %û�����žͽ��Ÿ���
    cluster_kernal(1) = round(sum(pic_left(:))/pic_left_num);
    cluster_kernal(2) = round(sum(pic_right(:))/pic_right_num);
    
    %ÿ�θ��º����¾���
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



%�ҵ��ֲ����ž�����ͬʱҲ�����˲�ͬ����ͼ��������ֱ���ҵ�ÿ����ͼ�����ֵgap
gap = max(pic_left(:));

%TODO ����ͨ���ֲ������ҵ���gap
%���滹Ҫ�����޸�����ϲ�������ֱ����gap�ֱ����֣�����ʵ�����Ƕ��ڴ�Ĳ��ֵ�
%���Դֱ����֣�����������ɡ�
%��������Ľ������о�ѡ�����ž��������µľ���ͽ��


%ע��ӳ���ϵ�������±�gap+2λ����ֵ�����Ӧ�ĻҶ�gap+1��ֵ
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

%��ӡ�ָ���ֱ��ͼ
figure;
subplot(121),imhist(uint8(pic_left)),title('histograph\_left'),xlabel('�Ҷ�ֵ'),ylabel('��Ŀ');
subplot(122),imhist(uint8(pic_right)),title('histograph\_right'),xlabel('�Ҷ�ֵ'),ylabel('��Ŀ');

%�ָ�ͼ��ͳ��ֱ��ͼ

for i = 0:gap
    %����ͼ����ת����ͼ  %%!������double ����Ϊint��ȥint���0
    histograph_left(i+1) = histograph_left(i+1)/double(pic_left_num);
end
for i = gap+1:255
    %����ͼ����ת����ͼ
    histograph_right(i+1) = histograph_right(i+1)/double(pic_right_num);
end

%�����ۻ��ֲ�
histograph_left_acc = zeros(1,256);
histograph_right_acc = zeros(1,256);

for i=0:gap
    if i == 0
        %��һ���������⴦��ֱ����ԭ���������ۻ��ֲ�
        histograph_left_acc(i+1) = histograph_left(i+1);
    else   
        %���������ۼ�map�ֲ���ǰһ���ۻ��ֲ����ϵ�ǰ���صĸ��ʼ���
        histograph_left_acc(i+1) = histograph_left_acc(i)+histograph_left(i+1);
    end
end
%�����и����⣬���ɵ�����ͼ���صĵ�256�����ۻ��ֲ���0��,������iλuint8ʱ���255��������ô�Ӷ���255
%��Ҫ��uint16���޸��ټ�
for i= (gap+1):255
    if i == gap+1
        %��һ���������⴦��ֱ����ԭ���������ۻ��ֲ�
        histograph_right_acc(i+1) = histograph_right(i+1);
    else   
        %���������ۼƷֲ���ǰһ���ۻ��ֲ����ϵ�ǰ���صĸ��ʼ���
        histograph_right_acc(uint16(i)+1) = histograph_right_acc(i)+histograph_right(i+1);
    end
end

%ӳ�亯������ͺϲ�
graymap = zeros(1,256);
for i=0:gap
    graymap(uint16(i)+1) = round(histograph_left_acc(uint16(i)+1)*gap);
end
for i=gap+1:255
    graymap(uint16(i)+1) = round((gap+1)+histograph_right_acc(uint16(i)+1)*(255-(gap+1)));
end

%ӳ�������µ�ͼƬ
pic_new = zeros(row_num,col_num);
for i = 1:row_num
    for j = 1:col_num
        pixel_raw = pic_raw(i,j);
        pic_new(i,j) = graymap(pixel_raw+1);
    end
end
%��ӡԭͼ����ͼ��ֱ��ͼ
figure;
subplot(121),imhist(uint8(pic_raw)),title('histograph\_raw'),xlabel('�Ҷ�ֵ'),ylabel('����');
subplot(122),imhist(uint8(pic_new)),title('histograph\_new'),xlabel('�Ҷ�ֵ'),ylabel('����');
%��ӡԭͼ����ͼ
figure;
subplot(121),imshow(uint8(pic_raw)),title('pic\_raw'),xlabel('�Ҷ�ֵ'),ylabel('����');
subplot(122),imshow(uint8(pic_new)),title('pic\_new'),xlabel('�Ҷ�ֵ'),ylabel('����');

