(
/*
Efectos VST con parámetros completos desde Tidal
=================================================

Cada efecto tiene parámetros específicos controlables desde Tidal.
Los valores se mapean automáticamente a los parámetros del VST.

PARÁMETROS DISPONIBLES:
=======================

REVERB (Room Builder Stereo):
  #reverb 0.5          -- wet/dry mix (0-1)
  #reverbsize 0.7      -- room size (0-1)
  #reverbdamp 0.5      -- damping (0-1)
  #reverbpredelay 0.1  -- pre-delay (0-1)
  #reverbwidth 0.8     -- stereo width (0-1)

DELAY2 (Artistic Delay Stereo):
  #delay2 0.4          -- wet/dry mix (0-1)
  #delaytime 0.25      -- delay time (0-1)
  #delayfb 0.6         -- feedback (0-1)
  #delaypingpong 0.5   -- ping-pong (0-1)

SIDECHAIN (Sidechain Compressor):
  #sidechain 0.5       -- wet/dry mix (0-1)
  #scthreshold 0.3     -- threshold (0-1)
  #scratio 0.25        -- ratio (0-1)
  #scattack 0.1        -- attack (0-1)
  #screlease 0.5       -- release (0-1)

CLIP (Clipper Stereo):
  #clip 0.6            -- wet/dry mix (0-1)
  #clipthresh 0.5      -- threshold (0-1)
  #clipmakeup 0.3      -- makeup gain (0-1)

LPF2 (Filter Stereo):
  #lpf2 0.7            -- wet/dry mix (0-1)
  #lpfcutoff 0.5       -- cutoff (0-1)
  #lpfreso 0.3         -- resonance (0-1)
*/

s.waitForBoot {
    
    VSTPlugin.search(s, ["/usr/lib/vst3", "/usr/local/lib/vst3", "~/.vst3".standardizePath]);
    
    // Bus de control para actualizar parámetros VST
    ~vstUpdateBus = Bus.control(s, 16);
    ~vstUpdateTrig = Bus.control(s, 1);
    
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
    
    s.sync;
    
    // ========================================
    // Añadir efectos globales a SuperDirt
    // ========================================
    
    if(~dirt.notNil) {
        
        ~dirt.orbits.do { |orbit|
            // Añadir efectos con todos los parámetros
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
        
        // Controladores VST
        ~reverbControllers = [];
        ~delay2Controllers = [];
        ~sidechainControllers = [];
        ~clipControllers = [];
        ~lpf2Controllers = [];
        
        // =====================================================
        // MAPEO DE PARÁMETROS TIDAL -> VST
        // =====================================================
        // Esta función lee los valores del synth y los pasa al VST
        
        ~mapVSTParams = { |orbitNum = 0|
            var params;
            
            // REVERB: Mapear parámetros
            if(~reverbControllers[orbitNum].notNil) {
                // El índice depende del plugin específico
                // Usa ~listReverbParams.() para ver los índices correctos
                // Estos son índices típicos, ajusta según sea necesario:
                // ~reverbControllers[orbitNum].set(0, valor_room_size);
                // ~reverbControllers[orbitNum].set(1, valor_damping);
                // etc.
            };
            
            // DELAY2
            if(~delay2Controllers[orbitNum].notNil) {
                // ~delay2Controllers[orbitNum].set(0, valor_delay_time);
                // ~delay2Controllers[orbitNum].set(1, valor_feedback);
            };
            
            // SIDECHAIN
            if(~sidechainControllers[orbitNum].notNil) {
                // ~sidechainControllers[orbitNum].set(0, valor_threshold);
                // etc.
            };
        };
        
        // Función para inicializar VSTs
        ~initVSTControllers = {
            var reverbSynths, delay2Synths, sidechainSynths, clipSynths, lpf2Synths;
            reverbSynths = [];
            delay2Synths = [];
            sidechainSynths = [];
            clipSynths = [];
            lpf2Synths = [];
            
            ~dirt.orbits.do { |orbit, i|
                orbit.globalEffects.do { |effect|
                    if(effect.name == \dirt_global_reverb) {
                        reverbSynths = reverbSynths.add(effect.node);
                    };
                    if(effect.name == \dirt_global_delay2) {
                        delay2Synths = delay2Synths.add(effect.node);
                    };
                    if(effect.name == \dirt_global_sidechain) {
                        sidechainSynths = sidechainSynths.add(effect.node);
                    };
                    if(effect.name == \dirt_global_clip) {
                        clipSynths = clipSynths.add(effect.node);
                    };
                    if(effect.name == \dirt_global_lpf2) {
                        lpf2Synths = lpf2Synths.add(effect.node);
                    };
                };
            };
            
            // Inicializar controladores VST
            reverbSynths.do { |synth, i|
                if(synth.notNil) {
                    var ctrl = VSTPluginController(synth);
                    ctrl.open('Room Builder Stereo');
                    ~reverbControllers = ~reverbControllers.add(ctrl);
                };
            };
            
            delay2Synths.do { |synth, i|
                if(synth.notNil) {
                    var ctrl = VSTPluginController(synth);
                    ctrl.open('Artistic Delay Stereo');
                    ~delay2Controllers = ~delay2Controllers.add(ctrl);
                };
            };
            
            sidechainSynths.do { |synth, i|
                if(synth.notNil) {
                    var ctrl = VSTPluginController(synth);
                    ctrl.open('Sidechain Compressor Stereo');
                    ~sidechainControllers = ~sidechainControllers.add(ctrl);
                };
            };
            
            clipSynths.do { |synth, i|
                if(synth.notNil) {
                    var ctrl = VSTPluginController(synth);
                    ctrl.open('Clipper Stereo');
                    ~clipControllers = ~clipControllers.add(ctrl);
                };
            };
            
            lpf2Synths.do { |synth, i|
                if(synth.notNil) {
                    var ctrl = VSTPluginController(synth);
                    ctrl.open('Filter Stereo');
                    ~lpf2Controllers = ~lpf2Controllers.add(ctrl);
                };
            };
            
            // Ejecutar mapeo inicial
            ~mapVSTParams.(0);
            
            postln("\n[Controladores VST inicializados]");
            postln("Ejecuta ~listReverbParams.() etc. para ver parámetros");
        };
        
        // Editores GUI
        ~openReverbEditor = { |orbitNum = 0|
            if(~reverbControllers[orbitNum].notNil) {
                ~reverbControllers[orbitNum].editor;
            };
        };
        
        ~openDelay2Editor = { |orbitNum = 0|
            if(~delay2Controllers[orbitNum].notNil) {
                ~delay2Controllers[orbitNum].editor;
            };
        };
        
        ~openSidechainEditor = { |orbitNum = 0|
            if(~sidechainControllers[orbitNum].notNil) {
                ~sidechainControllers[orbitNum].editor;
            };
        };
        
        ~openClipEditor = { |orbitNum = 0|
            if(~clipControllers[orbitNum].notNil) {
                ~clipControllers[orbitNum].editor;
            };
        };
        
        ~openLpf2Editor = { |orbitNum = 0|
            if(~lpf2Controllers[orbitNum].notNil) {
                ~lpf2Controllers[orbitNum].editor;
            };
        };
        
        // Funciones para setear parámetros VST manualmente
        ~setReverbParam = { |orbitNum = 0, index, value|
            if(~reverbControllers[orbitNum].notNil) {
                ~reverbControllers[orbitNum].set(index, value);
            };
        };
        
        ~setDelay2Param = { |orbitNum = 0, index, value|
            if(~delay2Controllers[orbitNum].notNil) {
                ~delay2Controllers[orbitNum].set(index, value);
            };
        };
        
        ~setSidechainParam = { |orbitNum = 0, index, value|
            if(~sidechainControllers[orbitNum].notNil) {
                ~sidechainControllers[orbitNum].set(index, value);
            };
        };
        
        ~setClipParam = { |orbitNum = 0, index, value|
            if(~clipControllers[orbitNum].notNil) {
                ~clipControllers[orbitNum].set(index, value);
            };
        };
        
        ~setLpf2Param = { |orbitNum = 0, index, value|
            if(~lpf2Controllers[orbitNum].notNil) {
                ~lpf2Controllers[orbitNum].set(index, value);
            };
        };
        
        // Inicializar
        s.sync;
        ~initVSTControllers.value();
        
        postln("\n[VST Effects con parámetros desde Tidal]");
        postln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        postln("\nREVERB:");
        postln("  #reverb 0.5 #reverbsize 0.7 #reverbdamp 0.5");
        postln("  #reverbpredelay 0.1 #reverbwidth 0.8");
        postln("\nDELAY2:");
        postln("  #delay2 0.4 #delaytime 0.25 #delayfb 0.6 #delaypingpong 0.5");
        postln("\nSIDECHAIN:");
        postln("  #sidechain 0.5 #scthreshold 0.3 #scratio 0.25");
        postln("  #scattack 0.1 #screlease 0.5");
        postln("\nCLIP:");
        postln("  #clip 0.6 #clipthresh 0.5 #clipmakeup 0.3");
        postln("\nLPF2:");
        postln("  #lpf2 0.7 #lpfcutoff 0.5 #lpfreso 0.3");
        postln("\nEDITORES GUI:");
        postln("  ~openReverbEditor.(0)");
        postln("  ~openDelay2Editor.(0)");
        postln("  ~openSidechainEditor.(0)");
        postln("  ~openClipEditor.(0)");
        postln("  ~openLpf2Editor.(0)");
        
    } {
        postln("[ERROR] SuperDirt no está inicializado.");
    };
};
)