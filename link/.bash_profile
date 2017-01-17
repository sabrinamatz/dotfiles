# Esse arquivo é executado uma vez sempre que o usuário fizer login na maquina.
# O arquivo profile faz a mesama coisa quando o login é via terminal, ou
# ssh
# O bashrc é executado a cada nova janela de terminal


[ -r ~/.profile ] && . ~/.profile             # set up environment, once, Bourne-sh syntax only

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add
fi