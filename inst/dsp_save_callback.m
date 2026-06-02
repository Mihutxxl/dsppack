## -*- texinfo -*-
## @deftypefn {Function File} dsp_save_callback (@var{h})
## Save the current filter design (parameters and coefficients) to a .mat file.
## @end deftypefn

function dsp_save_callback(h)
    if ~isfield(h, "last_b") || isempty(h.last_b)
        errordlg("Please design a filter first.", "Save Error");
        return;
    end

    Fs       = str2double(get(h.edit_Fs,    "string"));
    Fc       = str2double(get(h.edit_Fc,    "string"));
    Fc2      = str2double(get(h.edit_Fc2,   "string"));
    N        = str2double(get(h.edit_Order, "string"));
    type_idx = get(h.popup_Type, "value");
    topo_idx = get(h.popup_Topo, "value");
    arch_idx = get(h.popup_Arch, "value");

    b = h.last_b;
    a = h.last_a;

    [fname, fpath] = uiputfile("*.mat", "Save Filter Design");
    if isequal(fname, 0)
        return;
    end

    type_names = {"Low Pass", "High Pass", "Band Pass", "Band Stop"};
    arch_names = {"IIR", "FIR"};
    topo_items = get(h.popup_Topo, "String");

    design.Fs        = Fs;
    design.Fc        = Fc;
    design.Fc2       = Fc2;
    design.N         = N;
    design.type_idx  = type_idx;
    design.topo_idx  = topo_idx;
    design.arch_idx  = arch_idx;
    design.type_name = type_names{type_idx};
    design.topo_name = topo_items{topo_idx};
    design.arch_name = arch_names{arch_idx};
    design.b         = b;
    design.a         = a;
    design.version   = "dsppack-1.0.0";
    design.date      = datestr(now());

    filepath = fullfile(fpath, fname);
    save(filepath, "design");
    msgbox(sprintf("Filter design saved to:\n%s", filepath), "Save Successful");
end
