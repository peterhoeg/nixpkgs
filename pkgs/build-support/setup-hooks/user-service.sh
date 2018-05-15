preInstallPhases+=" userServicePhase"

patchService() {
    mkdir -p $out/lib/systemd/user
    for f in $out/*.service ; do
        substitute $f $out/lib/systemd/user/$(basename $f .service).service \
                   --subst-var out
    done
}

userServicePhase() {
    runHook preUserService

    if [[ ${#userServices[@]} -gt 0 ]]; then
        echo "multiple services defined"
        for f in ${userServices[@]} ; do
            patchService $f
        done
    fi
    if [[ -n "${userService}" ]]; then
        echo "single service defined"
        patchService $userService
    fi

    runHook postUserService
}
