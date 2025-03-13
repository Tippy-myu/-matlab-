clc, clear
% 定义符号变量
syms t V;
Z0 = 1000;
X0 = 100;
% 定义符号表达式
E = atan(Z0 / sqrt(X0^2 + V^2 * t^2));
dEdt = diff(E, t);
d2Edt2 = diff(dEdt, t);
% 将符号表达式转换为数值函数
E_func = matlabFunction(E, 'Vars', [t, V]);
dEdt_func = matlabFunction(dEdt, 'Vars', [t, V]);
d2Edt2_func = matlabFunction(d2Edt2, 'Vars', [t, V]);
% 定义 t 的范围
t_values = linspace(-10, 10, 1000); % 根据需要调整范围
% 创建交互式窗口
fig = uifigure('Name', '频谱特性分析', 'Position', [100 100 800 600]);
% 添加滑动条用于调整 V
V_slider = uislider(fig, 'Position', [100 550 600 3], 'Limits', [100 5000], 'Value', 1000);
V_label = uilabel(fig, 'Position', [100 570 600 20], 'Text', sprintf('V = %.2f', V_slider.Value));
% 添加绘图区域
ax1 = uiaxes(fig, 'Position', [50 350 700 150]);
ax2 = uiaxes(fig, 'Position', [50 200 700 150]);
ax3 = uiaxes(fig, 'Position', [50 50 700 150]);
% 更新函数
updatePlot = @() updatePlotFunction(V_slider.Value, t_values, E_func, dEdt_func, d2Edt2_func, ax1, ax2, ax3, V_label);
% 绑定滑动条回调函数
V_slider.ValueChangedFcn = @(src, event) updatePlot();
% 初始绘图
updatePlot();
% 更新绘图函数
function updatePlotFunction(V, t_values, E_func, dEdt_func, d2Edt2_func, ax1, ax2, ax3, V_label)
    % 计算函数值
    E_values = E_func(t_values, V);
    dEdt_values = dEdt_func(t_values, V);
    d2Edt2_values = d2Edt2_func(t_values, V);
    % 计算频谱特性
    Fs = 1 / (t_values(2) - t_values(1)); % 采样频率
    n = length(t_values);
    f = (-n/2:n/2-1) * (Fs / n);
    E_fft = abs(fftshift(fft(E_values)));
    dEdt_fft = abs(fftshift(fft(dEdt_values)));
    d2Edt2_fft = abs(fftshift(fft(d2Edt2_values)));
    % 更新绘图
    plot(ax1, f, E_fft, 'b', 'LineWidth', 1.5);
    title(ax1, 'E 的频谱特性');
    xlabel(ax1, '频率 (Hz)');
    ylabel(ax1, '幅度');
    grid(ax1, 'on');
    plot(ax2, f, dEdt_fft, 'r', 'LineWidth', 1.5);
    title(ax2, 'dEdt 的频谱特性');
    xlabel(ax2, '频率 (Hz)');
    ylabel(ax2, '幅度');
    grid(ax2, 'on');
    plot(ax3, f, d2Edt2_fft, 'g', 'LineWidth', 1.5);
    title(ax3, 'd2Edt2 的频谱特性');
    xlabel(ax3, '频率 (Hz)');
    ylabel(ax3, '幅度');
    grid(ax3, 'on');
    % 更新 V 的标签
    V_label.Text = sprintf('V = %.2f', V);
end
