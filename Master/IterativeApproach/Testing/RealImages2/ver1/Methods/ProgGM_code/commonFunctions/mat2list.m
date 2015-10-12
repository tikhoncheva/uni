function [ L12 ] =  mat2list( E12 )
% convert N x N incident matrix (0 or 1) into N x 2 pairwise list
%
% 2011.3 
% SNU CVL Minsu CHo
%
%

% make sets of unique indexes
featIdx1 = unique(list(:,1));
featIdx2 = unique(list(:,2)); 
% make a new list by replacing original feature idx with ordered idx as 1,2,... 
t_list = zeros(size(list));
for i = 1:length(featIdx1)
    t_list(list(:,1) == featIdx1(i), 1) = i;
end
for i = 1:length(featIdx2)
    t_list(list(:,2) == featIdx2(i), 2) = i;
end
% pause;
%list(1:15,:)%t_list(1:15,:)
E12 = sparse(t_list(:,1),t_list(:,2),1); % transform list to E12
%E12 = full(E12);

