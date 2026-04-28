% StateQuantization.m
% Predictor-feedback control: fixed mu (large & small) vs. dynamic mu.
%
% System:  X1_dot = X2 - X2^2 * u(0,t)
%          X2_dot = u(0,t)
%          u_t    = u_x,   x in [0,D],   u(D,t) = U(t)
%
% Control: U = -mu*q1 - (2+D)*mu*q2 - (1/3)*mu*q2^3 - IntTerm
%   where  q1 = q(X1/mu),  q2 = q(X2/mu)  (uniform quantizer)
%   and    IntTerm = integral_0^D (2+D-x)*u(x,t) dx  (predictor)
%
% Four cases:
%   LARGE   : mu fixed at 6          --> red   'r'
%   SMALL   : mu fixed at 0.01       --> blue  'b'
%   DYNAMIC : mu(t) zoom-scheduling  --> black 'k'
%   LIBERZON: predictor-free         --> magenta 'm'
%
% Figures produced:
%   statedyn.eps   -- X1, X2, u(x,t) for dynamic mu(t)
%   normfix.eps    -- norms: DYNAMIC + LARGE + SMALL
%   normlib.eps    -- norm: predictor-free (with zoom inset)
% =========================================================================

close all; clear all; clc
global U

%% -----------------------------------------------------------------------
%% PARAMETERS
%% -----------------------------------------------------------------------
D   = 1;      % PDE domain length / transport delay
L   = D;      % right spatial boundary
Ts  = 20;     % simulation duration [s]
Nx  = 151;    % spatial grid points
Nt  = 500;    % time steps

x        = linspace(0, L, Nx);
dx       = x(2) - x(1);
howfar   = Ts / Nt;       % output time step for hpde
timestep = 0.5 * dx;      % CFL inner time step

M     = 2;        % quantizer saturation level
Delta = M / 100;  % quantizer resolution

% Zoom scheduling parameters (dynamic case)
mu0   = 5.6;   % initial zoom value
Omega = 0.63;  % contraction ratio
t0    = 0;     % zoom activation time
T     = 2;     % switching period
tau   = 1;     % dwell time
t_f   = Ts;    % final time (for zoom_mu)

% Fixed mu values
mu_large = 6;
mu_small = 0.01;

%% -----------------------------------------------------------------------
%% AXIS LIMITS -- change these to adjust all figures at once
%% -----------------------------------------------------------------------
t_min      = 0;    % x-axis (time) lower limit for ODE state plots
t_max      = 20;   % x-axis (time) upper limit for ODE state plots
t_mesh_max = 20;   % time horizon for u(x,t) mesh in subplot(2,2,[3,4])
y_norm_min = 0;    % y-axis lower limit for norm plots
y_norm_max = 50;   % y-axis upper limit for norm plots
y_X1_min   = [];   % y-axis for X1 plots ([] = auto)
y_X1_max   = [];
y_X2_min   = [];   % y-axis for X2 plots ([] = auto)
y_X2_max   = [];

%% -----------------------------------------------------------------------
%% RUN FOUR CASES
%% -----------------------------------------------------------------------
fprintf('Running LARGE fixed mu = %.1f ...\n', mu_large);
[t_L, norm_L, Y1_L, Y2_L, Y3_L, ~] = ...
    run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
            mu_large, 'fixed', mu0, Omega, t0, T, tau, t_f, D, L);

fprintf('Running SMALL fixed mu = %.2f ...\n', mu_small);
[t_S, norm_S, Y1_S, Y2_S, Y3_S, ~] = ...
    run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
            mu_small, 'fixed', mu0, Omega, t0, T, tau, t_f, D, L);

fprintf('Running DYNAMIC mu ...\n');
[t_D, norm_D, Y1_D, Y2_D, Y3_D, mu_D] = ...
    run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
            mu0, 'dynamic', mu0, Omega, t0, T, tau, t_f, D, L);

fprintf('Running PREDICTOR-FREE (Liberzon) ...\n');
[t_Lib, norm_Lib, Y1_Lib, Y2_Lib, Y3_Lib, mu_Lib] = ...
    run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
            mu0, 'liberzon', mu0, Omega, t0, T, tau, t_f, D, L);

