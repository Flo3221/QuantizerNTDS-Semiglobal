% InputQuantization.m
% Predictor-feedback control with INPUT quantization:
%   fixed mu (large & small) vs. dynamic mu vs. predictor-free.
%
% System:  X1_dot = X2 - X2^2 * u(0,t)
%          X2_dot = u(0,t)
%          u_t    = u_x,   x in [0,D],   u(D,t) = U(t)
%
% Nominal law:  Unom = -X1 - (2+D)*X2 - (1/3)*X2^3 - IntTerm
%   where       IntTerm = integral_0^D (2+D-x)*u(x,t) dx
%
% Control (input quantization):
%   With predictor:    U = mu * q( Unom / mu )
%   Without predictor: U = mu * q( kappa(X) / mu ),
%                      kappa(X) = -X1-(2+D)*X2-(1/3)*X2^3
%
% Four cases:
%   LARGE   : mu fixed at 200        --> red   'r'
%   SMALL   : mu fixed at 0.01       --> blue  'b'
%   DYNAMIC : mu(t) zoom-scheduling  --> black 'k'
%   NOPRED  : dynamic mu, no pred.   --> magenta 'm'
close all; clear all; clc
global U

%% -----------------------------------------------------------------------
%% PARAMETERS
%% -----------------------------------------------------------------------
D   = 1;      % PDE domain length / transport delay
L   = D;      % right spatial boundary
Ts  = 50;     % simulation duration [s]
Nx  = 151;    % spatial grid points
Nt  = 500;    % time steps

x        = linspace(0, L, Nx);
dx       = x(2) - x(1);
howfar   = Ts / Nt;       % output time step for hpde
timestep = 0.5 * dx;      % CFL inner time step

M     = 2;        % quantizer saturation level
Delta = M / 20;   % quantizer resolution (input quantization: M/20)

% Zoom scheduling parameters (dynamic case)
mu0   = 5;     % initial zoom value
Omega = 0.63;  % contraction ratio
t0    = 0;     % zoom activation time
T     = 2;     % switching period
tau   = 1;     % dwell time
t_f   = Ts;    % final time (for zoom_mu)

% Fixed mu values
mu_large = 200;
mu_small = 0.01;

%% -----------------------------------------------------------------------
%% AXIS LIMITS -- change these to adjust all figures at once
%% -----------------------------------------------------------------------
t_min   = 0;    % x-axis (time) lower limit
t_max   = 20;   % x-axis (time) upper limit
y_norm_min = 0;   % y-axis lower limit for norm plots
y_norm_max = 50;  % y-axis upper limit for norm plots
y_X1_min   = [];  % y-axis for X1 plots ([] = auto)
y_X1_max   = [];
y_X2_min   = [];  % y-axis for X2 plots ([] = auto)
y_X2_max   = [];
y_U_min    = [];  % y-axis for U(t) plots ([] = auto)
y_U_max    = [];
y_Unom_min = [];  % y-axis for U_nom(t) plots ([] = auto)
y_Unom_max = [];
%% -----------------------------------------------------------------------
%% RUN FOUR CASES
%% -----------------------------------------------------------------------
fprintf('Running LARGE fixed mu = %.1f ...\n', mu_large);
[t_L, norm_L, Y1_L, Y2_L, Y3_L, ~, ~, ~] = ...
    run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
            mu_large, 'fixed', mu0, Omega, t0, T, tau, t_f, D, L);

fprintf('Running SMALL fixed mu = %.2f ...\n', mu_small);
[t_S, norm_S, Y1_S, Y2_S, Y3_S, ~, ~, ~] = ...
    run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
            mu_small, 'fixed', mu0, Omega, t0, T, tau, t_f, D, L);

fprintf('Running DYNAMIC mu ...\n');
[t_D, norm_D, Y1_D, Y2_D, Y3_D, mu_D, ~, ~] = ...
    run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
            mu0, 'dynamic', mu0, Omega, t0, T, tau, t_f, D, L);

