## -*- texinfo -*-
## @deftypefn {Function File} dsp_update_stability (@var{txt_handle}, @var{b}, @var{a})
## Run a BIBO stability check and update the given text UI control with
## the result (green for stable, red otherwise).
## @end deftypefn

function dsp_update_stability(txt_handle, b, a)
    s = dsp_check_stability(b, a);
    if s.stable
        set(txt_handle, ...
            "String", sprintf("STABLE  |  max pole radius: %.4f  |  margin: %.4f", s.max_radius, s.margin), ...
            "BackgroundColor", [0.18, 0.72, 0.25], "ForegroundColor", [1, 1, 1]);
    else
        set(txt_handle, ...
            "String", sprintf("%s  |  max pole radius: %.4f", s.status, s.max_radius), ...
            "BackgroundColor", [0.85, 0.15, 0.15], "ForegroundColor", [1, 1, 1]);
    end
end
