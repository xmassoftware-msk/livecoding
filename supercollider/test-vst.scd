// Diagnosticar VST Reverb

postln("\n========================================");
postln("DIAGNÓSTICO VST REVERB");
postln("========================================");

// 1. Verificar que SuperDirt está corriendo
postln("\n1. SuperDirt:");
if(~dirt.notNil) {
    postln("   ✓ SuperDirt inicializado");
    postln("   Orbits: %".format(~dirt.orbits.size));
    postln("   Canales: %".format(~dirt.numChannels));
} {
    postln("   ✗ SuperDirt NO está inicializado");
};

// 2. Verificar VSTPlugin
postln("\n2. VSTPlugin:");
postln("   Plugins disponibles: %".format(VSTPlugin.pluginList.size));
if(VSTPlugin.pluginList.size > 0) {
    postln("   ✓ VSTs encontrados");
    VSTPlugin.pluginList.do { |plugin| postln("     - %".format(plugin.name)) };
} {
    postln("   ✗ NO hay VSTs");
};

// 3. Verificar VST Reverb
postln("\n3. VST Reverb:");
postln("   ~vstReverbBus: %".format(~vstReverbBus));
postln("   ~vstReverbSynth: %".format(~vstReverbSynth));
postln("   ~vstReverbController: %".format(~vstReverbController));

if(~vstReverbSynth.notNil) {
    postln("   Synth isPlaying: %".format(~vstReverbSynth.isPlaying));
    postln("   Synth defName: %".format(~vstReverbSynth.defName));
};

if(~vstReverbController.notNil) {
    postln("   VST loaded: %".format(~vstReverbController.loaded));
    postln("   VST name: %".format(~vstReverbController.info.name ?? "NO CARGADO"));
};

// 4. Verificar conexión
postln("\n4. Estado de conexión:");
if(~originalOutBuses.notNil) {
    postln("   ✓ VST conectado (usando bus VST)");
    postln("   Bus VST: %".format(~vstReverbBus.index));
} {
    postln("   ✗ VST NO conectado (audio va directo a speakers)");
    postln("");
    postln("   Ejecuta: ~connectVSTReverb.()");
};

// 5. Test de audio
postln("\n5. Test de audio:");
postln("   Ejecuta en SuperCollider:");
postln("   { SinOsc.ar(440, 0, 0.1) ! 2 }.play");
postln("");
postln("   Ejecuta en Tidal:");
postln("   d1 $ s \"bd sn\"");
postln("");
postln("   Si NO suena el VST:");
postln("   ~connectVSTReverb.()");

postln("\n========================================");