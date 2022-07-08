

classdef Selected

    properties
        Segments
    end

    methods
        function obj = Selected(s)
            if nargin < 1
                error("Please provide a frame and segment list")
            end
            obj.Segments = s;
        end

        function translate(obj,dx, dy)
            for i = 1 : length(obj.Segments)
                obj.Segments(i).translate(dx, dy);
            end    
        end

        function pivot(obj, x, y, dtheta)
            for i = 1 : length(obj.Segments)
                if ~isequal(class(obj.Segments(i)), 'Point'))
                    obj.Segments(i).pivot(x, y, dtheta);
                end
            end    
        end


    end
end