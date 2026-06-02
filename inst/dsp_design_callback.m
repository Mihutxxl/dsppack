## -*- texinfo -*-
## @deftypefn {Function File} dsp_design_callback (@var{h})
## Design button handler.  Reads filter parameters from the GUI,
## computes the filter, plots responses, and updates the stability
## indicator.
## @end deftypefn

function dsp_design_callback(h)
    % 1. Extract inputs
    Fs       = str2double(get(h.edit_Fs,    "string"));
    Fc       = str2double(get(h.edit_Fc,    "string"));
    Fc2      = str2double(get(h.edit_Fc2,   "string"));
    N        = str2double(get(h.edit_Order, "string"));
    type_idx = get(h.popup_Type, "value");
    topo_idx = get(h.popup_Topo, "value");
    arch_idx = get(h.popup_Arch, "value");

    % 2. Validation
    if isnan(Fs) || isnan(Fc) || isnan(N)
        errordlg("Please enter valid numbers for Fs, Fc, and Order."); return;
    end
    if Fc >= Fs/2
        errordlg("Cutoff Fc must be less than Nyquist frequency (Fs/2)."); return;
    end
    if type_idx >= 3
        if isnan(Fc2) || Fc2 >= Fs/2 || Fc2 <= Fc
            errordlg("For Band Pass/Stop, Fc2 must satisfy: Fc < Fc2 < Fs/2."); return;
        end
    end

    % 3. Read ripple / attenuation values
    Rp = str2double(get(h.edit_Rp, "string"));
    Rs = str2double(get(h.edit_Rs, "string"));
    if isnan(Rp) || Rp <= 0; Rp = 3; end
    if isnan(Rs) || Rs <= 0; Rs = 40; end

    % 4. Compute filter using shared function
    try
        [b, a] = dsp_compute_filter(Fs, Fc, Fc2, N, type_idx, topo_idx, arch_idx, Rp, Rs);
    catch err
        errordlg(sprintf("Filter design failed:\n%s", err.message), "Design Error");
        return;
    end

    % 5. Persist coefficients so the analysis window always reflects
    %    the last-designed filter (whether from here or the P/Z editor)
    h.last_b = b;
    h.last_a = a;
    guidata(h.fig, h);

    % 6. Plot responses. When the spec mask is enabled it (re)draws the
    %    magnitude axis itself, so only plot the phase here to avoid drawing
    %    the magnitude twice (which caused a visible flicker).
    mask_on = isfield(h, "chk_mask") && get(h.chk_mask, "value");
    if mask_on
        dsp_plot_response([], h.ax_phase, b, a, Fs);
        Rp = str2double(get(h.edit_Rp, "string"));
        Rs = str2double(get(h.edit_Rs, "string"));
        if isnan(Rp); Rp = 1; end
        if isnan(Rs); Rs = 40; end
        dsp_draw_mask(h.ax_mag, b, a, Fs, Fc, Fc2, type_idx, Rp, Rs);
    else
        dsp_plot_response(h.ax_mag, h.ax_phase, b, a, Fs);
    end

    % 7. Update stability indicator
    dsp_update_stability(h.txt_stability, b, a);
end
