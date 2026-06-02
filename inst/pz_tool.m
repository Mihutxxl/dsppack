## -*- texinfo -*-
## @deftypefn {Function File} pz_tool ()
## Interactive Pole-Zero placement tool with live magnitude frequency response.
## Click on the Z-plane to place poles or zeros. Complex conjugates are
## placed automatically for any off-axis click.
## @end deftypefn

function pz_tool()
    snap_thr = 0.05;   % imaginary snap-to-zero threshold (data units)

    % --- Default state -------------------------------------------------
    p0 = 0.8 * exp(1j * pi / 4);    % r=0.8, ±45°
    z0 = 1.0 * exp(1j * pi / 2);    % r=1.0, ±90°
    state.poles = [p0; conj(p0)];
    state.zeros = [z0; conj(z0)];
    state.mode  = 1;                  % 1 = place pole, 0 = place zero

    % --- Figure (sized to match the main FDA Tool window) -------------
    h.fig = dsp_new_window("Pole-Zero Placement Tool");

    % --- Toggle button -------------------------------------------------
    h.btn_toggle = uicontrol(h.fig, ...
        "Style",           "pushbutton", ...
        "String",          "Mode:  PLACE POLE  [X]", ...
        "Units",           "normalized", ...
        "Position",        [0.05, 0.956, 0.52, 0.036], ...
        "FontWeight",      "bold", ...
        "BackgroundColor", [0.72, 0.18, 0.18], ...
        "ForegroundColor", [1, 1, 1], ...
        "Callback",        @cb_toggle);

    % --- Clear All button ----------------------------------------------
    h.btn_clear = uicontrol(h.fig, ...
        "Style",           "pushbutton", ...
        "String",          "Clear All", ...
        "Units",           "normalized", ...
        "Position",        [0.67, 0.956, 0.28, 0.036], ...
        "FontWeight",      "bold", ...
        "BackgroundColor", [0.18, 0.32, 0.62], ...
        "ForegroundColor", [1, 1, 1], ...
        "Callback",        @cb_clear);

    % --- Z-Plane axes (top ~55 % of figure) ---------------------------
    h.ax_pz = axes("Parent",   h.fig, ...
                   "Units",    "normalized", ...
                   "Position", [0.13, 0.46, 0.82, 0.47]);

    % --- Frequency Response axes (bottom ~35 %) -----------------------
    h.ax_freq = axes("Parent",   h.fig, ...
                     "Units",    "normalized", ...
                     "Position", [0.13, 0.06, 0.82, 0.33]);

    % Register figure-level click handler
    set(h.fig, "WindowButtonDownFcn", @cb_click);

    % Initial render
    redraw_pz();
    redraw_freq();

    % ===================================================================
    % Callbacks  (nested functions share 'state' and 'h' via closure)
    % ===================================================================

    function cb_toggle(src, ~)
        state.mode = 1 - state.mode;
        if state.mode == 1
            set(src, "String",          "Mode:  PLACE POLE  [X]", ...
                     "BackgroundColor", [0.72, 0.18, 0.18]);
        else
            set(src, "String",          "Mode:  PLACE ZERO  [O]", ...
                     "BackgroundColor", [0.08, 0.52, 0.14]);
        end
    end

    function cb_clear(~, ~)
        state.poles = [];
        state.zeros = [];
        redraw_pz();
        redraw_freq();
    end

    function cb_click(~, ~)
        % Only respond to plain left-click
        if ~strcmp(get(h.fig, "SelectionType"), "normal")
            return;
        end

        % Read cursor position in Z-plane data coordinates
        cp = get(h.ax_pz, "CurrentPoint");
        cx = cp(1, 1);
        cy = cp(1, 2);

        % Reject clicks that fall outside the Z-plane axes bounds
        xl = get(h.ax_pz, "XLim");
        yl = get(h.ax_pz, "YLim");
        if cx < xl(1) || cx > xl(2) || cy < yl(1) || cy > yl(2)
            return;
        end

        % Snap near-real-axis clicks to the real axis
        if abs(cy) < snap_thr
            cy = 0;
        end

        pt = cx + 1j * cy;

        if state.mode == 1     % --- Place pole ---
            state.poles = [state.poles; pt];
            if cy ~= 0
                state.poles = [state.poles; conj(pt)];
            end
        else                   % --- Place zero ---
            state.zeros = [state.zeros; pt];
            if cy ~= 0
                state.zeros = [state.zeros; conj(pt)];
            end
        end

        redraw_pz();
        redraw_freq();
    end

    % ===================================================================
    % Drawing helpers
    % ===================================================================

    function redraw_pz()
        dsp_draw_zplane(h.ax_pz, state.zeros, state.poles, ...
                        "Z-Plane  (click to place a pole or zero)");
    end

    function redraw_freq()
        axes(h.ax_freq);
        cla;

        N   = 512;
        w   = linspace(0, pi, N);
        mag = zeros(1, N);

        for k = 1:N
            z = exp(1j * w(k));

            % Product of distances from z to every zero
            if isempty(state.zeros)
                num_dist = 1;
            else
                num_dist = prod(abs(z - state.zeros(:).'));
            end

            % Product of distances from z to every pole
            if isempty(state.poles)
                den_dist = 1;
            else
                den_dist = prod(abs(z - state.poles(:).'));
            end

            if den_dist < 1e-12
                mag(k) = Inf;
            else
                mag(k) = num_dist / den_dist;
            end
        end

        % Determine a sensible y ceiling (clip display of near-singularities)
        finite_mag = mag(isfinite(mag));
        if ~isempty(finite_mag) && max(finite_mag) > 0
            ymax = max(finite_mag) * 1.15;
        else
            ymax = 2;
        end
        ymax = max(ymax, 0.5);
        mag  = min(mag, ymax);   % clip spikes for clean display

        plot(w / pi, mag, "-", ...
             "Color",     [0.10, 0.35, 0.75], ...
             "LineWidth", 2);

        xlim([0, 1]);
        ylim([0, ymax]);
        grid on;
        title("Magnitude Frequency Response", "FontSize", 11);
        dsp_freq_xticks();
        ylabel("|H(e^{j\omega})|");
    end

end
