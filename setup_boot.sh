#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Configurando boot automático de 3proxy + frpc"

# Instalar dependências
pkg update -y && pkg install termux-api wget -y

# Criar scripts
mkdir -p ~/.termux/boot

# Script principal que inicia os dois
cat > ~/start_all.sh <<EOF
#!/data/data/com.termux/files/usr/bin/bash
sleep 2
echo "\$(date) >> iniciando 3proxy" >> ~/boot_debug.log
nohup env LD_LIBRARY_PATH=\$PREFIX/lib \$PREFIX/bin/3proxy \$PREFIX/etc/3proxy/3proxy.cfg > ~/3proxy.log 2>&1 &
sleep 2
echo "\$(date) >> iniciando frpc" >> ~/boot_debug.log
nohup ~/proxy_node/frpc/frpc -c ~/proxy_node/frpc/frpc.ini > ~/proxy_node/frpc/frpc.log 2>&1 &
EOF
chmod +x ~/start_all.sh

# Script de boot chamando o start_all
cat > ~/.termux/boot/autostart.sh <<EOF
#!/data/data/com.termux/files/usr/bin/bash
sleep 10
~/start_all.sh
EOF
chmod +x ~/.termux/boot/autostart.sh

echo "[✓] Tudo pronto!"
echo "[→] Instale o app Termux:Boot (https://f-droid.org/packages/com.termux.boot)"
echo "[→] Reinicie o celular e tudo subirá sozinho!"
