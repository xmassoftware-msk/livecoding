(
/*
VST Effect para SuperDirt - Versión Simple
===========================================

Este es un enfoque simplificado que usa SynthDef distintos para cada
número de canales, como lo hace SuperDirt internamente.

Creamos un SYNTH (no un GlobalDirtEffect) que se puede usar como
instrumento en Tidal: d1 $ s "vstreverb" ...
*/

// Esperar a que todo esté listo
s.waitForBoot {
    
    // Buscar plugins VST
    VSTPlugin.search(s, ["/usr/lib/vst3", "/usr/local/lib/vst3", "~/.vst3".standardizePath]);
    
    // ========================================
    // SynthDefs para el efecto VST
    // Registramos para mono y estéreo
    // ========================================
    
    // Mono
    SynthDef(\vstreverb1, { |out = 0, vstroom = 0.5, vstsize = 0.5|
        var signal;
        signal = In.ar(out, 1);
        signal = VSTPlugin.ar(signal, 1, id: \reverb);
        signal = signal * vstroom + (In.ar(out, 1) * (1 - vstroom));
        ReplaceOut.ar(out, signal);
    }).add;
    
    // Estéreo
    SynthDef(\vstreverb2, { |out = 0, vstroom = 0.5, vstsize = 0.5|
        var signal;
        signal = In.ar(out, 2);
        signal = VSTPlugin.ar(signal, 2, id: \reverb);
        signal = signal * vstroom + (In.ar(out, 2) * (1 - vstroom));
        ReplaceOut.ar(out, signal);
    }).add;
    
    s.sync;
    
    postln("\n[VST Reverb SynthDefs registrados]");
    postln("==================================");
    postln("Synths: \\vstreverb1 (mono), \\vstreverb2 (estéreo)");
    postln("");
    postln("Controladores:");
    postln("  ~vstReverb1 - controller para mono");
    postln("  ~vstReverb2 - controller para estéreo");
    postln("");
    postln("Ejemplo de uso:");
    postln("  { Out.ar(0, VSTPlugin.ar(WhiteNoise.ar(0.1)!2, 2, id: \\reverb)) }.play");
    postln("  ~vstReverb2.set(0, 0.7) // parámetro 0 = 0.7");
    
    // ========================================
    // Función para crear un effecto VST en un bus
    // ========================================
    
    ~createVSTReverb = { |numChannels = 2|
        var synth, controller, bus;
        var synthName = "vstreverb" ++ numChannels;
        
        // Crear bus privado para el efecto
        bus = Bus.audio(s, numChannels);
        
        // Crear synth del efecto
        synth = Synth(synthName, [\out, bus], s, \addToTail);
        
        // Crear controller
        controller = VSTPluginController(synth, id: \reverb);
        controller.open('Room Builder Stereo');
        
        // Devolver todo
        (
            synth: synth,
            controller: controller,
            bus: bus
        )
    };
    
    // Crear effectos VST para uso general
    ~vstReverbMono = ~createVSTReverb.(1);
    ~vstReverbStereo = ~createVSTReverb.(2);
    
    // Abrir editor
    ~openVSTReverbEditor = {
        if(~vstReverbStereo.notNil) {
            ~vstReverbStereo[\controller].editor;
        } {
            "VST no inicializado".postln;
        };
    };
    
    // Setear parámetros
    ~setVSTReverb = { |index, value|
        if(~vstReverbStereo.notNil) {
            ~vstReverbStereo[\controller].set(index, value);
        };
    };
    
    // Listar parámetros
    ~listVSTReverbParams = {
        if(~vstReverbStereo.notNil) {
            postln("\n=== Room Builder Stereo - Parámetros ===");
            for(0, ~vstReverbStereo[\controller].numParameters - 1) { |i|
                postln("[%] % = %".format(
                    i,
                    ~vstReverbStereo[\controller].getParameterName(i) ?? "?",
                    ~vstReverbStereo[\controller].getParameter(i)
                ));
            };
        } {
            "VST no inicializado".postln;
        };
    };
    
    postln("\n[VST Reverb listo para usar]");
    postln("Para abrir el editor: ~openVSTReverbEditor.()");
};
)

/*
NOTAS DE USO:
=============

Este es un enfoque MÁS SIMPLE que intentar crear GlobalDirtEffects.
Los VSTs aquí son synths independientes que puedes usar de varias formas:

1. PARA PROCESAR AUDIO DE SUPERDIRT:
   - Necesitarías redirigir el output de los orbits a un bus
   - Y luego procesar ese bus con el VST
   
2. COMO EFECTO MANUAL:
   - Bus bus = Bus.audio(s, 2);
   - Synth(\vstreverb2, [\out, bus]);
   - Y luego enviar audio a ese bus

3. PARA USO CON TIDAL:
   - Podrías crear un synth que encapsule sample + VST
   - O procesar el output de SuperDirt globalmente

PROBLEMAS CON EL ENFOQUE ANTERIOR:
===================================

- GlobalDirtEffect requiere nombres específicos de SynthDef
- SuperDirt añade el número de canales al nombre
- Si el efecto no está registrado para TODOS los canales, falla
- Los parámetros con nombres existentes (room) colisionan

PROXIMOS PASOS:
===============

Para integrar con SuperDirt como efecto global, necesitaríamos:
1. Entender exactamente cómo SuperDirt crea sus efectos globales
2. Usar los nombres de SynthDef correctos (dirt_reverb1, dirt_reverb2, etc.)
3. Registrar para todos los canales configurados

¿Quieres que intente otro enfoque?
*/