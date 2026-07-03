function dsp_result_window(parent_fig, b, a, Fs)
    h.fig = dsp_new_window("Detailed Filter Analysis");
    set(h.fig, "CloseRequestFcn", @cb_back_wrapper);

    % BACK button
    uicontrol(h.fig, "Style", "pushbutton", ...
              "String", "< BACK", ...
              "Units", "normalized", ...
              "Position", [0.02, 0.955, 0.10, 0.038], ...
              "Callback", @cb_back_wrapper);

    % Frequency axis unit toggle (shares its state with the main screen)
    [~, freq_lbl] = dsp_freq_axis_hz();
    h.btn_FreqAxis = uicontrol(h.fig, "Style", "pushbutton", ...
              "String", freq_lbl, ...
              "Units", "normalized", ...
              "Position", [0.76, 0.955, 0.21, 0.038], ...
              "TooltipString", ["Toggle the frequency axis between " ...
                                "normalized units (0 to pi rad/sample) " ...
                                "and absolute frequency (0 to Fs/2 Hz)"], ...
              "Callback", @cb_freqaxis_wrapper);

    % Shared data
    [H, w] = freqz(b, a, 1024);
    wn     = w / pi;   % normalized frequency (×π rad/sample)
    stab   = dsp_check_stability(b, a);

    % Colour used for both the max-radius circle and the stability label
    if stab.stable
        stab_color = [0.13, 0.55, 0.13];
    else
        stab_color = [0.85, 0.15, 0.15];
    end

    % -------------------------------------------------------
    % Row 1, Left: Pole-Zero Diagram
    % -------------------------------------------------------
    h.ax_pz = axes("Units", "normalized", "Position", [0.05, 0.68, 0.40, 0.25]);
    zeros_z = roots(b);
    poles_z = roots(a);
    theta   = linspace(0, 2*pi, 256);

    plot(cos(theta), sin(theta), "k--", "LineWidth", 0.8); hold on;
    plot(real(zeros_z), imag(zeros_z), "bo", "MarkerSize", 9, "LineWidth", 2);

    safe = poles_z(stab.radii < 0.95);
    warn = poles_z(stab.radii >= 0.95 & stab.radii < 1 - 1e-10);
    crit = poles_z(stab.radii >= 1 - 1e-10);

    leg_items = {"Unit Circle", "Zeros"};
    if ~isempty(safe)
        plot(real(safe), imag(safe), "x", "MarkerSize", 9, "LineWidth", 2, "Color", [0.13, 0.55, 0.13]);
        leg_items{end+1} = "Poles (safe)";
    end
    if ~isempty(warn)
        plot(real(warn), imag(warn), "x", "MarkerSize", 10, "LineWidth", 2.5, "Color", [0.93, 0.69, 0.13]);
        leg_items{end+1} = "Poles (near boundary)";
    end
    if ~isempty(crit)
        plot(real(crit), imag(crit), "x", "MarkerSize", 11, "LineWidth", 2.5, "Color", [0.85, 0.15, 0.15]);
        leg_items{end+1} = "Poles (unstable)";
    end

    if stab.max_radius > 0
        r = stab.max_radius;
        plot(r*cos(theta), r*sin(theta), ":", "LineWidth", 1.2, "Color", stab_color);
        leg_items{end+1} = sprintf("Max radius = %.3f", r);
    end

    hold off;
    axis equal; grid on;
    title("Pole-Zero Diagram");
    xlabel("Real Part");
    ylabel("Imaginary Part");
    legend(leg_items{:}, "location", "northeast");

    % -------------------------------------------------------
    % Row 1, Right: Phase Response
    % -------------------------------------------------------
    h.ax_phase = axes("Units", "normalized", "Position", [0.55, 0.68, 0.42, 0.25]);
    plot(wn, unwrap(angle(H)) * (180 / pi), "LineWidth", 2, "Color", [0.85, 0.33, 0.10]);
    title("Phase Response");
    dsp_freq_xticks(h.ax_phase, Fs);
    ylabel("Phase (degrees)");
    grid on;
    xlim([0, 1]);

    % -------------------------------------------------------
    % Row 2, Left: Group Delay
    % -------------------------------------------------------
    h.ax_gd = axes("Units", "normalized", "Position", [0.05, 0.37, 0.42, 0.25]);
    ws = warning("off", "all");
    [gd, w_gd] = grpdelay(b, a, 1024);
    warning(ws);
    plot(w_gd / pi, gd, "LineWidth", 2, "Color", [0.13, 0.55, 0.13]);
    title("Group Delay");
    dsp_freq_xticks(h.ax_gd, Fs);
    ylabel("Delay (samples)");
    grid on;
    xlim([0, 1]);

    % -------------------------------------------------------
    % Row 2, Right: Impulse Response
    % -------------------------------------------------------
    h.ax_imp = axes("Units", "normalized", "Position", [0.55, 0.37, 0.42, 0.25]);
    [h_imp, t_imp] = impz(b, a, [], Fs);
    stem(t_imp, h_imp, "filled", "MarkerSize", 3, "Color", [0.00, 0.45, 0.74]);
    title("Impulse Response");
    xlabel("Time (s)");
    ylabel("Amplitude");
    grid on;

    % -------------------------------------------------------
    % Row 3, Left: Step Response
    % -------------------------------------------------------
    h.ax_step = axes("Units", "normalized", "Position", [0.05, 0.06, 0.42, 0.25]);
    n_pts = length(h_imp);
    step_resp = filter(b, a, ones(n_pts, 1));
    t_step = (0:n_pts-1)' / Fs;
    plot(t_step, step_resp, "LineWidth", 2, "Color", [0.64, 0.08, 0.18]);
    title("Step Response");
    xlabel("Time (s)");
    ylabel("Amplitude");
    grid on;

    % -------------------------------------------------------
    % Row 3, Right: Filter Metrics + Coefficients
    % -------------------------------------------------------
    h.ax_info = axes("Units", "normalized", "Position", [0.55, 0.17, 0.42, 0.14]);
    axis off;
    title("Filter Metrics");

    mag_db     = 20 * log10(abs(H));
    max_db     = max(mag_db);
    f3db_str   = dsp_compute_f3db(H, wn);
    dc_gain_db = 20 * log10(abs(H(1)));
    N_order    = length(a) - 1;

    metrics = sprintf([ ...
        "Order: %d    Max Gain: %.2f dB    DC Gain: %.2f dB\n\n" ...
        "-3 dB Crossing(s): %s\n\n" ...
        "Max Pole Radius: %.6f    Stability Margin: %.6f"], ...
        N_order, max_db, dc_gain_db, f3db_str, stab.max_radius, stab.margin);

    text(0.02, 0.85, metrics, ...
         "Units", "normalized", ...
         "VerticalAlignment", "top");

    text(0.02, 0.15, sprintf("Stability: %s", stab.status), ...
         "Units", "normalized", ...
         "VerticalAlignment", "top", ...
         "FontSize", 11, "FontWeight", "bold", ...
         "Color", stab_color);

    % Coefficient display
    uicontrol(h.fig, "Style", "text", ...
              "String", "Filter Coefficients:", ...
              "Units", "normalized", ...
              "Position", [0.55, 0.135, 0.25, 0.025], ...
              "HorizontalAlignment", "left", ...
              "FontWeight", "bold");

    coeff_str = format_coeffs(b, a);

    uicontrol(h.fig, "Style", "edit", ...
              "String", coeff_str, ...
              "Max", 2, ...
              "Enable", "inactive", ...
              "HorizontalAlignment", "left", ...
              "Units", "normalized", ...
              "Position", [0.55, 0.02, 0.44, 0.11]);

    guidata(h.fig, h);

    function cb_back_wrapper(~, ~)
        delete(h.fig);
        if ishandle(parent_fig)
            set(parent_fig, "Visible", "on");
        end
    end

    function cb_freqaxis_wrapper(src, ~)
        hh = guidata(src);
        [~, lbl] = dsp_freq_axis_hz(~dsp_freq_axis_hz());
        set(hh.btn_FreqAxis, "String", lbl);
        dsp_freq_xticks(hh.ax_phase, Fs);
        dsp_freq_xticks(hh.ax_gd,    Fs);
        % Keep the (hidden) main screen in step so its plots and toggle
        % button are already correct when the user goes BACK.
        if ishandle(parent_fig)
            ph = guidata(parent_fig);
            if isfield(ph, "btn_FreqAxis")
                pFs = str2double(get(ph.edit_Fs, "string"));
                dsp_freq_xticks(ph.ax_mag,   pFs);
                dsp_freq_xticks(ph.ax_phase, pFs);
                set(ph.btn_FreqAxis, "String", lbl);
            end
        end
    end
end

% -------------------------------------------------------
% Helper: format b and a coefficient arrays as a string
% -------------------------------------------------------
function str = format_coeffs(b, a)
    str = ["Numerator  b:  ", fmt_row(b), "\n\n", ...
           "Denominator a:  ", fmt_row(a)];
end

function s = fmt_row(v)
    s = "";
    per_line = 6;
    for k = 1:numel(v)
        s = [s, sprintf("%12.6f", v(k))];
        if k < numel(v)
            if mod(k, per_line) == 0
                s = [s, "\n               "];
            end
        end
    end
end
