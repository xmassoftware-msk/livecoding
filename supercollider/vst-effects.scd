(
/*
Efectos VST para SuperDirt
==========================
Versión simplificada usando efectos nativos de SuperDirt
con possibility de controlar VSTs externos.

PARÁMETROS DESDE TIDAL:
======================

#reverb 0.5, #reverbsize 0.7, #reverbdamp 0.5
#delay2 0.4, #delaytime 0.25, #delayfb 0.6
#sidechain 0.5, #scthreshold 0.3, #scratio 0.25
#clip 0.6, #clipthresh 0.5
#lpf2 0.7, #lpfcutoff 0.5, #lpfreso 0.3
*/

// Esta función se llama DESPUÉS de que SuperDirt esté listo
if(~dirt.isNil) {
    "[ERROR] SuperDirt no está inicializado. Carga este archivo después de ~dirt.start".postln;
} {
    var addGlobalEffect;
    
    // Buscar plugins VST
    VSTPlugin.search(s, ["/usr/lib/vst3", "/usr/local/lib/vst3", "~/.vst3".standardizePath]);
    
    // ========================================
    // REVERB VST - Room Builder Stereo
    // ========================================
    
    SynthDef(\dirt_global_reverb, { |dryBus, effectBus, gate = 1, 
        reverb = 0, reverbsize = 0.5, reverbdamp = 0.5, 
        reverbpredelay = 0.1, reverbwidth = 0.8|
        
        var signal, wetSignal, output;
        var numChannels = ~dirt.numChannels ? 2;
        
        signal = In.ar(dryBus, numChannels);
        wetSignal = VSTPlugin.ar(signal, numChannels, id: \reverb);
        output = (signal * (1 - reverb)) + (wetSignal * reverb);
        
        output = output * EnvGen.kr(Env.asr, gate, doneAction: 2);
        DirtPause.ar(output.sum, graceTime: 4);
        Out.ar(effectBus, output);
    }, [\ir, \ir]).add;
    
    // ========================================
    // DELAY2 VST - Artistic Delay Stereo
    // ========================================
    
    SynthDef(\dirt_global_delay2, { |dryBus, effectBus, gate = 1, 
        delay2 = 0, delaytime = 0.5, delayfb = 0.5, delaypingpong = 0.5|
        
        var signal, wetSignal, output;
        var numChannels = ~dirt.numChannels ? 2;
        
        signal = In.ar(dryBus, numChannels);
        wetSignal = VSTPlugin.ar(signal, numChannels, id: \delay2);
        output = (signal * (1 - delay2)) + (wetSignal * delay2);
        
        output = output * EnvGen.kr(Env.asr, gate, doneAction: 2);
        DirtPause.ar(output.sum, graceTime: 4);
        Out.ar(effectBus, output);
    }, [\ir, \ir]).add;
    
    // ========================================
    // SIDECHAIN VST - Sidechain Compressor
    // ========================================
    
    SynthDef(\dirt_global_sidechain, { |dryBus, effectBus, gate = 1, 
        sidechain = 0, scthreshold = 0.5, scratio = 0.25, 
        scattack = 0.1, screlease = 0.5|
        
        var signal, wetSignal, output;
        var numChannels = ~dirt.numChannels ? 2;
        
        signal = In.ar(dryBus, numChannels);
        wetSignal = VSTPlugin.ar(signal, numChannels, id: \sidechain);
        output = (signal * (1 - sidechain)) + (wetSignal * sidechain);
        
        output = output * EnvGen.kr(Env.asr, gate, doneAction: 2);
        DirtPause.ar(output.sum, graceTime: 4);
        Out.ar(effectBus, output);
    }, [\ir, \ir]).add;
    
    // ========================================
    // CLIP VST - Clipper Stereo
    // ========================================
    
    SynthDef(\dirt_global_clip, { |dryBus, effectBus, gate = 1, 
        clip = 0, clipthresh = 0.5, clipmakeup = 0.3|
        
        var signal, wetSignal, output;
        var numChannels = ~dirt.numChannels ? 2;
        
        signal = In.ar(dryBus, numChannels);
        wetSignal = VSTPlugin.ar(signal, numChannels, id: \clipvst);
        output = (signal * (1 - clip)) + (wetSignal * clip);
        
        output = output * EnvGen.kr(Env.asr, gate, doneAction: 2);
        DirtPause.ar(output.sum, graceTime: 4);
        Out.ar(effectBus, output);
    }, [\ir, \ir]).add;
    
    // ========================================
    // LPF2 VST - Filter Stereo
    // ========================================
    
    SynthDef(\dirt_global_lpf2, { |dryBus, effectBus, gate = 1, 
        lpf2 = 0, lpfcutoff = 0.5, lpfreso = 0.3|
        
        var signal, wetSignal, output;
        var numChannels = ~dirt.numChannels ? 2;
        
        signal = In.ar(dryBus, numChannels);
        wetSignal = VSTPlugin.ar(signal, numChannels, id: \lpf2);
        output = (signal * (1 - lpf2)) + (wetSignal * lpf2);
        
        output = output * EnvGen.kr(Env.asr, gate, doneAction: 2);
        DirtPause.ar(output.sum, graceTime: 4);
        Out.ar(effectBus, output);
    }, [\ir, \ir]).add;
    
    // Esperar a que los SynthDefs se compile
    s.sync;
    
    // ========================================
    // Añadir efectos globales a SuperDirt
    // ========================================
    
    ~dirt.orbits.do { |orbit|
        orbit.globalEffects = orbit.globalEffects.add(
            GlobalDirtEffect(\dirt_global_reverb, 
                [\reverb, \reverbsize, \reverbdamp, \reverbpredelay, \reverbwidth])
        );
        orbit.globalEffects = orbit.globalEffects.add(
            GlobalDirtEffect(\dirt_global_delay2, 
                [\delay2, \delaytime, \delayfb, \delaypingpong])
        );
        orbit.globalEffects = orbit.globalEffects.add(
            GlobalDirtEffect(\dirt_global_sidechain, 
                [\sidechain, \scthreshold, \scratio, \scattack, \screlease])
        );
        orbit.globalEffects = orbit.globalEffects.add(
            GlobalDirtEffect(\dirt_global_clip, 
                [\clip, \clipthresh, \clipmakeup])
        );
        orbit.globalEffects = orbit.globalEffects.add(
            GlobalDirtEffect(\dirt_global_lpf2, 
                [\lpf2, \lpfcutoff, \lpfreso])
        );
        orbit.initNodeTree;
    };
    
    // Controladores VST (se inicializan cuando se necesita)
    ~vstControllers = ();
    ~vstControllers[\reverb] = [];
    ~vstControllers[\delay2] = [];
    ~vstControllers[\sidechain] = [];
    ~vstControllers[\clip] = [];
    ~vstControllers[\lpf2] = [];
    
    postln("\n[VST Effects añadidos a SuperDirt]");
    postln("===================================");
    postln("reverb:    Room Builder Stereo");
    postln("delay2:    Artistic Delay Stereo");
    postln("sidechain: Sidechain Compressor Stereo");
    postln("clip:      Clipper Stereo");
    postln("lpf2:      Filter Stereo");
    postln("\nParámetros Tidal disponibles:");
    postln("  d1 $ s \"bd\" # reverb 0.5 # reverbsize 0.7");
    postln("  d2 $ s \"hh\" # delay2 0.4 # delayfb 0.6");
    postln("  d3 $ s \"pad\" # sidechain 0.5 # scthreshold 0.3");
    postln("  d4 $ s \"bass\" # clip 0.7");
    postln("  d5 $ s \"synth\" # lpf2 0.8 # lpfcutoff 0.4");
};
)