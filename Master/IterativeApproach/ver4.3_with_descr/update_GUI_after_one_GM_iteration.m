function [handles] = update_GUI_after_one_GM_iteration(L,handles) %, it, time, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches)
    
%     L = handles.IPlevel;

    img1 = handles.IP1(L).img;
    img2 = handles.IP2(L).img;
    
    time = handles.SummaryT;
    it = handles.M(L).it;

    LLG1 = handles.IP1(L).LLG;
    LLG2 = handles.IP2(L).LLG;

    HLG1 = handles.IP1(L).HLG;
    HLG2 = handles.IP2(L).HLG;

    LLGmatches = handles.M(L).LLGmatches;
    HLGmatches = handles.M(L).HLGmatches;

    GT = handles.M(L).GT;

    % update plots and labels   
    set(handles.text_IPlevel, 'String', sprintf('Level: %d', L))
    set(handles.text_IterationCount, 'String', sprintf('Iteration: %d', it));   
    set(handles.text_SummaryT, 'String', sprintf('Summary time: %0.3f', time));
    
    % plot current partition
    axes(handles.axes3);
    nColors = max(size(HLG1.V,1), size(HLG2.V,1));
    plot_2levelgraphs(img1, LLG1, HLG1, nColors, false, false, HLGmatches(it).matched_pairs,1);
    axes(handles.axes4);
    plot_2levelgraphs(img2, LLG2, HLG2, nColors, false, false, HLGmatches(it).matched_pairs,2);    

    drawnow;
    
    % Higher Level
    set(handles.text_objval_HLG, 'String', sprintf('Objval:  %0.3f', HLGmatches(it).objval));

    axes(handles.axes5); cla reset; % plot new correspondencies
    plot_HLGmatches(img1, HLG1, img2, HLG2, HLGmatches(it).matched_pairs, GT.HLpairs);
    
    axes(handles.axes11); plot_score(HLGmatches); % plot score and accuracy
    if ~isempty(GT.HLpairs)                       % if we know the Ground Truth fot the HL
        axes(handles.axes12); plot_accuracy(HLGmatches, GT.HLpairs);
    end
    drawnow;
    
    % Lower Level
    set(handles.text_objval_LLG, 'String', sprintf('Objval:  %0.3f', LLGmatches(it).objval));
   
    axes(handles.axes6);  % plot new correspondencies  
    plot_LLGmatches(img1, LLG1, HLG1, ...
                    img2, LLG2, HLG2, ...
                    LLGmatches(it).matched_pairs, ...
                    HLGmatches(it).matched_pairs, GT.LLpairs);    
   
    figure; 
%     axes(handles.axes13);
    plot_score(LLGmatches); % plot score and accuracy
    if ~isempty(GT.LLpairs)                       % if we know the Ground Truth fot the HL
        figure;
%         axes(handles.axes14); %plot_accuracy(LLG1, LLG2, LLGmatches, GT.LLpairs);
        i = 1:1:it;
        plot(i, handles.Accuracy,'lineWidth', 3)
        hold on;
        plot(i,handles.Accuracy, 'bo', 'MarkerSize', 10), hold off;
        xlabel('Iteration'); ylabel('Accurasy'); set(gca,'FontSize',15)
        set(legend('Accurasy'), 'Location', 'best', 'FontSize', 15);

    end
    drawnow;          

end