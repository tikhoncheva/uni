%% Methods & Settings
nMethods = 0;
%% RRWM
if 1
    nMethods = nMethods + 1;
    methods(nMethods).fhandle = @RRWM;
    methods(nMethods).variable = {'affinityMatrix', 'group1', 'group2'};
    methods(nMethods).strName = 'RRWM';
    methods(nMethods).postProcess = @postGreedy;
    methods(nMethods).color = 'r';
    methods(nMethods).lineStyle = '-';
    methods(nMethods).marker = 'p';
    
end

%% Spectral Matching
if 0
    nMethods = nMethods + 1;
    methods(nMethods).fhandle = @SM;
    methods(nMethods).variable = {'affinityMatrix'};
    methods(nMethods).strName = 'SM';
    methods(nMethods).postProcess = @postGreedy;
    methods(nMethods).color = 'k';
    methods(nMethods).lineStyle = '-';
    methods(nMethods).marker = 'x';
end

disp('* GM modules in use *'); for k = 1:nMethods, disp(methods(k).strName); end; disp(' ')