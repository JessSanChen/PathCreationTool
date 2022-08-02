

classdef Endpoint < handle

    properties
        Pos
        Connected
        Segment
    end

    methods
        function obj = Endpoint(x,y, seg)
            if nargin < 2
                error("Must input x and y to instantiate endpoint.")
            end
            obj.Pos = [x y];
            obj.Connected = [];
            obj.Segment = seg;
        end

        function connect(obj, otherEndp)
            obj.Connected = [obj.Connected, otherEndp];
            otherEndp.Connected = [otherEndp.Connected, obj];
        end

        function disconnect(obj, otherEndp)
            obj.Connected(obj.Connected == otherEndp) = [];
            otherEndp.Connected(otherEndp.Connected == obj) = [];
        end

        function disconnectAll(obj)
            if ~isempty(obj.Connected)
                for i = 1:length(obj.Connected)
                    obj.disconnect(obj.Connected(i));
                end
            end
        end

        function setPos(obj, x,y)
            obj.Pos = [x y];
            obj.Segment.Frame.checkConnect(obj);
        end

    end
end