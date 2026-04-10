(
/*
Efecto VST simple - Solo Reverb
================================
Versión minimal para probar que funciona.
*/

if(~dirt.isNil) {
    "[ERROR] SuperDirt no está inicializado".postln;
} {
    
    // Buscar plugins VST
    VSTPlugin.search(s, ["/usr/lib/vst3", "/usr/local/lib/vst3", "~/.vst3".standardizePath]);
    
    // ========================================
    // SYNTHDEF para efecto Reverb VST
    // ========================================
    
    SynthDef(\dirt_vst_reverb, { |dryBus, effectBus, gate = 1, room = 0.5|
        var signal, wetSignal, output;
        var numChannels = ~dirt.numChannels ? 2;
        
        signal = In.ar(dryBus, numChannels);
        
        // VST procesa la señal
        wetSignal = VSTPlugin.ar(signal, numChannels, id: \vstreverb);
        
        // Wet/dry mix
        output = (signal * (1 - room.linlin(0, 1, 0, 1))) + (wetSignal * room.linlin(0, 1, 0, 1));
        
        output = output * EnvGen.kr(Env.asr, gate, doneAction: 2);
        DirtPause.ar(output.sum, graceTime: 4);
        Out.ar(effectBus, output);
    }, [\ir, \ir]).add;
    
    s.sync;
    
    // ========================================
    // Añadir efecto a SuperDirt
    // ========================================
    
    ~dirt.orbits.do { |orbit|
        orbit.globalEffects = orbit.globalEffects.add(
            GlobalDirtEffect(\dirt_vst_reverb, [\room])
        );
        orbit.initNodeTree;
    };
    
    postln("\n[VST Reverb añadido a SuperDirt]");
    postln("=================================");
    postln("Parámetro: #room 0.5");
    postln("");
    postln("Para abrir el editor GUI:");
    postln("  ~vstReverbEditor.()");
    postln("");
    postln("Para ver parámetros del VST:");
    postln("  ~vstReverb.print()");
    
    // ========================================
    // Funciones de utilidad (se inicializan después)
    // ========================================
    
    // Controller y editor se inicializan cuando se necesita
    ~vstReverb = nil;
    ~vstReverbEditor = {
        if(~vstReverb.notNil) {
            ~vstReverb.editor;
        } {
            // Buscar el synth del efecto
            ~dirt.orbits.do { |orbit, i|
                orbit.globalEffects.do { |effect|
                    if(effect.synth.notNil && (effect.synth.def.name == \dirt_vst_reverb)) {
                        ~vstReverb = VSTPluginController(effect.synth, id: \vstreverb);
                        ~vstReverb.open('Room Builder Stereo');
                        ~vstReverb.editor;
                    };
                };
            };
        };
    };
    
    ~listReverbParams = {
        if(~vstReverb.notNil) {
            postln("\n=== Room Builder Stereo - Parámetros ===");
            for(0, ~vstReverb.numParameters - 1) { |i|
                postln("[%] % = %".format(i, ~vstReverb.getParameterName(i) ?? "?", ~vstReverb.getParameter(i)));
            };
        } {
            "VST no inicializado. Ejecuta: ~vstReverbEditor.()".postln;
        };
    };
};
)