fprintf('Running PREDICTOR-FREE (input quant., no predictor) ...\n');
[t_Lib, norm_Lib, Y1_Lib, Y2_Lib, Y3_Lib, mu_Lib, ~, ~] = ...
    run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
            mu0, 'nopred', mu0, Omega, t0, T, tau, t_f, D, L);

fprintf('Done. Generating figures...\n');

%% -----------------------------------------------------------------------
%% Mesh grid and time cutoff for ALL figures
%% -----------------------------------------------------------------------
t_disp  = Ts;
idx     = find(t_L <= t_disp);
pstep   = 3; tstep = 3;
idx_sub = idx(1:tstep:end);
[Xm, Tm] = meshgrid(x(1:pstep:end), t_L(idx_sub));

% %% -----------------------------------------------------------------------
% %% FIGURE 1 -- State evolution: fixed mu large
% %% -----------------------------------------------------------------------
% figure;
% subplot(2,2,1);
% plot(t_L(idx), Y1_L(idx), 'r', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,2);
% plot(t_L(idx), Y2_L(idx), 'r', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,[3,4]);
% mesh(Xm, Tm, Y3_L(idx_sub, 1:pstep:end), 'LineWidth', 1, 'edgecolor', 'black');
% view(83, 10); hold on;
% plot3(L*ones(size(t_L(idx))), t_L(idx), Y3_L(idx,end), 'r', 'LineWidth', 4);
% xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
% zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'statefix_largeiq.eps', 'ContentType', 'vector');

% %% -----------------------------------------------------------------------
% %% FIGURE 2 -- State evolution: fixed mu small
% %% -----------------------------------------------------------------------
% figure;
% subplot(2,2,1);
% plot(t_S(idx), Y1_S(idx), 'b', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,2);
% plot(t_S(idx), Y2_S(idx), 'b', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,[3,4]);
% mesh(Xm, Tm, Y3_S(idx_sub, 1:pstep:end), 'LineWidth', 1, 'edgecolor', 'black');
% view(83, 10); hold on;
% plot3(L*ones(size(t_S(idx))), t_S(idx), Y3_S(idx,end), 'r', 'LineWidth', 4);
% xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
% zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'statefix_smalliq.eps', 'ContentType', 'vector');
% 
% %% -----------------------------------------------------------------------
% %% FIGURE 3 -- State evolution: dynamic mu(t)
% %% -----------------------------------------------------------------------
% figure;
% subplot(2,2,1);
% plot(t_D(idx), Y1_D(idx), 'k', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_X1_min); ylim([y_X1_min, y_X1_max]); end
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% 
% subplot(2,2,2);
% plot(t_D(idx), Y2_D(idx), 'k', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_X2_min); ylim([y_X2_min, y_X2_max]); end
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% 
% subplot(2,2,[3,4]);
% mesh(Xm, Tm, Y3_D(idx_sub, 1:pstep:end), 'LineWidth', 1, 'edgecolor', 'black');
% view(83, 10); hold on;
% plot3(L*ones(size(t_D(idx))), t_D(idx), Y3_D(idx,end), 'r', 'LineWidth', 4);
% xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
% zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'statedyniq.eps', 'ContentType', 'vector');
%% -----------------------------------------------------------------------
%% FIGURE 3 -- State evolution: dynamic mu(t)
%% -----------------------------------------------------------------------
t_mesh_max = 20;   % <-- change this to adjust the u(x,t) mesh time horizon

idx_mesh     = find(t_D <= t_mesh_max);
idx_sub_mesh = idx_mesh(1:tstep:end);
[Xm_D, Tm_D] = meshgrid(x(1:pstep:end), t_D(idx_sub_mesh));

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
mesh(Xm_D, Tm_D, Y3_D(idx_sub_mesh, 1:pstep:end), ...
     'LineWidth', 1, 'edgecolor', 'black');
view(83, 10); hold on;
plot3(L*ones(size(t_D(idx_mesh))), t_D(idx_mesh), ...
      Y3_D(idx_mesh,end), 'r', 'LineWidth', 4);
xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
set(gca, 'FontSize', 30); grid on; style_grid(gca);
exportgraphics(gcf, 'statedyniq.eps', 'ContentType', 'vector');
%% -----------------------------------------------------------------------
%% FIGURE 4 -- Norms: DYNAMIC + LARGE + SMALL + PREDICTOR-FREE
%% -----------------------------------------------------------------------
idx_D  = find(t_D   <= t_disp);
idx_L2 = find(t_L   <= t_disp);
idx_S2 = find(t_S   <= t_disp);
idx_Lib2 = find(t_Lib <= t_disp);
figure;
plot(t_D(idx_D),     norm_D(idx_D),     'k', 'LineWidth', 5); hold on;
plot(t_L(idx_L2),    norm_L(idx_L2),    'r', 'LineWidth', 5);
plot(t_S(idx_S2),    norm_S(idx_S2),    'b', 'LineWidth', 5);
plot(t_Lib(idx_Lib2), norm_Lib(idx_Lib2), 'm', 'LineWidth', 5);
xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
ylabel('$|X(t)|+\|u(t)\|_{\infty}$', 'Interpreter', 'latex', 'FontSize', 30);
xlim([t_min, t_max]); ylim([y_norm_min, y_norm_max]);
% legend({'$\mu(t)$','$\mu=200$','$\mu=0.01$','No predictor'}, ...
%        'Interpreter','latex','FontSize',20,'Location','northeast');
set(gca, 'FontSize', 30); grid on; style_grid(gca);
exportgraphics(gcf, 'normiq.eps', 'ContentType', 'vector');

% %% -----------------------------------------------------------------------
% %% FIGURE 4 -- Norms: DYNAMIC + LARGE + SMALL
% %% -----------------------------------------------------------------------
% idx_D  = find(t_D  <= t_disp);
% idx_L2 = find(t_L  <= t_disp);
% idx_S2 = find(t_S  <= t_disp);
% figure;
% plot(t_D(idx_D),  norm_D(idx_D),  'k', 'LineWidth', 5); hold on;
% plot(t_L(idx_L2), norm_L(idx_L2), 'r', 'LineWidth', 5);
% plot(t_S(idx_S2), norm_S(idx_S2), 'b', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$|X(t)|+\|u(t)\|_{\infty}$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]); ylim([y_norm_min, y_norm_max]);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'normfixiq.eps', 'ContentType', 'vector');
% %% -----------------------------------------------------------------------
% %% FIGURE 5 -- State evolution: predictor-free
% %% -----------------------------------------------------------------------
% idx_Lib     = find(t_Lib <= t_disp);
% idx_Lib_sub = idx_Lib(1:tstep:end);
% [Xm_Lib, Tm_Lib] = meshgrid(x(1:pstep:end), t_Lib(idx_Lib_sub));
%
% figure;
% subplot(2,2,1);
% plot(t_Lib(idx_Lib), Y1_Lib(idx_Lib), 'm', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,2);
% plot(t_Lib(idx_Lib), Y2_Lib(idx_Lib), 'm', 'LineWidth', 5);
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
%
% subplot(2,2,[3,4]);
% mesh(Xm_Lib, Tm_Lib, Y3_Lib(idx_Lib_sub, 1:pstep:end), ...
%      'LineWidth', 1, 'edgecolor', 'black');
% view(83, 10); hold on;
% plot3(L*ones(size(t_Lib(idx_Lib))), t_Lib(idx_Lib), ...
%       Y3_Lib(idx_Lib,end), 'r', 'LineWidth', 4);
% xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
% zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'statelibiq.eps', 'ContentType', 'vector');
%% -----------------------------------------------------------------------
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
% exportgraphics(gcf, 'normlibiq.eps', 'ContentType', 'vector');

