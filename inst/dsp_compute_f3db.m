## -*- texinfo -*-
## @deftypefn {Function File} {@var{str} =} dsp_compute_f3db (@var{H}, @var{wn})
## Return a human-readable string describing the -3 dB crossing
## frequencies of a frequency response @var{H} sampled at normalized
## frequencies @var{wn} (in units of @math{\\times\\pi} rad/sample, so
## @math{wn \\in [0, 1]} where 1 corresponds to the Nyquist frequency).
## @end deftypefn

function f3db_str = dsp_compute_f3db(H, wn)
    mag_db = 20 * log10(abs(H));
    max_db = max(mag_db);
    cross  = find(diff(sign(mag_db - (max_db - 3))));
    if ~isempty(cross)
        f3db_str = sprintf("%.4f x pi rad/sample", wn(cross(1)));
        if numel(cross) > 1
            f3db_str = sprintf("%s / %.4f x pi rad/sample", f3db_str, wn(cross(end)));
        end
    else
        f3db_str = "N/A";
    end
end
