## -*- texinfo -*-
## @deftypefn {Function File} dsp_audio_demo (@var{parent_fig}, @var{b}, @var{a}, @var{Fs_filter})
## Open an audio demo window.  Load a WAV file, apply the designed filter,
## play original / filtered audio, and display waveforms and spectrograms
## side by side.
## @end deftypefn

function dsp_audio_demo(parent_fig, b, a, Fs_filter)
    h.fig = dsp_new_window("Audio Demo - dsppack");
    set(h.fig, "CloseRequestFcn", @cb_back);

    h.b = b;
    h.a = a;
    h.Fs_filter = Fs_filter;
    h.signal   = [];
    h.filtered = [];
    h.Fs_audio = 0;

    % --- Top control bar ---
    uicontrol(h.fig, "Style", "pushbutton", ...
              "String", "< BACK", ...
              "Units", "normalized", ...
              "Position", [0.02, 0.955, 0.08, 0.035], ...
              "Callback", @cb_back);

    h.btn_load = uicontrol(h.fig, "Style", "pushbutton", ...
                           "String", "Load WAV", ...
                           "Units", "normalized", ...
                           "Position", [0.12, 0.955, 0.10, 0.035], ...
                           "FontWeight", "bold", ...
                           "Callback", @cb_load);

    h.btn_play_orig = uicontrol(h.fig, "Style", "pushbutton", ...
                                "String", "Play Original", ...
                                "Units", "normalized", ...
                                "Position", [0.24, 0.955, 0.11, 0.035], ...
                                "Enable", "off", ...
                                "Callback", @cb_play_orig);

    h.btn_play_filt = uicontrol(h.fig, "Style", "pushbutton", ...
                                "String", "Play Filtered", ...
                                "Units", "normalized", ...
                                "Position", [0.37, 0.955, 0.11, 0.035], ...
                                "Enable", "off", ...
                                "Callback", @cb_play_filt);

    h.btn_stop = uicontrol(h.fig, "Style", "pushbutton", ...
                           "String", "Stop", ...
                           "Units", "normalized", ...
                           "Position", [0.50, 0.955, 0.07, 0.035], ...
                           "Enable", "off", ...
                           "Callback", @cb_stop);

    h.btn_save = uicontrol(h.fig, "Style", "pushbutton", ...
                           "String", "Save WAV", ...
                           "Units", "normalized", ...
                           "Position", [0.58, 0.955, 0.09, 0.035], ...
                           "FontWeight", "bold", ...
                           "Enable", "off", ...
                           "Callback", @cb_save_wav);

    h.txt_info = uicontrol(h.fig, "Style", "text", ...
                           "String", "No file loaded. Click 'Load WAV' to begin.", ...
                           "Units", "normalized", ...
                           "Position", [0.68, 0.955, 0.30, 0.035], ...
                           "HorizontalAlignment", "left", ...
                           "FontSize", 9);

    % --- Volume control (bottom strip) ---
    uicontrol(h.fig, "Style", "text", ...
              "String", "Volume:", ...
              "Units", "normalized", ...
              "Position", [0.02, 0.03, 0.05, 0.03], ...
              "HorizontalAlignment", "left", ...
              "FontWeight", "bold");

    h.slider_vol = uicontrol(h.fig, "Style", "slider", ...
                             "Units", "normalized", ...
                             "Position", [0.07, 0.03, 0.20, 0.03], ...
                             "Min", 0, "Max", 1, "Value", 0.8, ...
                             "Callback", @cb_volume);

    h.txt_vol = uicontrol(h.fig, "Style", "text", ...
                           "String", "80%", ...
                           "Units", "normalized", ...
                           "Position", [0.28, 0.03, 0.05, 0.03], ...
                           "HorizontalAlignment", "left");

    h.volume = 0.8;

    % --- Labels ---
    uicontrol(h.fig, "Style", "text", ...
              "String", "Original", ...
              "Units", "normalized", ...
              "Position", [0.06, 0.92, 0.42, 0.03], ...
              "FontSize", 12, "FontWeight", "bold", ...
              "ForegroundColor", [0.00, 0.45, 0.74], ...
              "HorizontalAlignment", "center");

    uicontrol(h.fig, "Style", "text", ...
              "String", "Filtered", ...
              "Units", "normalized", ...
              "Position", [0.56, 0.92, 0.42, 0.03], ...
              "FontSize", 12, "FontWeight", "bold", ...
              "ForegroundColor", [0.85, 0.33, 0.10], ...
              "HorizontalAlignment", "center");

    % --- Axes: 2x2 grid ---
    h.ax_orig_wave = axes("Units", "normalized", "Position", [0.06, 0.54, 0.42, 0.36]);
    title("Waveform"); xlabel("Time (s)"); ylabel("Amplitude"); grid on;

    h.ax_filt_wave = axes("Units", "normalized", "Position", [0.56, 0.54, 0.42, 0.36]);
    title("Waveform"); xlabel("Time (s)"); ylabel("Amplitude"); grid on;

    h.ax_orig_spec = axes("Units", "normalized", "Position", [0.06, 0.08, 0.42, 0.36]);
    title("Spectrogram");
    xlabel("Time (s)");
    ylabel("Normalized Frequency (\\times\\pi rad/sample)");

    h.ax_filt_spec = axes("Units", "normalized", "Position", [0.56, 0.08, 0.42, 0.36]);
    title("Spectrogram");
    xlabel("Time (s)");
    ylabel("Normalized Frequency (\\times\\pi rad/sample)");

    guidata(h.fig, h);

    % ------------------------------------------------------------------
    function cb_load(src, ~)
        [fname, fpath] = uigetfile({"*.wav", "WAV Files (*.wav)"; ...
                                     "*.flac", "FLAC Files (*.flac)"; ...
                                     "*.*", "All Files (*.*)"}, ...
                                    "Load Audio File");
        if isequal(fname, 0); return; end

        filepath = fullfile(fpath, fname);
        try
            [y, fs] = audioread(filepath);
        catch err
            errordlg(sprintf("Cannot read file:\n%s", err.message), "Load Error");
            return;
        end

        if size(y, 2) > 1
            y = mean(y, 2);
        end

        h = guidata(src);
        h.signal   = y;
        h.Fs_audio = fs;

        if fs ~= h.Fs_filter
            warndlg(sprintf( ...
                "Audio sample rate (%d Hz) differs from filter design rate (%d Hz).\nCutoff frequencies will shift relative to the audio content.", ...
                fs, h.Fs_filter), "Sample Rate Mismatch");
        end

        h.filtered = filter(h.b, h.a, y);

        peak_filt = max(abs(h.filtered));
        if peak_filt > 1
            h.filtered = h.filtered / peak_filt;
        end

        guidata(h.fig, h);

        duration_s = length(y) / fs;
        set(h.txt_info, "String", sprintf("%s  |  Fs: %d Hz  |  %.2f s  |  %d samples", ...
                                           fname, fs, duration_s, length(y)));

        set(h.btn_play_orig, "Enable", "on");
        set(h.btn_play_filt, "Enable", "on");
        set(h.btn_stop,      "Enable", "on");
        set(h.btn_save,      "Enable", "on");

        t = (0:length(y)-1) / fs;

        axes(h.ax_orig_wave);
        plot(t, y, "Color", [0.00, 0.45, 0.74]);
        title("Waveform"); xlabel("Time (s)"); ylabel("Amplitude");
        grid on; xlim([0, t(end)]);

        axes(h.ax_filt_wave);
        plot(t, h.filtered, "Color", [0.85, 0.33, 0.10]);
        title("Waveform"); xlabel("Time (s)"); ylabel("Amplitude");
        grid on; xlim([0, t(end)]);

        target_cols = 1500;
        hop = max(256, floor(length(y) / target_cols));
        nfft = 2^nextpow2(hop * 2);
        nfft = max(nfft, 512);
        nfft = min(nfft, 16384);
        win  = hanning(nfft);
        olap = nfft - hop;

        [S1, f1, t1] = specgram(y,          nfft, fs, win, olap);
        [S2, f2, t2] = specgram(h.filtered, nfft, fs, win, olap);

        % Convert spectrogram frequency axes from Hz to normalized (×π rad/sample).
        % f/(fs/2) maps [0, Nyquist] -> [0, 1], where 1 corresponds to π rad/sample.
        wn1 = f1 / (fs / 2);
        wn2 = f2 / (fs / 2);

        S1_db = 20 * log10(abs(S1) + eps);
        S2_db = 20 * log10(abs(S2) + eps);
        peak_db = max(max(S1_db(:)), max(S2_db(:)));
        clims = [peak_db - 80, peak_db];

        axes(h.ax_orig_spec);
        imagesc(t1, wn1, S1_db, clims);
        axis xy; colorbar;
        title("Spectrogram");
        xlabel("Time (s)");
        ylabel("Normalized Frequency (\\times\\pi rad/sample)");
        ylim([0, 1]);

        axes(h.ax_filt_spec);
        imagesc(t2, wn2, S2_db, clims);
        axis xy; colorbar;
        title("Spectrogram");
        xlabel("Time (s)");
        ylabel("Normalized Frequency (\\times\\pi rad/sample)");
        ylim([0, 1]);
    end

    function cb_volume(src, ~)
        h = guidata(src);
        h.volume = get(src, "value");
        set(h.txt_vol, "String", sprintf("%.0f%%", h.volume * 100));
        guidata(h.fig, h);
    end

    function cb_play_orig(src, ~)
        h = guidata(src);
        if isfield(h, "player") && isobject(h.player)
            stop(h.player);
        end
        h.player = audioplayer(h.signal * h.volume, h.Fs_audio);
        guidata(h.fig, h);
        play(h.player);
    end

    function cb_play_filt(src, ~)
        h = guidata(src);
        if isfield(h, "player") && isobject(h.player)
            stop(h.player);
        end
        h.player = audioplayer(h.filtered * h.volume, h.Fs_audio);
        guidata(h.fig, h);
        play(h.player);
    end

    function cb_save_wav(src, ~)
        h = guidata(src);
        [fname, fpath] = uiputfile("*.wav", "Save Filtered Audio");
        if isequal(fname, 0); return; end
        filepath = fullfile(fpath, fname);
        audiowrite(filepath, h.filtered, h.Fs_audio);
        msgbox(sprintf("Filtered audio saved to:\n%s", filepath), "Save Successful");
    end

    function cb_stop(src, ~)
        h = guidata(src);
        if isfield(h, "player") && isobject(h.player)
            stop(h.player);
        end
    end

    function cb_back(src, ~)
        h = guidata(src);
        if isfield(h, "player") && isobject(h.player)
            stop(h.player);
        end
        delete(h.fig);
        if ishandle(parent_fig)
            set(parent_fig, "Visible", "on");
        end
    end
end
