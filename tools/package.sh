#!/bin/bash
set -e

PKGDIR="${MESON_BUILD_ROOT}/pkg"

mkdir -p "$PKGDIR"
cd "$PKGDIR"

mkdir -p spoutwire-dlls/x86_64-windows
cp "${MESON_BUILD_ROOT}/spoutwire.exe" spoutwire-dlls/x86_64-windows
# Provide a spoutwire.dll so LoadLibraryW("spoutwire.dll") in WinMain succeeds.
# Marked as a Wine builtin DLL so it also maps to the spoutwire.so unixlib.
cp "${MESON_BUILD_ROOT}/spoutwire.exe" spoutwire-dlls/x86_64-windows/spoutwire.dll
mkdir -p spoutwire-dlls/x86_64-unix
cp "${MESON_BUILD_ROOT}/spoutwire_unixlib.so" spoutwire-dlls/x86_64-unix/spoutwire.so
cp "${MESON_SOURCE_ROOT}/misc/spoutwire.inf" .
cp "${MESON_SOURCE_ROOT}/misc/spoutwire.sh" .

# Mark both PE files as Wine builtin DLLs so Wine automatically loads the
# matching spoutwire.so unixlib from WINEDLLPATH/x86_64-unix/ when either is
# loaded. This registers the module in builtin_modules, allowing
# __wine_init_unix_call() to succeed.
for i in spoutwire-dlls/x86_64-windows/*; do
    echo -ne "Wine builtin DLL\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0" | \
        dd of=$i bs=1 seek=64 conv=notrunc \
        2>/dev/null
done
