#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Sync All Packages to https://github.com/pkgforge/bincache/releases
## Self: https://raw.githubusercontent.com/pkgforge/bincache/refs/heads/main/scripts/github/sync_releases.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/bincache/refs/heads/main/scripts/github/sync_releases.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##Sanity
if ! command -v gh &> /dev/null; then
  echo -e "[-] Failed to find Github CLI (gh)\n"
 exit 1 
fi
if [ -z "${GITHUB_TOKEN+x}" ] || [ -z "${GITHUB_TOKEN##*[[:space:]]}" ]; then
  echo -e "\n[-] FATAL: Failed to Find GITHUB_TOKEN (\${GITHUB_TOKEN}\n"
 exit 1
else
  ##gh-cli (uses ${GITHUB_TOKEN} env var)
   #echo "${GITHUB_TOKEN}" | gh auth login --with-token
   gh auth status
fi
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
if [[ -z "${USER_AGENT}" ]]; then
 USER_AGENT="$(curl -qfsSL 'https://raw.githubusercontent.com/pkgforge/devscripts/refs/heads/main/Misc/User-Agents/ua_firefox_macos_latest.txt')"
fi
##Host
HOST_TRIPLET="$(uname -m)-$(uname -s)"
HOST_TRIPLET_L="${HOST_TRIPLET,,}"
export HOST_TRIPLET HOST_TRIPLET_L
##Metadata
curl -qfsSL "https://meta.pkgforge.dev/bincache/${HOST_TRIPLET}.json" -o "${TMPDIR}/METADATA.json"
if [[ "$(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/METADATA.json" | wc -l)" -le 20 ]]; then
  echo -e "\n[-] FATAL: Failed to Fetch bincache (${HOST_TRIPLET}) Metadata\n"
 exit 1
fi
if ! command -v oras &> /dev/null; then
  echo -e "[-] Failed to find oras\n"
 exit 1
else
  oras login --username "Azathothas" --password "${GHCR_TOKEN}" "ghcr.io"
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Main
sync_to_gh_release() 
{
 ##Chdir
  pushd "${TMPDIR}" >/dev/null 2>&1
 ##Enable Debug
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set -x
  fi
 ##Input
  local INPUT="${1:-$(cat)}"
  export GHCR_PKG="$(echo ${INPUT} | tr -d '[:space:]')"
  export GHCR_PKGNAME="$(echo ${INPUT} | awk -F'[:]' '{print $1}' | tr -d '[:space:]')"
  export GHCR_PKGVER="$(echo ${INPUT} | awk -F'[:]' '{print $2}' | tr -d '[:space:]')"
  export GHCR_PKGPATH="$(echo ${INPUT} | sed -n 's/.*\/bincache\/\(.*\):.*/\1/p' | tr -d '[:space:]')"
  export SRC_TAG="${GHCR_PKGPATH}/${GHCR_PKGVER}"
  export GH_PKG="https://github.com/pkgforge/bincache/releases/tag/${SRC_TAG}"
  export PKG_DIR="$(mktemp -d)"
 ##Sync
  echo -e "\n[+] Syncing ${GHCR_PKGNAME} (${GHCR_PKGVER})\n"
  unset GH_PKG_STATUS
  GH_PKG_STATUS="$(curl -X "HEAD" -qfsSL "${GH_PKG}" -I | sed -n 's/^[[:space:]]*HTTP\/[0-9.]*[[:space:]]\+\([0-9]\+\).*/\1/p' | tail -n1 | tr -d '[:space:]')"
  #if gh release list --repo "https://github.com/pkgforge/bincache" --json 'tagName' -q ".[].tagName" | grep -q "${SRC_TAG}"; then
   if echo "${GH_PKG_STATUS}" | grep -qi '200$'; then
    if [[ "${FORCE_REUPLOAD}" != "YES" ]]; then
      echo "[+] Skipping ==> ${GH_PKG} [Exists]"
      rm -rf "${PKG_DIR}" 2>/dev/null
      unset GHCR_FILE GHCR_FILES GHCR_PKG GHCR_PKGNAME GHCR_PKGVER GHCR_PKGPATH SRC_TAG SRC_RELEASE_BODY
     return 0 || exit 0
    else
      echo "[+] Force Reuploading ==> ${GH_PKG} [Exists]"
      gh release delete "${SRC_TAG}" --repo "https://github.com/pkgforge/bincache" --cleanup-tag -y
    fi
  fi
  pushd "${PKG_DIR}" >/dev/null 2>&1 && \
   oras pull "${GHCR_PKG}" ; unset GHCR_FILE GHCR_FILES
    #Ensure all files were fetched
     readarray -t "GHCR_FILES" < <(jq -r --arg GHCR_PKG "${GHCR_PKG}" '.[] | select(.ghcr_pkg == $GHCR_PKG) | .ghcr_files[]' "${TMPDIR}/METADATA.json")
     for GHCR_FILE in "${GHCR_FILES[@]}"; do
      if [ ! -s "${PKG_DIR}/${GHCR_FILE}" ]; then
       echo -e "\n[-] Missing/Empty: ${PKG_DIR}/${GHCR_FILE}\n(Retrying ...)\n"
       oras pull "${GHCR_PKG}"
       if [ ! -s "${PKG_DIR}/${GHCR_FILE}" ]; then
         echo -e "\n[-] FATAL: Failed to Fetch ${PKG_DIR}/${GHCR_FILE}\n"
         return 1
       fi
      fi
     done
    #Create Release Body
     PKG_JSON="$(find "${PKG_DIR}" -type f -iname "*.json" -type f -print0 | xargs -0 realpath | head -n 1)"
     jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "" and .value != [] and .value != {})) elif type == "array" then map(select(. != null and . != "" and . != [] and . != {})) else . end)' "${PKG_JSON}" | jq . > "${PKG_JSON}.tmp"
     mv -fv "${PKG_JSON}.tmp" "${PKG_JSON}" ; rm -rf "${TMPDIR}/REl_NOTES.txt" 2>/dev/null
     echo -e '```yaml' > "${TMPDIR}/REl_NOTES.txt"
     yq . "${PKG_JSON}" --output-format='yaml' >> "${TMPDIR}/REl_NOTES.txt"
     echo -e '```' >> "${TMPDIR}/REl_NOTES.txt"
    #Edit json 
     find "${PKG_DIR}" -type f -iname "*.json" -type f -print0 | xargs -0 -I "{}" sed -E "s|https://api\.ghcr\.pkgforge\.dev/pkgforge/bincache/(.*)\?tag=(.*)\&download=(.*)$|https://github.com/pkgforge/bincache/releases/download/\1/\2/\3|g" -i "{}"
    #Upload
     pushd "${PKG_DIR}" >/dev/null 2>&1 && \
       gh release create "${SRC_TAG}" --repo "https://github.com/pkgforge/bincache" --title "${SRC_TAG}" --notes-file "${TMPDIR}/REl_NOTES.txt" --prerelease
       find "${PKG_DIR}" -type f -size +3c -print0 | xargs -0 -P "$(($(nproc)+1))" -I '{}' gh release upload "${SRC_TAG}" --repo "https://github.com/pkgforge/bincache" '{}'
       (
         sleep 10
         unset GH_PKG_STATUS
         GH_PKG_STATUS="$(curl -X "HEAD" -qfsSL "${GH_PKG}" -I | sed -n 's/^[[:space:]]*HTTP\/[0-9.]*[[:space:]]\+\([0-9]\+\).*/\1/p' | tail -n1 | tr -d '[:space:]')"
         if echo "${GH_PKG_STATUS}" | grep -qiv '200$'; then
           echo -e "\n[-] FATAL: Failed to Upload ==> ${GH_PKG}\n"
         fi
       ) &
     pushd "${TMPDIR}" >/dev/null 2>&1
 ##Cleanup
   rm -rf "${PKG_DIR}" "${TMPDIR}/REl_NOTES.txt" 2>/dev/null && popd >/dev/null 2>&1
   unset GHCR_FILE GHCR_FILES GHCR_PKG GHCR_PKGNAME GHCR_PKGVER GHCR_PKGPATH GH_PKG GH_PKG_STATUS SRC_TAG SRC_RELEASE_BODY
 ##Disable Debug 
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set +x
  fi
}
export -f sync_to_gh_release
#-------------------------------------------------------#

#-------------------------------------------------------#
##Run
pushd "${TMPDIR}" >/dev/null 2>&1
 unset GH_PKG_INPUT ; readarray -t "GH_PKG_INPUT" < <(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/METADATA.json" | sort -u)
  if [[ -n "${PARALLEL_LIMIT}" ]]; then
   printf '%s\n' "${GH_PKG_INPUT[@]}" | xargs -P "${PARALLEL_LIMIT}" -I "{}" bash -c 'sync_to_gh_release "$@"' _ "{}"
  else
   printf '%s\n' "${GH_PKG_INPUT[@]}" | xargs -P "$(($(nproc)+1))" -I "{}" bash -c 'sync_to_gh_release "$@"' _ "{}"
  fi
popd >/dev/null 2>&1
#-------------------------------------------------------# 