

classdef PathTest < matlab.unittest.TestCase

    methods(Test)
    
        function lineSegmentBasic(testCase)
            f = Frame;

            % creates first segment
            l1 = LineSegment(f); % (0,0,1,0)
            testCase.verifyEmpty(l1.P1.Connected);
            
            % create second connecting segment l2
            % check connections with l1
            l2 = LineSegment(f,1,0,2,0);
            testCase.verifyEqual(l1, l2.P1.Connected(1).Segment);
            testCase.verifyEqual(l2, l1.P2.Connected(1).Segment);

        end

        function lineSegmentBasicTranslate(testCase)
            f = Frame;

            % create basic connected segments
            l1 = LineSegment(f); % (0,0,1,0)
            l2 = LineSegment(f,1,0,2,0);

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
            
            % pivot l2 by 90 deg on l2.p1
            % test position and connection
            l2.pivot(l2.P1.Pos,90);
            testCase.verifyEqual(l2.P1.Pos, [1 0]);
            testCase.verifyEqual(l2.P2.Pos, [1 1]);
            testCase.verifyEqual(l1, l2.P1.Connected(1).Segment);
            testCase.verifyEqual(l2, l1.P2.Connected(1).Segment);

            % pivot l2 by -270 deg on l2.p1
            l2.pivot(l2.P1.Pos, -270);
            testCase.verifyEqual(l2.P1.Pos, [1 0]);
            testCase.verifyEqual(l2.P2.Pos, [0 0]);
            testCase.verifyEqual(l1, l2.P1.Connected(1).Segment);
            testCase.verifyEqual(l2, l1.P2.Connected(1).Segment);
            testCase.verifyEqual(l1, l2.P2.Connected(1).Segment);
            testCase.verifyEqual(l2, l1.P1.Connected(1).Segment);

            % pivot l2 by 360+180 deg on l2.p1
            l2.pivot(l2.P1.Pos, 540);
            testCase.verifyEqual(l2.P1.Pos, [1 0]);
            testCase.verifyEqual(l2.P2.Pos, [2 0]);
            testCase.verifyEqual(l1, l2.P1.Connected(1).Segment);
            testCase.verifyEqual(l2, l1.P2.Connected(1).Segment);

            % pivot l2 by 90 deg on origin
            l2.pivot([0 0], 90);
            testCase.verifyEqual(l2.P1.Pos, [0 1]);
            testCase.verifyEqual(l2.P2.Pos, [0 2]);
            testCase.verifyEmpty(l1.P1.Connected);
            testCase.verifyEmpty(l1.P2.Connected);
            testCase.verifyEmpty(l2.P1.Connected);
            testCase.verifyEmpty(l2.P2.Connected);            
        end

        function lineSegmentScale(testCase)
            f = Frame;

            % create basic connected segments
            l1 = LineSegment(f); % (0,0,1,0)
            l2 = LineSegment(f,1,0,2,0);
            
            % scale l2 by 2 on l2.p1
            % test position and connection
            l2.scale(l2.P1.Pos,2);
            testCase.verifyEqual(l2.P1.Pos, [1 0]);
            testCase.verifyEqual(l2.P2.Pos, [3 0]);
            testCase.verifyEqual(l1, l2.P1.Connected(1).Segment);
            testCase.verifyEqual(l2, l1.P2.Connected(1).Segment);

            % check error thrown for factors <=0
%             testCase.verifyError


        end

        function lineSegmentValidate(testCase)
            f = Frame;

            % create basic connected segments
            l1 = LineSegment(f); % (0,0,1,0)
            l2 = LineSegment(f,1,0,2,0);

            validate(f);
            testCase.verifyEqual([l1 l2], f.ValidatedPath.SegmentList);
            
            % disconnect segment
            l2.translate(1,0);
            testCase.verifyEqual(l2.P2.Pos, [3 0]);
            testCase.verifyEmpty(l2.P1.Connected);
            testCase.verifyEmpty(l1.P2.Connected);
            testCase.verifyError(f.validate, ?MException);
        end
    
    end
end