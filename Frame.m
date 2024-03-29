
classdef Frame < handle

    properties
        Title
        ValidatedPath
        SegmentList
        PointList
        Selected
%         GuideList
%         LastState
%         CurrState
%         History
    end

    methods
        function obj = Frame()
            obj.Title = "Untitled";
%             obj.ValidatedPath = libpointer; % what should be start value?
%             obj.Selected = libpointer;
            obj.SegmentList = LineSegment.empty; % will need to abstract
            obj.PointList = Point.empty;
        end

        function addSegment(obj,segment)
            
            obj.checkConnect(segment.P1);
            obj.checkConnect(segment.P2);
            obj.SegmentList(end+1) = segment;
        end
        
        function addPoint(obj,point)
            obj.PointList(end+1) = point;
        end
        
        function validate(obj)
%             val = true;
            count = 0;
            empty1 = [];
            empty2 = [];
            % validate: boolean val
            for i = 1 : length(obj.SegmentList)
                seg = obj.SegmentList(i);
                if isempty(seg.P1.Connected)
                    count = count + 1;
                    if isempty(empty1)
                        empty1 = seg.P1;
                    else
                        empty2 = seg.P1;
                    end
                end
                if isempty(seg.P2.Connected)
                    count = count + 1;
                    if isempty(empty2)
                        empty2 = seg.P2;
                    else
                        empty1 = seg.P1;
                    end
                end
                if count > 2
                    error("Invalid path: More than two open endpoints");
                end
                if length(seg.P1.Connected) > 1 ...
                    || length(seg.P2.Connected) > 1
                   error("Invalid path: Multi-branch segment")
                end
            end
            % create path, pass on the endpoints with 1 empty
            obj.ValidatedPath = obj.createPath(empty1,empty2);
        end

        function checkConnect(obj, endp)
            % called after endpoint is added or transformed
            % ALREADY DETERMINED LOCATION HAS CHANGED 
            % won't do that here
            
            % for endps with existing connects, disconnect all

            if ~isempty(endp.Connected)
                for i = 1 : length(endp.Connected)
                    endp.disconnect(endp.Connected(i));
                end
            end
            
            for i = 1 : length(obj.SegmentList)
                otherSeg = obj.SegmentList(i);
                % don't connect to itself
                if ~isequal(endp.Segment, otherSeg)
                    % checks P1 connections
                    if isequal(endp.Pos, otherSeg.P1.Pos)
                        endp.connect(otherSeg.P1);
                    elseif isequal(endp.Pos, otherSeg.P2.Pos)
                        endp.connect(otherSeg.P2);
                    end
                end
            end
        end


        function delete(obj, selected)
            if isa(selected, "Point")
                obj.PointList(obj.PointList == selected) = [];
            else
                selected.P1.disconnectAll;
                selected.P2.disconnectAll;

                for i = 1:length(obj.SegmentList)
                    if isequal(obj.SegmentList(i), selected)
                        obj.SegmentList(i) = [];
                    end
                end
                delete(selected.P1);
                delete(selected.P2);
            end
            delete(selected);
        end

        function export(obj)
            % start point is the one closest to the origin
            % start and end points already stored in validatedPath

            if ~isempty(obj.ValidatedPath.SegmentList)
                arr = [];
                
                cursor = obj.ValidatedPath.Start;
                i = 1;
                while 1
                    newarr = cursor.Segment.export(cursor);
                    if i > 1
                        newarr = newarr(:,2:end);
                    else
                        i = 2;
                    end
                    arr = cat(2,arr,newarr);

                    % do-while loop
                    if isempty(cursor.Segment.otherP(cursor).Connected)
                        break
                    else
                        cursor = cursor.Segment.otherP(cursor).Connected(1);
                    end
                end

                fname = sprintf('%s.mat', obj.Title);
                save(fname, 'arr');
                clear arr;
            else
                error("Please first complete a validated path to export")
            end
        end
        
    end

    methods (Access = private)
        function path = createPath(obj, empty1, empty2)
            if dist(empty1.Pos, [0 0]) <= dist(empty2.Pos, [0 0])
                startp = empty1;
                endp = empty2;
            else
                startp = empty2;
                endp = empty1;
            end 
            path = Path(obj.SegmentList, startp, endp);
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