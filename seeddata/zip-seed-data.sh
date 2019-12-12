#!/bin/bash
set -eu

CSI=$(printf "\033[")
BOLD="$CSI;1m"
WARN="$CSI;31;1m"
INFO="$CSI;34;1m"
RESET="$CSI;0m"

code() {
  echo "    $BOLD$@$RESET"
}

step() {
  echo
  echo "${INFO}Step $1:$RESET $2"
  echo
}

batch=${1:-}
if [[ $batch == "" ]]; then
  echo "A batch must be specified"
  exit 1
fi

if [[ ! -d $batch ]]; then
  echo "Batch name must represent a directory (./$batch is not a directory)"
  exit 1
fi

echo
echo "${WARN}Sanity check!$RESET"
echo "Are you set up to ingest migration seed data?"
step 1a "first-run setup:"
code "./build/firstrun.sh"
step 1b "OR to do this manually:"
code "bundle exec rails hyrax:default_admin_set:create"
code "bundle exec rails hyrax:default_collection_types:create"
code "bundle exec rails hyrax:workflow:load"
code "bundle exec rake oregon_digital:create_admin_sets"
step 2 "create core OD collections:"
code "bundle exec rake oregon_digital:create_collections"
step 3 "alter \`config/initializers/hyrax_migrator.rb\`:"
code "config.upload_storage_service = :file_system"
code "config.skip_field_mode = true"
echo

dest=$(realpath ../tmp/shared/batch_$batch)
echo "${WARN}Creating batch in $dest$RESET"
rm -rf $dest
mkdir -p $dest

for assetdir in $(find $1/ -mindepth 1 -maxdepth 1 -type d); do
  pid=${assetdir##*/}
  pushd . >/dev/null
  cd $assetdir
  echo "  - Zipping $assetdir into $dest/$pid.zip"
  zip -r0q $dest/$pid.zip .
  popd >/dev/null
done
echo "${WARN}Done${RESET}"

step 4 "start the ingest:"
echo "    rails runner 'Hyrax::Migrator::Services::BagIngestService.new([\"batch_$batch\"], Hyrax::Migrator.config).ingest'"
