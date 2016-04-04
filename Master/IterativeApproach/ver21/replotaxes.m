function replotaxes(object, background)

axes(object);
cla reset

imagesc(background);

set(object,'XTick',[]);
set(object,'YTick',[]);

end