%% -----------------------------------------------------------------------
%% MULTI-MU SWEEP -- fixed large mu in {200, 100, 50, 20, 10}
%%   200->blue, 100->black, 50->red, 20->orange, 10->magenta
%% -----------------------------------------------------------------------
% mu_list = [200, 100, 50, 20, 10];
% clrs    = [0   0   1 ;   % blue    (mu=200)
%            0   0   0 ;   % black   (mu=100)
%            1   0   0 ;   % red     (mu=50)
%            1  0.5  0 ;   % orange  (mu=20)
%            1   0   1 ];  % magenta (mu=10)
% leg_str = {'$\mu=200$','$\mu=100$','$\mu=50$','$\mu=20$','$\mu=10$'};
% 
% n_mu    = numel(mu_list);
% t_mm    = cell(n_mu,1);
% norm_mm = cell(n_mu,1);
% U_mm    = cell(n_mu,1);
% Unom_mm = cell(n_mu,1);
% Y1_mm   = cell(n_mu,1);
% Y2_mm   = cell(n_mu,1);
% Y3_mm   = cell(n_mu,1);
% 
% for k = 1:n_mu
%     mu_k = mu_list(k);
%     fprintf('Running fixed mu = %g ...\n', mu_k);
%     [t_mm{k}, norm_mm{k}, Y1_mm{k}, Y2_mm{k}, Y3_mm{k}, ~, U_mm{k}, Unom_mm{k}] = ...
%         run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
%                 mu_k, 'fixed', mu0, Omega, t0, T, tau, t_f, D, L);
% end
% fprintf('Done. Generating multi-mu figures...\n');
% 
% %% -----------------------------------------------------------------------
%% FIGURE 7 -- Norm for multi-mu sweep
%% -----------------------------------------------------------------------
% figure;
% for k = 1:n_mu
%     plot(t_mm{k}, norm_mm{k}, 'Color', clrs(k,:), 'LineWidth', 4);
%     hold on;
% end
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$|X(t)|+\|u(t)\|_{\infty}$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]); ylim([y_norm_min, y_norm_max]);
% legend(leg_str, 'Interpreter', 'latex', 'FontSize', 20, 'Location', 'northeast');
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'norm_multimu_iq.eps', 'ContentType', 'vector');
%
% %% -----------------------------------------------------------------------
% %% FIGURE 8 -- Applied control U(t) for multi-mu sweep
% %% -----------------------------------------------------------------------
% figure;
% for k = 1:n_mu
%     plot(t_mm{k}, U_mm{k}, 'Color', clrs(k,:), 'LineWidth', 4);
%     hold on;
% end
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$U(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_U_min); ylim([y_U_min, y_U_max]); end
% legend(leg_str, 'Interpreter', 'latex', 'FontSize', 20, 'Location', 'northeast');
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'U_multimu_iq.eps', 'ContentType', 'vector');
% 
% %% -----------------------------------------------------------------------
% %% FIGURE 9 -- Nominal U_nom(t) for multi-mu sweep
% %% -----------------------------------------------------------------------
% figure;
% for k = 1:n_mu
%     plot(t_mm{k}, Unom_mm{k}, 'Color', clrs(k,:), 'LineWidth', 4);
%     hold on;
% end
% xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
% ylabel('$U_{\mathrm{nom}}(t)$', 'Interpreter', 'latex', 'FontSize', 30);
% xlim([t_min, t_max]);
% if ~isempty(y_Unom_min); ylim([y_Unom_min, y_Unom_max]); end
% legend(leg_str, 'Interpreter', 'latex', 'FontSize', 20, 'Location', 'northeast');
% set(gca, 'FontSize', 30); grid on; style_grid(gca);
% exportgraphics(gcf, 'Unom_multimu_iq.eps', 'ContentType', 'vector');
% 
% %% -----------------------------------------------------------------------
% %% FIGURES 10-14 -- State evolution (X1, X2, u) subplot for each fixed mu
% %% -----------------------------------------------------------------------
% for k = 1:n_mu
%     idx_k     = find(t_mm{k} <= t_disp);
%     idx_sub_k = idx_k(1:tstep:end);
%     [Xm_k, Tm_k] = meshgrid(x(1:pstep:end), t_mm{k}(idx_sub_k));
% 
%     figure;
%     subplot(2,2,1);
%     plot(t_mm{k}(idx_k), Y1_mm{k}(idx_k), 'Color', clrs(k,:), 'LineWidth', 5);
%     xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
%     ylabel('$X_1(t)$', 'Interpreter', 'latex', 'FontSize', 30);
%     xlim([t_min, t_max]);
%     if ~isempty(y_X1_min); ylim([y_X1_min, y_X1_max]); end
%     legend(leg_str{k}, 'Interpreter', 'latex', 'FontSize', 20, ...
%            'Location', 'northeast');
%     set(gca, 'FontSize', 30); grid on; style_grid(gca);
% 
%     subplot(2,2,2);
%     plot(t_mm{k}(idx_k), Y2_mm{k}(idx_k), 'Color', clrs(k,:), 'LineWidth', 5);
%     xlabel('$t$', 'Interpreter', 'latex', 'FontSize', 30);
%     ylabel('$X_2(t)$', 'Interpreter', 'latex', 'FontSize', 30);
%     xlim([t_min, t_max]);
%     if ~isempty(y_X2_min); ylim([y_X2_min, y_X2_max]); end
%     legend(leg_str{k}, 'Interpreter', 'latex', 'FontSize', 20, ...
%            'Location', 'northeast');
%     set(gca, 'FontSize', 30); grid on; style_grid(gca);
% 
%     subplot(2,2,[3,4]);
%     mesh(Xm_k, Tm_k, Y3_mm{k}(idx_sub_k, 1:pstep:end), ...
%          'LineWidth', 1, 'edgecolor', 'black');
%     view(83, 10); hold on;
%     plot3(L*ones(size(t_mm{k}(idx_k))), t_mm{k}(idx_k), ...
%           Y3_mm{k}(idx_k, end), 'Color', clrs(k,:), 'LineWidth', 4);
%     xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 30);
%     ylabel('$t$',  'Interpreter', 'latex', 'FontSize', 30);
%     zlabel('$u(x,t)$', 'Interpreter', 'latex', 'FontSize', 30);
%     set(gca, 'FontSize', 30); grid on; style_grid(gca);
% 
%     exportgraphics(gcf, sprintf('state_mu%g_iq.eps', mu_list(k)), ...
%                    'ContentType', 'vector');
% end
%
%% =======================================================================
%% LOCAL FUNCTIONS
%% =======================================================================

