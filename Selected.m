

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

        function pivot(obj, point, dtheta)
            for i = 1 : length(obj.Segments)
                % applies to all objects except points
                if ~isequal(class(obj.Segments(i)), 'Point')
                    obj.Segments(i).pivot(point, dtheta);
                end
            end    
        end

        function scale(obj, point, factor)
            for i = 1 : length(obj.Segments)
                % applies to all objects except points
                if ~isequal(class(obj.Segments(i)), 'Point')
                    obj.Segments(i).pivot(point, factor);
                end
            end    
        end

        function export(obj)
            obj.Segments(1).Frame.export;  
        end

        function lengthen(obj, point, newL)
            % newL can either be new theta or length
            if length(obj.Segments) == 1
                if isequal(class(obj.Segments(1)), 'LineSegment')
                    obj.Segments(1).lengthen(point, newL)
                elseif isequal(class(obj.Segments(1)), 'Arc')
                    obj.Segments(1).lengthen(newL)
                else
                    error("Object must be an arc or line segment to lengthen")
                end
                
            else
                error("Lengthen can only apply to one segment at a time.")
            end
        end


    end
end