fprintf('Done. Generating figures...\n');

%% -----------------------------------------------------------------------
%% Common index for ODE state plots
%% -----------------------------------------------------------------------
t_disp  = Ts;
idx     = find(t_L <= t_disp);
pstep   = 3; tstep = 3;

% %% -----------------------------------------------------------------------
% %% FIGURE 1 -- State evolution: fixed mu = 6
% %% -----------------------------------------------------------------------
% idx_mesh_L     = find(t_L <= t_mesh_max);
% idx_sub_mesh_L = idx_mesh_L(1:tstep:end);
% [Xm_L, Tm_L]   = meshgrid(x(1:pstep:end), t_L(idx_sub_mesh_L));
%
% figure;
% subplot(2,2,1);
% plot(t_L(idx), Y1_L(idx), 'r', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_X1_min); ylim([y_X1_min, y_X1_max]); end
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,2);
% plot(t_L(idx), Y2_L(idx), 'r', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_X2_min); ylim([y_X2_min, y_X2_max]); end
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,[3,4]);
% mesh(Xm_L, Tm_L, Y3_L(idx_sub_mesh_L, 1:pstep:end), ...
%      'LineWidth', 1, 'edgecolor', 'black');
% view(83, 10); hold on;
% plot3(L*ones(size(t_L(idx_mesh_L))), t_L(idx_mesh_L), ...
%       Y3_L(idx_mesh_L,end), 'r', 'LineWidth', 4);
% xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
% zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'statefix_large.eps', 'ContentType', 'vector');

% %% -----------------------------------------------------------------------
% %% FIGURE 2 -- State evolution: fixed mu = 0.01
% %% -----------------------------------------------------------------------
% idx_mesh_S     = find(t_S <= t_mesh_max);
% idx_sub_mesh_S = idx_mesh_S(1:tstep:end);
% [Xm_S, Tm_S]   = meshgrid(x(1:pstep:end), t_S(idx_sub_mesh_S));
%
% figure;
% subplot(2,2,1);
% plot(t_S(idx), Y1_S(idx), 'b', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_X1_min); ylim([y_X1_min, y_X1_max]); end
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,2);
% plot(t_S(idx), Y2_S(idx), 'b', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_X2_min); ylim([y_X2_min, y_X2_max]); end
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,[3,4]);
% mesh(Xm_S, Tm_S, Y3_S(idx_sub_mesh_S, 1:pstep:end), ...
%      'LineWidth', 1, 'edgecolor', 'black');
% view(83, 10); hold on;
% plot3(L*ones(size(t_S(idx_mesh_S))), t_S(idx_mesh_S), ...
%       Y3_S(idx_mesh_S,end), 'r', 'LineWidth', 4);
% xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
% zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'statefix_small.eps', 'ContentType', 'vector');

%% -----------------------------------------------------------------------
%% FIGURE 3 -- State evolution: dynamic mu(t)
%% -----------------------------------------------------------------------
idx_mesh_D     = find(t_D <= t_mesh_max);
idx_sub_mesh_D = idx_mesh_D(1:tstep:end);
[Xm_D, Tm_D]   = meshgrid(x(1:pstep:end), t_D(idx_sub_mesh_D));

figure;
subplot(2,2,1);
plot(t_D(idx), Y1_D(idx), 'k', 'LineWidth', 5);
xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
xlim([t_min, t_max]);
if ~isempty(y_X1_min); ylim([y_X1_min, y_X1_max]); end
set(gca, 'FontSize', 30); grid on; style_grid(gca);

subplot(2,2,2);
plot(t_D(idx), Y2_D(idx), 'k', 'LineWidth', 5);
xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
xlim([t_min, t_max]);
if ~isempty(y_X2_min); ylim([y_X2_min, y_X2_max]); end
set(gca, 'FontSize', 30); grid on; style_grid(gca);

subplot(2,2,[3,4]);
mesh(Xm_D, Tm_D, Y3_D(idx_sub_mesh_D, 1:pstep:end), ...
     'LineWidth', 1, 'edgecolor', 'black');
