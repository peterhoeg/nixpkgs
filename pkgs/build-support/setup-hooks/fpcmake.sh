preConfigurePhases+=" fpcmakePhase"

for i in @fpc@ ; do
    findInputs $i nativePkgs propagated-native-build-inputs
done

fpcmakePhase() {
    runHook preFpcmake
    fpcmake ${fpcmakeFlags:--w}
    runHook postFpcmake
}
