function [Input, Desired] = filter_synthesis_input(f, a, ph, c, fs, ns)
    DesiredWave = dsp.SineWave(a.*c, f, ph, "SampleRate", fs, "SamplesPerFrame", ns);
    Desired = sum(DesiredWave(),2);
    InputWave = dsp.SineWave(c, f, "SampleRate", fs, "SamplesPerFrame", ns);
    Input = sum(InputWave(),2);
end

