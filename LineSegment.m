

classdef LineSegment < handle
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
            % Construct an instance of this class
            %   Detailed explanation goes here
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

            % upon instantiation, should decide if connected
            % framework should check & update every time a segment is
            % created, transformed, etc.
%             obj.e1 = [];
%             obj.e2 = [];
        end

        function out = export(obj)
            points = obj.Resolution * round(obj.getLength);
            x1 = obj.P1.Pos(1);
            y1 = obj.P1.Pos(2);
            x2 = obj.P2.Pos(1);
            y2 = obj.P2.Pos(2);
            x = zeros(1,points + 1);
            y = zeros(1,points + 1);
            for i = 0:points
                x(i+1) = x1 + (x2-x1)*(i/points);
                y(i+1) = y1 + (y2-y1)*(i/points);
            end
            out = [x;y];
        end

        function val = getLength(obj)
%             x1 = obj.P1(1) ; % is there a better way to do this
%             y1 = obj.P1(2) ;
%             x2 = obj.P2(1) ; 
%             y2 = obj.P2(2) ;
%             val = sqrt((x2-x1)^2 + (y2-y1)^2);
%             val = norm(obj.P2.Pos - obj.P1.Pos);
            val = dist(obj.P2.Pos, obj.P1.Pos);
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

        function val = getDir(obj, endp)
            % counter-clockwise angle in degrees
%             if isequal(obj.P1, endp)
%                 x1 = obj.P1.Pos(1);
%                 y1 = obj.P1.Pos(2);
%                 x2 = obj.P2.Pos(1);
%                 y2 = obj.P2.Pos(2);
%             elseif isequal(obj.P2, endp)
%                 x1 = obj.P2.Pos(1);
%                 y1 = obj.P2.Pos(2);
%                 x2 = obj.P1.Pos(1);
%                 y2 = obj.P1.Pos(2);
%             else
%                 error('Input point is not an endpoint of this segment')
%             end
            x1 = endp.Pos(1);
            y1 = endp.Pos(2);
            other = obj.otherP(endp);
            x2 = other.Pos(1);
            y2 = other.Pos(2);
            val = atan2d(y2 - y1,x2 - x1);
        end

        function translate(obj, dx, dy)
            obj.P1.Pos = [obj.P1.Pos(1) + dx, obj.P1.Pos(2) + dy];
            obj.P2.Pos = [obj.P2.Pos(1) + dx, obj.P2.Pos(2) + dy];

            if dx ~= 0 && dy ~= 0
                obj.Frame.checkConnect(obj.P1);
                obj.Frame.checkConnect(obj.P2);
            end
        end

        function pivot(obj, x, y, dtheta)
            % counter-clockwise angle in degrees
            % how to deal with floats/decimals?
            % NEED TO CLEAN

            % for event later
            old1 = obj.P1.Pos;
            old2 = obj.P2.Pos;

            % one point at a time -> ABSTRACT LATER
%             dist1 = sqrt((obj.P1.Pos(1)-x)^2 + (obj.P1.Pos(2)-y)^2);
            dist1 = dist(obj.P1.Pos, [x y]);
%             dir1 = atan2d([obj.P1.Pos(2) - y],[obj.P1.Pos(1) - x]); 
            dir1 = dir([x y], obj.P1.Pos);
            newDir1 = dir1 + dtheta;
            obj.P1.Pos = [x + dist1 * cosd(newDir1), ... 
                      y + dist1 * sind(newDir1)];

%             dist2 = sqrt((obj.P2.Pos(1)-x)^2 + (obj.P2.Pos(2)-y)^2);
            dist2 = dist(obj.P2.Pos, [x y]);
%             dir2 = atan2d([obj.P2.Pos(2) - y],[obj.P2.Pos(1) - x]);
            dir2 = dir([x y], obj.P2.Pos);
            newDir2 = dir2 + dtheta;
            obj.P2.Pos = [x + dist2 * cosd(newDir2), ... 
                      y + dist2 * sind(newDir2)];
