function diffs = wt_test_rig(sz, scales)
% Crude set of tests to check phiw and uviw functions give same outputs
% FORMAT diffs = wt_test_rig(sz, scales)
% 
% Input 
% sz      - size (1D) of matrix
% scales  - number of scales to process
% 
% Returns
% diffs   - max absolute difference between uviw and phiw call
% 
% $Id: wt_test_rig.m,v 1.1 2004/09/26 06:44:50 matthewbrett Exp $

if nargin < 2
  error('Need size for matrix, and scales to process');
end

global WTCENTERMETHOD
WTCENTERMETHOD=0;
[h g rh rg] = lemarie(sz/2);
lh = length(h);
lg = length(g);

diffs = [];

% 1D matrix to transform
a = rand(1,sz);

for WTCENTERMETHOD = 1:3
  dlp=wtcenter(h); 
  dhp=wtcenter(g);
  diffs(end+1) = mx_abs(wt(a, h, g, scales, dlp, dhp),  uviw_wt(a, h, g, scales, dlp, dhp));
end
for WTCENTERMETHOD = 1:3
  diffs(end+1) = mx_abs(wt(a, h, g, scales),  uviw_wt(a, h, g, scales));
end

for dlp = [-10 lh + 10]
  for dhp = [-10  lh + 10]
    diffs(end+1) = mx_abs(wt(a, h, g, scales, dlp, dhp),  uviw_wt(a, h, g, scales, dlp, dhp));
  end
end

% Row vector
a = a';
diffs(end+1) = mx_abs(wt(a, h, g, scales),  uviw_wt(a, h, g, scales));

% 2D matrix
b = rand(sz,sz);

% 1D transform - over rows
diffs(end+1) = mx_abs(wt(b, h, g, scales),  uviw_wt(b, h, g, scales));

% 2D transform
diffs(end+1) = mx_abs(wt2d(b, h, g, scales),  uviw_wt2d(b, h, g, scales));

% Get wt matrix first
wa = wt(a, h, g, scales);

% iwt
for WTCENTERMETHOD = 1:3
  diffs(end+1) = mx_abs(iwt(wa, rh, rg, scales),  uviw_iwt(wa, rh, rg, scales));
end

% iwt
for dlp = [-10 lh + 10]
  for dhp = [-10  lh + 10]
    [sdlp sdhp] = wt_synth_delay(rh, rg, dlp, dhp);
    diffs(end+1) = mx_abs(iwt(wa, rh, rg, scales, sz, scales, sdlp, sdhp),  ...
	uviw_iwt(wa, rh, rg, scales, sz, scales, sdlp, sdhp));
    
  end
end

% Now 2D matrix
wb =  wt2d(b, h, g, scales);

% iwt
for WTCENTERMETHOD = 1:3
  diffs(end+1) = mx_abs(iwt(wb, rh, rg, scales),  uviw_iwt(wb, rh, rg, scales));
end

% iwt
for dlp = [-10 lh + 10]
  for dhp = [-10  lh + 10]
    [sdlp sdhp] = wt_synth_delay(rh, rg, dlp, dhp);
    diffs(end+1) = mx_abs(iwt(wb, rh, rg, scales, sz, scales, sdlp, sdhp),  ...
	uviw_iwt(wb, rh, rg, scales, sz, scales, sdlp, sdhp));
  end
end

% 2D transform
diffs(end+1) = mx_abs(iwt2d(wb, rh, rg, scales),  uviw_iwt2d(wb, rh, rg, scales));

% 2D transform giving correct dimensions
diffs(end+1) = mx_abs(iwt2d(wb, rh, rg, scales, sz, sz), ...
		      uviw_iwt2d(wb, rh, rg, scales, sz, sz));

% 2D transform with odd dimensions
sz2 = sz+3;
b_w = rand(sz, sz2); 
wb_w = wt2d(b_w, h, g, scales);
% Note that sz and sz2 have to be reversed because of UviWave's reading of
% X and Y for matrices
diffs(end+1) = mx_abs(iwt2d(wb_w, rh, rg, scales, sz2, sz), ...
		      uviw_iwt2d(wb_w, rh, rg, scales, sz2, sz));

% 2D transform, low pass only for some scales
diffs(end+1) = mx_abs(iwt2d(wb, rh, rg, scales, sz, sz, 1), ...
		      uviw_iwt2d(wb, rh, rg, scales, sz, sz, 1));

% 2D transform, low pass only for some more scales
sc_levels = ones(1, scales);
if sc_levels > 2
  sc_levels(3:end) = 0;
end
diffs(end+1) = mx_abs(iwt2d(wb, rh, rg, scales, sz, sz, sc_levels), ...
		      uviw_iwt2d(wb, rh, rg, scales, sz, sz, sc_levels));


return

function mx = mx_abs(a, b)
a = a - b;
mx = max(abs(a(:)));
return

