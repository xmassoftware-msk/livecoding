// SuperDirt conectado a Bitwig via MIDI
Server.default.options.device = nil;
s.options.numBuffers = 8192;
s.options.numOutputBusChannels = 16;
s.options.numInputBusChannels = 2;
s.options.memSize = 8192 * 64;

// Buscar plugins VST en directorios estándar y del proyecto
VSTPlugin.search(s, ["/usr/lib/vst3", "/usr/local/lib/vst3", "~/.vst3".standardizePath]);

s.waitForBoot {    
    ~dirt = SuperDirt(2, s);
    // ~dirt.loadSoundFiles;
    ~dirt.loadSoundFiles("/home/alex/Descargas/Samples/dirt_samples/*");
    
    // Cargar efectos VST para Room y Delay (DESPUÉS de SuperDirt)
    load(thisProcess.platform.userConfigDir ++ "/vst-effects.scd");
    
    // Cargar helper para listar y controlar parámetros VST
    load(thisProcess.platform.userConfigDir ++ "/vst-params-helper.scd");
    
    MIDIClient.init;
    
    // Puerto virtual que Bitwig detecta
    ~midiOut = MIDIOut.newByName("Virtual Raw MIDI 0-0", "VirMIDI 0-0");
    ~midiOut.latency = 0;

    // Cargar configuración de mapeo MIDI para Bitwig ANTES de addMIDI
    // Esto modifica DirtEventTypes.midiEvent antes de que se copie
    load(thisProcess.platform.userConfigDir ++ "/bitwig-midi-mapping.scd");

    ~dirt.soundLibrary.addMIDI(\midi, ~midiOut);    
    ~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14]); // Asigna cada 'orbit' a un par de salidas            
};