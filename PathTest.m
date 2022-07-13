

classdef PathTest < matlab.unittest.TestCase

    methods(Test)
    
        function lineSegmentBasicTranslate(testCase)
            f = Frame;

            % creates first segment
            l1 = LineSegment(f); % (0,0,1,0)
            testCase.verifyEmpty(l1.P1.Connected);
            
            % create second connecting segment l2
            % check connections with l1
            l2 = LineSegment(f,1,0,2,0);
            testCase.verifyEqual(l1, l2.P1.Connected(1).Segment);
            testCase.verifyEqual(l2, l1.P2.Connected(1).Segment);

            % translate second connecting segment
            % test position and connection
            l2.translate(2,2);
            testCase.verifyEqual(l2.P1.Pos, [3 2]);
            testCase.verifyEqual(l2.P2.Pos, [4 2]);
            testCase.verifyEmpty(l2.P1.Connected);
            testCase.verifyEmpty(l1.P2.Connected);

            % translate and connect back
            l2.translate(-2,-2);
            testCase.verifyEqual(l1, l2.P1.Connected(1).Segment);
            testCase.verifyEqual(l2, l1.P2.Connected(1).Segment);
        end

        function lineSegmentPivot(testCase)
            f = Frame;

            % create basic connected segments
            l1 = LineSegment(f); % (0,0,1,0)
            l2 = LineSegment(f,1,0,2,0);
            
        end
    
    end
end