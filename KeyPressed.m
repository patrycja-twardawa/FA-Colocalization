function KeyPressed(~, evnt, h)
try
    fprintf('A key was pressed. Turn ROI modification OFF. Key pressed: %s\n', evnt.Key);
    close(h);
catch
    disp('WARNING: Key press event error. Close window manually to stop ROI modification procedure.');
end
  end