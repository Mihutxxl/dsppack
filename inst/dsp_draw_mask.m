## -*- texinfo -*-
## @deftypefn {Function File} dsp_draw_mask (@var{ax}, @var{b}, @var{a}, @var{Fs}, @var{Fc}, @var{Fc2}, @var{type_idx}, @var{Rp}, @var{Rs})
## Redraw the magnitude response with a specification mask overlay.
## Forbidden zones are shaded light red; allowed passband is light green.
## The response curve is drawn on top.
## @end deftypefn

function dsp_draw_mask(ax, b, a, Fs, Fc, Fc2, type_idx, Rp, Rs)
    [H, w] = freqz(b, a, 1024);
    wn     = w / pi;                 % normalized frequency on [0, 1]
    mag_db = 20 * log10(abs(H) + eps);   % +eps avoids -Inf at deep nulls

    % Normalize the Hz cutoffs into the same ×π rad/sample units.
    Fn_n  = 1;                       % Nyquist in normalized units
    Wc    = Fc  / (Fs / 2);
    Wc2   = Fc2 / (Fs / 2);
    y_top = 5;
    y_bot = -(Rs + 30);
    red   = [1.0, 0.80, 0.80];
    green = [0.65, 1.0, 0.65];
    tw    = 0.10;

    axes(ax);
    cla;
    hold on;

    switch type_idx
        case 1  % Low Pass
            fp = Wc;
            fs_edge = min(Wc * (1 + tw), Fn_n);
            draw_passband(0, fp, -Rp, y_bot, y_top, green, red);
            draw_stopband(fs_edge, Fn_n, -Rs, y_bot, y_top, red);
            draw_edge(fp, y_bot, y_top);
            draw_edge(fs_edge, y_bot, y_top);

        case 2  % High Pass
            fs_edge = max(Wc * (1 - tw), 0);
            fp = Wc;
            draw_stopband(0, fs_edge, -Rs, y_bot, y_top, red);
            draw_passband(fp, Fn_n, -Rp, y_bot, y_top, green, red);
            draw_edge(fs_edge, y_bot, y_top);
            draw_edge(fp, y_bot, y_top);

        case 3  % Band Pass
            fs1 = max(Wc * (1 - tw), 0);
            fp1 = Wc;
            fp2 = Wc2;
            fs2 = min(Wc2 * (1 + tw), Fn_n);
            draw_stopband(0, fs1, -Rs, y_bot, y_top, red);
            draw_passband(fp1, fp2, -Rp, y_bot, y_top, green, red);
            draw_stopband(fs2, Fn_n, -Rs, y_bot, y_top, red);
            draw_edge(fs1, y_bot, y_top);
            draw_edge(fp1, y_bot, y_top);
            draw_edge(fp2, y_bot, y_top);
            draw_edge(fs2, y_bot, y_top);

        case 4  % Band Stop
            fp1 = Wc;
            fs1 = min(Wc * (1 + tw), Fn_n);
            fs2 = max(Wc2 * (1 - tw), 0);
            fp2 = Wc2;
            draw_passband(0, fp1, -Rp, y_bot, y_top, green, red);
            draw_stopband(fs1, fs2, -Rs, y_bot, y_top, red);
            draw_passband(fp2, Fn_n, -Rp, y_bot, y_top, green, red);
            draw_edge(fp1, y_bot, y_top);
            draw_edge(fs1, y_bot, y_top);
            draw_edge(fs2, y_bot, y_top);
            draw_edge(fp2, y_bot, y_top);
    end

    plot(wn, mag_db, "b-", "LineWidth", 2);

    hold off;
    grid on;
    title("Magnitude Response");
    dsp_freq_xticks(ax, Fs);
    ylabel("Magnitude (dB)");
    xlim([0, Fn_n]);
    ylim([y_bot, y_top]);
end

function draw_passband(f1, f2, rp_db, y_bot, y_top, green, red)
    fill([f1, f2, f2, f1], [y_top, y_top, rp_db, rp_db], green, "EdgeColor", "none");
    fill([f1, f2, f2, f1], [rp_db, rp_db, y_bot, y_bot], red, "EdgeColor", "none");
    plot([f1, f2], [rp_db, rp_db], "r--", "LineWidth", 1.3);
end

function draw_stopband(f1, f2, rs_db, y_bot, y_top, red)
    fill([f1, f2, f2, f1], [y_top, y_top, rs_db, rs_db], red, "EdgeColor", "none");
    plot([f1, f2], [rs_db, rs_db], "r--", "LineWidth", 1.3);
end

function draw_edge(freq, y_bot, y_top)
    plot([freq, freq], [y_bot, y_top], ":", "Color", [0.5, 0.5, 0.5], "LineWidth", 0.8);
end
