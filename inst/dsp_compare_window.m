## -*- texinfo -*-
## @deftypefn {Function File} dsp_compare_window (@var{main_h})
## Open a comparison window that overlays the responses of two filters.
## Each filter can be sourced from the current design or loaded from a
## previously saved @file{.mat} file.
## @end deftypefn

function dsp_compare_window(main_h)
    type_names = {"Low Pass", "High Pass", "Band Pass", "Band Stop"};
    topo_names = {"Butterworth", "Chebyshev I", "Chebyshev II", "Elliptic"};

    col_a = [0.00, 0.45, 0.74];
    col_b = [0.85, 0.33, 0.10];

    filt_a = empty_filter();
    filt_b = empty_filter();

    % -------------------------------------------------------------------
    % Window (sized to match the main FDA Tool window)
    % -------------------------------------------------------------------
    c.fig = dsp_new_window("Filter Comparison");

    % -------------------------------------------------------------------
    % Filter A controls (left half of top bar)
    % -------------------------------------------------------------------
    uicontrol(c.fig, "Style", "text", "String", "Filter A", ...
              "Units", "normalized", "Position", [0.03, 0.94, 0.10, 0.03], ...
              "FontWeight", "bold", "FontSize", 11, ...
              "ForegroundColor", col_a, "HorizontalAlignment", "left");

    uicontrol(c.fig, "Style", "pushbutton", "String", "Use Current", ...
              "Units", "normalized", "Position", [0.14, 0.935, 0.15, 0.04], ...
              "Callback", @(~,~) set_current("a"));

    uicontrol(c.fig, "Style", "pushbutton", "String", "Load from File", ...
              "Units", "normalized", "Position", [0.30, 0.935, 0.15, 0.04], ...
              "Callback", @(~,~) set_from_file("a"));

    c.lbl_a = uicontrol(c.fig, "Style", "text", ...
              "String", "(no filter selected)", ...
              "Units", "normalized", "Position", [0.03, 0.90, 0.45, 0.03], ...
              "HorizontalAlignment", "left", "FontSize", 9, ...
              "ForegroundColor", [0.3, 0.3, 0.3]);

    % -------------------------------------------------------------------
    % Filter B controls (right half of top bar)
    % -------------------------------------------------------------------
    uicontrol(c.fig, "Style", "text", "String", "Filter B", ...
              "Units", "normalized", "Position", [0.53, 0.94, 0.10, 0.03], ...
              "FontWeight", "bold", "FontSize", 11, ...
              "ForegroundColor", col_b, "HorizontalAlignment", "left");

    uicontrol(c.fig, "Style", "pushbutton", "String", "Use Current", ...
              "Units", "normalized", "Position", [0.64, 0.935, 0.15, 0.04], ...
              "Callback", @(~,~) set_current("b"));

    uicontrol(c.fig, "Style", "pushbutton", "String", "Load from File", ...
              "Units", "normalized", "Position", [0.80, 0.935, 0.15, 0.04], ...
              "Callback", @(~,~) set_from_file("b"));

    c.lbl_b = uicontrol(c.fig, "Style", "text", ...
              "String", "(no filter selected)", ...
              "Units", "normalized", "Position", [0.53, 0.90, 0.45, 0.03], ...
              "HorizontalAlignment", "left", "FontSize", 9, ...
              "ForegroundColor", [0.3, 0.3, 0.3]);

    % -------------------------------------------------------------------
    % Separator line between A and B
    % -------------------------------------------------------------------
    uicontrol(c.fig, "Style", "text", "String", "", ...
              "Units", "normalized", "Position", [0.50, 0.90, 0.002, 0.07], ...
              "BackgroundColor", [0.7, 0.7, 0.7]);

    % -------------------------------------------------------------------
    % Plot axes (2x2 grid)
    % -------------------------------------------------------------------
    c.ax_mag = axes("Parent", c.fig, "Units", "normalized", ...
                    "Position", [0.07, 0.50, 0.40, 0.36]);
    title("Magnitude Response");
    dsp_freq_xticks();
    ylabel("Magnitude (dB)");
    grid on;

    c.ax_phase = axes("Parent", c.fig, "Units", "normalized", ...
                      "Position", [0.57, 0.50, 0.40, 0.36]);
    title("Phase Response");
    dsp_freq_xticks();
    ylabel("Phase (degrees)");
    grid on;

    c.ax_gd = axes("Parent", c.fig, "Units", "normalized", ...
                   "Position", [0.07, 0.07, 0.40, 0.36]);
    title("Group Delay");
    dsp_freq_xticks();
    ylabel("Delay (samples)");
    grid on;

    c.ax_metrics = axes("Parent", c.fig, "Units", "normalized", ...
                        "Position", [0.57, 0.07, 0.40, 0.36]);
    axis off; title("Comparison Metrics");

    % -------------------------------------------------------------------
    % Close button
    % -------------------------------------------------------------------
    uicontrol(c.fig, "Style", "pushbutton", "String", "Close", ...
              "Units", "normalized", "Position", [0.88, 0.015, 0.10, 0.04], ...
              "Callback", @(~,~) delete(c.fig));

    % ===================================================================
    % Callbacks
    % ===================================================================

    function set_current(slot)
        mh = guidata(main_h.fig);
        if ~isfield(mh, "last_b") || isempty(mh.last_b)
            errordlg("No filter designed in the main window yet.", "Compare");
            return;
        end
        f.b  = mh.last_b;
        f.a  = mh.last_a;
        f.Fs = str2double(get(mh.edit_Fs, "string"));
        ti   = get(mh.popup_Type, "value");
        to   = get(mh.popup_Topo, "value");
        N    = str2double(get(mh.edit_Order, "string"));
        f.label = sprintf("%s %s, Order %d, Fs=%.0f Hz", ...
                          topo_names{to}, type_names{ti}, N, f.Fs);
        apply_filter(slot, f);
    end

    function set_from_file(slot)
        [fname, fpath] = uigetfile("*.mat", "Load Filter Design");
        if isequal(fname, 0); return; end

        data = load(fullfile(fpath, fname));
        if ~isfield(data, "design")
            errordlg("Not a valid dsppack design file.", "Compare");
            return;
        end
        d = data.design;
        if isempty(d.b) || isempty(d.a)
            errordlg("Design file has no computed coefficients.", "Compare");
            return;
        end
        f.b  = d.b;
        f.a  = d.a;
        f.Fs = d.Fs;
        f.label = sprintf("%s %s, Order %d, Fs=%.0f Hz [%s]", ...
                          d.topo_name, d.type_name, d.N, d.Fs, fname);
        apply_filter(slot, f);
    end

    function apply_filter(slot, f)
        if strcmp(slot, "a")
            filt_a = f;
            set(c.lbl_a, "String", f.label);
        else
            filt_b = f;
            set(c.lbl_b, "String", f.label);
        end
        update_plots();
    end

    % ===================================================================
    % Plotting
    % ===================================================================

    function update_plots()
        has_a = ~isempty(filt_a.b);
        has_b = ~isempty(filt_b.b);
        if ~has_a && ~has_b; return; end

        % --- Magnitude ---
        axes(c.ax_mag); cla; hold on;
        if has_a
            [Ha, wa] = freqz(filt_a.b, filt_a.a, 1024);
            wna = wa / pi;
            plot(wna, 20*log10(abs(Ha) + eps), "LineWidth", 2, "Color", col_a, ...
                 "DisplayName", "Filter A");
        end
        if has_b
            [Hb, wb] = freqz(filt_b.b, filt_b.a, 1024);
            wnb = wb / pi;
            plot(wnb, 20*log10(abs(Hb) + eps), "LineWidth", 2, "Color", col_b, ...
                 "DisplayName", "Filter B");
        end
        hold off; grid on;
        title("Magnitude Response");
        dsp_freq_xticks();
        ylabel("Magnitude (dB)");
        legend("location", "southwest");
        xlim([0, 1]);

        % --- Phase ---
        axes(c.ax_phase); cla; hold on;
        if has_a
            plot(wna, unwrap(angle(Ha)) * (180/pi), "LineWidth", 2, ...
                 "Color", col_a, "DisplayName", "Filter A");
        end
        if has_b
            plot(wnb, unwrap(angle(Hb)) * (180/pi), "LineWidth", 2, ...
                 "Color", col_b, "DisplayName", "Filter B");
        end
        hold off; grid on;
        title("Phase Response");
        dsp_freq_xticks();
        ylabel("Phase (degrees)");
        legend("location", "southwest");
        xlim([0, 1]);

        % --- Group Delay ---
        axes(c.ax_gd); cla; hold on;
        ws = warning("off", "all");
        if has_a
            [gda, wgda] = grpdelay(filt_a.b, filt_a.a, 1024);
            plot(wgda / pi, gda, "LineWidth", 2, "Color", col_a, ...
                 "DisplayName", "Filter A");
        end
        if has_b
            [gdb, wgdb] = grpdelay(filt_b.b, filt_b.a, 1024);
            plot(wgdb / pi, gdb, "LineWidth", 2, "Color", col_b, ...
                 "DisplayName", "Filter B");
        end
        warning(ws);
        hold off; grid on;
        title("Group Delay");
        dsp_freq_xticks();
        ylabel("Delay (samples)");
        legend("location", "northeast");
        xlim([0, 1]);

        % --- Metrics ---
        axes(c.ax_metrics); cla; axis off;
        title("Comparison Metrics");

        row = 0;
        if has_a
            sa = dsp_check_stability(filt_a.b, filt_a.a);
            f3a = dsp_compute_f3db(Ha, wna);
            row = draw_metric_block(0.02, 0.92, "Filter A", ...
                      length(filt_a.a)-1, sa, f3a, col_a);
        end
        if has_b
            sb = dsp_check_stability(filt_b.b, filt_b.a);
            f3b = dsp_compute_f3db(Hb, wnb);
            if has_a
                y_start = row - 0.06;
            else
                y_start = 0.92;
            end
            draw_metric_block(0.02, y_start, "Filter B", ...
                      length(filt_b.a)-1, sb, f3b, col_b);
        end

        if has_a && has_b && filt_a.Fs ~= filt_b.Fs
            text(0.02, 0.02, "Note: filters have different Fs", ...
                 "Units", "normalized", "FontSize", 9, ...
                 "Color", [0.8, 0.4, 0.0], "FontWeight", "bold");
        end
    end

    function y = draw_metric_block(x, y, name, order, stab, f3db_str, col)
        text(x, y, name, "Units", "normalized", ...
             "FontWeight", "bold", "FontSize", 10, "Color", col);
        y = y - 0.10;
        txt = sprintf([ ...
            "Order:           %d\n" ...
            "Stability:       %s\n" ...
            "Max Pole Radius: %.4f\n" ...
            "Stability Margin:%.4f\n" ...
            "-3 dB Crossing:  %s"], ...
            order, stab.status, stab.max_radius, stab.margin, f3db_str);
        text(x + 0.02, y, txt, "Units", "normalized", ...
             "VerticalAlignment", "top", "FontSize", 9);
        y = y - 0.34;
    end
end

% ---------------------------------------------------------------
% Helpers
% ---------------------------------------------------------------

function f = empty_filter()
    f = struct("b", [], "a", [], "Fs", 0, "label", "");
end

