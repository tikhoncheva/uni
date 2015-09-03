function id = getThreadID()

% get the thread id
t = getCurrentTask();
if isempty(t)
	% only one thread
	id = 0;
else
	% parfor (multithreaded)
	id = t.ID;
end
