%% Methods & Settings
% Script for setting algorithms to run

% You can add an algorithm following the script below
%nMethods = 1;
%methods(nMethods).fhandle = @fhandle;                         % Function of the algorithm
%methods(nMethods).variable = {'var1', 'var2', 'var3'};        % Input variables that the algorithm requires
%methods(nMethods).param = {'name1', 'val1', 'name2', 'val2'}; % Default parameter values
%methods(nMethods).strName = 'algorithm name';                 % Algorithm name tag
%methods(nMethods).color = 'color';                            % Color for plots
%methods(nMethods).lineStyle = 'line style';                   % Line style for plots
%methods(nMethods).marker = 'marker';                          % Marker for plots

nMethods = 0;
% Progressive Graph Matching
if 1
    nMethods = nMethods + 1;
    methods(nMethods).fhandle = @wrapper_ProgGM;
    methods(nMethods).variable = { 'pparam', 'method', 'cdata', 'extrapolation_dist'};
    methods(nMethods).param = {};
    methods(nMethods).strName = 'ProgGM';
    methods(nMethods).color = 'm';
    methods(nMethods).lineStyle = '-';
    methods(nMethods).marker = 'o';
end
% new Two Level Graph Matching algorithm
if 1
    nMethods = nMethods + 1;
    methods(nMethods).fhandle = @wrapper_TwoLevelGM;
    methods(nMethods).variable = {'LLG1', 'LLG2'};
    methods(nMethods).param = {};
    methods(nMethods).strName = '2LevelGM';
    methods(nMethods).color = 'g';
    methods(nMethods).lineStyle = '-';
    methods(nMethods).marker = 'o';    
    
end

% Feature Matching
if 1
    nMethods = nMethods + 1;
    methods(nMethods).fhandle = @wrapper_featureMatching;
    methods(nMethods).variable = {'LLG1', 'LLG2'};
    methods(nMethods).param = {};
    methods(nMethods).strName = 'featureMatching';
    methods(nMethods).color = 'b';
    methods(nMethods).lineStyle = '-';
    methods(nMethods).marker = 'o';    
    
end


%% Show the algorithms to run
disp('* Algorithms to run *');
for k = 1:nMethods, disp([methods(k).strName ' : @' func2str(methods(k).fhandle)]); end; disp(' ')
clear k