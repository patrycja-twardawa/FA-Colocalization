function [cMap3, cMap7] = colormapprep

cMap = interp1([0;1], [0 1 0; 1 1 0], linspace(0, 1, 32767));
cMap = [[0 0 0]; cMap];
cMap2 = interp1([0;1], [1 1 0; 1 0 0], linspace(0, 1, 32768));
cMap3 = [cMap; cMap2];

cMap4 = interp1([0;1], [0 0 1; 1 1 0], linspace(0, 1, 32767));
cMap5 = [[0 0 0]; cMap4];
cMap6 = interp1([0;1], [1 1 0; 1 0 0], linspace(0, 1, 32768));
cMap7 = [cMap5; cMap6];

end