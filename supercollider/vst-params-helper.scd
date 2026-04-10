(
/*
Listar y controlar parámetros VST
=================================

Este archivo proporciona funciones para:
1. Listar parámetros de cada plugin VST
2. Controlar parámetros específicos del VST programáticamente

USO:
====
~listReverbParams.()     -- Ver parámetros del Room Builder
~listDelay2Params.()     -- Ver parámetros del Artistic Delay
~listSidechainParams.()  -- Ver parámetros del Sidechain Compressor
~listClipParams.()        -- Ver parámetros del Clipper
~listLpf2Params.()        -- Ver parámetros del Filter

~setReverbParam.(0, 0.5)              -- Setear por índice
~setReverbParam.(orbitNum: 0, index: 0, value: 0.5)

Ejemplo:
~setReverbParam.(0, 0.7)  -- Parámetro 0 = 0.7
*/

// Función genérica para listar parámetros
~listVSTParams = { |controller|
    var numParams, params;
    if(controller.notNil) {
        numParams = controller.numParameters;
        postln("\nParámetros disponibles:");
        postln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        postln("Índice | Nombre | Valor");
        postln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        for(0, numParams - 1) { |i|
            postln("[%] % = %".format(
                i,
                controller.getParameterName(i) ?? "?",
                controller.getParameter(i) ?? 0.0
            ));
        };
        postln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    } {
        "Controlador no inicializado. Ejecuta ~initVSTControllers.()".postln;
    };
};

// Inicializar arrays si no existen
if(~reverbControllers.isNil) { ~reverbControllers = [] };
if(~delay2Controllers.isNil) { ~delay2Controllers = [] };
if(~sidechainControllers.isNil) { ~sidechainControllers = [] };
if(~clipControllers.isNil) { ~clipControllers = [] };
if(~lpf2Controllers.isNil) { ~lpf2Controllers = [] };

postln("\n========================================");
postln("LISTAR PARÁMETROS VST");
postln("========================================");
postln("\nEjecuta para ver parámetros de cada VST:");
postln("  ~listReverbParams.()");
postln("  ~listDelay2Params.()");
postln("  ~listSidechainParams.()");
postln("  ~listClipParams.()");
postln("  ~listLpf2Params.()");
postln("\nPara setear valores:");
postln("  ~setReverbParam.(orbitNum, index, value)");
postln("  ~setDelay2Param.(orbitNum, index, value)");
postln("  etc.");
);

// Funciones para listar parámetros de cada VST
~listReverbParams = { |orbitNum = 0|
    postln("\n=== ROOM BUILDER STEREO [Orbit %]===".format(orbitNum));
    if(~reverbControllers[orbitNum].notNil) {
        ~listVSTParams.(~reverbControllers[orbitNum]);
    } {
        "VST no cargado en orbit %.".format(orbitNum).postln;
    };
};

~listDelay2Params = { |orbitNum = 0|
    postln("\n=== ARTISTIC DELAY STEREO [Orbit %]===".format(orbitNum));
    if(~delay2Controllers[orbitNum].notNil) {
        ~listVSTParams.(~delay2Controllers[orbitNum]);
    } {
        "VST no cargado en orbit %.".format(orbitNum).postln;
    };
};

~listSidechainParams = { |orbitNum = 0|
    postln("\n=== SIDECHAIN COMPRESSOR STEREO [Orbit %]===".format(orbitNum));
    if(~sidechainControllers[orbitNum].notNil) {
        ~listVSTParams.(~sidechainControllers[orbitNum]);
    } {
        "VST no cargado en orbit %.".format(orbitNum).postln;
    };
};

~listClipParams = { |orbitNum = 0|
    postln("\n=== CLIPPER STEREO [Orbit %]===".format(orbitNum));
    if(~clipControllers[orbitNum].notNil) {
        ~listVSTParams.(~clipControllers[orbitNum]);
    } {
        "VST no cargado en orbit %.".format(orbitNum).postln;
    };
};

