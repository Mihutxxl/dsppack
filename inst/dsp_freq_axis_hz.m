## -*- texinfo -*-
## @deftypefn  {Function File} {[@var{hz}, @var{label}] =} dsp_freq_axis_hz ()
## @deftypefnx {Function File} {[@var{hz}, @var{label}] =} dsp_freq_axis_hz (@var{new_val})
## Query or set the tool-wide frequency-axis unit mode.
##
## When @var{hz} is false (the default) frequency axes are labelled in
## normalized radians per sample, 0 to @math{\pi}.  When true they are
## labelled in absolute frequency, 0 to Fs/2 Hz.  The flag is stored as
## appdata on the root object so every dsppack window (main screen,
## detailed analysis) shares the same mode; it is applied by
## @code{dsp_freq_xticks}, which falls back to @math{\pi} units for axes
## that have no sampling frequency associated with them (e.g. the compare
## window, whose two filters may use different sampling rates).
##
## @var{label} is the matching caption for the toggle buttons, describing
## the mode currently shown.
## @end deftypefn

function [hz, label] = dsp_freq_axis_hz(new_val)
    if nargin > 0
        setappdata(0, "dsppack_hz_axis", logical(new_val));
    end
    hz = isequal(getappdata(0, "dsppack_hz_axis"), true);
    if hz
        label = "Freq Axis: Hz (0 - Fs/2)";
    else
        label = "Freq Axis: Normalized (0 - pi)";
    end
end
