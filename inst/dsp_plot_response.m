## -*- texinfo -*-
## @deftypefn {Function File} dsp_plot_response (@var{ax_mag}, @var{ax_phase}, @var{b}, @var{a}, @var{Fs})
## Plot the magnitude and phase responses of a digital filter on the
## given axes handles.
## @end deftypefn

function dsp_plot_response(ax_mag, ax_phase, b, a, Fs)
    [H, w] = freqz(b, a, 1024);
    wn = w / pi;   % normalized frequency in units of pi rad/sample

    % Magnitude response (skipped when ax_mag is empty, e.g. when the caller
    % draws its own magnitude axis such as the spec-mask overlay). The +eps
    % keeps deep nulls (elliptic/Cheby-II stopbands, FIR notches) from going
    % to -Inf and wrecking the auto-scaled y-axis.
    if ~isempty(ax_mag)
        axes(ax_mag);
        cla;
        plot(wn, 20*log10(abs(H) + eps), "LineWidth", 2);
        title("Magnitude Response");
        dsp_freq_xticks();
        ylabel("Magnitude (dB)");
        grid on;
        xlim([0, 1]);
    end

    % Phase response
    if ~isempty(ax_phase)
        axes(ax_phase);
        cla;
        plot(wn, unwrap(angle(H)) * (180 / pi), "LineWidth", 2, "Color", [0.85, 0.33, 0.10]);
        title("Phase Response");
        dsp_freq_xticks();
        ylabel("Phase (degrees)");
        grid on;
        xlim([0, 1]);
    end
end
