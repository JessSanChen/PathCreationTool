classdef Point < handle
    % Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Pos
        Frame
    end

    methods
        function obj = Point(f, x, y)
            % Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 3 
                x = 0;
                y = 0;
            end
            if nargin < 1
                error("Must provide frame where the point exists")
            end
            obj.Pos = [x y];
            obj.Frame = f;

            obj.Frame.addPoint(obj);
        end

        function translate(obj, dx, dy)
            % Summary of this method goes here
            %   Detailed explanation goes here
            obj.Pos = [obj.P(1) + dx, obj.P(2) + dy];
        end

%         function obj = set.X(obj, newx)
%             obj.X = newx;
%         end
% 
%         function obj = set.Y(obj, newy)
%             obj.Y = newy;
%         end
% 
%         function val = get.X(obj)
%             val = obj.X;
%         end
% 
%         function val = get.Y(obj)
%             val = obj.Y;
%         end
    end
end