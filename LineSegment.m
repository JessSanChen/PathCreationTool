

classdef LineSegment < Segment & handle
    % Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % MUST MAKE ALL PRIVATE
        P1
        P2
        Frame
        Resolution
        MaxAccel
        StartSpeed
        MaxSpeed
%         e1
%         e2
    end

    methods
        function obj = LineSegment(f,x1,y1,x2,y2, ...
                maxAccel, startSpeed, maxSpeed)

            if nargin < 8
                maxSpeed = 0;
            end 
            if nargin < 7
                startSpeed = 0;
            end
            if nargin < 6
                maxAccel = 0;
            end
            if nargin < 5
                x1 = 0;
                y1 = 0;
                x2 = 1;
                y2 = 0;
            end
            if nargin < 1
                error("Please provide a frame for this segment");
            end
            obj.P1 = Endpoint(x1,y1, obj);
            obj.P2 = Endpoint(x2,y2, obj);
            obj.Frame = f;
            obj.MaxAccel = maxAccel;
            obj.StartSpeed = startSpeed;
            obj.MaxSpeed = maxSpeed;

            % add segment to frame
            obj.Frame.addSegment(obj);

            % set default resolution
            obj.Resolution = 20;

        end

        function out = export(obj, endp)
            % specify endp to start at, either P1 or P2
            points = obj.Resolution * round(obj.getLength);

            x1 = endp.Pos(1);
            y1 = endp.Pos(2);
            x2 = obj.otherP(endp).Pos(1);
            y2 = obj.otherP(endp).Pos(2);
            dx = x2-x1;
            dy = y2-y1;

            x = zeros(1,points + 1);
            y = zeros(1,points + 1);

            for i = 0:points
                x(i+1) = x1 + dx*(i/points);
                y(i+1) = y1 + dy*(i/points);
            end
            out = [x;y];
        end

        function val = getLength(obj)
            val = dist(obj.P2.Pos, obj.P1.Pos);
        end

        function val = getEndp(obj, point)
            % given point [x y], returns the corresponding endpoint
            if isequal(point, obj.P1.Pos)
                val = obj.P1;
            elseif isequal(point, obj.P2.Pos)
                val = obj.P2;
            else
                error("Given xy-coordinate does not correspond to an endpoint")
            end
        end

        function val = otherP(obj, endp)
            if isequal(obj.P1,endp)
                val = obj.P2;
            elseif isequal(obj.P2, endp)
                val = obj.P1;
            else
                error('Input point is not an endpoint of this segment')
            end
        end

%         function val = getDir(obj, endp)
%             % counter-clockwise angle in degrees
% 
%             x1 = endp.Pos(1);
%             y1 = endp.Pos(2);
%             other = obj.otherP(endp);
%             x2 = other.Pos(1);
%             y2 = other.Pos(2);
%             val = atan2d(y2 - y1,x2 - x1);
%         end

        function setPos(obj, x1,y1,x2, y2)
            obj.P1.setPos(x1,y1);
            obj.P2.setPos(x2,y2);
        end

        function translate(obj, dx, dy)
            obj.P1.Pos = [obj.P1.Pos(1) + dx, obj.P1.Pos(2) + dy];
            obj.P2.Pos = [obj.P2.Pos(1) + dx, obj.P2.Pos(2) + dy];

            if ~(dx == 0 && dy == 0)
                obj.Frame.checkConnect(obj.P1);
                obj.Frame.checkConnect(obj.P2);
            end
        end

        function pivot(obj, point, dtheta)
            % counter-clockwise angle in degrees

            % for checkConnect later
            old1 = obj.P1.Pos;
            old2 = obj.P2.Pos;

            % ABSTRACT LATER
            dist1 = dist(point, obj.P1.Pos);
            dir1 = dir(point, obj.P1.Pos);
            newDir1 = dir1 + dtheta;
            obj.P1.Pos = [point(1) + dist1 * cosd(newDir1), ... 
                      point(2) + dist1 * sind(newDir1)];

            dist2 = dist(point, obj.P2.Pos);
            dir2 = dir(point, obj.P2.Pos);
            newDir2 = dir2 + dtheta;
            obj.P2.Pos = [point(1) + dist2 * cosd(newDir2), ... 
                      point(2) + dist2 * sind(newDir2)];

            if ~isequal(obj.P1.Pos, old1)
                obj.Frame.checkConnect(obj.P1);
            end
            if ~isequal(obj.P2.Pos, old2)
                obj.Frame.checkConnect(obj.P2);
            end
        end

        function scale(obj, point, factor)
            % changed to any point, not just endpoint

            if factor <=0
                error('Scale factor must be greater than 0')
            end

            % for checkConnect later
            old1 = obj.P1.Pos;
            old2 = obj.P2.Pos;

            % repeated code, ABSTRACT LATER
            
            % scale P1 from point
            dir1 = dir(point, obj.P1.Pos);
            dist1 = dist(point, obj.P1.Pos);
            newDist1 = factor * dist1;
            obj.P1.Pos = [point(1) + newDist1 * cosd(dir1),...
                            point(2) + newDist1 * sind(dir1)];
            
            % scale P2 from point
            dir2 = dir(point, obj.P2.Pos);
            dist2 = dist(point, obj.P2.Pos);
            newDist2 = factor * dist2;
            obj.P2.Pos = [point(1) + newDist2 * cosd(dir2),...
                            point(2) + newDist2 * sind(dir2)];

            if ~isequal(obj.P1.Pos, old1)
                obj.Frame.checkConnect(obj.P1);
            end
            if ~isequal(obj.P2.Pos, old2)
                obj.Frame.checkConnect(obj.P2);
            end
        end

        function lengthen(obj, endp, newLength)
            % changed to take in point as input
            % CHANGE: point that is moving, NOT anchor

            % scale factor must be >0
            if newLength <=0
                error('New length must be greater than 0')
            end
            
%             oldLength = endp.Pos;

            other = obj.otherP(endp);
            angle = dir(other.Pos, endp.Pos);

            endp.Pos = [other.Pos(1) + (newLength) * cosd(angle), ...
                       other.Pos(2) + (newLength) * sind(angle)];

            obj.Frame.checkConnect(obj.otherP(endp));
        end

    end
end

function val = dist(pos1, pos2)
    % takes array arguments [a,b]
    val = norm(pos1 - pos2);
end

function val = dir(pos1, pos2)
    val = atan2d(pos2(2) - pos1(2),pos2(1) - pos1(1)); 
end

