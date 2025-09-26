%% constants and boundary conditions
% setting up discretization info constants for cardinal coordinates
xN          = 1;
del_X       = .01;
xdata       = 1:del_X:xN;
yN          = 1;
del_Y       =.01;
ydata       = 1:del_Y:yN;

% time info
t_final     = 60;
NUM_TIMES   = 50;
t_range     = linspace(0, t_final, NUM_TIMES);

% generating an initial T0 with boundary counditions on corner heat
[XX,YY]     = meshgrid(xdata,ydata); % Generate a meshgrid in case needed
T0          = 30*sin(1*pi*XX/xN - rand*sign(rand-0.5)*2*pi).*...
                    sin(2*pi*YY/yN - rand*sign(rand-0.5)*2*pi) + 20 + ...
                    30*rand*cos(2*pi*XX/xN - rand*sign(rand-0.5)*2*pi).*...
                    cos(4*pi*YY/yN - rand*sign(rand-0.5)*2*pi);

T0          = 35*reshape(T0',[length(XX)*length(YY) 1])/max(T0(:)) + 300;
targetTemp  = 400;

%% ode45 and plotting
nabla_operator  = nabla(length(xdata), length(ydata));
[t,T]       = ode45(@(t,T) diffusion(T, length(xdata), length(ydata), h, nabla_operator) + controller(targetTemp, T) + radiation(T), t_range, T0);

tiledlayout(2,4)
for tt = 1:ceil(NUM_TIMES/8):(NUM_TIMES)
    nexttile;
    Z = reshape(T(tt,:),length(xdata),length(ydata));
    plotted = surf(xdata,ydata, Z);
    set(plotted,'LineStyle','none');
    colorbar;
    time        = tt/NUM_TIMES * t_final;
    subtitle("t = " + time  + " secs");
    zlim([250, 550]);
    xlim([0 25])
    ylim([0 25])
    zlabel("Temperature (K)");
end

%% calculating diffusion and heat flow form controller
function dTdt = diffusion(T, xlength, ylength, h, nabla_operator)
% developing a nabla operator to multiply T
k           = .001;
dTdt        = zeros(xlength*ylength, 1);
dTdt(1:end) = k * (nabla_operator * T)/(h^2); 
end


function dTdt = radiation(T)
sb          = stefan_const(T);
dTdt        = zeros(length(T),1);
T_infinity  = 293;

for index   = 1:length(T)
dTdt(index) = - sb * (T(index)^4 - T_infinity^4);
end

end


function dTdt = controller(T_c, T)
dTdt        = zeros(length(T),1);
for index   = 1:length(T)
dTdt(index) = ctrl_term(T_c, T(index));
end
end


%% developing a matrix representing the nabla operator, using edge logic
%specifically: produces a centered difference sum
function matrixK = nabla(xlength, ylength)

kdimension  = xlength*ylength;
matrixK     = zeros(kdimension, kdimension);

for n = 1:kdimension
counter = 0;
if mod(n, xlength) ~= 1
    matrixK(n, n - 1) = 1;
    counter = counter + 1;
end

if mod(n, xlength) ~= 0
    matrixK(n, n + 1) = 1; % right edge detection
    counter = counter + 1;
end
if (ceil(n/xlength) ~= 1) 
    matrixK(n, n - xlength) = 1; % top edge detection
    counter = counter + 1;
end
if (ceil(n/xlength) ~= ylength)
    matrixK(n, n + xlength) = 1; % bottom edge detection
    counter = counter + 1;
end

matrixK(n, n) = -counter;
end

end


%% showing that the matrix K function works for a 3x3 and 2x3 matrix
syms T11 T12 T13 T21 T22 T23 T31 T32 T33

T           = [T11 T12 T13 T21 T22 T23 T31 T32 T33];
display(transpose(T))
display(nabla(3, 3) * transpose(T));

% three rows, two columns
T_nonsquare = [T11 T12 T21 T22 T31 T32];
display(nabla(2, 3) * transpose(T_nonsquare));

%% 
% calculate controller term for SINGLE POSITION 
function ctrl = ctrl_term(T_c, T)
% max and min heat from TEC, and steady state solution
Q_max       = 10;
Q_min       = -5;
sb          = stefan_const(T);
T_infinity  = 293;
heat_ss     = sb * (T_c^4 - T_infinity^4);

% enables a gain coefficient that gives you close-to steady state
del_T       = T_c -T;
%c           = c_map(del_T);
c           = 1;

% if steady state enabled, override c value function
if abs(del_T) < 5
    ctrl = heat_ss;
end

ctrl  = abs(c) * del_T;

%limit the possible values of Q_max and Q_min
if ctrl > Q_max
    ctrl = Q_max;
elseif ctrl < Q_min
    ctrl = Q_min;
end
end

%% helper functions and physical constants
%useful constants
T_length    = xN*yN;
h           = sqrt(del_X^2 + del_Y^2);

function k = stefan_const(T)
A_plate     = 2.4;
sigma_sb    = 5.67e-8;
emissivity  = 1;
m_plate     = 5000; % grams
C_p         = heat_capacity(T); % defaults to a constant

k           = A_plate * emissivity * sigma_sb / (m_plate * C_p);
end

function C_p = heat_capacity(T)
C_p         = .1;
end