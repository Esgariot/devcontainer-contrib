#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${0}")" &>/dev/null && pwd -P)

feature="${1}"
cmdline="${2:-"${1} --version"}"

[[ "${feature}" =~ ^[-_0-9a-zA-Z]+$ ]] || exit 1

feature_test_path="${script_dir}/../test/${feature}"

mkdir -p "${feature_test_path}"

cat <<- EOF > "${feature_test_path}/test.sh"
#!/usr/bin/env bash

source dev-container-features-test-lib

check "'$feature' executable is present in PATH and works" $cmdline

reportResults
EOF
