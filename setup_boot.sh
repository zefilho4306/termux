#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Configurando Termux Boot para frpc e 3proxy..."

# Instalar dependências
pkg update -y && pkg install termux-api -y

# Criar diretório de boot
mkdir -p ~/.termux/boot

# Criar autostart.sh direto
cat > ~/.termux/boot/autostart.sh <<EOF
#!/data/data/com.termux/files/usr/bin/bash
sleep 5
nohup env LD_LIBRARY_PATH=\$PREFIX/lib \$PREFIX/bin/3proxy \$PREFIX/etc/3proxy/3proxy.cfg > ~/3proxy.log 2>&1 &
nohup ~/proxy_node/frpc/frpc -c ~/proxy_node/frpc/frpc.ini > ~/proxy_node/frpc/frpc.log 2>&1 &
EOF

# Dar permissão
chmod +x ~/.termux/boot/autostart.sh

echo ""
echo "[✓] Termux Boot configurado com sucesso!"
echo "[→] Reinicie o celular ou abra o app Termux:Boot para iniciar automaticamente."
