#!@bash@/bin/bash
export JAVA_HOME="${JAVA_HOME:-@jdk@}"
export SAL_USE_VCLPLUGIN="${SAL_USE_VCLPLUGIN:-@VCL_PLUGIN@}"

for PROFILE in $NIX_PROFILES; do
    HDIR="$PROFILE/share/hunspell"
    if [ -d "$HDIR" ]; then
        export DICPATH=$DICPATH''${DICPATH:+:}$HDIR
    fi
done

"@libreoffice@/bin/$(basename "$0")" "$@"
