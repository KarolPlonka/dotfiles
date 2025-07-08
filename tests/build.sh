set -e

cp -f ../install_deps.sh .

docker build  -t dotfiles_vm . 

rm -f install_deps.sh
