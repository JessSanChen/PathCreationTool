

classdef Arc < Handle
    % Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % CHANGE TO 2-D ARRAYS AS POINTS
        P1
        P2
        C
%         Radius % get from calc, does it need to be a prop?
        Theta % always from P1 to P2 (CCW)
        Frame
        Resolution
        MaxAccel
        StartSpeed
        MaxSpeed
    end

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
            obj.P1 = Endpoint(x1, y1, obj);
            obj.C = Point(cx, cy);
            obj.Theta = theta;
            obj.MaxAccel = maxAccel;
            obj.StartSpeed = startSpeed;
            obj.MaxSpeed = maxSpeed;
            obj.Frame = f;

%             % upon instantiation, should decide if connected
%             % framework should check & update every time a segment is
%             % created, transformed, etc.
%             obj.e1 = [];
%             obj.e2 = [];

            % instantiate endpoint
            % calc P2
            obj.P2 = Endpoint(0,0,obj);
            obj.calcP2;

            obj.Resolution = 50;
        end

        function val = getRadius(obj)
            % NOT stored as property? --> or yes, for now
            % dependent on X1 and Y1 currently
            % abstract to be independent of which endpoint?
%             val = sqrt((obj.P1(1)-obj.C(1))^2 + (obj.P1(2)-obj.C(2))^2);
            
            val = dist(obj.P1.Pos, obj.C.Pos);
        end

        function val = getLength(obj)
            % usually theta in degrees
            % must CONVERT TO RAD
            val = (obj.getRadius * obj.Theta) * (pi/180);
        end
        
        function val = getAnchorDir(obj)
            % get dir of "anchor" point from center
            % counter-clockwise angle in degrees
%             x1 = obj.C(1) ; % is there a better way to do this
%             y1 = obj.C(2) ;
%             x2 = obj.P1(1) ; 
%             y2 = obj.P1(2) ;
%             val = atan2d([y2 - y1],[x2 - x1]);

            val = dir(obj.P1.Pos, obj.C.Pos);
        end

        function calcP2(obj)
            % given anchor point, use theta/radius to calc other point
            % returns value or simply sets?
            % just return value (don't set, bc would need p = set...)
            % like geogebra, can ONLY GO COUNTERCLOCKWISE            
%             if isequal(obj.P1, anchor)
%                 % has "right" point as anchor 
%                 theta = obj.Theta;
%             elseif isequal(obj.P2, anchor)
%                 % has "left" point as anchor (more CCW)
%                 theta = -(obj.Theta);
%             else
%                 error('Input point is not an endpoint of this segment')
%             end
            pDir = obj.getAnchorDir + obj.Theta;
            radius = obj.getRadius;
            px = obj.C.Pos(1) + radius * cosd(pDir);
            py = obj.C.Pos(2) + radius * sind(pDir);
            obj.P2.Pos = [px py]; % why can't we just return [px py]

        end
        
        function translate(obj, dx, dy)
            obj.P1.Pos = [obj.P1.Pos(1) + dx, obj.P1.Pos(2) + dy];
            obj.P2.Pos = [obj.P2.Pos(1) + dx, obj.P2.Pos(2) + dy];
            obj.C.Pos = [obj.C.Pos(1) + dx, obj.C.Pos(2) + dy];
        end

        function pivot(obj, x, y, dtheta)
            % LOTS of copy and paste - must abstract
            
%             dist1 = sqrt((obj.P1(1)-x)^2 + (obj.P1(2)-y)^2);
%             dir1 = atan2d([obj.P1(2) - y],[obj.P1(1) - x]); 
            dist1 = dist(obj.P1.Pos, [x y]);
            dir1 = dir([x y], obj.P1.Pos);
            newDir1 = dir1 + dtheta;
            obj.P1.Pos = [x + dist1 * cosd(newDir1), ... 
                      y + dist1 * sind(newDir1)];

%             dist2 = sqrt((obj.P2(1)-x)^2 + (obj.P2(2)-y)^2)
%             dir2 = atan2d([obj.P2(2) - y],[obj.P2(1) - x])
%             newDir2 = dir2 + dtheta
%             obj.P2 = [x + dist2 * cosd(newDir2), ... 
%                       y + dist2 * sind(newDir2)]
%             

%             distC = sqrt((obj.C(1)-x)^2 + (obj.C(2)-y)^2);
%             dirC = atan2d(obj.C(2) - y,obj.C(1) - x);
            distC = dist(obj.C.Pos, [x y]);
            dirC = dir([x y], obj.C.Pos);
            newDirC = dirC + dtheta;
            obj.C.Pos = [x + distC * cosd(newDirC), ... 
                      y + distC * sind(newDirC)];

            obj.calcP2;
        end

        function scale(obj, factor)
            % scale factor must be >0
            if factor <=0
                error('Scale factor must be greater than 0')
            end
            % anchor is ALWAYs
            newRadius = factor * obj.getRadius;
            dir1 = obj.getAnchorDir;
            obj.P1.Pos = [obj.C.Pos(1)+ (newRadius) * cosd(dir1),...
                          obj.C.Pos(2)+ (newRadius) * sind(dir1)];
            
            obj.calcP2;
        end
        
        function lengthen(obj, dTheta)
            % newLength must be >0
            if dTheta <=0
                error('New length must be greater than 0')
            end
            % anchor is 
            obj.Theta = obj.Theta + dTheta;
            obj.calcP2;
        end

        function out = export(obj)
            points = obj.Resolution * round(obj.getLength);
            theta_i = obj.getAnchorDir;
            theta_f = dir(obj.C.Pos, obj.P2.Pos);
            dtheta = theta_f - theta_i;
            r = obj.getRadius;
            x = zeros(1,points + 1);
            y = zeros(1,points + 1);
            for i = 0:points
                x(i+1) = obj.C.Pos(1) + r * cosd((dtheta)*(i/points));
                y(i+1) = obj.C.Pos(2) + r * sind((dtheta)*(i/points));
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




