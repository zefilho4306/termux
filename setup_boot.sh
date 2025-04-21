#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "============================================="
echo "[*] Instalador automático do 3proxy + frpc"
echo "[*] Configurando boot automático com wake-lock"
echo "============================================="

# Etapa 1: Atualizações e dependências
pkg update -y && pkg upgrade -y
pkg install -y git wget curl tsu clang make golang termux-api

# Etapa 2: Clonar e compilar 3proxy
cd ~
rm -rf 3proxy || true
git clone https://github.com/3proxy/3proxy.git
cd 3proxy
make -f Makefile.Linux

# Etapa 3: Gerar config do 3proxy
mkdir -p $PREFIX/etc/3proxy
cat > $PREFIX/etc/3proxy/3proxy.cfg <<EOF
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
auth none
allow *
proxy -n -a -p3128 -i0.0.0.0 -e0.0.0.0
flush
EOF

# Etapa 4: Clonar e compilar frpc
cd ~
rm -rf frp || true
git clone https://github.com/fatedier/frp
cd frp/cmd/frpc
go build

# Etapa 5: Estrutura frpc
mkdir -p ~/proxy_node/frpc
cp ./frpc ~/proxy_node/frpc/frpc
chmod +x ~/proxy_node/frpc/frpc

# Gerar nome/porta aleatória
RANDOM_NAME="ep-$(head /dev/urandom | tr -dc a-z0-9 | head -c6)"
RANDOM_PORT=$(( ( RANDOM % 40000 ) + 10000 ))

cat > ~/proxy_node/frpc/frpc.ini <<EOF
[common]
server_addr = 185.194.205.181
server_port = 7000

[$RANDOM_NAME]
type = tcp
local_ip = 127.0.0.1
local_port = 3128
remote_port = $RANDOM_PORT
EOF

echo "NOME = $RANDOM_NAME" > ~/proxy_node/frpc/INFO.txt
echo "PORTA REMOTA = $RANDOM_PORT" >> ~/proxy_node/frpc/INFO.txt

# Etapa 6: Criar autostart.sh
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/autostart.sh <<EOF
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
sleep 3
nohup env LD_LIBRARY_PATH=\$PREFIX/lib \$PREFIX/bin/3proxy \$PREFIX/etc/3proxy/3proxy.cfg > ~/3proxy.log 2>&1 &
nohup ~/proxy_node/frpc/frpc -c ~/proxy_node/frpc/frpc.ini > ~/proxy_node/frpc/frpc.log 2>&1 &
EOF

chmod +x ~/.termux/boot/autostart.sh

# Etapa 7: Feedback
echo ""
echo "[✓] Tudo pronto!"
echo "[→] NOME DO TÚNEL: $RANDOM_NAME"
echo "[→] PORTA REMOTA: $RANDOM_PORT"
echo "[→] Logs: ~/3proxy.log e ~/proxy_node/frpc/frpc.log"
echo ""
echo "[!] ATENÇÃO: Instale o app Termux:Boot (F-Droid)"
echo "[→] https://f-droid.org/packages/com.termux.boot"
echo "[!] Depois disso, REINICIE o celular!"
echo "[✓] O 3proxy e o frpc vão iniciar sozinhos no boot"
