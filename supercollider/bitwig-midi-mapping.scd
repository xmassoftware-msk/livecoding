/*
Mapeo de parámetros Tidal a MIDI CC estándar para Bitwig
=========================================================

Este archivo configura el envío automático de MIDI CC cuando se usan
parámetros Tidal como cutoff, lpf, hpf, etc. con el synth MIDI.

IMPORTANTE: Este archivo debe cargarse DESPUÉS de inicializar SuperDirt
en startup.scd

Basado en la lista estándar de MIDI CC:
https://anotherproducer.com/online-tools-for-musicians/midi-cc-list/

Mapeos Tidal -> MIDI CC:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CCs Estándar:
- gain/volume -> CC 7 (Volume)
- pan -> CC 10 (Pan)
- cutoff -> CC 74 (Sound Controller 5 - Filter Cutoff)
- resonance -> CC 71 (Sound Controller 2 - Resonance)
- room (reverb) -> CC 91 (Effect 1 Depth - Reverb)
- chorus -> CC 93 (Effect 3 Depth - Chorus)
- release -> CC 72 (Sound Controller 3 - Release Time)
- attack -> CC 73 (Sound Controller 4 - Attack Time)

CCs Undefined (personalizados):
- lpf -> CC 3 (Undefined)
- hpf -> CC 9 (Undefined)
- size -> CC 14 (Undefined)
- delaytime -> CC 15 (Undefined)
- delayfeedback -> CC 20 (Undefined)
- crush -> CC 21 (Undefined)
- coarse -> CC 22 (Undefined)
*/

(
var freqToCC, linearToCC, originalMidiEventPlayFunc;

// Función para escalar frecuencia a CC (0-127)
freqToCC = { |freq, minFreq = 20, maxFreq = 20000|
((freq.linexp(minFreq, maxFreq, 0, 127))).clip(0, 127).asInteger;
};

// Función para escalar valor lineal a CC (0-127)
linearToCC = { |value, minValue = 0, maxValue = 1|
((value.linlin(minValue, maxValue, 0, 127))).clip(0, 127).asInteger;
};

// Guardamos referencia al midiEvent original
originalMidiEventPlayFunc = DirtEventTypes.midiEvent[\play].deepCopy;

// Extender el midiEvent para enviar CCs adicionales
DirtEventTypes.midiEvent[\play] = { |dirtEvent|
    var midiout, chan, result;
    var paramMappings;
    
    midiout = ~midiout;
    chan = (~midichan ? 0).asInteger;
    
    // Definir mapeos: [parametro, ccNumber, funcionConversion]
    paramMappings = [
        // CCs Estándar MIDI
        [\cutoff, 74, { |val| freqToCC.value(val) }],
        [\resonance, 71, { |val| linearToCC.value(val) }],
        [\gain, 7, { |val| linearToCC.value(val, 0, 2) }],
        [\pan, 10, { |val| linearToCC.value(val, 0, 1) }],
        [\room, 91, { |val| linearToCC.value(val) }],
        [\chorus, 93, { |val| linearToCC.value(val) }],
        [\release, 72, { |val| linearToCC.value(val) }],
        [\attack, 73, { |val| linearToCC.value(val) }],
        [\lpf, 3, { |val| freqToCC.value(val) }],
        [\hpf, 9, { |val| freqToCC.value(val) }],
        [\size, 14, { |val| linearToCC.value(val) }],
        [\delaytime, 15, { |val| linearToCC.value(val) }],
        [\delayfeedback, 20, { |val| linearToCC.value(val) }],
        [\crush, 21, { |val| linearToCC.value(val) }],
        [\coarse, 22, { |val| linearToCC.value(val, 1, 16) }]
    ];
    
    // Enviar CCs para cada parámetro mapeado
    if(midiout.notNil) {
        paramMappings.do { |mapping|
            var paramName = mapping[0];
            var ccNum = mapping[1];
            var conversionFunc = mapping[2];
            var paramValue;
            
            paramValue = currentEnvironment.at(paramName);
            
            if(paramValue.notNil) {
                var ccValue = conversionFunc.value(paramValue);
                midiout.control(chan, ccNum, ccValue);
            };
        };
    };
    
    // Ejecutar el play original (enviar notas MIDI)
    result = originalMidiEventPlayFunc.value();
};

"\n[Bitwig MIDI Mapping activado]".postln;
"Parámetros Tidal -> CC estándar:".postln;
"━━━━━━━━━━━━━━━━━━━━━━━━━━━".postln;
"CCs Estándar MIDI:".postln;
"  cutoff -> CC 74 (Filter Cutoff)".postln;
"  resonance -> CC 71 (Filter Resonance)".postln;
"  gain -> CC 7 (Volume)".postln;
"  pan -> CC 10 (Pan)".postln;
"  room -> CC 91 (Reverb)".postln;
"  chorus -> CC 93 (Chorus)".postln;
"  release -> CC 72 (Release Time)".postln;
"  attack -> CC 73 (Attack Time)".postln;
"".postln;
"CCs Personalizados (Undefined):".postln;
"  lpf -> CC 3".postln;
"  hpf -> CC 9".postln;
"  size -> CC 14".postln;
"  delaytime -> CC 15".postln;
"  delayfeedback -> CC 20".postln;
"  crush -> CC 21 (Bitcrusher)".postln;
"  coarse -> CC 22 (Sample rate)".postln;
"".postln;
)

/*
NOTA: CCs estándar MIDI disponibles pero NO mapeados:
==========================================

CCs MIDI estándar sin uso actualmente:
- CC 1: Modulation Wheel (vibrato) - podría mapearse a 'vibrato' o similar
- CC 2: Breath Controller - sin equivalente en Tidal
- CC 4: Foot Pedal - sin equivalente directo en Tidal
- CC 5: Portamento Time - podría mapearse a parámetros de glide/portamento
- CC 6: Data Entry - reservado para NRPN/RPN
- CC 8: Balance (estéreo) - Tidal usa 'pan' en su lugar
- CC 11: Expression (porcentaje de volumen) - similar a 'gain'
- CC 64: Damper Pedal (Sustain on/off) - Tidal maneja sustain internamente
- CC 65: Portamento on/off - sin equivalente directo
- CC 66: Sostenuto Pedal - sin equivalente en Tidal
- CC 92: Effect 2 Depth (Tremolo) - parámetro 'tremr' o similar no estándar en Tidal
- CC 94: Effect 4 Depth (Detune) - sin equivalente estándar
- CC 95: Effect 5 Depth (Phaser) - sin equivalente estándar

Parámetros Tidal sin CC asignado:
- speed / accelerate - parámetro interno de Tidal
- begin / end - parámetros de sample
- legato - parámetro interno de duración
- timescale - parámetro de tiempo
- nudge - ajuste de timing
- offset - desplazamiento de fase

Para añadir más mapeos:
1. Añade una línea al array paramMappings con el formato:
   [\nombreParametro, numeroCC, { |val| funcionConversion }]
*/