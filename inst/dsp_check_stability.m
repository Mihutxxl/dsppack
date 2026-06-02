## -*- texinfo -*-
## @deftypefn {Function File} {@var{s} =} dsp_check_stability (@var{b}, @var{a})
## Analyse the BIBO stability of a discrete-time filter given its
## transfer-function coefficients @var{b} (numerator) and @var{a}
## (denominator).
##
## Returns a struct @var{s} with the fields:
## @table @code
## @item poles
## Column vector of filter poles (roots of @var{a}).
## @item radii
## Absolute values of each pole.
## @item max_radius
## Radius of the pole closest to or outside the unit circle.
## @item margin
## Distance from the largest-radius pole to the unit circle (1 - max_radius).
## @item stable
## Boolean — true when every pole lies strictly inside the unit circle.
## @item status
## Human-readable string: @code{"STABLE"}, @code{"MARGINALLY STABLE"},
## or @code{"UNSTABLE"}.
## @end table
## @end deftypefn

function s = dsp_check_stability(b, a)
    tol = 1e-10;

    s.poles  = roots(a);
    s.radii  = abs(s.poles);

    if isempty(s.radii)
        s.max_radius = 0;
        s.margin     = 1;
        s.stable     = true;
        s.status     = "STABLE (FIR)";
        return;
    end

    s.max_radius = max(s.radii);
    s.margin     = 1 - s.max_radius;

    if s.max_radius < 1 - tol
        s.stable = true;
        s.status = "STABLE";
    elseif s.max_radius <= 1 + tol
        s.stable = false;
        s.status = "MARGINALLY STABLE";
    else
        s.stable = false;
        s.status = "UNSTABLE";
    end
end
