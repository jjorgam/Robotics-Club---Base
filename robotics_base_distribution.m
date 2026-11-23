clc;
clear;
close all;

%% ==========================================
% WHEEL POSITIONS [mm]
% ===========================================

wheelPos = [
    0   0;
    0   600;
    800 600;
    800 0
];

%% ==========================================
% COMPONENTS
%
% Format:
% [Mass(kg)  X(mm)  Y(mm)]
% ===========================================

components = [
    6   250   300;     % Battery
    2   350   250;     % Electronics
    4   650   300;     % Arm Base
    3   650   350;     % Drill
    8   1100  300      % Extended Arm COM
];

componentNames = {
    'Battery'
    'Electronics'
    'Arm Base'
    'Drill'
    'Extended Arm'
};

%% ==========================================
% GLOBAL CENTER OF MASS
% ===========================================

m = components(:,1);
x = components(:,2);
y = components(:,3);

totalMass = sum(m);

xCOM = sum(m.*x)/totalMass;
yCOM = sum(m.*y)/totalMass;

%% ==========================================
% SUPPORT POLYGON
% ===========================================

K = convhull(wheelPos(:,1),wheelPos(:,2));

%% ==========================================
% STABILITY CHECK
% ===========================================

inside = inpolygon( ...
    xCOM,...
    yCOM,...
    wheelPos(K,1),...
    wheelPos(K,2));

%% ==========================================
% STABILITY MARGIN
% ===========================================

supportPoly = wheelPos(K,:);

nEdges = size(supportPoly,1)-1;

distances = zeros(nEdges,1);

for i=1:nEdges

    p1 = supportPoly(i,:);
    p2 = supportPoly(i+1,:);

    edgeVec = p2-p1;
    pointVec = [xCOM yCOM]-p1;

    distances(i) = abs(det([edgeVec; pointVec])) ...
        / norm(edgeVec);

end

margin = min(distances);

%% ==========================================
% PLOT
% ===========================================

figure('Color','w');
hold on;
grid on;
axis equal;

title('ERC Rover Stability Study')
xlabel('X [mm]')
ylabel('Y [mm]')

%% Support Polygon

fill( ...
    supportPoly(:,1),...
    supportPoly(:,2),...
    [0.85 0.9 1],...
    'FaceAlpha',0.4,...
    'EdgeColor','b',...
    'LineWidth',2);

%% Wheels

scatter( ...
    wheelPos(:,1),...
    wheelPos(:,2),...
    120,...
    'filled',...
    'k');

%% Components

for i=1:size(components,1)

    scatter(...
        x(i),...
        y(i),...
        100,...
        'filled');

    text(...
        x(i)+25,...
        y(i),...
        componentNames{i});

end

%% Global COM

scatter( ...
    xCOM,...
    yCOM,...
    250,...
    'r',...
    'filled');

text( ...
    xCOM+25,...
    yCOM,...
    'GLOBAL COM',...
    'Color','r',...
    'FontWeight','bold');

%% Results

if inside
    status = 'STABLE';
    statusColor = [0 0.5 0];
else
    status = 'UNSTABLE';
    statusColor = [0.8 0 0];
end

xlim([-200 max([wheelPos(:,1);x])+300])
ylim([-200 max([wheelPos(:,2);y])+300])

annotation( ...
    'textbox',...
    [0.70 0.70 0.25 0.20],...
    'String',...
    sprintf([ ...
    'Total Mass = %.1f kg\n' ...
    'COM X = %.1f mm\n' ...
    'COM Y = %.1f mm\n' ...
    'Margin = %.1f mm\n' ...
    '%s'],...
    totalMass,...
    xCOM,...
    yCOM,...
    margin,...
    status),...
    'FitBoxToText','on',...
    'BackgroundColor','white',...
    'Color',statusColor,...
    'FontSize',10,...
    'FontWeight','bold');

%% Command Window Output

fprintf('\n');
fprintf('===============================\n');
fprintf('ERC STABILITY ANALYSIS\n');
fprintf('===============================\n');

fprintf('Total Mass      : %.2f kg\n',totalMass);
fprintf('COM X           : %.2f mm\n',xCOM);
fprintf('COM Y           : %.2f mm\n',yCOM);

fprintf('Stability Margin: %.2f mm\n',margin);

if inside
    fprintf('STATUS          : STABLE\n');
else
    fprintf('STATUS          : UNSTABLE\n');
end

fprintf('===============================\n');