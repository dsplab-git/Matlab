classdef Dw1000 < handle
    % DW1000 모듈을 기준으로 삼변측량 방법
    % 초기 환경 설치 및 데이터 취득
    % 초기 환경 (Anchor의 ID와 위치)
    % 데이터 취득의 타이밍의 문제가 존재하며 이를 해결해야함
    %

    properties
        % Anchor Info
        PosAnchor = []
        IDAnchor = []
        NumAnchor = 0
        MatInverse = []
        DimSpace = 3
        FlagEnable = 0

        % Measurement
        DistMeasure = []
        TimeMeasure = []
        TimeInner = 0
    end

    methods
        %% Basic
        % Generator
        function obj = Dw1000()
            obj.NumAnchor = 0;
        end

        % Print
        function [] = showClass(obj)
            disp("Total Anchor : "+obj.NumAnchor);
            disp("Location(m)")
            for i = 1 : obj.NumAnchor
                disp("["+i+"] : "+"["+obj.PosAnchor(i,1)+", "+obj.PosAnchor(i,2)+", "+obj.PosAnchor(i,3)+"]")
            end
        end

        % Check func
        function flag = checkIndex(obj, index)
            if index > 0 && index <= obj.NumAnchor
                flag = true;
            else
                flag = false;
                disp("[ERR] Out of index")
            end
        end

        % FindIndex
        function index = findIndex(obj, ID)
            flagFind = 0;
            for i = 1 : obj.NumAnchor
                if obj.IDAnchor(i) == ID
                    index = i;
                    flagFind = 1;
                    break;
                end
            end
            if flagFind == 0
                index = 0;
            end
        end


        %% Init Setting
        % addAnchor
        function index = addAnchor(varargin) % (obj), ID, PosX, PosY, PosZ(option)
            if nargin == 5
                varargin{1}.PosAnchor = [varargin{1}.PosAnchor ; [varargin{3},varargin{4},varargin{5}]];
            elseif nargin == 4
                varargin{1}.PosAnchor = [varargin{1}.PosAnchor ; [varargin{3},varargin{4},0]];
            else
                disp("[ERR] Please check the 'addAnchor' function's input form. The inputs should be 'obj', 'ID', 'PosX', 'PosY', and 'PosZ' (optional).");
                return
            end
            varargin{1}.NumAnchor = varargin{1}.NumAnchor + 1;
            varargin{1}.IDAnchor = [varargin{1}.IDAnchor; varargin{2}];
            varargin{1}.DistMeasure = zeros(varargin{1}.NumAnchor,1);
            varargin{1}.TimeMeasure = zeros(varargin{1}.NumAnchor,1);
            index = varargin{1}.NumAnchor;
            if nargin == 5
                disp(['[RUN] DW1000 addAnchor(' num2str(index) ') <- ID[' num2str(varargin{2}) '] : ' num2str(varargin{3}) ',' num2str(varargin{4}) ',' num2str(varargin{5})]);
            elseif nargin == 4
                disp(['[RUN] DW1000 addAnchor(' num2str(index) ') <- ID[' num2str(varargin{2}) '] : ' num2str(varargin{3}) ',' num2str(varargin{4})]);
            end

            varargin{1}.setMatInverse();
        end
        
        % Update Anchore
        function [] = updateAnchor(varargin) %% (obj), ID, PosX, PosY, PosZ(option)
            if varargin{1}.checkIndex(varargin{2})
                if nargin == 6
                    varargin{1}.PosAnchor(varargin{2},:) = [varargin{4}, varargin{5}, varargin{6}];
                elseif nargin == 5
                    varargin{1}.PosAnchor(varargin{2},:) = [varargin{4}, varargin{5}, 0];
                else
                    disp("[ERR] Please check the 'updateAnchor' function's input form. The inputs should be 'obj', 'ID', 'PosX', 'PosY', and 'PosZ' (optional).");
                    return
                end
                varargin{1}.IDAnchor = varargin{3};
                varargin{1}.setMatInverse();
            end
        end

        % Delete Anchore 
        function [] = deleteAnchor(obj, ID)
            index = obj.findIndex(ID);
            if index == 0
                disp("[ERR] The input ID does not exist");
                return
            end
            obj.PosAnchor(index,:) = [];
            obj.IDAnchor(index) = [];
            obj.NumAnchor = obj.NumAnchor - 1;
            obj.DistMeasure = zeros(obj.NumAnchor,1);
            obj.TimeMeasure = zeros(obj.NumAnchor,1);
            obj.setMatInverse();
        end


        %% Setter and Getter
        function [] = getDistance(obj, ID, dist)
            for i = 1 : obj.NumAnchor
                if obj.IDAnchor(i) == ID
                    obj.DistMeasure(i) = dist;
                    obj.TimeMeasure(i) = obj.TimeInner;
                    obj.TimeInner = obj.TimeInner + 1;
                    break;
                end
            end
        end

        function [] = getDistanceTime(obj, ID, dist, time)
            for i = 1 : obj.NumAnchor
                if obj.IDAnchor(i) == ID
                    obj.DistMeasure(i) = dist;
                    obj.TimeMeasure(i) = time;
                    obj.TimeInner = time;
                    break;
                end
            end
        end
        
        function [] = setMatInverse(obj)
            if obj.NumAnchor > 2
                disp("[RUN] Obtain the inverse matrix by using the registered anchor positions.");
                MatSudo = zeros(obj.NumAnchor*(obj.NumAnchor-1)/2,size(obj.PosAnchor,2));
                index = 1;
                for i = 1 : obj.NumAnchor-1
                    for j = i + 1 : obj.NumAnchor
                        MatSudo(index,:) = 2*(obj.PosAnchor(j,:) - obj.PosAnchor(i,:));
                        index = index + 1;
                    end
                end

                if(det(MatSudo' * MatSudo) > 1e-8)
                    obj.MatInverse = inv(MatSudo' * MatSudo) * MatSudo';
                    obj.DimSpace = 3;
                else
                    disp("[ERR] The 3D anchor positions were placed in a singular location, so we are now attempting to use 2D positions instead.");
                    MatSudo2 = zeros(obj.NumAnchor*(obj.NumAnchor-1)/2,2);
                    index = 1;
                    for i = 1 : obj.NumAnchor-1
                        for j = i + 1 : obj.NumAnchor
                            MatSudo2(index,1:2) = 2*(obj.PosAnchor(j,1:2) - obj.PosAnchor(i,1:2));
                            index = index + 1;
                        end
                    end
                    if(det(MatSudo2' * MatSudo2) > 1e-8)
                        obj.MatInverse = inv(MatSudo2' * MatSudo2) * MatSudo2';
                        obj.DimSpace = 2;
                    else
                        disp("[ERR] Anchor positions were placed in a singular location");
                        return;
                    end
                end
                obj.FlagEnable = 1;
            else
                obj.FlagEnable = 0;

            end

        end

        function outputPos = getPosition(obj)
            outputPos = zeros(obj.DimSpace,1);
            if(obj.FlagEnable == 0)
                disp("[ERR] Inverse matrix was not built");
                return
            end

            b = zeros(obj.NumAnchor*(obj.NumAnchor-1)/2,1);
            index = 1;
            for i = 1 : obj.NumAnchor-1
                for j = i + 1 : obj.NumAnchor
                    b(index,:) = obj.DistMeasure(i)^2 - obj.DistMeasure(j)^2 + sum(obj.PosAnchor(j,1:obj.DimSpace).^2-obj.PosAnchor(i,1:obj.DimSpace).^2);
                    index = index + 1;
                end
            end
            outputPos = obj.MatInverse * b;
        end
    end
end