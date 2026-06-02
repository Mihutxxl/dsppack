## -*- texinfo -*-
## @deftypefn {Function File} dsp_export_callback (@var{h})
## Export the current filter coefficients to the base workspace as
## @code{num_coeffs}, @code{den_coeffs}, and @code{fs_val}.
## @end deftypefn

function dsp_export_callback(h)
    if ~isfield(h, "last_b") || isempty(h.last_b)
        errordlg("Please design a filter first.", "Export Error");
        return;
    end

    Fs = str2double(get(h.edit_Fs, "string"));

    assignin("base", "num_coeffs", h.last_b);
    assignin("base", "den_coeffs", h.last_a);
    assignin("base", "fs_val",     Fs);

    msgbox("Exported to workspace: 'num_coeffs', 'den_coeffs', 'fs_val'.", "Export Successful");
end
