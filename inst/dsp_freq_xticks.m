## -*- texinfo -*-
## @deftypefn  {Function File} dsp_freq_xticks ()
## @deftypefnx {Function File} dsp_freq_xticks (@var{ax})
## Relabel the frequency x-axis of @var{ax} (default @code{gca}) so it reads
## in radians per sample from 0 to @math{\pi}.
##
## The frequency responses are plotted in @math{\times\pi} units (data range
## [0, 1], i.e. @math{w/\pi}).  Rather than rescaling that data, this places
## ticks at 0, @math{\pi/4}, @math{\pi/2}, @math{3\pi/4}, @math{\pi} and sets
## a matching @math{\omega} (rad/sample) axis label, so the displayed axis
## runs 0 to @math{\pi}.
## @end deftypefn

function dsp_freq_xticks(ax)
    if nargin < 1 || isempty(ax)
        ax = gca();
    end
    set(ax, "XTick",      [0, 0.25, 0.50, 0.75, 1.0], ...
            "XTickLabel", {'0', '\pi/4', '\pi/2', '3\pi/4', '\pi'});
    xlabel(ax, 'Frequency \omega (rad/sample)');
end
