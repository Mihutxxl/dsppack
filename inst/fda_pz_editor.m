## -*- texinfo -*-
## @deftypefn {Function File} fda_pz_editor (@var{main_fig}, @var{Fs})
## Interactive Z-Plane pole-zero editor. Places poles and zeros either by
## clicking on the Z-plane or by typing magnitude (r) and angle (deg) into
## the Manual Entry panel.  Enforces complex-conjugate symmetry so the
## resulting filter has real coefficients, then submits the design back to
## the main FDA Tool window.
## @end deftypefn

function fda_pz_editor(main_fig, Fs)
    snap_thr = 0.05;   % imaginary snap-to-zero threshold (data units)

    % Mutable state shared across all nested callbacks via closure
    state.poles = [];   % column vector of complex pole locations
    state.zeros = [];   % column vector of complex zero locations
    state.mode  = 1;    % 1 = place pole, 0 = place zero

    % -------------------------------------------------------------------
    % Editor figure (sized to match the main FDA Tool window)
    % -------------------------------------------------------------------
    h.fig = dsp_new_window("Interactive P/Z Editor");
    set(h.fig, "CloseRequestFcn", @cb_close);

    % -------------------------------------------------------------------
    % Top control bar
    % -------------------------------------------------------------------
    h.btn_clear = uicontrol(h.fig, ...
        "Style",           "pushbutton", ...
        "String",          "Clear All", ...
        "Units",           "normalized", ...
        "Position",        [0.03, 0.945, 0.54, 0.042], ...
        "FontWeight",      "bold", ...
        "BackgroundColor", [0.40, 0.40, 0.40], ...
        "ForegroundColor", [1, 1, 1], ...
        "Callback",        @cb_clear);

    % -------------------------------------------------------------------
    % Z-Plane axes (left side)
    % -------------------------------------------------------------------
    h.ax_pz = axes("Parent",   h.fig, ...
                   "Units",    "normalized", ...
                   "Position", [0.04, 0.18, 0.55, 0.72]);

    draw_zplane();   % draw static elements + initial empty state

    % -------------------------------------------------------------------
    % Right side: Manual entry panel
    % -------------------------------------------------------------------
    h.panel_entry = uipanel("Parent",      h.fig, ...
                            "Title",       "Manual Entry", ...
                            "FontSize",    11, ...
                            "FontWeight",  "bold", ...
                            "Position",    [0.62, 0.18, 0.35, 0.72]);

    uicontrol(h.panel_entry, "Style", "text", ...
              "String",              "Magnitude (r):", ...
              "Units",               "normalized", ...
              "Position",            [0.05, 0.86, 0.45, 0.06], ...
              "HorizontalAlignment", "left", ...
              "FontSize",            10);

    h.edit_radius = uicontrol(h.panel_entry, "Style", "edit", ...
                              "String",          "0.8", ...
                              "Units",           "normalized", ...
                              "Position",        [0.52, 0.86, 0.43, 0.06], ...
                              "BackgroundColor", [1, 1, 1], ...
                              "FontSize",        10);

    uicontrol(h.panel_entry, "Style", "text", ...
              "String",              "Angle (deg):", ...
              "Units",               "normalized", ...
              "Position",            [0.05, 0.77, 0.45, 0.06], ...
              "HorizontalAlignment", "left", ...
              "FontSize",            10);

    h.edit_angle = uicontrol(h.panel_entry, "Style", "edit", ...
                             "String",          "45", ...
                             "Units",           "normalized", ...
                             "Position",        [0.52, 0.77, 0.43, 0.06], ...
                             "BackgroundColor", [1, 1, 1], ...
                             "FontSize",        10);

    uicontrol(h.panel_entry, "Style", "pushbutton", ...
              "String",          "Add as Pole  [X]", ...
              "Units",           "normalized", ...
              "Position",        [0.05, 0.63, 0.90, 0.09], ...
              "FontWeight",      "bold", ...
              "BackgroundColor", [0.72, 0.18, 0.18], ...
              "ForegroundColor", [1, 1, 1], ...
              "Callback",        @(~,~) cb_manual_add("pole"));

    uicontrol(h.panel_entry, "Style", "pushbutton", ...
              "String",          "Add as Zero  [O]", ...
              "Units",           "normalized", ...
              "Position",        [0.05, 0.52, 0.90, 0.09], ...
              "FontWeight",      "bold", ...
              "BackgroundColor", [0.08, 0.52, 0.14], ...
              "ForegroundColor", [1, 1, 1], ...
              "Callback",        @(~,~) cb_manual_add("zero"));

    uicontrol(h.panel_entry, "Style", "text", ...
              "String", ["Non-real entries automatically add the complex" ...
                         " conjugate to keep filter coefficients real."], ...
              "Units",               "normalized", ...
              "Position",            [0.05, 0.36, 0.90, 0.12], ...
              "HorizontalAlignment", "left", ...
              "FontSize",            9, ...
              "ForegroundColor",     [0.4, 0.4, 0.4]);

    % -------------------------------------------------------------------
    % Bottom control bar
    % -------------------------------------------------------------------
    h.btn_submit = uicontrol(h.fig, ...
        "Style",           "pushbutton", ...
        "String",          "SUBMIT & DESIGN", ...
        "Units",           "normalized", ...
        "Position",        [0.04, 0.03, 0.40, 0.09], ...
        "FontSize",        11, ...
        "FontWeight",      "bold", ...
        "BackgroundColor", [0.10, 0.52, 0.18], ...
        "ForegroundColor", [1, 1, 1], ...
        "Callback",        @cb_submit);

    h.btn_cancel = uicontrol(h.fig, ...
        "Style",           "pushbutton", ...
        "String",          "Cancel", ...
        "Units",           "normalized", ...
        "Position",        [0.46, 0.03, 0.18, 0.09], ...
        "FontSize",        10, ...
        "BackgroundColor", [0.60, 0.15, 0.15], ...
        "ForegroundColor", [1, 1, 1], ...
        "Callback",        @cb_close);

    % Register Z-plane click handler on the figure level
    set(h.fig, "WindowButtonDownFcn", @cb_click);

    % ===================================================================
    % Callbacks  (nested — share 'state', 'h', 'main_fig', 'Fs' via closure)
    % ===================================================================

    function cb_clear(~, ~)
        state.poles = [];
        state.zeros = [];
        draw_zplane();
    end

    function cb_manual_add(kind)
        r       = str2double(get(h.edit_radius, "string"));
        ang_deg = str2double(get(h.edit_angle,  "string"));

        if isnan(r) || isnan(ang_deg)
            errordlg("Please enter numeric values for magnitude and angle.", ...
                     "Invalid Input");
            return;
        end
        if r < 0
            errordlg("Magnitude must be non-negative.", "Invalid Input");
            return;
        end

        pt = r * exp(1j * ang_deg * pi / 180);
        if abs(imag(pt)) < snap_thr
            pt = real(pt);
        end

        add_pt_to_state(kind, pt);
        draw_zplane();
    end

    function cb_click(~, ~)
        % Only respond to a plain left-click...
        if ~strcmp(get(h.fig, "SelectionType"), "normal")
            return;
        end

        % ...that physically landed on the Z-plane axes. Checking the axes'
        % XLim/YLim alone is not enough: `axis equal` can auto-extend the
        % data limits, letting clicks from neighbouring controls (notably
        % the Add Pole / Add Zero buttons) extrapolate into the data range
        % and get registered as random pole/zero placements.
        if ~click_in_axes()
            return;
        end

        cp = get(h.ax_pz, "CurrentPoint");
        cx = cp(1, 1);
        cy = cp(1, 2);

        % Snap near-zero imaginary values to the real axis
        if abs(cy) < snap_thr
            cy = 0;
        end

        if state.mode == 1
            kind = "pole";
        else
            kind = "zero";
        end
        add_pt_to_state(kind, cx + 1j * cy);
        draw_zplane();
    end

    function tf = click_in_axes()
        % True iff the figure CurrentPoint falls inside the Z-plane axes'
        % normalized rectangle.
        old_units = get(h.fig, "Units");
        set(h.fig, "Units", "normalized");
        cp_fig = get(h.fig, "CurrentPoint");
        set(h.fig, "Units", old_units);
        ax_pos = get(h.ax_pz, "Position");
        tf = cp_fig(1) >= ax_pos(1) && ...
             cp_fig(1) <= ax_pos(1) + ax_pos(3) && ...
             cp_fig(2) >= ax_pos(2) && ...
             cp_fig(2) <= ax_pos(2) + ax_pos(4);
    end

    function add_pt_to_state(kind, pt)
        % Append pt (and its conjugate, when non-real) to the pole or
        % zero list. Shared by cb_click and cb_manual_add.
        if strcmp(kind, "pole")
            state.poles = [state.poles; pt];
            if imag(pt) ~= 0
                state.poles = [state.poles; conj(pt)];
            end
        else
            state.zeros = [state.zeros; pt];
            if imag(pt) ~= 0
                state.zeros = [state.zeros; conj(pt)];
            end
        end
    end

    function cb_submit(~, ~)
        % Convert root locations to polynomial coefficients.
        % poly([]) returns [1], so an empty set gives a trivial coefficient.
        b = real(poly(state.zeros(:).'));
        a = real(poly(state.poles(:).'));

        % Persist coefficients into the main window's guidata so the
        % analysis window picks up these P/Z-derived coefficients
        main_h = guidata(main_fig);
        main_h.last_b = b;
        main_h.last_a = a;
        guidata(main_fig, main_h);

        dsp_plot_response(main_h.ax_mag, main_h.ax_phase, b, a, Fs);

        % Close editor and restore main window
        delete(h.fig);
        set(main_fig, "Visible", "on");
    end

    function cb_close(~, ~)
        % Cancel: just restore the main window without changing its plots
        delete(h.fig);
        set(main_fig, "Visible", "on");
    end

    % ===================================================================
    % Z-Plane drawing helper
    % ===================================================================

    function draw_zplane()
        dsp_draw_zplane(h.ax_pz, state.zeros, state.poles, ...
                        sprintf("Z-Plane  —  Fs = %.0f Hz  (click to place)", Fs));
    end

end
