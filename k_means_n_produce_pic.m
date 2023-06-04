%ȷ�����ž������Ŀ
cluster_num = 4;
%�ö�Ӧ�����ž������ľ����ֱ��ͼ����
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

%���¼���ͼ������ֱ��ͼ����
for i =1:cluster_num
    %����ÿ����ͼ�Ŀհ�ͼ�����
    expr1 = ['pic_',int2str(i),'=uint8(zeros(row_num,col_num));'];
    eval(expr1);
    %����ÿ����ͼ��Ӧ�Ŀհ�ֱ��ͼ
    expr2 = ['histograph_',int2str(i),'=zeros(1,256);'];
    eval(expr2);
    %ͳ��ÿ����ͼӵ�е����ظ���
    expr3 = ['pic_',int2str(i),'_num = 0;'];
    eval(expr3);
end

%���ݾ�������ö�Ӧ��������ͼ��ֱ��ͼͳ����Ŀ
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

% % %�ҵ��ֲ����ž�����ͬʱҲ�����˲�ͬ����ͼ��������ֱ���ҵ�ÿ����ͼ�����ֵgap,���һ��gap��255
% %ע�⣬�ؼ��㣺�ָ�gap���ھ�������ϣ�����gap�ָ��ÿ����ͼ���Ǿ����Ѿ����ɵģ�����Ҫ��������
gap_group = zeros(1,cluster_num);
for k = 1:cluster_num
    gap_group(k) =  max(eval(['pic_',int2str(k),'(:)']));
end

% %���ֹ���������ɡ�
% %��������Ľ������о�ѡ�����ų�ʼ���������µľ���ͽ��

%��ӡ�ָ���ֱ��ͼ

for k=1:cluster_num
    subplot(eval([int2str(ceil(cluster_num/4)),'4',int2str(k)]));
    imhist(uint8(eval(['pic_',int2str(k)]))),title(['histograph\_',int2str(k)]),xlabel('�Ҷ�ֵ'),ylabel('��Ŀ');
    ax = gca;
    ax.YAxis.Exponent = 0;
    ylim([0,5000]);
end
%�ָ�ͼ��ͳ��ֱ��ͼ

for k = 1:cluster_num
    %��ͼ����ת����
    expr_num2prob = ['histograph_',int2str(k),'= histograph_',int2str(k),'/double(pic_',int2str(k),'_num);'];
    eval(expr_num2prob);

end


%�����ۻ��ֲ�
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

%ӳ�亯������ͺϲ�
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
subplot(121),imshow(uint8(pic_raw)),title('pic\_raw');%xlabel('�Ҷ�ֵ'),ylabel('����');
subplot(122),imshow(uint8(pic_new)),title('pic\_new');%xlabel('�Ҷ�ֵ'),ylabel('����');

% figure,subplot(241),imshow(pic_1),subplot(242),imshow(pic_2),subplot(243),imshow(pic_3),subplot(244),imshow(pic_4);
% subplot(245),imshow(pic_5),subplot(246),imshow(pic_6),subplot(247),imshow(pic_7),subplot(248),imshow(pic_8);
