%% Taylor Model
% 
%
%%
%
%
%% Open in Editor
%
%% Contents

%% 

% display pole figure plots with RD on top and ND west
plotx2north

storepfA = getMTEXpref('pfAnnotations');
pfAnnotations = @(varargin) text(-[vector3d.X,vector3d.Y],{'RD','ND'},...
  'BackgroundColor','w','tag','axesLabels',varargin{:});

setMTEXpref('pfAnnotations',pfAnnotations);

%% Set up 
% consider cubic crystal symmetry
cs = crystalSymmetry('432');

% define a family of slip systems
sS = slipSystem.fcc(cs);

% some strain
q = 0;
epsilon = tensor(diag([1 -q -(1-q)]),'name','strain')

% define a crystal orientation
ori = orientation('Euler',0,30*degree,15*degree,cs)

% compute the Taylor factor
[M,b,mori] = calcTaylor(inv(ori)*epsilon,sS.symmetrise);

%% The orientation dependence of the Taylor factor
% The following code reproduces Fig. 5 of the paper of Bunge, H. J. (1970).
% Some applications of the Taylor theory of polycrystal plasticity.
% Kristall Und Technik, 5(1), 145-175.
% http://doi.org/10.1002/crat.19700050112

% set up an phi1 section plot
sP = phi1Sections(cs,specimenSymmetry('222'));
sP.phi1 = (0:10:90)*degree;

% generate an orientations grid
oriGrid = sP.makeGrid('resolution',2.5*degree);
oriGrid.SS = specimenSymmetry;

% compute Taylor factor for all orientations
tic
[M,~,mori] = calcTaylor(inv(oriGrid)*epsilon,sS.symmetrise);
toc

% plot the taylor factor
sP.plot(M,'smooth')

mtexColorbar


%% The orientation dependence of the rotation value 
% Compare Fig. 8 of the above paper

sP.plot(mori.angle./degree,'smooth')
mtexColorbar

%%
sP = sigmaSections(cs,specimenSymmetry);
oriGrid = sP.makeGrid('resolution',2.5*degree);
[M,~,mori] = calcTaylor(inv(oriGrid)*epsilon,sS.symmetrise);
sP.plot(mori.angle./degree,'smooth')
mtexColorbar

%% Most active slip direction

mtexdata csl

grains = calcGrains(ebsd('indexed'));

% remove small grains
grains(grains.grainSize <= 2) = []

%%

% some strain
q = 0;
epsilon = tensor(diag([1 -q -(1-q)]),'name','strain')

sS = symmetrise(slipSystem.fcc(grains.CS));

[M,b,mori] = calcTaylor(inv(grains.meanOrientation)*epsilon,sS);

%%

% colorize grains according to Taylor factor
plot(grains,M)
mtexColorbar

% index of the most active slip system - largest b
[~,bMaxId] = max(b,[],2);

% rotate the moste active slip system in specimen coordinates
sSGrains = grains.meanOrientation .* sS(bMaxId);

% visualize slip direction and slip plane for each grain
hold on
quiver(grains,sSGrains.b,'autoScaleFactor',0.5,'displayName','Burgers vector')
hold on
quiver(grains,sSGrains.n,'autoScaleFactor',0.5,'displayName','slip plane trace')
hold off

%%
% plot the most active slip directions 
% observe that they point all towards the lower hemisphere - why?
% they do change if q is changed 

figure(2)
plot(sSGrains.b)


%% Texture evolution during rolling

% define some random orientations
ori = orientation.rand(10000,cs);

% 30 percent strain
q = 0;
epsilon = 0.3 * tensor(diag([1 -q -(1-q)]),'name','strain');

% 
numIter = 10;
progress(0,numIter);
for sas=1:numIter

  % compute the Taylor factors and the orientation gradients
  [M,~,mori] = calcTaylor(inv(ori) * epsilon ./ numIter, sS.symmetrise,'silent');
  
  % rotate the individual orientations
  ori = ori .* mori;
  progress(sas,numIter);
end

%%

% plot the resulting pole figures

plotPDF(ori,Miller({0,0,1},{1,1,1},cs),'contourf')
mtexColorbar

%% restore MTEX preferences

setMTEXpref('pfAnnotations',storepfA);

%% Inverse Taylor

oS = axisAngleSections(cs,cs,'antipodal');
oS.angles = 10*degree;

mori = oS.makeGrid;

[M,b,eps] = calcInvTaylor(mori,sS.symmetrise);

%%

plot(oS,M,'contourf')

