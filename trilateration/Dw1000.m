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
                disp("[Error] Out of index")
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

        % set dim
        function [] = setDim(obj, dim)
            if dim == 2 || dim == 3
                obj.DimSpace = dim;
            else
                disp("[Error] Dimension is allow only 2 or 3, not "+dim+" Dim");
            end
        end


        %% Init Setting
        % addAnchor with ID, x, y, (z)
        function index = addAnchor(varargin)
            if nargin == 5
                varargin{1}.PosAnchor = [varargin{1}.PosAnchor ; [varargin{3},varargin{4},varargin{5}]];
            elseif nargin == 4
                varargin{1}.PosAnchor = [varargin{1}.PosAnchor ; [varargin{3},varargin{4},0]];
            else
                disp("[Error] Func addAnchor input form is obj,ID, PosX, PosY, PosZ(option)");
                return
            end
            varargin{1}.NumAnchor = varargin{1}.NumAnchor + 1;
            varargin{1}.IDAnchor = [varargin{1}.IDAnchor; varargin{2}];
            varargin{1}.DistMeasure = zeros(varargin{1}.NumAnchor,1);
            varargin{1}.TimeMeasure = zeros(varargin{1}.NumAnchor,1);
            index = varargin{1}.NumAnchor;
            varargin{1}.setMatInverse();
        end
        
        % Update Anchore
        function [] = updateAnchor(varargin)          
            if varargin{1}.checkIndex(varargin{2})
                if nargin == 6
                    varargin{1}.PosAnchor(varargin{2},:) = [varargin{4}, varargin{5}, varargin{6}];
                elseif nargin == 5
                    varargin{1}.PosAnchor(varargin{2},:) = [varargin{4}, varargin{5}, 0];
                else
                    disp("[Error] Func updateAnchor input form is obj, ID, PosX, PosY, PosZ(option)");
                    return
                end
                varargin{1}.IDAnchor = varargin{3};
                varargin{1}.setMatInverse();
            end
        end
        
        % Update Anchore 2 Dimension
        function [] = changeAnchor2(obj, index, ID, PosX, PosY)
            if obj.DimSpace ~= 2
                disp("[Error] Privious added anchor dim is "+obj.DimSpace+" that is not 2 Dim");
                return
            end
            if obj.checkIndex(index)
                obj.PosAnchor(index,:) = [PosX, PosY];
                obj.IDAnchor = ID;
                obj.setMatInverse();
            end
        end

        % Delete Anchore 
        function [] = deleteAnchor(obj, index)
            obj.PosAnchor(index,:) = [];
            obj.IDAnchor(index) = [];
            obj.NumAnchor = obj.NumAnchor - 1;
            obj.DistMeasure = zeros(obj.NumAnchor,1);
            obj.TimeMeasure = zeros(obj.NumAnchor,1);
            obj.setMatInverse();
        end
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
                else
                    disp("[Error] Anchor Posisions were placed singular position");
                    return;
                end
                obj.FlagEnable = 1;
            else
                obj.FlagEnable = 0;

            end

        end

        function outputPos = getPosition(obj)
            outputPos = zeros(obj.DimSpace,1);
            if(obj.FlagEnable == 0)
                disp("[Error] Inverse Mat was not builded");
                return
            end

            b = zeros(obj.NumAnchor*(obj.NumAnchor-1)/2,1);
            index = 1;
            for i = 1 : obj.NumAnchor-1
                for j = i + 1 : obj.NumAnchor
                    b(index,:) = obj.DistMeasure(i)^2 - obj.DistMeasure(j)^2 + sum(obj.PosAnchor(j,:).^2-obj.PosAnchor(i,:).^2);
                    index = index + 1;
                end
            end
            outputPos = obj.MatInverse * b;
        end
    end
end