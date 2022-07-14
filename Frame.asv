
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

        % title simply uses obj.Title = ...?

        function addSegment(obj,segment)
%             for i = 1 : length(obj.SegmentList)
%                 otherSeg = obj.SegmentList(i);
%                 % checks P1 connections
%                 if isequal(segment.P1.Pos, otherSeg.P1.Pos)
%                     segment.P1.connect(otherSeg.P1);
%                 elseif isequal(segment.P1.Pos, otherSeg.P2.Pos)
%                     segment.P1.connect(otherSeg.P2);
%                 end
% 
%                 % checks P2 connections
%                 if isequal(segment.P2.Pos, otherSeg.P1.Pos)
%                     segment.P2.connect(otherSeg.P1);
%                 elseif isequal(segment.P2.Pos, otherSeg.P2.Pos)
%                     segment.P2.connect(otherSeg.P1);
%                 end
%             end
            
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
            % validate: boolean val
            for i = 1 : length(obj.SegmentList)
                seg = obj.SegmentList(i);
                if isempty(seg.P1.Connected)
                    count = count + 1;
                end
                if isempty(seg.P2.Connected)
                    count = count + 1;
                end
                if count > 2
                    error("Invalid path: More than two open endpoints");
                end
                if length(seg.P1.Connected) > 1 ...
                    || length(seg.P2.Connected) > 1
                   error("Invalid path: Multi-branch segment")
                end
            end
            % create path
            obj.ValidatedPath = obj.createPath;
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


        function delete(obj, seg)
            seg.P1.disconnectAll;
            seg.P2.disconnectAll;
            obj.SegmentList(obj.SegmentList == seg) = [];
            delete(seg);
        end

        function export(obj)
            if ~isempty(obj.ValidatedPath.SegmentList)
                arr = [];
                for i = 1:length(obj.ValidatedPath.SegmentList)
                    newarr = obj.ValidatedPath.SegmentList(i).export;
                    if i > 1
                        newarr = newarr(:,2:end);
                    end
                    arr = cat(2,arr,newarr);
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
        function path = createPath(obj)
            path = Path(obj.SegmentList);
        end
    end
end