view(83, 10); hold on;
plot3(L*ones(size(t_D(idx_mesh_D))), t_D(idx_mesh_D), ...
      Y3_D(idx_mesh_D,end), 'r', 'LineWidth', 4);
xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
set(gca, 'FontSize', 30); grid on; style_grid(gca);
exportgraphics(gcf, 'statedynstate.eps', 'ContentType', 'vector');

%% -----------------------------------------------------------------------
%% FIGURE 4 -- Norms: DYNAMIC + LARGE + SMALL + PREDICTOR-FREE
%% -----------------------------------------------------------------------
figure;
plot(t_D,   norm_D,   'k', 'LineWidth', 5); hold on;
plot(t_L,   norm_L,   'r', 'LineWidth', 5);
plot(t_S,   norm_S,   'b', 'LineWidth', 5);
plot(t_Lib, norm_Lib, 'm', 'LineWidth', 5);
% plot(t_D, M*mu_D, 'k--', 'LineWidth', 3);
xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
ylabel('$|X(t)|+\|u(t)\|_{\infty}$', 'Interpreter', 'latex', 'FontSize', 30);
xlim([t_min, t_max]); ylim([y_norm_min, y_norm_max]);
% legend({'$\mu(t)$', '$\mu = 6$', '$\mu = 0.01$', 'No predictor', '$M\mu(t)$'}, ...
%        'Interpreter', 'latex', 'FontSize', 20, 'Location', 'northeast');
set(gca, 'FontSize', 30); grid on; style_grid(gca);
exportgraphics(gcf, 'normstate.eps', 'ContentType', 'vector');

% %% -----------------------------------------------------------------------
% %% FIGURE 4 -- Norms: DYNAMIC + LARGE + SMALL
% %% -----------------------------------------------------------------------
% figure;
% plot(t_D, norm_D, 'k', 'LineWidth', 5); hold on;
% plot(t_L, norm_L, 'r', 'LineWidth', 5);
% plot(t_S, norm_S, 'b', 'LineWidth', 5);
% % plot(t_D, M*mu_D, 'k--', 'LineWidth', 3);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$|X(t)|+\|u(t)\|_{\infty}$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]); ylim([y_norm_min, y_norm_max]);
% % legend({'$\mu(t)$', '$\mu = 6$', '$\mu = 0.01$', '$M\mu(t)$'}, ...
% %        'Interpreter', 'latex', 'FontSize', 20, 'Location', 'northeast');
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'normfix.eps', 'ContentType', 'vector');

% %% -----------------------------------------------------------------------
% %% FIGURE 5 -- State evolution: predictor-free (Liberzon)
% %% -----------------------------------------------------------------------
% idx_Lib         = find(t_Lib <= t_disp);
% idx_mesh_Lib    = find(t_Lib <= t_mesh_max);
% idx_sub_mesh_Lib = idx_mesh_Lib(1:tstep:end);
% [Xm_Lib, Tm_Lib] = meshgrid(x(1:pstep:end), t_Lib(idx_sub_mesh_Lib));
%
% figure;
% subplot(2,2,1);
% plot(t_Lib(idx_Lib), Y1_Lib(idx_Lib), 'm', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_X1_min); ylim([y_X1_min, y_X1_max]); end
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,2);
% plot(t_Lib(idx_Lib), Y2_Lib(idx_Lib), 'm', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_X2_min); ylim([y_X2_min, y_X2_max]); end
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,[3,4]);
% mesh(Xm_Lib, Tm_Lib, Y3_Lib(idx_sub_mesh_Lib, 1:pstep:end), ...
%      'LineWidth', 1, 'edgecolor', 'black');
% view(83, 10); hold on;
% plot3(L*ones(size(t_Lib(idx_mesh_Lib))), t_Lib(idx_mesh_Lib), ...
%       Y3_Lib(idx_mesh_Lib,end), 'r', 'LineWidth', 4);
% xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
% zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'statelib.eps', 'ContentType', 'vector');

