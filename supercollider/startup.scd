// SuperDirt conectado a Bitwig via MIDI
Server.default.options.device = nil;
s.options.numBuffers = 8192;
s.options.numOutputBusChannels = 16;
s.options.numInputBusChannels = 2;
s.options.memSize = 8192 * 64;

s.waitForBoot {    
    ~dirt = SuperDirt(2, s);
    // ~dirt.loadSoundFiles;
    ~dirt.loadSoundFiles("/home/alex/Descargas/Samples/dirt_samples/*");
    
    MIDIClient.init;
    
    // Puerto virtual que Bitwig detecta
    ~midiOut = MIDIOut.newByName("Virtual Raw MIDI 0-0", "VirMIDI 0-0");
    ~midiOut.latency = 0;

    // Cargar configuración de mapeo MIDI para Bitwig ANTES de addMIDI
    load(thisProcess.platform.userConfigDir ++ "/bitwig-midi-mapping.scd");

    ~dirt.soundLibrary.addMIDI(\midi, ~midiOut);    
    ~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14]); // Asigna cada 'orbit' a un par de salidas            
};