~listLpf2Params = { |orbitNum = 0|
    postln("\n=== FILTER STEREO [Orbit %]===".format(orbitNum));
    if(~lpf2Controllers[orbitNum].notNil) {
        ~listVSTParams.(~lpf2Controllers[orbitNum]);
    } {
        "VST no cargado en orbit %.".format(orbitNum).postln;
    };
};

/*
SETear parámetros VST manualmente
=================================

Los índices los obtienes con ~listXXXParams.()

Ejemplo:
~setReverbParam.(0, 0.5)              -- Parámetro 0 = 0.5
~setReverbParam.(orbitNum: 0, index: 2, value: 0.7)

O directamente:
~reverbControllers[0].set(0, 0.5)
~reverbControllers[0].set(1, 0.7, 2, 0.3)  -- Múltiples

Por nombre (si el plugin lo soporta):
~reverbControllers[0].set('room_size', 0.8)
*/

// Funciones helper por defecto (orbit 0)
~setReverbParamIndexed = { |index, value|
    if(~reverbControllers[0].notNil) {
        ~reverbControllers[0].set(index, value);
    };
};

~setDelay2ParamIndexed = { |index, value|
    if(~delay2Controllers[0].notNil) {
        ~delay2Controllers[0].set(index, value);
    };
};

~setSidechainParamIndexed = { |index, value|
    if(~sidechainControllers[0].notNil) {
        ~sidechainControllers[0].set(index, value);
    };
};

~setClipParamIndexed = { |index, value|
    if(~clipControllers[0].notNil) {
        ~clipControllers[0].set(index, value);
    };
};

~setLpf2ParamIndexed = { |index, value|
    if(~lpf2Controllers[0].notNil) {
        ~lpf2Controllers[0].set(index, value);
    };
};

// Funciones con orbit específico
~setReverbParamOrbit = { |orbitNum, index, value|
    if(~reverbControllers[orbitNum].notNil) {
        ~reverbControllers[orbitNum].set(index, value);
    };
};

~setDelay2ParamOrbit = { |orbitNum, index, value|
    if(~delay2Controllers[orbitNum].notNil) {
        ~delay2Controllers[orbitNum].set(index, value);
    };
};

~setSidechainParamOrbit = { |orbitNum, index, value|
    if(~sidechainControllers[orbitNum].notNil) {
        ~sidechainControllers[orbitNum].set(index, value);
    };
};

~setClipParamOrbit = { |orbitNum, index, value|
    if(~clipControllers[orbitNum].notNil) {
        ~clipControllers[orbitNum].set(index, value);
    };
};

~setLpf2ParamOrbit = { |orbitNum, index, value|
    if(~lpf2Controllers[orbitNum].notNil) {
        ~lpf2Controllers[orbitNum].set(index, value);
    };
};

// Funciones por nombre del parámetro (si el plugin lo soporta)
~setReverbParamByName = { |paramsDict|
    if(~reverbControllers[0].notNil) {
        paramsDict.keysValuesDo { |key, value|
            ~reverbControllers[0].set(key, value);
        };
    };
};

~setDelay2ParamByName = { |paramsDict|
    if(~delay2Controllers[0].notNil) {
        paramsDict.keysValuesDo { |key, value|
            ~delay2Controllers[0].set(key, value);
        };
    };
};

~setSidechainParamByName = { |paramsDict|
    if(~sidechainControllers[0].notNil) {
        paramsDict.keysValuesDo { |key, value|
            ~sidechainControllers[0].set(key, value);
        };
    };
};

~setClipParamByName = { |paramsDict|
    if(~clipControllers[0].notNil) {
        paramsDict.keysValuesDo { |key, value|
            ~clipControllers[0].set(key, value);
        };
    };
};

~setLpf2ParamByName = { |paramsDict|
    if(~lpf2Controllers[0].notNil) {
        paramsDict.keysValuesDo { |key, value|
            ~lpf2Controllers[0].set(key, value);
        };
    };
};
)