% %% -----------------------------------------------------------------------
% %% FIGURE 6 -- Norm: predictor-free (with zoom inset)
% %% -----------------------------------------------------------------------
% idx_Lib2 = find(t_Lib <= t_disp);
% figure;
% ax_main = axes;
% plot(ax_main, t_Lib(idx_Lib2), norm_Lib(idx_Lib2), 'm', 'LineWidth', 5); hold on;
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$|X(t)|+\|u(t)\|_{\infty}$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim(ax_main, [t_min, t_max]); ylim(ax_main, [y_norm_min, y_norm_max]);
% set(ax_main, 'FontSize', 30); grid on; style_grid(ax_main);
% 
% % Zoom inset: magnified view of tail to show non-convergence to zero
% t_zoom_start = 15;   % adjust to taste
% t_zoom_end   = Ts;
% idx_zoom     = find(t_Lib >= t_zoom_start & t_Lib <= t_zoom_end);
% 
% tail_min   = min(norm_Lib(idx_zoom));
% tail_max   = max(norm_Lib(idx_zoom));
% y_pad      = (tail_max - tail_min + 0.1);
% y_rect_min = max(0, tail_min - y_pad);
% y_rect_max = tail_max + y_pad;
% 
% rectangle('Position', [t_zoom_start, y_rect_min, ...
%            t_zoom_end - t_zoom_start, y_rect_max - y_rect_min], ...
%            'EdgeColor', 'k', 'LineWidth', 2, 'LineStyle', '--');
% 
% ax_inset = axes('Position', [0.30, 0.35, 0.38, 0.32]);
% plot(ax_inset, t_Lib(idx_zoom), norm_Lib(idx_zoom), 'm', 'LineWidth', 4);
% set(ax_inset, 'FontSize', 20); grid on; style_grid(ax_inset);
% xlim(ax_inset, [t_zoom_start, t_zoom_end]);
% ylim(ax_inset, [y_rect_min, y_rect_max]);
% xlabel(ax_inset, '$t$', 'Interpreter', 'latex', 'FontSize', 22);
% exportgraphics(gcf, 'normlib.eps', 'ContentType', 'vector');

%% =======================================================================
%% LOCAL FUNCTIONS
%% =======================================================================
% -------------------------------------------------------------------------
% run_sim -- Simulate the ODE-PDE system
%
%   mu_init : fixed mu value (used when mode='fixed')
%   mode    : 'fixed'    -- constant mu = mu_init, with predictor
%             'dynamic'  -- zoom-scheduled mu(t), with predictor
%             'liberzon' -- zoom-scheduled mu(t), NO predictor
%                          U = kappa( q_{mu}(X) )
%
%   Returns:
%     tout     -- time vector       (Nt x 1)
%     norm_tot -- |X| + ||u||_inf  (Nt x 1)
%     Y1, Y2   -- ODE states       (Nt x 1)
%     Y3       -- PDE state        (Nt x Nx)
%     mu_vals  -- mu(t) history    (Nt x 1)  [NaN at t=0]
% -------------------------------------------------------------------------
function [tout, norm_tot, Y1out, Y2out, Y3out, mu_vals] = ...
        run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
                mu_init, mode, mu0, Omega, t0, T, tau, t_f, D, L)

    global U

    Y1out      = zeros(Nt, 1);
    Y2out      = zeros(Nt, 1);
    Y3out      = zeros(Nt, Nx);
    tout       = zeros(Nt, 1);
    mu_vals    = zeros(Nt, 1);
    mu_vals(1) = NaN;

    % Initial conditions: X1(0)=3, X2(0)=2, u(0,x)=1
    Y = init_cond(x);
    Y1out(1)   = Y(1,1);
    Y2out(1)   = Y(2,1);
    Y3out(1,:) = Y(3,:);
    U = 0;

    sol = setup(1, @pde_rhs, 0, x, Y, 'LxF', [], @bc_fun);

    for m = 2:Nt
        sol = hpde(sol, howfar, timestep);
        t_y = sol.t;
        Y   = sol.u;

        % Zoom parameter
        if strcmp(mode, 'fixed')
            mu_t = mu_init;
        else   % 'dynamic' or 'liberzon': both use zoom scheduling
            mu_t = zoom_mu(t_y, mu0, Omega, t0, T, t_f, tau);
        end

        % Control law
        if strcmp(mode, 'liberzon')
            % No predictor: U = kappa( q_{mu}(X) )
            qX1 = mu_t * quantizer(Y(1,1), mu_t, M, Delta);
            qX2 = mu_t * quantizer(Y(2,1), mu_t, M, Delta);
            U   = -qX1 - (2+D)*qX2 - (1/3)*qX2^3;
        else
            % With predictor integral: int_0^D (2+D-x)*u(x,t) dx
            IntTerm = trapz(x, (2 + D - x) .* Y(3,:));
            q1 = quantizer(Y(1,1), mu_t, M, Delta);
            q2 = quantizer(Y(2,1), mu_t, M, Delta);
            U  = -mu_t*q1 - (2+D)*mu_t*q2 - (1/3)*mu_t*q2^3 - IntTerm;
        end

        mu_vals(m) = mu_t;
        tout(m)    = t_y;
        Y1out(m)   = Y(1,1);
        Y2out(m)   = Y(2,1);
        Y3out(m,:) = Y(3,:);
    end

    norm_X   = sqrt(Y1out.^2 + Y2out.^2);
    norm_tot = norm_X + max(abs(Y3out), [], 2);