function [tout, norm_tot, Y1out, Y2out, Y3out, mu_vals, Uout, Unom_out] = ...
        run_sim(x, Nx, Nt, howfar, timestep, M, Delta, ...
                mu_init, mode, mu0, Omega, t0, T, tau, t_f, D, L)

    global U

    Y1out      = zeros(Nt, 1);
    Y2out      = zeros(Nt, 1);
    Y3out      = zeros(Nt, Nx);
    tout       = zeros(Nt, 1);
    mu_vals    = zeros(Nt, 1);
    Uout       = zeros(Nt, 1);
    Unom_out   = zeros(Nt, 1);
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
        else   % 'dynamic' or 'nopred': both use zoom scheduling
            mu_t = zoom_mu(t_y, mu0, Omega, t0, T, t_f, tau);
        end

        % Control law (input quantization)
        if strcmp(mode, 'nopred')
            % No predictor: quantize kappa(X) directly
            kappa_val    = -Y(1,1) - (2+D)*Y(2,1) - (1/3)*Y(2,1)^3;
            Unom_out(m)  = kappa_val;
            U            = mu_t * quantizer(kappa_val, mu_t, M, Delta);
        else
            % With predictor integral: int_0^D (2+D-x)*u(x,t) dx
            IntTerm      = trapz(x, (2 + D - x) .* Y(3,:));
            Unom         = -Y(1,1) - (2+D)*Y(2,1) - (1/3)*Y(2,1)^3 - IntTerm;
            Unom_out(m)  = Unom;
            U            = mu_t * quantizer(Unom, mu_t, M, Delta);
        end

        Uout(m)    = U;
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