(
/*
Efecto VST simple - Solo Reverb
================================
Versión minimal corregida para SuperDirt.
El nombre del SynthDef debe incluir el número de canales.
*/

if(~dirt.isNil) {
    "[ERROR] SuperDirt no está inicializado".postln;
} {
    
    // Buscar plugins VST
    VSTPlugin.search(s, ["/usr/lib/vst3", "/usr/local/lib/vst3", "~/.vst3".standardizePath]);
    
    // ========================================
    // SYNTHDEF para efecto Reverb VST
    // El nombre debe terminar con el número de canales
    // ========================================
    
    (1..SuperDirt.maxSampleNumChannels).do { |numChannels|
        
        SynthDef("dirt_vst_reverb" ++ numChannels, { |dryBus, effectBus, gate = 1, room = 0.5, pre = 0, size = 0.5, damp = 0.5, hiband = 0.5, lowband = 0.5|
            var signal, wetSignal, output;
            
            signal = In.ar(dryBus, numChannels);
            
            // VST procesa la señal
            wetSignal = VSTPlugin.ar(signal, numChannels, id: \vstreverb);
            
            // Wet/dry mix
            output = (signal * (1 - room)) + (wetSignal * room);
            
            output = output * EnvGen.kr(Env.asr(0.1, 1, 0.1), gate, doneAction: 2);
            DirtPause.ar(output, graceTime: 4);
            Out.ar(effectBus, output);
        }, [\ir, \ir]).add;
    };
    
    s.sync;
    
    // ========================================
    // Añadir efecto a SuperDirt
    // IMPORTANTE: No usar nombre que colisione con efectos nativos
    // El parámetro \room colisiona con el room nativo de SuperDirt
    // Usamos \vstroom en su lugar
    // ========================================
    
    ~dirt.orbits.do { |orbit|var i;
        
        // Encontrar el índice del efecto reverb nativo si existe
        i = orbit.globalEffects.detectIndex { |fx| fx.name.asString.contains("dirt_reverb") };
        
        if(i.notNil) {
            // Reemplazar el reverb nativo con el VST
            orbit.globalEffects[i] = GlobalDirtEffect(\dirt_vst_reverb, [\vstroom, \vstsize, \vstpre, \vstdamp]);
            postln("Reemplazado reverb nativo en orbit %".format(orbit));
        } {
            // Si no existe reverb, añadirlo
            orbit.globalEffects = orbit.globalEffects.add(
                GlobalDirtEffect(\dirt_vst_reverb, [\vstroom, \vstsize, \vstpre, \vstdamp])
            );
            postln("Añadido reverb VST en orbit %".format(orbit));
        };
        
        orbit.initNodeTree;
    };
    
    postln("\n[VST Reverb configurado]");
    postln("========================");
    postln("Parámetros Tidal:");
    postln("  # vstroom 0.5   -- wet/dry (0-1)");
    postln("  # vstsize 0.5    -- room size");
    postln("  # vstpre 0.0     -- pre-delay");
    postln("  # vstdamp 0.5     -- damping");
    postln("");
    postln("Para abrir editor GUI:");
    postln("  ~vstReverbEditor.()");
    
    // Controller se inicializará cuando se necesite
    ~vstReverb = nil;
    
    ~vstReverbEditor = {
        var found = false;
        if(~vstReverb.notNil) {
            ~vstReverb.editor;
        } {
            // Buscar el synth del efecto en el primer orbit
            ~dirt.orbits.do { |orbit, i|
                orbit.globalEffects.do { |effect|
                    if(effect.synth.notNil && (effect.synth.def.name.asString.contains("dirt_vst_reverb"))) {
                        ~vstReverb = VSTPluginController(effect.synth, id: \vstreverb);
                        ~vstReverb.open('Room Builder Stereo');
                        ~vstReverb.editor;
                        found = true;
                    };
                };
                if(found) { ^this };
            };
            if(found.notNil) {
                "VST Reverb encontrado y editor abierto.".postln;
            } {
                "No se encontró el VST. Intenta reproducir audio primero.".postln;
            };
        };
    };
    
    ~listReverbParams = {
        if(~vstReverb.notNil) {
            postln("\n=== Room Builder Stereo ===");
            for(0, ~vstReverb.numParameters - 1) { |i|
                postln("[%] % = %".format(i, ~vstReverb.getParameterName(i) ?? "?", ~vstReverb.getParameter(i)));
            };
        } {
            "VST no inicializado. Ejecuta ~vstReverbEditor.()".postln;
        };
    };
};
)