end

% -------------------------------------------------------------------------
% init_cond -- Initial conditions: X1(0)=3, X2(0)=2, u(0,x)=1
% -------------------------------------------------------------------------
function Y = init_cond(x)
    Y(1,:) = 0*x + 3;
    Y(2,:) = 0*x + 2;
    Y(3,:) = 0*x + 1;
end

% -------------------------------------------------------------------------
% pde_rhs -- ODE-PDE right-hand side
% -------------------------------------------------------------------------
function Y_t = pde_rhs(~, ~, Y, Y_x)
    Y_t(1,:) = Y(2,:) - Y(2,:).^2 .* Y(3,1);  % X1_dot
    Y_t(2,:) = Y(3,1);                          % X2_dot
    Y_t(3,:) = Y_x(3,:);                        % u_t = u_x (transport)
end

% -------------------------------------------------------------------------
% bc_fun -- Boundary conditions: u(D,t) = U(t)
% -------------------------------------------------------------------------
function [YL, YR] = bc_fun(~, YLex, YRex)
    global U
    YL(1) = YLex(1);  YR(1) = YRex(1);
    YL(2) = YLex(2);  YR(2) = YRex(2);
    YL(3) = YLex(3);  YR(3) = U;
end

% -------------------------------------------------------------------------
% zoom_mu -- Piecewise-constant geometric zoom scheduling
%   mu(t) = mu0 * Omega^(i-1)  on  [t0+(i-1)*T, t0+i*T)
% -------------------------------------------------------------------------
function mu_t = zoom_mu(t, mu0, Omega, t0, T, t_f, tau)
    if t <= t0
        mu_t = mu0;
    elseif t <= t0 + T
        mu_t = zoom_mu(t0, mu0, Omega, t0, T, t_f, tau);
    else
        i  = 2;
        ok = (t0+(i-1)*T < t) && (t <= t0+i*T);
        while ~ok && i <= floor((t_f-t0)/T)
            i  = i + 1;
            ok = (t0+(i-1)*T < t) && (t <= t0+i*T);
        end
        mu_t = Omega * zoom_mu(t0+(i-1)*T, mu0, Omega, t0, T, t_f, tau);
    end
end

% -------------------------------------------------------------------------
% quantizer -- Uniform mid-tread quantizer, saturated at +-M
% -------------------------------------------------------------------------
function qv = quantizer(u, mu_t, M, Delta)
    if     u/mu_t >=  M;  qv =  M;
    elseif u/mu_t <= -M;  qv = -M;
    else;  qv = Delta * floor(u/(Delta*mu_t) + 0.5);
    end
end

% -------------------------------------------------------------------------
% style_grid -- Transparent grid (consistent visual style)
% -------------------------------------------------------------------------
function style_grid(ax)
    ax.GridLineStyle = '-';
    ax.GridColor     = [0, 0, 0];
    ax.GridAlpha     = 0;
    ax.LineWidth     = 1;
end