%             if isequal(obj.P1, [x y])
%                obj.P2 = newLoc;
%             elseif isequal(obj.P2, [x y])
%                obj.P1 = newLoc;
%             else
%                 error('Input point is not an endpoint of this segment')
%             end

            if ~isequal(obj.P1.Pos, old1)
                obj.Frame.checkConnect(obj.P1);
            end
            if ~isequal(obj.P2.Pos, old2)
                obj.Frame.checkConnect(obj.P2);
            end
        end

        function scale(obj, endp, factor)
            % scale factor must be >0
            % CHANGE: from x, y to "endp" object
            if factor <=0
                error('Scale factor must be greater than 0')
            end
%             dir = obj.getDir(x,y); 
            dir = obj.getDir(endp);
            newLength = factor * obj.getLength;
%             newLoc = [x + (newLength) * cosd(dir),...
%                           y + (newLength) * sind(dir)];
%             if isequal(obj.P1.Pos, [x y])
%                 obj.P2.Pos = newLoc;
%             elseif isequal(obj.P2.Pos, [x y])
%                 obj.P1.Pos = newLoc;
%             else
%                 error('Input point is not an endpoint of this segment')
%             end
            obj.otherP(endp).Pos = [endp.Pos(1) + newLength * cosd(dir), ...
                endp.Pos(2) + newLength * sind(dir)];

            if factor ~= 1
                obj.Frame.checkConnect(obj.otherP(endp));
            end
        end

        function lengthen(obj, endp, newLength)
            % scale factor must be >0
            if newLength <=0
                error('New length must be greater than 0')
            end

            oldLength = endp.Pos;

%             dir = obj.getDir(x,y);
            dir = obj.getDir(endp);
%             newLoc = [x + (newLength) * cosd(dir), ...
%                        y + (newLength) * sind(dir)];
%             if isequal(obj.P1, [x y])
%                 obj.P2 = newLoc; 
%             elseif isequal(obj.P2, [x y])
%                 obj.P1 = newLoc;
%             else
%                 error('Input point is not an endpoint of this segment')
%             end
            obj.otherP(endp).Pos = [endp.Pos(1) + (newLength) * cosd(dir), ...
                       endp.Pos(2) + (newLength) * sind(dir)];

            if ~isequal(obj.getLength, oldLength)
                obj.Frame.checkConnect(obj.otherP(endp));
            end
        end

%         function connect(~, endp, otherEndp)
%             % framework takes care of most "thinking"
%             % including figuring out what other segments intersect
%             % this function ONLY changes private properties and stores
% %             if isequal(obj.P1, p)
% %                 obj.e1 = [obj.e1, otherSeg];
% % %                 obj.e1(end+1) = otherSeg;
% %             elseif isequal(obj.P2, p)
% %                 obj.e2 = [obj.e2, otherSeg];
% % %                 obj.e2(end+1) = otherSeg;
% %             else
% %                 error('Input point is not an endpoint of this segment')
% %             end
%             endp.connect(otherEndp);
% %             otherEndp.connect = (endp);
%         end
% 
%         function disconnect(~, endp, otherEndp)
% %             if isequal(obj.P1, [x y])
% %                 obj.e1(obj.e1 == otherSeg) = [];
% %             elseif isequal(obj.P2, [x y])
% %                 obj.e2(obj.e2 == otherSeg) = [];
% %             else
% %                 error('Input point is not an endpoint of this segment')
% %             end
% %             endp.Connected(endp.Connected == otherEndp.Segment) = [];
% %             otherEndp.Connected(otherEndp.Connected == endp.Segment) = [];
%             endp.disconnect(otherEndp);
%         end

    end
end

function val = dist(pos1, pos2)
    % takes array arguments [a,b]
    val = norm(pos1 - pos2);
end

function val = dir(pos1, pos2)
    val = atan2d(pos2(2) - pos1(2),pos2(1) - pos1(1)); 
end

