function [ Contour_x_array, Contour_y_array, Contour_p1_array, Contour_p2_array, Contour_count ] = LinkedList( Img_Edge, Th_Num_Pixel )
%UNTITLED 이 함수의 요약 설명 위치
%   자세한 설명 위치
% Analysis Input Data
[height, width] = size(Img_Edge);
Img_Visited = zeros(height, width);

Img_Tinning = bwmorph(Img_Edge,"skeleton");

Num = 0;
for r = 1 : height
    for c = 1 : width
        if(Img_Tinning(r,c) ~= 0)
            Img_Visited(r,c) = 1;
            Num = Num + 1;
        end
    end
end

nei = [0 1; 1 1; 1 0; 1 -1; 0 -1; -1 -1; -1 0; -1 1]; % r,c cw

Num_object = 100;
countour_array = zeros(4,Num);
countour_array_forward = zeros(4,Num);
countour_array_back = zeros(4,Num);
max_border_count = 0;

Contour_num = 0;
Contour_x_array = zeros(Num_object,Num);
Contour_y_array = zeros(Num_object,Num);

Contour_p1_array = zeros(Num_object,Num);
Contour_p2_array = zeros(Num_object,Num);

Contour_count = zeros(Num_object,1);  

for r = 2 : height-1
    for c = 2 : width-1
        if(Img_Visited(r,c) == 1)
            Img_Visited(r,c) = 2;
            init_r = r;
            init_c = c;
            indexInsert = 1;
            
            %Forward Search
            border_count_forward = 1;
            countour_array_forward(:,border_count_forward) = [init_r;init_c;1;0];

            r_check = init_r;
            c_check = init_c;
            flag_Start = 1;
            indexExcape = indexInsert;
            while(flag_Start==1)
                flag_Start = 0;
                for k = 1 : 8
                    u = r_check + nei(indexExcape,1);
                    v = c_check + nei(indexExcape,2);
                    if(u<1)||(u>height)||(v<1)||(v>width);continue;end
                    if(Img_Visited(u,v) == 1)
                        % add
                        flag_Start = 1;
                        border_count_forward = border_count_forward + 1;
                        Img_Visited(u,v) = 0;
                        indexEx = indexExcape;
                        indexEx = indexEx + 2;
                        if(indexEx > 8); indexEx = indexEx - 8; end
                        pattern = nei(indexEx,:);
                        countour_array_forward(:,border_count_forward) = [u;v;pattern(1);pattern(2)];
                        break;
                    end
                    indexExcape = indexExcape+1;
                    if(indexExcape > 8); indexExcape = 1; end
                end
                % update
                r_check = u;
                c_check = v;
            end

            %Backward Search
            r_check = init_r;
            c_check = init_c;
            border_count_back = 0;
            flag_Start = 1;
            indexExcape = 1;
            while(flag_Start==1)
                flag_Start = 0;
                for k = 1 : 8
                    u = r_check + nei(indexExcape,1);
                    v = c_check + nei(indexExcape,2);
                    if(u<1)||(u>height)||(v<1)||(v>width);continue;end
                    if(Img_Visited(u,v) == 1)
                        % add
                        flag_Start = 1;
                        border_count_back = border_count_back + 1;
                        Img_Visited(u,v) = 0;
                        indexEx = indexExcape;
                        indexEx = indexEx + 2;
                        if(indexEx > 8); indexEx = indexEx - 8; end
                        pattern = nei(indexEx,:);%
                        countour_array_back(:,border_count_back) = [u;v;pattern(1);pattern(2)];
                        break;
                    end
                    indexExcape = indexExcape+1;
                    if(indexExcape > 8); indexExcape = 1; end
                end
                r_check = u;
                c_check = v;
            end

            % backword + foreword
            border_count = border_count_forward + border_count_back;
            countour_array = [flip(countour_array_back(:,1:border_count_back),2),countour_array_forward(:,1:border_count_forward)];

            % Check Size
            if(border_count > Th_Num_Pixel)
                Contour_num = Contour_num + 1;
                Contour_y_array(Contour_num,1:border_count) = countour_array(1,1:border_count);
                Contour_x_array(Contour_num,1:border_count) = countour_array(2,1:border_count);
                Contour_p1_array(Contour_num,1:border_count) = countour_array(3,1:border_count);
                Contour_p2_array(Contour_num,1:border_count) = countour_array(4,1:border_count);
                Contour_count(Contour_num,1) = border_count;
                if(max_border_count < border_count); max_border_count = border_count; end
            end
        end     
    end
    %data delete
    Contour_x_array = Contour_x_array(1:Contour_num,1:max_border_count);
    Contour_y_array = Contour_y_array(1:Contour_num,1:max_border_count);
    Contour_p1_array = Contour_p1_array(1:Contour_num,1:max_border_count);
    Contour_p2_array = Contour_p2_array(1:Contour_num,1:max_border_count);

    Contour_count = Contour_count(1:Contour_num,:);
end