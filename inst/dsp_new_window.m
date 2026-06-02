## -*- texinfo -*-
## @deftypefn {Function File} {@var{fig} =} dsp_new_window (@var{name})
## Create a standard dsppack application window and return its handle.
##
## The figure is sized to the screen (capped at 1920x1080), centred, fixed
## (non-resizable), and has no menubar or default number-title.  Every
## dsppack window is created through this helper so their look and behaviour
## stay consistent, and so each one carries the @code{"dsppack_window"} tag
## that lets @code{dsppack_launch}'s EXIT button close only this tool's own
## figures (leaving unrelated Octave figures untouched).
##
## Windows are deliberately non-resizable: the interactive click-to-place
## tools (@code{fda_pz_editor}, @code{pz_tool}) hit-test clicks against the
## figure geometry, which a resizable native window reports inconsistently,
## and Octave's qt toolkit applies native hover styling to resizable windows
## that can render the coloured control buttons unreadable.
## @end deftypefn

function fig = dsp_new_window(name)
    scr   = get(0, "screensize");
    fig_w = min(1920, scr(3));
    fig_h = min(1080, scr(4));
    x = max(0, (scr(3) - fig_w) / 2);
    y = max(0, (scr(4) - fig_h) / 2);
    fig = figure("position",    [x, y, fig_w, fig_h], ...
                 "name",        name, ...
                 "menubar",     "none", ...
                 "numbertitle", "off", ...
                 "resize",      "off", ...
                 "tag",         "dsppack_window");
end
