% --- Executes on mouse press over axes background.
%
% Show initial candidates and the best match according to the algorithm
%
function axes2_highlightSubgraphs(hObject, ~, handles)

img = handles.img;

HLGraph = handles.HLGraph;
LLGraph = handles.LLGraph;

imgSP_hl = handles.imgSP_hl; 
imgSP_ll = handles.imgSP_ll; 

showHLG = get(handles.chbox_Show_HLGraph,'Value');
showLLG = get(handles.chbox_Show_LLGraph,'Value');
                 
cP = get(gca,'Currentpoint');
n = cP(1,1);
m = cP(1,2);
 
% selected anchor
NN = knnsearch(HLGraph.V, [n,m]); 


axes(handles.axes2);
% --------------------------------------------------------------------------------
% Plotting
% --------------------------------------------------------------------------------
imagesc(img), hold on ;
% --------------------------------------------------------------------------------
% indices of nodes in subgraph of selected anchor NN
ind_subG = find(LLGraph.U(:,NN));
% --------------------------------------------------------------------------------
% vertices
plot(LLGraph.V(:,1), LLGraph.V(:,2), 'b*');

% edges between vertices
if showLLG
    E_subG = [];
    for i=1:size(LLGraph.E, 1)
        line([LLGraph.V(LLGraph.E(i,1),1) LLGraph.V(LLGraph.E(i,2),1) ],...
             [LLGraph.V(LLGraph.E(i,1),2) LLGraph.V(LLGraph.E(i,2),2) ], 'Color', 'g');  

        
        if ismember(LLGraph.E(i,1), ind_subG) || ismember(LLGraph.E(i,2), ind_subG)
            E_subG = [E_subG; LLGraph.E(i,:)];
            line([LLGraph.V(LLGraph.E(i,1),1) LLGraph.V(LLGraph.E(i,2),1) ],...
                 [LLGraph.V(LLGraph.E(i,1),2) LLGraph.V(LLGraph.E(i,2),2) ], 'Color', 'g', 'LineWidth', 3);  
        end
    end
end
% --------------------------------------------------------------------------------
% edges between vertives and anchor points
[i, j] = find(LLGraph.U);
matchesInd = [i,j]';

nans = NaN * ones(size(matchesInd,2),1) ;
xInit = [ LLGraph.V(matchesInd(1,:),1) , HLGraph.V(matchesInd(2,:),1) , nans ] ;
yInit = [ LLGraph.V(matchesInd(1,:),2) , HLGraph.V(matchesInd(2,:),2) , nans ] ;

line(xInit', yInit', 'Color','m', 'LineStyle', '--', 'LineWidth', 0.5) ;

nans = NaN * ones(numel(ind_subG),1) ;
xInit_highlight = [ LLGraph.V(ind_subG,1) , repmat(HLGraph.V(NN,1), numel(ind_subG),1) , nans ] ;
yInit_highlight = [ LLGraph.V(ind_subG,2) , repmat(HLGraph.V(NN,2), numel(ind_subG),1) , nans ] ;


line(xInit_highlight', yInit_highlight', 'Color','r', 'LineStyle', '-', 'LineWidth', 1) ;

%
% --------------------------------------------------------------------------------
% anchors
plot(HLGraph.V(:,1), HLGraph.V(:,2), 'yo','MarkerSize', 9, 'MarkerFaceColor','y');
% edges between anchors
if showHLG
    matchesInd = HLGraph.E';

    nans = NaN * ones(size(matchesInd,2),1) ;
    xInit = [ HLGraph.V(matchesInd(1,:),1) , HLGraph.V(matchesInd(2,:),1) , nans ] ;
    yInit = [ HLGraph.V(matchesInd(1,:),2) , HLGraph.V(matchesInd(2,:),2) , nans ] ;

    line(xInit', yInit', 'Color','y', 'LineStyle', '-', 'LineWidth', 3) ;
end
% --------------------------------------------------------------------------------

plot(HLGraph.V(NN,1), HLGraph.V(NN,2), 'ro','MarkerSize', 9, 'MarkerFaceColor','r');


% --------------------------------------------------------------------------------

hold off;
% --------------------------------------------------------------------------------
% --------------------------------------------------------------------------------

set(gca,'ButtonDownFcn', {@axes2_highlightSubgraphs, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes2_highlightSubgraphs, handles})    
