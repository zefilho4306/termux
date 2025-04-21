#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Configurando boot automático de 3proxy + frpc..."

# Instalar dependências mínimas
pkg update -y && pkg install -y termux-api

# Criar diretório de boot
mkdir -p ~/.termux/boot

# Criar autostart com wake-lock
cat > ~/.termux/boot/autostart.sh <<EOF
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
sleep 3
nohup env LD_LIBRARY_PATH=\$PREFIX/lib \$PREFIX/bin/3proxy \$PREFIX/etc/3proxy/3proxy.cfg > ~/3proxy.log 2>&1 &
nohup ~/proxy_node/frpc/frpc -c ~/proxy_node/frpc/frpc.ini > ~/proxy_node/frpc/frpc.log 2>&1 &
EOF

# Permissão de execução
chmod +x ~/.termux/boot/autostart.sh

echo ""
echo "[✓] Script de boot criado com sucesso!"
echo "[→] Arquivo: ~/.termux/boot/autostart.sh"
echo "[!] Agora instale o app Termux:Boot (F-Droid):"
echo "    https://f-droid.org/packages/com.termux.boot"
echo "[!] Após isso, reinicie o celular."
echo "[✓] O 3proxy e o frpc vão subir automaticamente!"
