## -*- texinfo -*-
## @deftypefn {Function File} {[@var{b}, @var{a}] =} dsp_compute_filter (@var{Fs}, @var{Fc}, @var{Fc2}, @var{N}, @var{type_idx}, @var{topo_idx}, @var{arch_idx}, @var{Rp}, @var{Rs})
## Compute filter coefficients from UI parameters.
## @var{arch_idx}: 1=IIR (default), 2=FIR
## @var{type_idx}: 1=lowpass, 2=highpass, 3=bandpass, 4=bandstop
## IIR @var{topo_idx}: 1=Butterworth, 2=Chebyshev I, 3=Chebyshev II, 4=Elliptic
## FIR @var{topo_idx}: 1=Hamming, 2=Hanning, 3=Blackman, 4=Kaiser, 5=Parks-McClellan, 6=Least-Squares
## @var{Rp}: passband ripple in dB (default 3)
## @var{Rs}: stopband attenuation in dB (default 40)
## @end deftypefn

function [b, a] = dsp_compute_filter(Fs, Fc, Fc2, N, type_idx, topo_idx, arch_idx, Rp, Rs)
    if nargin < 7; arch_idx = 1; end
    if nargin < 8 || isempty(Rp); Rp = 3; end
    if nargin < 9 || isempty(Rs); Rs = 40; end

    type_strs = {"low", "high", "pass", "stop"};
    type_str  = type_strs{type_idx};

    if type_idx <= 2
        Wn = Fc / (Fs / 2);
    else
        Wn = [Fc, Fc2] / (Fs / 2);
    end

    if any(Wn <= 0) || any(Wn >= 1)
        error("Normalized cutoff frequency must be in the range (0, 1). Got Wn = [%s]. Check that Fc < Fs/2.", ...
              num2str(Wn, "%.4f "));
    end

    if arch_idx == 1
        % ---- IIR ----
        switch topo_idx
            case 1
                [b, a] = butter(N, Wn, type_str);
            case 2
                [b, a] = cheby1(N, Rp, Wn, type_str);
            case 3
                [b, a] = cheby2(N, Rs, Wn, type_str);
            case 4
                [b, a] = ellip(N, Rp, Rs, Wn, type_str);
        end
    else
        % ---- FIR ----
        a = 1;

        % High-pass and band-stop FIR filters must have a non-zero response
        % at Nyquist, which requires a Type I (even-order) linear-phase
        % filter. Bump an odd order up by one so the design is realizable for
        % every method (fir1 does this internally, but firpm/firls do not).
        if (type_idx == 2 || type_idx == 4) && mod(N, 2) == 1
            N = N + 1;
        end

        if topo_idx <= 4
            switch topo_idx
                case 1; win = hamming(N + 1);
                case 2; win = hanning(N + 1);
                case 3; win = blackman(N + 1);
                case 4; win = kaiser(N + 1, 5);
            end
            if type_idx == 2
                b = fir1(N, Wn, "high", win);
            elseif type_idx == 4
                b = fir1(N, Wn, "stop", win);
            else
                b = fir1(N, Wn, win);
            end
        else
            [fb, ab] = make_pm_bands(Wn, type_idx);
            if topo_idx == 5
                b = firpm(N, fb, ab);
            else
                b = firls(N, fb, ab);
            end
        end
    end
end

function [f, amp] = make_pm_bands(Wn, type_idx)
    % Transition-band half-width: a quarter of the passband width, clamped
    % to [0.05, 0.15] (normalized) so narrow bands keep a designable
    % transition and wide bands do not over-widen it.
    gap = max(0.05, min(0.15, (Wn(end) - Wn(1)) / 4));
    switch type_idx
        case 1
            f   = [0, max(0.001, Wn - gap), min(0.999, Wn + gap), 1];
            amp = [1, 1, 0, 0];
        case 2
            f   = [0, max(0.001, Wn - gap), min(0.999, Wn + gap), 1];
            amp = [0, 0, 1, 1];
        case 3
            fs1 = max(0.001, Wn(1) - gap);
            fs2 = min(0.999, Wn(2) + gap);
            f   = [0, fs1, Wn(1), Wn(2), fs2, 1];
            amp = [0, 0, 1, 1, 0, 0];
        case 4
            mid = (Wn(1) + Wn(2)) / 2;
            fs1 = min(Wn(1) + gap, mid);
            fs2 = max(Wn(2) - gap, mid);
            f   = [0, Wn(1), fs1, fs2, Wn(2), 1];
            amp = [1, 1, 0, 0, 1, 1];
    end

    % Enforce strictly increasing frequency vector
    for k = 2:numel(f)
        if f(k) <= f(k-1)
            f(k) = f(k-1) + 0.001;
        end
    end
end
