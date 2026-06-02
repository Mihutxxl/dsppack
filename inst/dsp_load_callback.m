## -*- texinfo -*-
## @deftypefn {Function File} dsp_load_callback (@var{h})
## Load a filter design from a .mat file, restore UI fields, and replot.
## @end deftypefn

function dsp_load_callback(h)
    [fname, fpath] = uigetfile("*.mat", "Load Filter Design");
    if isequal(fname, 0)
        return;
    end

    filepath = fullfile(fpath, fname);
    data = load(filepath);

    if ~isfield(data, "design")
        errordlg("Selected file is not a valid dsppack filter design.", "Load Error");
        return;
    end

    d = data.design;

    required = {"Fs", "Fc", "Fc2", "N", "type_idx", "topo_idx"};
    for k = 1:numel(required)
        if ~isfield(d, required{k})
            errordlg(sprintf("Design file is missing field: %s", required{k}), "Load Error");
            return;
        end
    end

    set(h.edit_Fs,    "string", num2str(d.Fs));
    set(h.edit_Fc,    "string", num2str(d.Fc));
    set(h.edit_Fc2,   "string", num2str(d.Fc2));
    set(h.edit_Order, "string", num2str(d.N));
    set(h.popup_Type, "value",  d.type_idx);

    if isfield(d, "arch_idx")
        set(h.popup_Arch, "value", d.arch_idx);
        if d.arch_idx == 1
            set(h.popup_Topo, "String", ...
                {"Butterworth", "Chebyshev I", "Chebyshev II", "Elliptic"});
        else
            set(h.popup_Topo, "String", ...
                {"Hamming Window", "Hanning Window", "Blackman Window", ...
                 "Kaiser Window", "Parks-McClellan", "Least-Squares"});
        end
    end
    set(h.popup_Topo, "value", d.topo_idx);

    if isfield(d, "b") && isfield(d, "a") && ~isempty(d.b) && ~isempty(d.a)
        h.last_b = d.b;
        h.last_a = d.a;
        guidata(h.fig, h);
        dsp_plot_response(h.ax_mag, h.ax_phase, d.b, d.a, d.Fs);

        dsp_update_stability(h.txt_stability, d.b, d.a);
    end

    msgbox(sprintf("Loaded filter: %s %s (order %d)\nFrom: %s", ...
           d.topo_name, d.type_name, d.N, filepath), "Load Successful");
end
