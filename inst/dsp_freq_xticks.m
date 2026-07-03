## -*- texinfo -*-
## @deftypefn  {Function File} dsp_freq_xticks ()
## @deftypefnx {Function File} dsp_freq_xticks (@var{ax})
## @deftypefnx {Function File} dsp_freq_xticks (@var{ax}, @var{Fs})
## Relabel the frequency x-axis of @var{ax} (default @code{gca}) according
## to the tool-wide unit mode (@code{dsp_freq_axis_hz}).
##
## The frequency responses are plotted in @math{\times\pi} units (data range
## [0, 1], i.e. @math{w/\pi}), and that data is never rescaled -- only the
## tick positions and labels change:
##
## @itemize
## @item Normalized mode (default): ticks at 0, @math{\pi/4}, @math{\pi/2},
## @math{3\pi/4}, @math{\pi} with a matching @math{\omega} (rad/sample) label.
## @item Hz mode: ticks at round Hz values (1/2/5 steps) between 0 and the
## Nyquist frequency @var{Fs}/2, labelled in Hz (or kHz when Nyquist is at
## least 1 kHz), each placed at its normalized position @math{f/(Fs/2)}.
## @end itemize
##
## Hz mode only applies when a valid @var{Fs} is supplied; callers that
## omit it (compare window, report, P/Z preview) always get the normalized
## labels regardless of the mode toggle.
## @end deftypefn

function dsp_freq_xticks(ax, Fs)
    if nargin < 1 || isempty(ax)
        ax = gca();
    end

    use_hz = false;
    if nargin >= 2 && isscalar(Fs) && isfinite(Fs) && Fs > 0
        use_hz = dsp_freq_axis_hz();
    end

    if use_hz
        nyq = Fs / 2;
        % Nice tick step (1/2/5 x 10^k) targeting about six intervals.
        raw = nyq / 6;
        e   = 10 ^ floor(log10(raw));
        f   = raw / e;
        if f <= 1
            step = e;
        elseif f <= 2
            step = 2 * e;
        elseif f <= 5
            step = 5 * e;
        else
            step = 10 * e;
        end
        ticks_hz = 0:step:nyq;
        if nyq >= 1000
            labels = arrayfun(@(t) sprintf("%g", t / 1000), ticks_hz, ...
                              "UniformOutput", false);
            xlab = "Frequency (kHz)";
        else
            labels = arrayfun(@(t) sprintf("%g", t), ticks_hz, ...
                              "UniformOutput", false);
            xlab = "Frequency (Hz)";
        end
        set(ax, "XTick", ticks_hz / nyq, "XTickLabel", labels);
        xlabel(ax, xlab);
    else
        set(ax, "XTick",      [0, 0.25, 0.50, 0.75, 1.0], ...
                "XTickLabel", {'0', '\pi/4', '\pi/2', '3\pi/4', '\pi'});
        xlabel(ax, 'Frequency \omega (rad/sample)');
    end
end
