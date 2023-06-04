%计算新的图像对比度和信息熵来对图片进行评价

%先算概率分布
histograph_new = zeros(1,256);
for i =1:row_num
    for j = 1:col_num
        histograph_new(uint8(pic_new(i,j))+1) = histograph_new(uint8(pic_new(i,j))+1)+1;
    end
end
histograph_new = histograph_new/(row_num*col_num);
%信息熵
entropy = 0;
for k = 0:255
    if histograph_new(k+1)~=0
        entropy = entropy-(histograph_new(k+1)*log2(histograph_new(k+1)));
    end
end

%对比度

pic_new_pad = padarray(double(pic_new),[1,1],'replicate');
contrast = 0;
for i=2:row_num+1
    for j=2:col_num+1
        contrast = contrast+(pic_new_pad(i,j)-pic_new_pad(i-1,j))^2;
        contrast = contrast+(pic_new_pad(i,j)-pic_new_pad(i,j-1))^2;
        contrast = contrast+(pic_new_pad(i,j)-pic_new_pad(i+1,j))^2;
        contrast = contrast+(pic_new_pad(i,j)-pic_new_pad(i,j+1))^2;
    end
end
contrast = contrast/(4*2+(col_num+row_num-4)*3+(col_num-2)*(row_num-2)*4);