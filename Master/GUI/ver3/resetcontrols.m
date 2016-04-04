function resetcontrols(handles)


% delete frames
handles.frames{1} = [];
handles.frames{2} = [];

% delete descriptors
handles.descr{1} = [];
handles.descr{2} = [];

% delete match info
handles.matched = 0;
handles.matchInfo.match = [];
handles.matchInfo.dist = [];
handles.matchInfo.sim = [];
   
set(handles.axes3, 'Visible', 'off');
set(handles.axes6,'Visible', 'on');    


set(handles.checkShowDG,'Value', 0);   % Show Dependency Graph
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors

set(handles.checkShowDG,'Enable','off');   % Show Initial Matches
set(handles.checkboxShowInitM,'Enable','off');   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Enable','off');   % Show Neighbors

set(handles.pushbuttonGetFeauters,'enable','off');
set(handles.pbSelectPoints,'enable','off');
set(handles.pushbuttonClearAll,'Enable','off');   % Show Matching results
set(handles.pbMatchingAlg,'Enable','off');   % Enable matching 

end