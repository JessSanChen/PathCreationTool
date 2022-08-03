

classdef (HandleCompatible) Segment < matlab.mixin.Heterogeneous

    % abstract class for both arc and lineseg to inherit from

    properties (Abstract)
        P1
        P2
    end

    methods
        
    end
end