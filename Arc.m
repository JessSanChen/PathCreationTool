

classdef Arc < Segment & handle
    % Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % CHANGE TO 2-D ARRAYS AS POINTS
        P1
        P2
        C
        Theta % always from P1 to P2 (CCW)
        Frame
        Resolution
        MaxAccel
        StartSpeed
        MaxSpeed
    end

%     methods(Access = protected)
%         function cp = copy(obj)
%              cp = Arc;
%              cp.P1 = obj.P1;
%              cp.P2 = obj.P2;
%              cp.C = obj.C;
%              cp.Theta = obj.Theta;
%         end
%    end
    
    methods
        function obj = Arc(f, cx,cy, ...
                x1,y1, theta, ...
                maxAccel, startSpeed, maxSpeed)
            % does NOT ask for x2,y2 ??
            if nargin < 9
                maxSpeed = 0;
            end 
            if nargin < 8
                startSpeed = 0;
            end
            if nargin < 7
                maxAccel = 0;
            end
            if nargin < 6
                cx = 0;
                cy = 0;
                x1 = 1;
                y1 = 0;
                theta = 90;
            end
            if nargin < 1
                error("Please provide a frame for this segment");
            end
            obj.C = Point(f, cx, cy);
            obj.Theta = theta;
            obj.MaxAccel = maxAccel;
            obj.StartSpeed = startSpeed;
            obj.MaxSpeed = maxSpeed;
            obj.Frame = f;
            obj.P1 = Endpoint(x1, y1, obj);

%             % upon instantiation, should decide if connected
%             % framework should check & update every time a segment is
%             % created, transformed, etc.
%             obj.e1 = [];
%             obj.e2 = [];

            % instantiate endpoint
            % calc P2
            obj.P2 = Endpoint(0,0,obj);
            obj.calcP2;

            obj.Frame.addSegment(obj);

            obj.Resolution = 20;
        end

        function val = getRadius(obj)
            % NOT stored as property? 

            val = dist(obj.P1.Pos, obj.C.Pos);
        end

        function val = getLength(obj)
            % usually theta in degrees
            % must CONVERT TO RAD
            val = (obj.getRadius * obj.Theta) * (pi/180);
        end
        
        function val = getAnchorDir(obj)
            % get dir of "anchor" point (P1) from center

            val = dir(obj.C.Pos, obj.P1.Pos);
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

        function calcP2(obj)
            % given anchor point, use theta/radius to calc other point
            % like geogebra, can ONLY GO COUNTERCLOCKWISE            

            pDir = obj.getAnchorDir + obj.Theta;
            obj.C.Pos
            obj.P1.Pos
            radius = obj.getRadius;
            px = obj.C.Pos(1) + radius * cosd(pDir);
            py = obj.C.Pos(2) + radius * sind(pDir);
            obj.P2.setPos(px, py); 

        end
        
        function translate(obj, dx, dy)
            obj.P1.Pos = [obj.P1.Pos(1) + dx, obj.P1.Pos(2) + dy];
            obj.P2.Pos = [obj.P2.Pos(1) + dx, obj.P2.Pos(2) + dy];
            obj.C.Pos = [obj.C.Pos(1) + dx, obj.C.Pos(2) + dy];

            if dx ~= 0 && dy ~= 0
                obj.Frame.checkConnect(obj.P1);
                obj.Frame.checkConnect(obj.P2);
            end
        end

        function pivot(obj, point, dtheta)
            % ABSTRACT LATER
            % currently exactly the same as in LineSegment
            
            % for checkConnect later
            old1 = obj.P1.Pos;
            old2 = obj.P2.Pos;

            dist1 = dist(point, obj.P1.Pos);
            dir1 = dir(point, obj.P1.Pos);
            newDir1 = dir1 + dtheta;
            obj.P1.Pos = [point(1) + dist1 * cosd(newDir1), ... 
                      point(2) + dist1 * sind(newDir1)];

            distC = dist(point, obj.C.Pos);
            dirC = dir(point, obj.C.Pos);
            newDirC = dirC + dtheta;
            obj.C.Pos = [point(1) + distC * cosd(newDirC), ... 
                      point(2) + distC * sind(newDirC)];

            obj.calcP2;

%             dist2 = dist(point, obj.P2.Pos);
%             dir2 = dir(point, obj.P2.Pos);
%             newDir2 = dir2 + dtheta;
%             obj.P2.Pos = [point(1) + dist2 * cosd(newDir2), ... 
%                       point(2) + dist2 * sind(newDir2)];

            if ~isequal(obj.P1.Pos, old1)
                obj.Frame.checkConnect(obj.P1);
            end
            if ~isequal(obj.P2.Pos, old2)
                obj.Frame.checkConnect(obj.P2);
            end
        end



        function scale(obj, point, factor)
            % almost exactly the same as LineSegment, but with C 
            % ABSTRACT LATER
            
            % scale factor must be >0
            if factor <=0
                error('Scale factor must be greater than 0')
            end

            % for checkConnect later
            old1 = obj.P1.Pos;
            old2 = obj.P2.Pos;

            dist1 = dist(point, obj.P1.Pos);
            dir1 = dir(point, obj.P1.Pos);
            newDist1 = factor * dist1;
            obj.P1.Pos = [point(1) + newDist1 * cosd(dir1),...
                            point(2) + newDist1 * sind(dir1)];

            distC = dist(point, obj.C.Pos);
            dirC = dir(point, obj.C.Pos);
            newDistC = factor * distC;
            obj.C.Pos = [point(1) + newDistC * cosd(dirC),...
                            point(2) + newDistC * sind(dirC)];

            obj.calcP2;

            if ~isequal(obj.P1.Pos, old1)
                obj.Frame.checkConnect(obj.P1);
            end
            if ~isequal(obj.P2.Pos, old2)
                obj.Frame.checkConnect(obj.P2);
            end            

        end
        
        function lengthen(obj, newTheta)
            % newLength must be >0
            if dTheta <=0
                error('New length must be greater than 0')
            end

            oldTheta = obj.Theta;

            % anchor is 
            obj.Theta = newTheta;
            obj.calcP2;

            if oldTheta ~= newTheta
                obj.Frame.checkConnect(obj.P2);
            end
        end

        function setP1(obj, px, py)
            obj.P1.setPos(px, py);
            obj.calcP2;
        end

        function out = export(obj, endp)
            % endp is already either obj.P1 or obj.P2
            points = obj.Resolution * round(obj.getLength);
%             theta_i = obj.getAnchorDir;
%             theta_f = dir(obj.C.Pos, obj.P2.Pos);
%             dtheta = theta_f - theta_i;
            theta_i = dir(obj.C.Pos, endp.Pos);
            theta_f = dir(obj.C.Pos, obj.otherP(endp).Pos);
            dtheta = theta_f - theta_i;

            r = obj.getRadius;
            x = zeros(1,points + 1);
            y = zeros(1,points + 1);

            for i = 0:points
                x(i+1) = obj.C.Pos(1) + r * cosd(...
                    theta_i + (dtheta)*(i/points));
                y(i+1) = obj.C.Pos(2) + r * sind(...
                    theta_i + (dtheta)*(i/points));
            end
            out = [x;y];
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




