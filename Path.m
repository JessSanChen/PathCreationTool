

classdef Path < handle

    properties
        SegmentList
        Start
        End
    end

    methods
        function obj = Path(segmentList, startp, endp)
            if nargin < 3
                warning("Please provide start and end points")
                startp = [];
                endp = [];
            end
            if nargin < 1
                error("Please provide a segment list argument.")
            end
            obj.SegmentList = segmentList;
            obj.Start = startp;
            obj.End = endp;
        end

        function val = calcDist(obj)
            val = 0;
            for i = 1 : length(obj.SegmentList)
                val = val + obj.SegmentList(i).getLength;
            end
        end

%         function val = calcTime(obj)
% 
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end